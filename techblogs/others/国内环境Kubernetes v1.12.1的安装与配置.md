# 一、些重要概念
**cluster**：计算、存储、网络资源的总和。Kubernetes的各种基于容器的应用都是运行在这些资源上的。

**Master**：Kubernetes的大脑，负责调度各种计算资源。Master可以是物理机或虚拟机，多个Master可以同时运行，并实现HA。Master节点上运行的组件可以参见本文架构图。

**Node**：负责运行容器的应用，由Master管理，可以是物理机或虚拟机。

**Pod**：Kubernetes的最小工作单元，也就是说Kubernetes管理的是Pod而不是容器。每个Pod包括一个或多个容器。Pod中的容器会被作为一个整体被Master调度到另一个Node上。

**Controller**：Kubernetes通常不会直接创建Pod，而是通过Controller来管理Pod的。Controller中定义了容器中的一些部署特性。

**Service**：外界访问一组特定的Pod方式，有自己的IP和端口，Service为Pod提供了负载均衡。

**Namespace**：Namespace可以将一个物理的Cluster逻辑上划分为多个虚拟Cluster，每个Cluster就是一个Namespace，不同的Namespace里的资源完全是隔离的。创建资源时，如果不指定，将会被放到default这个默认的Namespace中。

# 二、实战环境
1. 各节点操作系统版本。
```
[root@k8s-m ~]# cat /etc/centos-release
CentOS Linux release 7.5.1804 (Core)
[root@k8s-m ~]# hostnamectl
   Static hostname: k8s-m
         Icon name: computer-vm
           Chassis: vm
        Machine ID: a9fff7a4819c41e1944be91c46dc15aa
           Boot ID: 03b55afaf51647c498d5b1df7ec7d331
    Virtualization: microsoft
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-862.el7.x86_64
      Architecture: x86-64
```
所有主机版本相同，均为最小化安装版。
2. Docker版本。
```
[root@k8s-m ~]# docker -v
Docker version 18.06.0-ce, build 0ffa825
```
3. Kubernetes版本。
```
[root@k8s-m ~]# kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"12", GitVersion:"v1.12.1", GitCommit:"4ed3216f3ec431b140b1d899130a69fc671678f4", GitTreeState:"clean", BuildDate:"2018-10-05T16:43:08Z", GoVersion:"go1.10.4", Compiler:"gc", Platform:"linux/amd64"}
```
4. 各主机的主机名及ip配置。
本次实战中一共用到三台主机，一台用于Master的部署，领导两台分别为node1和node2。主机名和IP的对应关系如下：
```
k8s-m 172.31.3.11
k8s-n1 172.31.3.12
k8s-n2 172.31.3.13
```
# 三、架构图
![架构图](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/KubernetesDeployment.png)
# 四、操作步骤
## 4.1每台主机都必须执行的操作
1. 关闭并禁用防火墙。
```
[root@k8s-m ~]# systemctl stop firewalld
[root@k8s-m ~]# systemctl disable firewalld
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
```
2. 关闭SeLinux。
```
[root@k8s-m ~]# sed -i 's/enforcing/disabled/' /etc/selinux/config
```
3. 禁用swap。
```
# swapoff -a
[root@k8s-m ~]# free -h
              total        used        free      shared  buff/cache   available
Mem:           1.7G        115M        1.4G        8.9M        219M        1.4G
Swap:            0B          
```
如果要永久禁止swap挂载，可以修改/etc/fstab，将与swap有关的配置注释，重启系统即可。
```
[root@k8s-m ~]# reboot
[root@k8s-m ~]# getenforce
Disabled
```
4. 修改/etc/hosts文件。
```
[root@k8s-m ~]# echo "172.31.3.11 k8s-m
172.31.3.12 k8s-n1
172.31.3.13 k8s-n2">>/etc/hosts
```
5. 配置Docker的yum安装源，并安装docker-ce-18.06.0。
```
[root@k8s-m ~]# echo '[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/centos/7/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg'>/etc/yum.repos.d/docker-ce.repo
[root@k8s-m ~]# yum list docker-ce --showduplicates|grep "^doc"|sort -r
docker-ce.x86_64            18.06.1.ce-3.el7                    docker-ce-stable
docker-ce.x86_64            18.06.0.ce-3.el7                    docker-ce-stable
...
```
yum安装指定的Docker版本，安装完成后启动docker，并设置开机自动启动。
```
[root@k8s-m ~]# yum -y install docker-ce-18.06.0.ce-3.el7
[root@k8s-m ~]# systemctl start docker
[root@k8s-m ~]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
```
6. 开启ipv4的转发在CentOS7.5版本上依然是必须的。如果使用到ipv6可能还需要启用ipv6的转发，操作类似。之前文章有介绍过。
```
[root@k8s-m ~]# echo "net.ipv4.ip_forward = 1">>/etc/sysctl.conf
[root@k8s-m ~]# sysctl -p
```
7. 启用bridge-nf-call-iptables和bridge-nf-call-ip6tables。

