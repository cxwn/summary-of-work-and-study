# 一 背景
# 二 环境
# 三 准备工作
## 3.1 执行脚本
```bash
[root@gysl-m ~]# sh k8s-init.sh
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: inactive (dead) since 一 2019-01-14 18:58:32 CST; 
...
net.ipv4.ip_forward = 1
Enforcing
```
k8s-init.sh脚本内容如下：
```bash
#/bin/bash
systemctl stop firewalld
systemctl enable firewalld
systemctl status firewalld
echo 'net.ipv4.ip_forward=1'>>/etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-iptables = 1'>>/etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1'>>/etc/sysctl.conf
sysctl -p
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
reboot
```
## 3.2 安装Docker并设置
```bash
[root@gysl-m ~]# curl -C - -O http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
[root@gysl-m ~]# mv docker-ce.repo /etc/yum.repos.d/
[root@gysl-m ~]# yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
[root@gysl-m ~]# yum list docker-ce --showduplicates|grep "^doc"|sort -r
docker-ce.x86_64            18.06.0.ce-3.el7                    docker-ce-stable
...
[root@gysl-m ~]# yum -y install docker-ce-18.06.0.ce-3.el7
[root@gysl-m ~]# systemctl start docker
[root@gysl-m ~]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
```
**注意：**以上步骤需要在每一个节点上执行。如果启用了swap，那么是需要禁用的，具体可以通过 free 命令查看详情。另外，还需要关注各个节点上的时间同步情况。
## 3.3 配置主机域名
```bash
[root@gysl-m ~]# echo '172.31.3.11 gysl-m
172.31.3.12 gysl-n1'>>/etc/hosts
[root@gysl-n1 ~]# echo '172.31.3.11 gysl-m
172.31.3.12 gysl-n1'>>/etc/hosts
```
每个节点都需要进行配置。
## 3.4 下载相关二进制包
### 3.4.1 下载 Kubernetes Server 并校验
```bash
[root@gysl-m ~]# curl -C - -O https://storage.googleapis.com/kubernetes-release/release/v1.13.0/kubernetes-server-linux-amd64.tar.gz
** Resuming transfer from byte position 5073666
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  393M  100  393M    0     0   687k      0  0:09:45  0:09:45 --:--:--  717k
[root@gysl-m ~]# sha512sum kubernetes-server-linux-amd64.tar.gz
a8e3d457e5bcc1c09eeb66111e8dd049d6ba048c3c0fa90a61814291afdcde93f1c6dbb07beef090d1d8a9958402ff843e9af23ae9f069c17c0a7c6ce4034686  kubernetes-server-linux-amd64.tar.gz
```
### 3.4.2 下载etcd
```bash
[root@gysl-m ~]# while true;do curl -L -C - -O  https://github.com/etcd-io/etcd/releases/download/v3.2.26/etcd-v3.2.26-linux-amd64.tar.gz;if [ $? -eq 0 ];then break; fi;done
** Resuming transfer from byte position 2513511
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   621    0   621    0     0     97      0 --:--:--  0:00:06 --:--:--   160
  2 7887k    2  203k    0     0   2389      0  0:56:20  0:01:27  0:54:53     0
```
网络不太好，只能这么做了。
## 3.5 部署Master节点
### 3.5.1 创建CA证书
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
### 3.5.2 安装配置etcd
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
### 3.5.3 安装配置kube-apiserver
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
   Active: active (running) since 五 2019-01-18 16:17:37 CST; 1s ago
```
至此，kube-apiser部署成功。一些启动参数如下：
- etcd_servers: 指定etcd服务的URL
- insecure-bind-address： apiserver绑定主机的非安全端口，设置0.0.0.0表示绑定所有IP地址
- insecure-port: apiserver绑定主机的非安全端口号，默认为8080
- service-cluster-ip-range: Kubernetes集群中service的虚拟IP地址范围，以CIDR表示，该IP范围不能与物理机的真实IP段有重合。
- service-node-port-range: kubernetes集群中Service可映射的物理机端口号范围，默认为30000–32767.
- admission_control: kubernetes集群的准入控制设置，各控制模块以插件的形式依次生效
- logtostderr: 设置为false表示将日志写入文件，不写入stderr
- log-dir: 日志目录
- v: 日志级别


# 参考资料
[认证相关](https://k8smeetup.github.io/docs/admin/kubelet-authentication-authorization/)

[证书相关](https://kubernetes.io/zh/docs/concepts/cluster-administration/certificates/)