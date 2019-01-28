# KubernetesInstall

## 一 背景

## 二 环境

## 三 操作步骤

### 3.1 针对性初始化设置

在所有主机上执行脚本KubernetesInstall-01.sh，以Master节点为例。

```bash
[root@gysl-master ~]# sh KubernetesInstall-01.sh
```

脚本内容如下：

```bash
#!/bin/bash
# Initialize the machine. This needs to be executed on every machine.
# Add host domain name.
cat>>/etc/hosts<<EOF
172.31.2.11 gysl-master
172.31.2.12 gysl-node1
172.31.2.13 gysl-node2
EOF
# Modify related kernel parameters.
cat>/etc/sysctl.d/kubernetes.conf<<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl -p /etc/sysctl.d/kubernetes.conf>&/dev/null
# Turn off and disable the firewalld.
systemctl stop firewalld
systemctl disable firewalld
# Disable the SELinux.
sed -i.bak 's/=enforcing/=disabled/' /etc/selinux/config
# Disable the swap .
sed -i.bak 's/^.*swap/#&/g' /etc/fstab
# Reboot the machine.
reboot
```

### 3.2 安装Docker Engine并设置

在所有主机上执行脚本KubernetesInstall-02.sh，以Master节点为例。

```bash
[root@gysl-master ~]# sh KubernetesInstall-02.sh
```

脚本内容如下：

```bash
#!/bin/bash
# Install the Docker engine. This needs to be executed on every machine.
curl http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo>&/dev/null
if [ $? -eq 0 ] ;
    then 
        yum remove docker \
                      docker-client \
                      docker-client-latest \
                      docker-common \
                      docker-latest \
                      docker-latest-logrotate \
                      docker-logrotate \
                      docker-selinux \
                      docker-engine-selinux \
                      docker-engine>&/dev/null
        yum list docker-ce --showduplicates|grep "^doc"|sort -r
        yum -y install docker-ce-18.06.0.ce-3.el7
        rm -f /etc/yum.repos.d/docker-ce.repo
        systemctl enable docker && systemctl start docker && systemctl status docker
    else
        echo "Install failed! Please try again! ";
        exit 110
fi
```

**注意：**以上步骤需要在每一个节点上执行。如果启用了swap，那么是需要禁用的（脚本KubernetesInstall-01.sh已有涉及），具体可以通过 free 命令查看详情。另外，还需要关注各个节点上的时间同步情况。

### 3.3 下载相关二进制包

在Master执行脚本KubernetesInstall-03.sh。

```bash
[root@gysl-master ~]# sh KubernetesInstall-03.sh
```

脚本内容如下：

```bash
#!/bin/bash
# Download relevant softwares. Please verify sha512 yourself.
while true;
    do
        echo "Downloading, please wait a moment." &&\
        curl -L -C - -O https://dl.k8s.io/v1.13.2/kubernetes-server-linux-amd64.tar.gz && \
        curl -L -C - -O https://github.com/etcd-io/etcd/releases/download/v3.2.26/etcd-v3.2.26-linux-amd64.tar.gz && \
        curl -L -C - -O https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 && \
        curl -L -C - -O https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 && \
        curl -L -C - -O https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 \
        curl -L -C - -O https://github.com/coreos/flannel/releases/download/v0.10.0/flannel-v0.10.0-linux-amd64.tar.gz
        if [ $? -eq 0 ];
            then
                echo "Congratulations! All software packages have been downloaded."
                break
        fi
    done
```

kubernetes-server-linux-amd64.tar.gz包括了kubernetes的主要组件，无需下载其他包。etcd-v3.2.26-linux-amd64.tar.gz是部署etcd需要用到的包。其余的是cfssl相关的软件，暂不深究。网络原因，只能这么做了，这个过程可能需要一会儿。

### 3.4 部署etcd集群

#### 3.4.1 创建CA证书

在Master执行脚本KubernetesInstall-04.sh。