docker info 命令看一下，出现以下警告，按照如下操作流程进行解决：

**WARNING: bridge-nf-call-iptables is disabled**

**WARNING: bridge-nf-call-ip6tables is disabled**

```
[root@k8s-m ~]# echo 'net.bridge.bridge-nf-call-iptables = 1'>>/etc/sysctl.conf
[root@k8s-m ~]# echo 'net.bridge.bridge-nf-call-ip6tables = 1'>>/etc/sysctl.conf
[root@k8s-m ~]# sysctl -p
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
```
8. 配置kubernetes阿里云yum镜像。
```
[root@k8s-m ~]# echo '[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg'>/etc/yum.repos.d/kubernetes.repo
```
9. 在每个节点上安装kubeadm，kubelet，kubectl。
```
[root@k8s-m ~]# yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
已安装:
  kubeadm.x86_64 0:1.12.1-0                  kubectl.x86_64 0:1.12.1-0                  kubelet.x86_64 0:1.12.1-0
作为依赖被安装:
  cri-tools.x86_64 0:1.12.0-0              kubernetes-cni.x86_64 0:0.6.0-0              socat.x86_64 0:1.7.3.2-2.el7
[root@k8s-m ~]# systemctl enable kubelet && systemctl start kubelet
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /etc/systemd/system/kubelet.service.
```
**以上步骤需要在所有机器上同步配置执行。**

## 4.2在master k8s-m上执行
```
[root@k8s-m ~] kubeadm init --kubernetes-version=1.12.1 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=172.31.3.11
```
1. 记录错误：
```
[root@k8s-m ~]# kubeadm init --kubernetes-version=1.12.1 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=172.31.3.11
[init] using Kubernetes version: v1.12.1
[preflight] running pre-flight checks
[preflight/images] Pulling images required for setting up a Kubernetes cluster
[preflight/images] This might take a minute or two, depending on the speed of your internet connection
[preflight/images] You can also perform this action in beforehand using 'kubeadm config images pull'
[preflight] Some fatal errors occurred:
        [ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-apiserver:v1.12.1: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
        [ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-controller-manager:v1.12.1: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
        [ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-scheduler:v1.12.1: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
        [ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-proxy:v1.12.1: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
        [ERROR ImagePull]: failed to pull image k8s.gcr.io/pause:3.1: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
        [ERROR ImagePull]: failed to pull image k8s.gcr.io/etcd:3.2.24: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
        [ERROR ImagePull]: failed to pull image k8s.gcr.io/coredns:1.2.2: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
```
2. 根据报错信息，在国内网站站上找到相关的镜像。
```
[root@k8s-m ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver-amd64:v1.12.1
[root@k8s-m ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager-amd64:v1.12.1
[root@k8s-m ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler-amd64:v1.12.1
[root@k8s-m ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy-amd64:v1.12.1
[root@k8s-m ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd-amd64:3.2.24
[root@k8s-m ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
[root@k8s-m ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.2.2
[root@k8s-m ~]# docker images
REPOSITORY                                                                          TAG                 IMAGE ID            CREATED             SIZE
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy-amd64                v1.12.1             61afff57f010        12 days ago         96.6MB
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver-amd64            v1.12.1             dcb029b5e3ad        12 days ago         194MB
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager-amd64   v1.12.1             aa2dd57c7329        12 days ago         164MB
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler-amd64            v1.12.1             d773ad20fd80        12 days ago         58.3MB
registry.cn-hangzhou.aliyuncs.com/google_containers/etcd-amd64                      3.2.24              3cab8e1b9802        3 weeks ago         220MB
registry.cn-hangzhou.aliyuncs.com/google_containers/coredns                         1.2.2               367cdc8433a4        7 weeks ago         39.2MB
registry.cn-hangzhou.aliyuncs.com/google_containers/pause                           3.1                 da86e6ba6ca1        10 months ago       742kB

```
3. 把这些images重新tag一下。
```
[root@k8s-m ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
[root@k8s-m ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.2.2 k8s.gcr.io/coredns:1.2.2
[root@k8s-m ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd-amd64:3.2.24 k8s.gcr.io/etcd:3.2.24
[root@k8s-m ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler-amd64:v1.12.1 k8s.gcr.io/kube-scheduler:v1.12.1
[root@k8s-m ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager-amd64:v1.12.1 k8s.gcr.io/kube-controller-manager:v1.12.1
[root@k8s-m ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver-amd64:v1.12.1 k8s.gcr.io/kube-apiserver:v1.12.1
[root@k8s-m ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy-amd64:v1.12.1 k8s.gcr.io/kube-proxy:v1.12.1
```
4. 编辑以下配置文件/var/lib/kubelet/kubeadm-flags.env，编辑后内容如下（在本次安装过程中，安装完成之后自动创建该文件，无需执行本步骤。在之前版本中这一步或许必不可少，具体情况请具体分析。本步骤主要是核实cgroup-driver=cgroupfs）：
```
[root@k8s-m ~]# echo 'KUBELET_KUBEADM_ARGS=--cgroup-driver=cgroupfs  --cni-bin-dir=/opt/cni/bin --cni-conf-dir=/etc/cni/net.d --network-plugin=cni'>/var/lib/kubelet/kubeadm-flags.env
[root@k8s-m ~]# cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS=--cgroup-driver=cgroupfs --cni-bin-dir=/opt/cni/bin --cni-conf-dir=/etc/cni/net.d --network-plugin=cni
```
5. 再次初始化Master。

