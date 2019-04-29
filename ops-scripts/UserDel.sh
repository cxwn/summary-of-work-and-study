#!/bin/bash
#批量删除用户脚本
USER1='payer'
UserName=('tangchanggen' 'wuyaxiong' 'lihui' 'wangyifeng' 'yanglongjun' 'liyunfeng' 'xiaoyongan' 'ivandu')
echo -e "\033[41;34m These account were deleting now! Please wait! \033[0m"
userdel -r $USER1
echo -e "\033[47;31m The account $USER1 had been deleted!  \033[0m"
for U in ${UserName[@]};
do
userdel -r $U
echo -e "\033[47;31m The account $U had been deleted!  \033[0m"
done