```bash
[root@gysl-master ~]# sh KubernetesInstall-04.sh
2019/01/28 16:29:47 [INFO] generating a new CA key and certificate from CSR
2019/01/28 16:29:47 [INFO] generate received request
2019/01/28 16:29:47 [INFO] received CSR
2019/01/28 16:29:47 [INFO] generating key: rsa-2048
2019/01/28 16:29:47 [INFO] encoded CSR
2019/01/28 16:29:47 [INFO] signed certificate with serial number 368034386524991671795323408390048460617296625670
2019/01/28 16:29:47 [INFO] generate received request
2019/01/28 16:29:47 [INFO] received CSR
2019/01/28 16:29:47 [INFO] generating key: rsa-2048
2019/01/28 16:29:48 [INFO] encoded CSR
2019/01/28 16:29:48 [INFO] signed certificate with serial number 714486490152688826461700674622674548864494534798
2019/01/28 16:29:48 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
/etc/etcd/ssl/ca-key.pem  /etc/etcd/ssl/ca.pem  /etc/etcd/ssl/server-key.pem  /etc/etcd/ssl/server.pem
```

脚本内容如下：

```bash
#!/bin/bash
mv cfssl* /usr/local/bin/
chmod +x /usr/local/bin/cfssl*
ETCD_SSL=/etc/etcd/ssl
mkdir -p $ETCD_SSL
# Create some CA certificates for etcd cluster.
cat<<EOF>$ETCD_SSL/ca-config.json
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "www": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF
cat<<EOF>$ETCD_SSL/ca-csr.json
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF
cat<<EOF>$ETCD_SSL/server-csr.json
{
    "CN": "etcd",
    "hosts": [
    "172.31.2.11",
    "172.31.2.12",
    "172.31.2.13"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF
cd $ETCD_SSL
cfssl_linux-amd64 gencert -initca ca-csr.json | cfssljson_linux-amd64 -bare ca -
cfssl_linux-amd64 gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson_linux-amd64 -bare server
cd ~
# ca-key.pem  ca.pem  server-key.pem  server.pem
ls $ETCD_SSL/*.pem
```

#### 3.4.2 配置etcd服务

### 3.5 部署Master节点

#### 3.5.1 创建CA证书

```bash
[root@gysl-m ~]# mkdir -p /etc/kubernetes/ssl
[root@gysl-m ~]# cd /etc/kubernetes/ssl/
[root@gysl-m ssl]# openssl genrsa -out ca.key 2048
Generating RSA private key, 2048 bit long modulus
..................+++
................+++
e is 65537 (0x10001)
[root@gysl-m ssl]# openssl req -x509 -new -nodes -key ca.key -subj "/CN=k8s-master" -days 5000 -out ca.pem
[root@gysl-m ssl]# echo \
'[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = k8s_master
IP.1 = 10.1.1.8
IP.2 = 172.31.3.11'>../openssl.conf
[root@gysl-m ssl]# openssl genrsa -out server.key 2048
Generating RSA private key, 2048 bit long modulus
...........+++
..........................................................+++
e is 65537 (0x10001)
[root@gysl-m ssl]# openssl req -new -key server.key -subj "/CN=gysl-m" -config ../openssl.conf -out server.csr
[root@gysl-m ssl]# openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial -days 5000 -extensions v3_req -extfile ../openssl.conf -out server.crt
Signature ok
subject=/CN=gysl-m
Getting CA Private Key
[root@gysl-m ssl]# openssl genrsa -out client.key 2048
Generating RSA private key, 2048 bit long modulus
...............................+++
...............................................................+++
e is 65537 (0x10001)
[root@gysl-m ssl]# openssl req -new -key client.key -subj "/CN=gysl-m" -out client.csr
[root@gysl-m ssl]# openssl x509 -req -in client.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out client.crt -days 5000
Signature ok
subject=/CN=gysl-m
Getting CA Private Key
[root@gysl-m ssl]# ls
ca.key  ca.pem  ca.srl  client.crt  client.csr  client.key  server.crt  server.csr  server.key
```

#### 3.5.2 安装配置etcd服务