知道配置之后，我又重新部署了一台机器，以下是操作记录。如果我们在部署过程中出现错误，我们可以使用kubeadm reset命令来重置。
```
[root@k8s-m ~]# kubeadm init --kubernetes-version=1.12.1 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=172.31.3.11
[init] using Kubernetes version: v1.12.1
[preflight] running pre-flight checks
[preflight/images] Pulling images required for setting up a Kubernetes cluster
[preflight/images] This might take a minute or two, depending on the speed of your internet connection
[preflight/images] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[preflight] Activating the kubelet service
[certificates] Generated etcd/ca certificate and key.
[certificates] Generated etcd/server certificate and key.
[certificates] etcd/server serving cert is signed for DNS names [k8s-m localhost] and IPs [127.0.0.1 ::1]
[certificates] Generated etcd/peer certificate and key.
[certificates] etcd/peer serving cert is signed for DNS names [k8s-m localhost] and IPs [172.31.3.11 127.0.0.1 ::1]
[certificates] Generated etcd/healthcheck-client certificate and key.
[certificates] Generated apiserver-etcd-client certificate and key.
[certificates] Generated ca certificate and key.
[certificates] Generated apiserver certificate and key.
[certificates] apiserver serving cert is signed for DNS names [k8s-m kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.31.3.11]
[certificates] Generated apiserver-kubelet-client certificate and key.
[certificates] Generated front-proxy-ca certificate and key.
[certificates] Generated front-proxy-client certificate and key.
[certificates] valid certificates and keys now exist in "/etc/kubernetes/pki"
[certificates] Generated sa key and public key.
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/controller-manager.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/scheduler.conf"
[controlplane] wrote Static Pod manifest for component kube-apiserver to "/etc/kubernetes/manifests/kube-apiserver.yaml"
[controlplane] wrote Static Pod manifest for component kube-controller-manager to "/etc/kubernetes/manifests/kube-controller-manager.yaml"
[controlplane] wrote Static Pod manifest for component kube-scheduler to "/etc/kubernetes/manifests/kube-scheduler.yaml"
[etcd] Wrote Static Pod manifest for a local etcd instance to "/etc/kubernetes/manifests/etcd.yaml"
[init] waiting for the kubelet to boot up the control plane as Static Pods from directory "/etc/kubernetes/manifests"
[init] this might take a minute or longer if the control plane images have to be pulled
[apiclient] All control plane components are healthy after 27.015529 seconds
[uploadconfig] storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.12" in namespace kube-system with the configuration for the kubelets in the cluster
[markmaster] Marking the node k8s-m as master by adding the label "node-role.kubernetes.io/master=''"
[markmaster] Marking the node k8s-m as master by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "k8s-m" as an annotation
[bootstraptoken] using token: jlidhg.sczmdc5wnvgi5pir
[bootstraptoken] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 172.31.3.11:6443 --token jlidhg.sczmdc5wnvgi5pir --discovery-token-ca-cert-hash sha256:74f5e3a3b1163fdafe9a634ff5ca81ea314a6895af18e03a5b482635b4ca93e0

[root@k8s-m ~]# cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS=--cgroup-driver=cgroupfs --network-plugin=cni
[root@k8s-m ~]#  mkdir -p $HOME/.kube
[root@k8s-m ~]# cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@k8s-m ~]# chown $(id -u):$(id -g) $HOME/.kube/config
```
初始化Master节点之后，查看各节点的时间是否一致，如果不一致则需要再次同步个节点的时间。时间同步可以看之前NTP相关的文章。保存安装日志的以下部分以备接下来在各node执行：
```
kubeadm join 172.31.3.11:6443 --token jlidhg.sczmdc5wnvgi5pir --discovery-token-ca-cert-hash sha256:74f5e3a3b1163fdafe9a634ff5ca81ea314a6895af18e03a5b482635b4ca93e0
```

