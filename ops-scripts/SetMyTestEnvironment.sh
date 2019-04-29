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
yum -y install epel-release vim git tree
yum repolist
# Alias vim. 
cat>/etc/profile.d/vim.sh<<EOF
alias vi='vim'
EOF
source /etc/profile.d/vim.sh
echo "set nu">>/etc/vimrc
# Add a docker user.
useradd $UserName
echo $PassWord|passwd $UserName --stdin
usermod $UserName -aG docker  
# Reboot the machine.  
reboot