```bash
[root@gysl-m ~]# tar -xvzf etcd-v3.2.26-linux-amd64.tar.gz
[root@gysl-m ~]# mv etcd-v3.2.26-linux-amd64/{etcd,etcdctl} /usr/local/bin/
[root@gysl-m ~]# echo \
'[Unit]
Description=Etcd Server
After=network.target
[Service]
Type=simple
EnvironmentFile=-/etc/etcd.conf
WorkingDirectory=/var/lib/etcd
ExecStart=/usr/local/bin/etcd
Restart=on-failure
[Install]
WantedBy=multi-user.target'>/usr/lib/systemd/system/etcd.service
[root@gysl-m ~]# mkdir -p /var/lib/etcd/
[root@gysl-m ~]# touch /etc/etcd.conf
[root@gysl-m ~]# systemctl daemon-reload
[root@gysl-m ~]# systemctl start etcd
[root@gysl-m ~]# systemctl enable etcd
Created symlink from /etc/systemd/system/multi-user.target.wants/etcd.service to /usr/lib/systemd/system/etcd.service.
[root@gysl-m ~]# etcdctl cluster-health
member 8e9e05c52164694d is healthy: got healthy result from http://localhost:2379
cluster is healthy
```

#### 3.5.3 安装配置kube-apiserver服务

```bash
[root@gysl-m ~]# tar -xzf kubernetes-server-linux-amd64.tar.gz
[root@gysl-m ~]# mv kubernetes/server/bin/kube-apiserver /usr/local/bin/
[root@gysl-m ~]# mkdir /etc/kubernetes/
[root@gysl-m ~]# echo \
'KUBE_API_ARGS="--advertise-address=172.31.3.11 \
--storage-backend=etcd3 \
--etcd-servers=http://172.31.3.11:2379 \
--bind-address=172.31.3.11 \
--service-cluster-ip-range=10.1.1.0/24 \
--service-node-port-range=30000-65535 \
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
--logtostderr=false \
--log-dir=/var/log/kubernetes/apiserver \
--v=2 \
--client-ca-file=/etc/kubernetes/ssl/ca.pem \
--tls-private-key-file=/etc/kubernetes/ssl/server.key \
--tls-cert-file=/etc/kubernetes/ssl/server.crt"'>/etc/kubernetes/apiserver.conf
[root@gysl-m ~]# echo \
'[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=etcd.service
Wants=etcd.service

[Service]
Type=simple
WorkingDirectory=/var/lib/kubernetes/kube-apiserver/
EnvironmentFile=/etc/kubernetes/apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver  $KUBE_API_ARGS
Restart=on-failure
LimitNOFIFE=65536

[Install]
WantedBy=multi-user.target'>/usr/lib/systemd/system/kube-apiserver.service
[root@gysl-m ~]# mkdir -p /var/lib/kubernetes/kube-apiserver/
[root@gysl-m ~]# mkdir -p /var/log/kubernetes/apiserver
[root@gysl-m ~]# systemctl daemon-reload
[root@gysl-m ~]# systemctl start kube-apiserver
[root@gysl-m ~]# systemctl enable kube-apiserver
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-apiserver.service to /usr/lib/systemd/system/kube-apiserver.service.
[root@gysl-m ~]# systemctl status kube-apiserver
● kube-apiserver.service - Kubernetes API Server
   Loaded: loaded (/usr/lib/systemd/system/kube-apiserver.service; enabled; vendor preset: disabled)
   Active: active (running)
```

至此，kube-apiser部署成功。一些启动参数如下：

- etcd_servers: 指定etcd服务的URL。
- insecure-bind-address： apiserver绑定主机的非安全端口，设置0.0.0.0表示绑定所有IP地址
- insecure-port: apiserver绑定主机的非安全端口号，默认为8080。
- service-cluster-ip-range: Kubernetes集群中service的虚拟IP地址范围，以CIDR表示，该IP范围不能与物理机的真实IP段有重合。
- service-node-port-range: kubernetes集群中Service可映射的物理机端口号范围，默认为30000–32767。
- admission_control: kubernetes集群的准入控制设置，各控制模块以插件的形式依次生效。
- logtostderr: 设置为false表示将日志写入文件，不写入stderr。
- log-dir: 日志目录。
- v: 日志级别。
  
#### 3.5.4 准备kubeconfig文件

文件内容如下：