6. 安装flanel。
```
[root@k8s-m ~]# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds-amd64 created
daemonset.extensions/kube-flannel-ds-arm64 created
daemonset.extensions/kube-flannel-ds-arm created
daemonset.extensions/kube-flannel-ds-ppc64le created
daemonset.extensions/kube-flannel-ds-s390x created
```
## 4.3在node k8s-n1和k8s-n2分别执行以下命令（可以从升级日志直接复制）。
```
[root@k8s-n1 ~]# kubeadm join 172.31.3.11:6443 --token jlidhg.sczmdc5wnvgi5pir --discovery-token-ca-cert-hash sha256:74f5e3a3b1163fdafe9a634ff5ca81ea314a6895af18e03a5b482635b4ca93e0
[preflight] running pre-flight checks
        [WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{}]
you can solve this problem with following methods:
1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support

[discovery] Trying to connect to API Server "172.31.3.11:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://172.31.3.11:6443"
[discovery] Requesting info from "https://172.31.3.11:6443" again to validate TLS against the pinned public key
[discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "172.31.3.11:6443"
[discovery] Successfully established connection with API Server "172.31.3.11:6443"
[kubelet] Downloading configuration for the kubelet from the "kubelet-config-1.12" ConfigMap in the kube-system namespace
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[preflight] Activating the kubelet service
[tlsbootstrap] Waiting for the kubelet to perform the TLS Bootstrap...
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "k8s-n1" as an annotation

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```
```
[root@k8s-n2 ~]# kubeadm join 172.31.3.11:6443 --token jlidhg.sczmdc5wnvgi5pir --discovery-token-ca-cert-hash sha256:74f5e3a3b1163fdafe9a634ff5ca81ea314a6895af18e03a5b482635b4ca93e0
[preflight] running pre-flight checks
        [WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs_wrr ip_vs_sh ip_vs ip_vs_rr] or no builtin kernel ipvs support: map[ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{}]
you can solve this problem with following methods:
1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support

[discovery] Trying to connect to API Server "172.31.3.11:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://172.31.3.11:6443"
[discovery] Requesting info from "https://172.31.3.11:6443" again to validate TLS against the pinned public key
[discovery] Cluster info signature and contents are valid and TLS certificate validates against pinned roots, will use API Server "172.31.3.11:6443"
[discovery] Successfully established connection with API Server "172.31.3.11:6443"
[kubelet] Downloading configuration for the kubelet from the "kubelet-config-1.12" ConfigMap in the kube-system namespace
[kubelet] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[preflight] Activating the kubelet service
[tlsbootstrap] Waiting for the kubelet to perform the TLS Bootstrap...
[patchnode] Uploading the CRI Socket information "/var/run/dockershim.sock" to the Node API object "k8s-n2" as an annotation

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```
查看以下各node的状态。
```
[root@k8s-m ~]# kubectl get nodes
NAME     STATUS     ROLES    AGE   VERSION
k8s-m    Ready      master   67m   v1.12.1
k8s-n1   NotReady   <none>   30m   v1.12.1
k8s-n2   NotReady   <none>   21m   v1.12.1
```
再查看一下各pod的情况。
```
[root@k8s-m ~]# kubectl get pod --all-namespaces
NAMESPACE     NAME                            READY   STATUS              RESTARTS   AGE
kube-system   coredns-576cbf47c7-h9fst        1/1     Running             0          23m
kube-system   coredns-576cbf47c7-wnzz5        1/1     Running             0          23m
kube-system   etcd-k8s-m                      1/1     Running             0          68m
kube-system   kube-apiserver-k8s-m            1/1     Running             0          69m
kube-system   kube-controller-manager-k8s-m   1/1     Running             0          68m
kube-system   kube-flannel-ds-amd64-2d4qc     1/1     Running             0          49m
kube-system   kube-flannel-ds-amd64-2fc6q     0/1     Init:0/1            0          32m
kube-system   kube-flannel-ds-amd64-7725c     0/1     Init:0/1            0          23m
kube-system   kube-proxy-jw7dw                1/1     Running             0          69m
kube-system   kube-proxy-qtgl8                0/1     ContainerCreating   0          32m
kube-system   kube-proxy-r4gx9                0/1     ContainerCreating   0          23m
kube-system   kube-scheduler-k8s-m            1/1     Running             0          69m
```
# 五、清除警告和错误
1.在k8s-n1和k8s-n2上执行把该节点注册到集群时，出现以下警告。
```
[WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{}]
you can solve this problem with following methods:
1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support
```
在最小化安装的CentOS7.5系统中没有包含改内核模块。对一般的实验和简单的使用没有影响。在后期会有专门的文章对此问题进行解决。

