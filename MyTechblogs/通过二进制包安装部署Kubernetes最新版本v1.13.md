# 一 背景
# 二 环境
# 三 准备工作
## 3.1 执行脚本
```bash
[root@gysl-k8s-1 ~]# sh k8s-init.sh
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
sysctl -p
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
getenforce
reboot
```
## 3.2 安装Docker并设置
```bash
[root@gysl-k8s-1 ~]# curl -C - -O http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
[root@gysl-k8s-1 ~]# mv docker-ce.repo /etc/yum.repos.d/
[root@gysl-k8s-1 ~]# yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
[root@gysl-k8s-1 ~]# yum list docker-ce --showduplicates|grep "^doc"|sort -r
docker-ce.x86_64            18.06.0.ce-3.el7                    docker-ce-stable
...
[root@gysl-k8s-1 ~]# yum -y install docker-ce-18.06.0.ce-3.el7
[root@gysl-k8s-1 ~]# systemctl start docker
[root@gysl-k8s-1 ~]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
```
**注意：**以上步骤需要在每一个节点上执行。如果启用了swap，那么是需要禁用的，具体可以通过 free 命令查看详情。
## 3.3 下载相关二进制包
### 3.3.1 下载 Kubernetes Server 并校验包
```bash
[root@gysl-k8s-1 ~]# curl -C - -O https://storage.googleapis.com/kubernetes-release/release/v1.13.0/kubernetes-server-linux-amd64.tar.gz
** Resuming transfer from byte position 5073666
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  393M  100  393M    0     0   687k      0  0:09:45  0:09:45 --:--:--  717k
[root@gysl-k8s-1 ~]# sha512sum kubernetes-server-linux-amd64.tar.gz
a8e3d457e5bcc1c09eeb66111e8dd049d6ba048c3c0fa90a61814291afdcde93f1c6dbb07beef090d1d8a9958402ff843e9af23ae9f069c17c0a7c6ce4034686  kubernetes-server-linux-amd64.tar.gz
```
### 3.3.2 下载 Kubernetes Client 并校验包
```bash
[root@gysl-k8s-2 ~]# curl -C - -O https://storage.googleapis.com/kubernetes-release/release/v1.13.0/kubernetes-node-linux-amd64.tar.gz
** Resuming transfer from byte position 3439478
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 83.7M  100 83.7M    0     0   577k      0  0:02:28  0:02:28 --:--:--  569k
[root@gysl-k8s-2 ~]# sha512sum kubernetes-node-linux-amd64.tar.gz
9d18ba5f0c3b09edcf29397a496a1e908f4906087be3792989285630d7bcbaf6cd3bdd7b07dace439823885acc808637190f5eaa240b7b4580acf277b67bb553  kubernetes-node-linux-amd64.tar.gz
```