```yaml
apiVersion: v1
kind: Config
users:
- name: gysl
  user:
    client-certificate: /etc/kubernetes/ssl/client.crt
    client-key: /etc/kubernetes/ssl/client.key
clusters:
- name: gysl-cluster
  cluster:
    certificate-authority: /etc/kubernetes/ssl/ca.pem
contexts:
- context:
    cluster: gysl-cluster
    user: gysl
  name: gysl-context
current-context: gysl-context
```

```bash
[root@gysl-m ~]# echo \
'apiVersion: v1
kind: Config
users:
- name: gysl
  user:
    client-certificate: /etc/kubernetes/ssl/client.crt
    client-key: /etc/kubernetes/ssl/client.key
clusters:
- name: gysl-cluster
  cluster:
    certificate-authority: /etc/kubernetes/ssl/ca.pem
contexts:
- context:
    cluster: gysl-cluster
    user: gysl
  name: gysl-context
current-context: gysl-context'>/etc/kubernetes/kubeconfig.yaml
```

#### 3.5.5 安装配置kube-controller-manager服务

```bash
[root@gysl-m ~]# mv kubernetes/server/bin/kube-controller-manager /usr/local/bin/
[root@gysl-m ~]# echo \
'KUBE_CONTROLLER_MANAGER_ARGS=" \
--master=https://172.31.3.11:6443 \
--service-account-private-key-file=/etc/kubernetes/ssl/server.key \
--root-ca-file=/etc/kubernetes/ssl/ca.pem \
--kubeconfig=/etc/kubernetes/kubeconfig.yaml \
--logtostderr=false \
--log-dir=/var/log/kubernetes/controller-manager \
--v=2"'>/etc/kubernetes/controller-manager.conf
[root@gysl-m ~]# mkdir -p /var/log/kubernetes/controller-manager
[root@gysl-m ~]# echo \
'[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kube-apiserver.service
Requires=kube-apiserver.service

[Service]
WorkingDirectory=/var/lib/kubernetes/kube-controller-manager/
EnvironmentFile=/etc/kubernetes/controller-manager.conf
ExecStart=/usr/local/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimitNOFIFE=65536

[Install]
WantedBy=multi-user.target'>/usr/lib/systemd/system/kube-controller-manager.service
[root@gysl-m ~]# mkdir -p /var/lib/kubernetes/kube-controller-manager
[root@gysl-m ~]# systemctl daemon-reload
[root@gysl-m ~]# systemctl start kube-controller-manager
[root@gysl-m ~]# systemctl enable kube-controller-manager
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-controller-manager.service to /usr/lib/systemd/system/kube-controller-manager.service.
[root@gysl-m ~]# systemctl status kube-controller-manager
● kube-controller-manager.service - Kubernetes Controller Manager
   Loaded: loaded (/usr/lib/systemd/system/kube-controller-manager.service; enabled; vendor preset: disabled)
   Active: active (running) 
```

kube-controller-manager服务安装配置成功！

#### 3.5.6 安装配置kube-scheduler服务

```bash
[root@gysl-m ~]# echo \
'KUBE_SCHEDULER_ARGS="\
--master=https://172.31.3.11:6443 \
--kubeconfig=/etc/kubernetes/kubeconfig.yaml \
--logtostderr=false \
--log-dir=/var/log/kubernetes/scheduler \
--v=2"'>/etc/kubernetes/scheduler.conf
[root@gysl-m ~]# mkdir /var/log/kubernetes/scheduler
[root@gysl-m ~]# echo \
'[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=kube-apiserver.service
Wants=kube-apiserver.service

[Service]
WorkingDirectory=/var/lib/kubernetes/kube-scheduler/
EnvironmentFile=/etc/kubernetes/scheduler.conf
ExecStart=/usr/local/bin/kube-scheduler $KUBE_SCHEDULER_ARGS
LimitNOFIFE=65536
Restart=on-failure

[Install]
WantedBy=multi-user.target'>/usr/lib/systemd/system/kube-scheduler.service
[root@gysl-m ~]# mkdir -p /var/lib/kubernetes/kube-scheduler/
[root@gysl-m ~]# systemctl daemon-reload
[root@gysl-m ~]# systemctl start kube-scheduler
[root@gysl-m ~]# systemctl enable kube-scheduler
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-scheduler.service to /usr/lib/systemd/system/kube-scheduler.service.
[root@gysl-m ~]# systemctl status kube-scheduler
● kube-scheduler.service - Kubernetes Scheduler
   Loaded: loaded (/usr/lib/systemd/system/kube-scheduler.service; enabled; vendor preset: disabled)
   Active: active (running) 
```