2.执行以下命令kubectl get pod --all-namespaces后，我们看到有的pod的状态并不是running，使用命令kubectl describe pod查看详情后，在屏幕末端显示警告和错误如下：
```
[root@k8s-m ~]# kubectl describe pod kube-flannel-ds-amd64-2fc6q --namespace=kube-system
Events:
  Type     Reason                  Age                   From               Message
  ----     ------                  ----                  ----               -------
  Normal   Scheduled               33m                   default-scheduler  Successfully assigned kube-system/kube-flannel-ds-amd64-2fc6q to k8s-n1
  Warning  FailedCreatePodSandBox  3m34s (x61 over 33m)  kubelet, k8s-n1    Failed create pod sandbox: rpc error: code = Unknown desc = failed pulling image "k8s.gcr.io/pause:3.1": Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
```
按照错误提示，我们推断产生这样的报错是因为有的镜像未被pull，本文环境不具备科学上网条件，无法从Google直接pull镜像，所以我们必须按照错误提示去pull相关镜像，并重新tag。分析得知，除Master之外，每个node还缺一些镜像，按照如下方法操作即可解决问题。
```
[root@k8s-n1 ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
[root@k8s-n1 ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
[root@k8s-n1 ~]# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy-amd64:v1.12.1
[root@k8s-n1 ~]# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy-amd64:v1.12.1 k8s.gcr.io/kube-proxy:v1.12.1
[root@k8s-n1 ~]# docker pull registry.cn-hangzhou.aliyuncs.com/kubernetes_containers/flannel:v0.10.0-amd64
[root@k8s-n1 ~]# docker tag registry.cn-hangzhou.aliyuncs.com/kubernetes_containers/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
```
现在，我们再看一下：
```
[root@k8s-m ~]# kubectl get pods --all-namespaces
NAMESPACE     NAME                            READY   STATUS    RESTARTS   AGE
kube-system   coredns-576cbf47c7-h9fst        1/1     Running   0          105m
kube-system   coredns-576cbf47c7-wnzz5        1/1     Running   0          105m
kube-system   etcd-k8s-m                      1/1     Running   0          151m
kube-system   kube-apiserver-k8s-m            1/1     Running   0          152m
kube-system   kube-controller-manager-k8s-m   1/1     Running   0          151m
kube-system   kube-flannel-ds-amd64-2d4qc     1/1     Running   0          132m
kube-system   kube-flannel-ds-amd64-2fc6q     1/1     Running   0          115m
kube-system   kube-flannel-ds-amd64-7725c     1/1     Running   0          106m
kube-system   kube-proxy-jw7dw                1/1     Running   0          152m
kube-system   kube-proxy-qtgl8                1/1     Running   0          115m
kube-system   kube-proxy-r4gx9                1/1     Running   0          106m
kube-system   kube-scheduler-k8s-m            1/1     Running   0          151m
[root@k8s-m ~]# kubectl get nodes
NAME     STATUS   ROLES    AGE    VERSION
k8s-m    Ready    master   153m   v1.12.1
k8s-n1   Ready    <none>   116m   v1.12.1
k8s-n2   Ready    <none>   107m   v1.12.1
[root@k8s-m ~]# kubectl get cs
NAME                 STATUS    MESSAGE              ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health": "true"}
```
# 六、总结
1. 本文中介绍的kubernetes部署方式不建议使用到生产环境，可以用于实验环境和测试环境。
2. kubernetes的部署过程中，网络的访问是一个问题，如果解决了这个问题，kubernetes的部署会显得格外简单。
3. 当试错成本可控时，在上生产环境之前请尽情地去试错，并记录、分析各种错误产生的原因。
4. 养成记录安装日志的习惯，不要随便忽略每一个警告和错误。