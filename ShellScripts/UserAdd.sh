#!/bin/bash
#批量创建用户及权限管理脚本
HostName=$(hostname)
Account=`whoami`
PASSWORD='TTkx1324'
USER1='payer'
APP='/app'
TEMP='/temp'
UserName=('tangchanggen' 'wuyaxiong' 'lihui' 'wangyifeng' 'yanglongjun' 'liyunfeng' 'xiaoyongan' 'ivandu')
adduser $USER1 -g root 
echo $PASSWORD | passwd payer --stdin 
passwd $USER1 -x 90 -w 7 
passwd -e $USER1      #chage -d0 payer 
echo -e "\033[47;31m The account $USER1 has been created!  \033[0m"
for U in ${UserName[@]};
do
adduser $U
echo $PASSWORD | passwd $U --stdin
passwd $U -x 90 -w 7
passwd -e $U
echo -e "\033[47;31m The account $U has been created!  \033[0m"
sleep 2
done
echo -e  "Runas_Alias OP = root\nCmnd_Alias DELEGATING = /usr/sbin/visudo, /bin/chown, /bin/chmod, /bin/chgrp\nCmnd_Alias STORAGE = /sbin/fdisk, /sbin/sfdisk, /sbin/parted, /sbin/partprobe, /bin/mount, /bin/umount\nCmnd_Alias SERVICES = /sbin/service, /sbin/chkconfig, /usr/bin/systemctl start, /usr/bin/systemctl stop, /usr/bin/systemctl reload, /usr/bin/systemctl restart, /usr/bin/systemctl status, /usr/bin/systemctl enable, /usr/bin/systemctl disable\nCmnd_Alias NETWORKING = /sbin/route, /sbin/ifconfig, /bin/ping, /sbin/dhclient, /usr/bin/net, /sbin/iptables, /usr/bin/rfcomm, /usr/bin/wvdial, /sbin/ifconfig, /sbin/mii-tool\nCmnd_Alias PROCESSES = /bin/nice, /bin/kill, /usr/bin/kill, /usr/bin/killall\nCmnd_Alias SOFTWARE = /bin/rpm, /usr/bin/up2date, /usr/bin/yum\nCmnd_Alias LOCATE = /usr/bin/updatedb\nUser_Alias ORDINARY_DEVELOP = ${UserName[0]},${UserName[1]},${UserName[2]},${UserName[3]},${UserName[4]}\nUser_Alias SUDO_DEVELOP = ${UserName[1]}\nUser_Alias NETWORKMANAGER = ${UserName[5]}\nUser_Alias DEVOPS = ${UserName[6]},${UserName[7]}\nORDINARY_DEVELOP       $HostName=(OP)    NOPASSWD:/sbin/service\nSUDO_DEVELOP           $HostName=(OP)    NOPASSWD:SERVICES\nNETWORKMANAGER         $HostName=(OP)    NOPASSWD:NETWORKING\nDEVOPS                 $HostName=(OP)    NOPASSWD:SERVICES,SOFTWARE,STORAGE,DELEGATING,PROCESSES,NETWORKING,LOCATE">>/etc/sudoers
if [ -d $APP ] ; then
setfacl -m u:${UserName[1]}:rwx -R $APP
elif [ ! -d $APP ] ;
then
mkdir $APP
setfacl -m u:${UserName[1]}:rwx -R $APP
fi
if [ -d $TEMP ] ; then
setfacl -m u:${UserName[1]}:rwx -R $TEMP
elif [ ! -d $TEMP ] ; 
then
mkdir "$TEMP"
setfacl -m u:${UserName[1]}:rwx -R $TEMP
fi
for ACL_Account in ${UserName[0]} ${UserName[1]} ${UserName[2]} ${UserName[3]} ${UserName[4]};
do 
setfacl -m u:${ACL_Account}:rwx -R /opt
done