kube-scheduler服务安装配置成功。

### 3.6 部署Node节点

#### 3.6.1 准备CA证书

```bash
[root@gysl-n1 ~]# mkdir -p /etc/kubernetes/ssl && cd /etc/kubernetes/ssl
[root@gysl-n1 ssl]# scp root@gysl-m:/etc/kubernetes/ssl/ca.{pem,key} .
root@gysl-m's password:
ca.pem                                                                                                                                       100% 1099   193.6KB/s   00:00
root@gysl-m's password:
ca.key                                                                                                                                       100% 1679   339.1KB/s   00:00
[root@gysl-n1 ssl]# ls
ca.key  ca.pem
[root@gysl-n1 ssl]# openssl genrsa -out client.key 2048
Generating RSA private key, 2048 bit long modulus
........................................................................+++
...................................................................................+++
e is 65537 (0x10001)
[root@gysl-n1 ssl]# openssl req -new -key client.key -subj "/CN=172.31.3.12" -out client.csr
[root@gysl-n1 ssl]# openssl x509 -req -in client.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out client.crt -days 5000
Signature ok
subject=/CN=172.31.3.12
Getting CA Private Key
```

#### 3.6.2 准备kubeconfig文件

文件内容如下：

```yaml
apiVersion: v1
kind: Config
users:
- name: gysl
  user:
    client-certificate: /etc/kubernetes/ssl/client.crt
    client-key: /etc/kubernetes/ssl/client.key
clusters:
- name: gysl-cluster
  cluster:
    certificate-authority: /etc/kubernetes/ssl/ca.crt
    server: https://172.31.3.11:6443
contexts:
- context:
    cluster: gysl-cluster
    user: gysl
  name: gysl-context
current-context: gysl-context
```

```bash
[root@gysl-n1 ssl]# echo \
'apiVersion: v1
kind: Config
users:
- name: gysl
  user:
    client-certificate: /etc/kubernetes/ssl/client.crt
    client-key: /etc/kubernetes/ssl/client.key
clusters:
- name: gysl-cluster
  cluster:
    certificate-authority: /etc/kubernetes/ssl/ca.crt
    server: https://172.31.3.11:6443
contexts:
- context:
    cluster: gysl-cluster
    user: gysl
  name: gysl-context
current-context: gysl-context'>/etc/kubernetes/kubeconfig.yaml
```

#### 3.6.3 安装配置kube-kubelet服务

```bash
[root@gysl-n1 ~]# scp root@172.31.3.11:~/kubernetes/server/bin/kubelet /usr/local/bin/
kubelet                                                                                                                                      100%  108MB  73.4MB/s   00:01
[root@gysl-n1 ~]# echo \
'KUBELET_ARGS=" \
--hostname-override=172.31.3.12 \
--logtostderr=false \
--log-dir=/var/log/kubernetes/kubelet \
--v=2 \
--kubeconfig=/etc/kubernetes/kubeconfig.yaml \
--cgroup-driver=systemd \
--pod-infra-container-image=172.31.3.11:443/k8s/pause-amd64:3.0"'>/etc/kubernetes/kubelet.conf
[root@gysl-n1 ~]# mkdir -p /var/log/kubernetes/kubelet
[root@gysl-n1 ~]# echo \
'[Unit]
Description=Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubernetes/kubelet
EnvironmentFile=/etc/kubernetes/kubelet.conf
ExecStart=/usr/local/bin/kubelet $KUBELET_ARGS
Restart=on-failure

[Install]
WantedBy=multi-user.target'>/usr/lib/systemd/system/kube-kubelet.service
[root@gysl-n1 ~]# mkdir -p /var/lib/kubernetes/kubelet
[root@gysl-n1 ~]# systemctl daemon-reload
[root@gysl-n1 ~]# systemctl start kube-kubelet
[root@gysl-n1 ~]# systemctl enable kube-kubelet
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-kubelet.service to /usr/lib/systemd/system/kube-kubelet.service.
[root@gysl-n1 ~]# systemctl status kube-kubelet
● kube-kubelet.service - Kubelet Server
   Loaded: loaded (/usr/lib/systemd/system/kube-kubelet.service; enabled; vendor preset: disabled)
   Active: active (running)
```

