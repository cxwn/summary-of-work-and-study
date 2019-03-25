# 在以 CentOS7.6 为基础镜像的 Docker 容器中通过 NFS 将内存挂载成高速硬盘使用

## 一 背景

这是最近项目中遇到的一个问题。在已知的部署在 docker 容器云上某个应用中，读写非常频繁，对磁盘的性能要求极高，但是又不能在同一个容器内进行高强度读写。另外，该主机内存资源有冗余，允许使用特权模式运行容器，不要求该部分数据持久性存储。

通过对问题的分析，我采取了以下解决方案：

- 通过把内存挂载成硬盘，可以大幅度提高磁盘的性能；

- 由于不能在同一个容器内进行读写，可以使用 NFS 来解决；  

- 允许使用特权模式，可以在容器内部挂载磁盘；

- 不要求数据持久存储，可以把内存当作告诉磁盘来使用；

- 在同一台主机上，可以不考虑容器的跨主机互联。

在本文中已经对涉及到公司利益部分内容进行处理，例如：文中涉及到的镜像已经移除相关应用，直接以centos7.6.1810为基础镜像。

## 二 环境

### 2.1 宿主机OS

```text
CentOS Linux release 7.6.1810 (Core)
```

### 2.2 硬件信息

```text
内存：256GB
```

### 2.3 宿主机的初始化配置

```bash
#!/bin/bash
UserName='gysl'
PassWord='drh123'
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
        yum -y install docker-ce-18.09.3-3.el7
        rm -f /etc/yum.repos.d/docker-ce.repo
        systemctl enable docker --now && systemctl status docker
    else
        echo "Install failed! Please try again! ";
        exit 110
fi
# Modify related kernel parameters.  
cat>/etc/sysctl.d/docker.conf<<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF  
sysctl -p /etc/sysctl.d/docker.conf>&/dev/null  
# Turn off and disable the firewalld.  
systemctl stop firewalld  
systemctl disable firewalld  
# Disable the SELinux.  
sed -i.bak 's/=enforcing/=disabled/' /etc/selinux/config  
# Disable the swap.  
sed -i.bak 's/^.*swap/#&/g' /etc/fstab
# Install EPEL/vim/git.  
yum -y install epel-release vim git
yum repolist
# Add a docker user.
useradd $UserName
echo $PassWord|passwd $UserName --stdin
usermod $UserName -aG docker  
# Reboot the machine.  
reboot
```

执行以上脚本重启服务器之后，以用户名 gysl 登录系统。

## 三 实施步骤

### 3.1 构建 NFS 服务镜像

#### 3.1.1 准备阶段

Dockefile内容如下：

```Dockerfile
FROM centos:7.6.1810
ENV  SSD='/high-speed-storage' SIZE='10m'
COPY . /
RUN  yum -y install nfs-utils && \
     mkdir $SSD  
CMD  [ "/bin/bash","/start.sh" ]
```

start.sh脚本内容如下：

```bash
#!/bin/bash
echo "$SSD *(fsid=0,rw,no_root_squash,no_subtree_check)">>/etc/exports
mount -t tmpfs -o size=$SIZE tmpfs $SSD
/usr/sbin/exportfs -r
/usr/sbin/rpcbind
/usr/sbin/rpc.nfsd
/usr/sbin/rpc.mountd
/usr/sbin/rpc.rquotad
while true;
    do
        sleep 6000;
    done
```

#### 3.1.2 构建阶段

新建一个目录，将上文中的 Dokcerfile 与 start.sh 放到该目录。

```bash
[gysl@gysl-dev ~]$ mkdir nfs
[gysl@gysl-dev ~]$ cd nfs
[gysl@gysl-dev nfs]$ docker build -t nfs:v1.0 .
```

#### 3.1.3 启动 NFS 服务容器

启动容器内的 NFS 服务，命令如下：

```bash
[gysl@gysl-dev nfs]$ docker run -itd --privileged --rm nfs:v1.0
953dd0cf03e024447ba3a7f1be6dce6217226b25c13ffa2b9967941c96b73f4e
```

#### 3.1.4 记下 NFS 服务容器的IP

```bash
[gysl@gysl-dev nfs]$ docker inspect 953|grep -w 'IPAddress'
            "IPAddress": "172.17.0.2",
                    "IPAddress": "172.17.0.2",
```

### 3.2 修改应用镜像

#### 3.2.1 在应用所在的镜像内添加 NFS 服务

修改 Dockerfile ，内容如下：

```Dockerfile
FROM centos:7.6.1810
ENV  SSD='/high-speed-storage' DATA='/data'
COPY . /
RUN  yum -y install nfs-utils && \
     mkdir $DATA
CMD  [ "/bin/bash","/start-client.sh" ]
```

添加 start-client.sh 脚本，脚本内容如下：

```bash
#!/bin/bash
mount -t nfs 172.17.0.2:$SSD $DATA
while true; do sleep 6000; done
```

#### 3.2.2 重新构建应用镜像

新建一个目录，把修改后的 Dockerfile 和 start-client.sh 放到同一目录，执行命令如下：

```bash
[gysl@gysl-dev ~]$ mkdir nfs-client
[gysl@gysl-dev ~]$ cd nfs-client/
[gysl@gysl-dev nfs-client]$ vi Dockerfile
[gysl@gysl-dev nfs-client]$ vi start-client.sh
[gysl@gysl-dev nfs-client]$ docker run --privileged -itd --rm nfs-client:v1.0
7e01276f49815b76dd4dc3ae3ff9a80b8d4f32814f46c4e58f7cfab0d945cebf
```

#### 3.3.3 验证是否挂载成功

进入应用容器，查看是否挂载成功：

```bash
[root@7e01276f4981 /]# df -h
Filesystem                      Size  Used Avail Use% Mounted on
overlay                         8.0G  2.6G  5.5G  32% /
tmpfs                            64M     0   64M   0% /dev
tmpfs                           455M     0  455M   0% /sys/fs/cgroup
/dev/mapper/centos-root         8.0G  2.6G  5.5G  32% /etc/hosts
shm                              64M     0   64M   0% /dev/shm
172.17.0.2:/high-speed-storage   10M     0   10M   0% /data
[root@7e01276f4981 /]# touch /data/test
```

成功！问题解决！

## 四 总结及拓展

### 4.1 本案例的缺点

- 不符合一个容器一个进程的容器运用的主流标准；

- 数据不能持久化保存，重启容器数据会被清除；

- 容器存在依赖性，必须先启动提供 NFS 服务的容器；

- 适用范围狭窄；

- 不能通过 systemd 来管理服务；

- 生产环境中不推荐使用此方案。

### 4.2 拓展知识

#### 4.2.1 把内存挂载成高速硬盘有 tmpfs 和 ramdisk 两种方案

linux下的 ramdisk 是由内核提供的，mount 命令挂载即可使用。它会被视为块设备，使用时需要格式化该文件系统。ramdisk 一旦创建就会占用固定大小的物理内存，tmpfs则是动态分配。

#### 4.2.2 Docker 容器的互联

在同一台主机的未指定网络方案的情况下，Docker 是通过 bridge 的方式进行桥接的。如果涉及到跨主机的互联，那么可能需要使用其他方案。

#### 4.2.3 在容器中的其他 NFS 解决方案

nfs-ganesha 也是 NFS 在容器中的一个比较流行的解决方案。更多资料可参阅：<https://access.redhat.com/documentation/en-US/Red_Hat_Storage/2.1/html/Administration_Guide/sect-NFS_Ganesha.html>