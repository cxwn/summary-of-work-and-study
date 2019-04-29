#!/bin/bash
echo -e "\033[33m Your current swap is \033[0m"
free -h
mkdir /SwapDir
cd /SwapDir
dd if=/dev/zero of=/SwapDir/swap bs=1M count=512 #这里增加的空间是512MB
chmod 0600 swap
mkswap /SwapDir/swap #把这个分区变成swap分区
swapon /SwapDir/swap #把刚建的swap分区设成为有效状态
myFile=/etc/fstab.bak 
cd /etc
if [ -f "$myFile" ];then
    rm -rf fstab.bak #删除之前的备份
    else
        cp /etc/fstab /etc/fstab.bak #备份fstab
fi
echo "/SwapDir/swap swap swap defaults 0 0">>/etc/fstab #增加新的swap开机自动启动
echo -e "\033[31m Done\!Congratulation\！System swap add successful\！ \033[0m"
echo -e "\033[33m Your system swap is \: \033[0m"
free -h