kube-kubelet服务安装配置成功！
#### 3.6.4 安装配置kube-proxy服务

```bash
[root@gysl-n1 ~]# scp root@172.31.3.11:~/kubernetes/server/bin/kube-proxy /usr/local/bin/
kube-proxy            100%   33MB  42.4MB/s   00:00
[root@gysl-n1 ~]# echo \
'KUBE_PROXY_ARGS=" \
--logtostderr=false \
--log-dir=/var/log/kubernetes/kube-proxy \
--v=2 \
--kubeconfig=/etc/kubernetes/kubeconfig.yaml"'>/etc/kubernetes/kube-proxy.conf
[root@gysl-n1 ~]# mkdir -p /var/log/kubernetes/kube-proxy
[root@gysl-n1 ~]# echo \
'[Unit]
Description=Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
Requires=network.target

[Service]
WorkingDirectory=/var/lib/kubernetes/kube-proxy
EnvironmentFile=/etc/kubernetes/proxy.conf
ExecStart=/usr/local/bin/kube-proxy $KUBE_PROXY_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target'>/usr/lib/systemd/system/kube-proxy.service
[root@gysl-n1 ~]# mkdir -p /var/lib/kubernetes/kube-proxy
[root@gysl-n1 ~]# systemctl daemon-reload
[root@gysl-n1 ~]# systemctl start kube-proxy
[root@gysl-n1 ~]# systemctl enable kube-proxy
Created symlink from /etc/systemd/system/multi-user.target.wants/kube-proxy.service to /usr/lib/systemd/system/kube-proxy.service.
[root@gysl-n1 ~]# systemctl status kube-proxy

```

### 3.7 导入相关镜像

```bash
[root@gysl-m ~]# docker load -i kubernetes/server/bin/kube-apiserver.tar
37ec61735c38: Loading layer [==================================================>]  138.6MB/138.6MB
Loaded image: k8s.gcr.io/kube-apiserver:v1.13.0
[root@gysl-m ~]# docker load -i kubernetes/server/bin/kube-controller-manager.tar
474fef97be8a: Loading layer [==================================================>]  103.9MB/103.9MB
Loaded image: k8s.gcr.io/kube-controller-manager:v1.13.0
[root@gysl-m ~]# docker load -i kubernetes/server/bin/kube-scheduler.tar
5fe6d025ca50: Loading layer [==================================================>]  43.87MB/43.87MB
f6c506417998: Loading layer [==================================================>]  37.27MB/37.27MB
Loaded image: k8s.gcr.io/kube-scheduler:v1.13.0
[root@gysl-m ~]# docker load -i kubernetes/server/bin/kube-proxy.tar
e5a609b37e16: Loading layer [==================================================>]  3.403MB/3.403MB
232e8910ede8: Loading layer [==================================================>]  34.81MB/34.81MB
Loaded image: k8s.gcr.io/kube-proxy:v1.13.0
[root@gysl-m ~]# docker images
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-proxy                v1.13.0             8fa56d18961f        6 weeks ago         80.2MB
k8s.gcr.io/kube-apiserver            v1.13.0             f1ff9b7e3d6e        6 weeks ago         181MB
k8s.gcr.io/kube-controller-manager   v1.13.0             d82530ead066        6 weeks ago         146MB
k8s.gcr.io/kube-scheduler            v1.13.0             9508b7d8008d        6 weeks ago         79.6MB
```

### 3.8 配置kubectl工具

### 3.9

## 参考资料

[认证相关](https://k8smeetup.github.io/docs/admin/kubelet-authentication-authorization/)

[证书相关](https://kubernetes.io/zh/docs/concepts/cluster-administration/certificates/)

[cfssl官方资料](https://blog.cloudflare.com/introducing-cfssl/)