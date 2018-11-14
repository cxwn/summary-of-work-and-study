#!/bin/bash
yum provides '*/applydeltarpm'
yum install deltarpm
yum -y install wget
yum -y install make
yum -y install perl
yum -y install libxcb
yum -y install libXft.so*
yum -y install libXft.so.2
yum -y install libX11.so.6
systemctl stop firewalld.service
systemctl stop iptables.service
mkdir /home/Acronis
cd /home/Acronis
wget -c http://mirror.centos.org/centos/7/os/x86_64/Packages/libX11-1.6.5-1.el7.x86_64.rpm
yum -y remove kernel-headers kernel-devel
wget -c https://buildlogs.centos.org/c7.1511.00/kernel/20151119220809/3.10.0-327.el7.x86_64/kernel-headers-3.10.0-327.el7.x86_64.rpm
wget -c https://buildlogs.centos.org/c7.1511.00/kernel/20151119220809/3.10.0-327.el7.x86_64/kernel-devel-3.10.0-327.el7.x86_64.rpm
wget -c http://mirror.centos.org/centos/7/os/x86_64/Packages/libxcb-1.12-1.el7.i686.rpm
rpm -ivh kernel-headers-3.10.0-327.el7.x86_64.rpm
sleep 20
rpm -ivh kernel-devel-3.10.0-327.el7.x86_64.rpm
sleep 20
rpm -ivh libxcb-1.12-1.el7.i686.rpm
sleep 20
rpm -ivh libX11-1.6.5-1.el7.x86_64.rpm
sleep 40
yum -y install gcc
rm -rf /home/Acronis
rmdir /home/Acronis