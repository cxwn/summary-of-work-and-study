#!/bin/bash
#===============================================================================
#          FILE: OpenVASInstall.sh
#         USAGE: ./OpenVASInstall.sh 
#   DESCRIPTION:请使用source OpenVASInstall来执行本脚 
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: GeekDevOps (IVAN DU), geeklp@qq.com
#  ORGANIZATION: GeekDevOps
#       CREATED: 2018年02月02日 15时51分35秒
#      REVISION: v.1.1.1
#===============================================================================
set -o nounset                              # Treat unset variables as an error
sed -i "/^SELINUX=enforcing/c\SELINUX=disabled" /etc/selinux/config
yum install -y wget bzip2 texlive net-tools alien gnutls-utils
wget -q -O - https://www.atomicorp.com/installers/atomic | sh
yum -y install openvas 
sed -i "/^# unixsocket \/tmp\/redis.sock/c\unixsocket \/tmp\/redis.sock" /etc/redis.conf 
sed -i "/^# unixsocketperm 700/c\unixsocketperm 700" /etc/redis.conf
systemctl enable redis && systemctl restart redis
firewall-cmd --permanent --add-port=9392/tcp
firewall-cmd --reload
firewall-cmd --list-ports
reboot