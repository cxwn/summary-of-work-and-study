#!/bin/bash 
#===============================================================================
#          FILE: NeobyPay.sh
#         USAGE: ./NeobyPay.sh 
#   DESCRIPTION: 此脚本请使用source执行，带空格的.执行也是可以的。 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: GeekDevOps (IVAN DU), geeklp@qq.com
#  ORGANIZATION: Neoby
#       CREATED: 2018年01月30日 16时51分16秒
#      REVISION: V1.1.1
#===============================================================================
set -o nounset                              # Treat unset variables as an error
#清除账号别名
cp /etc/aliases /etc/aliases.$( date "+%Y%m%d%H%M%S")
cat /dev/null>&/etc/aliases
#关于用户或组需要备份的系统配置文件
cp /etc/passwd /etc/passwd.$(date +"%Y%m%d%H%M%S") 
cp /etc/shadow /etc/shadow.$(date +"%Y%m%d%H%M%S")
cp /etc/group /etc/group.$(date +"%Y%m%d%H%M%S")
#删除不必要账户
UnusefulAccounts=("lp" "mail" "games" "ftp" "nobody" "postfix" )
for Username in ${UnusefulAccounts[@]} ; 
	do
		userdel -f $Username >& /dev/null
			if [ $? -eq 0 ] ; then 
				echo "The account $Username has been deleted!"
			else
				echo "Deleting the account $Username ERROR! Please try again!"
			fi
	done
#删除不必要的组
UnusefulGroups=("mail" "games" "ftp" "nobody" "postfix")
for Groups in ${UnusefulGroups[@]} ;
	do
		groupdel $Groups >& /dev/null
            if [ $? -eq 0 ] ; then
                echo "The group $Groups has been deleted!"
            else
                echo "The group $Groups is not exist or has been deleted! Please check!"
            fi
	done
#密码策略
echo "TMOUT=300">>/etc/profile #登录后不活动则300秒超时
cp /etc/login.defs /etc/login.defs.$(date +"%Y%m%d%H%M%S") #备份配置文件
sed -i '/^#PermitRootLogin/a\PermitRootLogin no' /etc/ssh/sshd_config #禁止root用户ssh登录
sed -i '/^#Port/a\Protocol 2' /etc/ssh/sshd_config #使用ssh2协议登录
sed -i "/^PASS_MAX_DAYS/c\PASS_MAX_DAYS   60" /etc/login.defs #密码有效时间最大值为60天
sed -i "/^PASS_MIN_DAYS/c\PASS_MIN_DAYS   1" /etc/login.defs #密码修改间隔最小值为1天
sed -i "/^PASS_MIN_LEN/c\PASS_MIN_LEN   8" /etc/login.defs #密码最短长度为8个字符
sed -i "/^PASS_WARN_AGE/c\PASS_WARN_AGE   7" /etc/login.defs #密码过期提前7天提醒用户
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.$(date +"%Y%m%d%H%M%S") #备份配置文件
sed -i "/^auth        required      pam_env.so/a\auth        required      pam_tally2.so deny=3 unlock_time=300" /etc/pam.d/system-auth #密码输入错误三次之后锁定用户，五分钟之后自动解锁 
source /etc/profile>&/dev/null
systemctl restart sshd #重启ssh服务