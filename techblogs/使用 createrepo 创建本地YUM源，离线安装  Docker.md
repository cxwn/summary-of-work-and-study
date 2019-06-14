# 使用 createrepo 创建本地YUM源，实现 Docker 的离线安装

## 一 背景

出于安全方面的考虑，很多情况下我们都不能直接连接互联网进行一些软件的安装。部分依赖包较少的软件我们可以去相关页面找到对应的软件包进行安装，但是对于依赖包较多的软件这种方式可能就显得有点有点捉襟见肘了，那么用什么办法来安装依赖包较多的软件呢？

## 二 实践环境

操作系统版本|安装软件版本
:-:|:-:
CentOS Linux release 7.4.1708 (Core)|docker-ce-18.06.2.ce-3.el7

## 三 操作步骤

### 3.1 准备离线包（createrepo、docker)

在能够联网的环境中创建一台与目标环境操作系统版本一致的机器，保持该机器全新安装并与目标环境机器软件系统配置全部一致。在此机器上下载并保存相关的 rpm 包。相关脚本如下：

```bash
#!/bin/bash
#===============================================================================
#          FILE: offline_install_docker_download.sh
#         USAGE: . ${YOUR_PATH}/offline_install_docker_download.sh  
#   DESCRIPTION: 
#        AUTHOR: IVAN DU
#        E-MAIL: mrivandu@hotmail.com
#        WECHAT: ecsboy
#      TECHBLOG: https://ivandu.blog.csdn.net
#        GITHUB: https://github.com/mrivandu
#       CREATED: 2019-06-13 18:26:03
#       LICENSE: GNU General Public License.
#     COPYRIGHT: © IVAN DU 2019
#      REVISION: v1.0
#===============================================================================

cd ~
mkdir {createrepo,docker}
curl http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo>&/dev/null
yum -y install --downloadonly --downloaddir=createrepo createrepo>&/dev/null
yum -y install --downloadonly --downloaddir=docker docker-ce-18.06.2.ce-3.el7>&/dev/null
tar -cvzf pkgs.tar.gz createrepo docker>&/dev/null
rm -rf createrepo docker
```

执行脚本：

```bash
[root@gysl ~]# bash offline_install_docker_download.sh
```

### 3.2 把离线包上传至目标环境的机器上

上传方式又很多种， ssh 、U 盘、ftp等方式均可，依个人情况选择，本文使用  U 盘拷贝。

### 3.3 在目标机器上执行创建 repo 及安装软件的脚本

脚本内容如下：

```bash
#!/bin/bash
#===============================================================================
#          FILE: offline_install_docker.sh
#         USAGE: . ${YOUR_PATH}/offline_install_docker.sh 
#   DESCRIPTION: 
#        AUTHOR: IVAN DU
#        E-MAIL: mrivandu@hotmail.com
#        WECHAT: ecsboy
#      TECHBLOG: https://ivandu.blog.csdn.net
#        GITHUB: https://github.com/mrivandu
#       CREATED: 2019-06-13 18:27:05
#       LICENSE: GNU General Public License.
#     COPYRIGHT: © IVAN DU 2019
#      REVISION: v1.0
#===============================================================================

cd ~
mkdir {createrepo,docker}
curl http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo>&/dev/null
yum -y install --downloadonly --downloaddir=createrepo createrepo>&/dev/null
yum -y install --downloadonly --downloaddir=docker docker-ce-18.06.2.ce-3.el7>&/dev/null
tar -cvzf pkgs.tar.gz createrepo docker>&/dev/null
rm -rf createrepo docker

while true;
do
    read -p "Do you need init your system and install docker-engine?(Y/n)" affirm
    if [[ "${affirm}" == 'y' || "${affirm}" == 'Y' ]];
       then
# Modify related kernel parameters.
       cat>/etc/sysctl.d/docker.conf<<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOF
        sysctl -p /etc/sysctl.d/docker.conf>&/dev/null
# IPv6 configuration.
        [ ! -d /etc/docker ] && mkdir /etc/docker
        cat>/etc/docker/daemon.json<<EOF
{
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
EOF
# Create a local repo_file.
        [ -d repo ] && rm -rf repo && mkdir repo
        [ ! -d repo ] && mkdir repo
        mv /etc/yum.repos.d/* repo
        cat>/etc/yum.repos.d/docker-ce.repo<<EOF
[docker]
name=docker
baseurl=file:///${PWD}/docker
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
# Turn off and disable the firewalld.
        systemctl stop firewalld
        systemctl disable firewalld
# Disable the SELinux.
        sed -i.bak 's/=enforcing/=disabled/' /etc/selinux/config
        echo "The system is initializing and installing docker-engine. Please waite a moment."
# Install the createrepo.
        yum clean all
        sleep 30
        tar -xvzf pkgs.tar.gz
        for rp in createrepo-0.9.9-28.el7.noarch.rpm  deltarpm-3.6-3.el7.x86_64.rpm  libxml2-python-2.9.1-6.el7_2.3.x86_64.rpm  python-deltarpm-3.6-3.el7.x86_64.rpm ;
        do
            rpm -Uvh ${PWD}/createrepo/${rp}
        done
        createrepo  ${PWD}/docker
        yum makecache
        sleep 30
# Install the docker engine.
        while true;
        do
                yum -y install docker-ce-18.06.2.ce-3.el7
                if [ $? -ne 0 ];
                    then
                        continue
                else
                        systemctl start docker>&/dev/null
                        [ $? -eq 0 ] && echo "Install successfully. " && rm -f /etc/yum.repos.d/docker-ce.repo && mv repo/* /etc/yum.repos.d/ && break 2
                fi
        done
    elif [[  "${affirm}" == 'N' || "${affirm}" == 'n' ]];
    then
        echo 'Your system and docker-engine will not be modify! '
        break
    else
        echo 'Your input is wrong. Please check! '
        continue
    fi
    done
systemctl enable docker
rm -rf repo docker createrepo pkgs.tar.gz
reboot
```
