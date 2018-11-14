#!/bin/bash
#===============================================================================
#          FILE: CreateUsersAndAccessManage.sh
#         USAGE: ./CreateUsersAndAccessManage.sh 
#   DESCRIPTION: 
#        AUTHOR: GeekDevOps (IVAN DU), geeklp@qq.com
#  ORGANIZATION: NEOBY
#       CREATED: 2018年01月26日 16时06分24秒
#      REVISION: V1.0.0
#===============================================================================
set -o nounset                              # Treat unset variables as an error
HostName=$(hostname)
Admin=('payer')
GROUP_ORDINARY='develop'
GROUP_SUDO='develop_sudo'
SuperUserName=('wuyx')
DeployUser=('dep')
UserName=('tangcg' 'wuyx' 'lihui' 'wangyf' 'yanglj' 'liyf' 'xiaoya' 'durh' )
APP='/app'
TEMP='/temp'
groupadd $GROUP_ORDINARY
groupadd $GROUP_SUDO
#Create Admin
for AdUser in ${Admin[@]};
    do
        id $AdUser>&/dev/null
        if [ $? -ne 0 ] ;then
            adduser $AdUser -g root
            echo 'Neoby123'|passwd $AdUser --stdin
            passwd $AdUser -x 90 -w 7
            passwd -e $AdUser
            echo -e "\033[47;31m The account $AdUser had been created!  \033[0m"
        else
            echo -e "\033[47;32m The account $AdUser was exsit!  \033[0m"
        fi
sleep 2
    done
#Create SuperUser
for SuperUser in ${SuperUserName[@]} ;
    do
        id $SuperUser>&/dev/null
        if [ $? -ne 0 ] ;then
            adduser $SuperUser -G $GROUP_ORDINARY -g $GROUP_SUDO
            echo 'Neoby123'|passwd $SuperUser --stdin
            passwd $SuperUser -x 90 -w 7
            passwd -e $SuperUser
            echo -e "\033[47;31m The account $SuperUser had been created!  \033[0m"
        else
            echo -e "\033[47;32m The account $SuperUser was exsit!  \033[0m"
        fi
        sleep 2
    done
#Create DeployUser #部署应用专用账户
for DepUser in ${DeployUser[@]} ;
    do
        id $DepUser>&/dev/null 
        if [ $? -ne 0 ] ;then    #如果账户存在则不进行创建
            adduser $DepUser -g $GROUP_ORDINARY
            echo 'Neoby123'|passwd $DepUser --stdin
            passwd $DepUser -x 90 -w 7
            passwd -e $DepUser 
            echo -e "\033[47;31m The account $DepUser had been created!  \033[0m"
        else
            echo -e "\033[47;32m The account $DepUser  was exsit!  \033[0m"
        fi
        sleep 2
    done
#Create ordinary user #创建一个普通用户，并将其添加至普通用户组
for User in ${UserName[@]} ;
    do
        id $User>&/dev/null
    if [ $? -ne 0 ] ;then
        adduser $User -g $GROUP_ORDINARY
        echo 'Neoby123'|passwd $User --stdin
        passwd $User -x 90 -w 7
        passwd -e $User
        echo -e "\033[47;31m The account $User had been created!  \033[0m"
    else
        echo -e "\033[47;32m The account $User was exsit!  \033[0m"
    fi
        sleep 2
    done
#以下内容为SUDO权限控制部分-----------
echo -e "Runas_Alias OP = root\nRunas_Alias DE = dep\nCmnd_Alias DELEGATING = /usr/sbin/visudo, /bin/chown, /bin/chmod, /bin/chgrp\nCmnd_Alias STORAGE = /sbin/fdisk, /sbin/sfdisk, /sbin/parted, /sbin/partprobe, /bin/mount, /bin/umount\nCmnd_Alias NETWORKING = /sbin/route, /usr/sbin/ip, /bin/ping, /sbin/dhclient, /sbin/mii-tool\nCmnd_Alias PROCESSES = /bin/nice, /bin/kill, /usr/bin/kill, /usr/bin/killall\nCmnd_Alias SOFTWARE = /bin/rpm, /usr/bin/up2date, /usr/bin/yum\nUser_Alias DEVELOPER = ${UserName[0]},${UserName[1]},${UserName[2]},${UserName[3]},${UserName[4]}\nUser_Alias ADMIN = ${Admin[0]}\nUser_Alias NETWORKMANAGER = ${UserName[5]}\nUser_Alias DEVOPS = ${UserName[6]},${UserName[7]}\nADMIN                $HostName=(OP)    NOPASSWD:ALL\nDEVELOPER            $HostName=(DE)    NOPASSWD:ALL\nNETWORKMANAGER       $HostName=(OP)    NOPASSWD:NETWORKING\nDEVOPS               $HostName=(OP)    NOPASSWD:SOFTWARE,STORAGE,DELEGATING,PROCESSES">>/etc/sudoers #修改sudo配置文件，给每一个用户分配权限。
if [ -d $APP ] ; then
    chgrp $GROUP_SUDO $APP
    chmod -R g+rwx /$APP 
elif [ ! -d $APP ] ; then
    mkdir $APP
    chgrp $GROUP_SUDO $APP
    chmod -R g+rwx /$APP
fi
if [ -d $TEMP ] ; then
    chgrp $GROUP_ORDINARY $TEMP
    chmod -R g+rwx /$TEMP
elif [ ! -d $TEMP ] ; then
    mkdir $TEMP
    chgrp $GROUP_ORDINARY $TEMP
    chmod -R g+rwx $TEMP
fi
chown -R ${DeployUser[0]}:$GROUP_ORDINARY /opt
chmod -R 775 /opt 