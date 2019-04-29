#!/bin/bash
LANGUAGE=zh_CN.UTF-8 #中文环境支持，默认设置为：zh_CN.UTF-8
LANGPATH=/etc/locale.conf
ETHCONF=/etc/sysconfig/network-scripts
HOSTS=/etc/hostname  
NETWORK=/etc/sysconfig/network  
BAK_DIR=/root/`date +%Y%m%d` #备份文件按照年月日规则进行命名
echo "当前系统语言环境为："
echo $LANG
locale
cd $ETHCONF
echo "This directory list:"
ls -al ifc* #列举网卡名称
echo "Please enter your network device name carefully (It is very important!) :"
read ETH_NAME
if [ ! -f $ETH_NAME ];then
	tag=0
else
	tag=1
fi
case $tag in 
0) #备份之前网卡配置信息
        echo "You input an error network device name! Please input your network device name again!"
        read ETH_NAME
        break
        ;;	
1)
        mv $ETH_NAME ./${ETH_NAME}_bak #按照文件名_时间的格式进行备份
        break
        ;;  
*) 
echo "ERROR"
;;
esac
echo "DEVICE=$ETH_NAME
ONBOOT=yes
BOOTPROTO=static
IPADDR=10.9.16.247
NETMASK=255.255.255.0
GATEWAY=10.9.16.254
DNS1=114.114.114.114">$ETHCONF/$ETH_NAME
echo "网卡配置完毕，正在重启网络服务，请稍后... ..."
service network restart
sleep 3
if [ $LANGUAGE -ne $(echo $LANG) ];then #判断是否语言环境支持已经为：zh_CN.UTF-8
	echo "$LANGUAGE">$LANGPATH
fi
echo "请输入您需要设置的主机名（输入完毕之后请按回车键）："
read HOSTNAME
echo "$HOSTNAME">$HOSTS
echo "NETWORKING=yes
HOSTNAME=$HOSTNAME">$NETWORK