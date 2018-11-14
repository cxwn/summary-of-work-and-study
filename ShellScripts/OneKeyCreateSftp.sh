#!/bin/bash - 
#===============================================================================
#
#          FILE: SftpCreate.sh
#         USAGE: ./SftpCreate.sh 
#   DESCRIPTION: Create a Sftp Server
#       OPTIONS: None
#  REQUIREMENTS: Nene
#        AUTHOR: Geeklp (IVAN DU), geeklp@qq.com
#  ORGANIZATION: GEEKLP
#       CREATED: 2017年12月19日 10时29分12秒
#      REVISION: V1.1
#===============================================================================
set -o nounset                              # Treat unset variables as an error
Users=('chinapay' 'ctbx' 'haoyilian' 'hbgyl' 'huaxia' 'jczh' 'kjb' 'lykj' 'lzkj' 'msyh' 'nyjt' 'pingan' 'xldz' 'yigw' 'yytwallet')
PassWord='Neoby1314'
#modify the /etc/ssh/sshd_config
sed -i '/Subsystem/s/^/#/' /etc/ssh/sshd_config
sed -i '/^#Subsystem/a\Subsystem       sftp    internal-sftp' /etc/ssh/sshd_config
#---------Create SFTPUsers----------
for UserName in ${Users[@]};
do
id -u $UserName>& /dev/null
if [ $? -ne 0 ]; then
mkdir /home/$UserName
adduser $UserName -d /home/$UserName/$UserName
echo "The account $UserName  was created!"
echo $PassWord | passwd $UserName --stdin
usermod -s /bash/false $UserName #禁止ssh登录
echo "
Match User $UserName
      X11Forwarding no
      AllowTcpForwarding no
      ForceCommand internal-sftp
      ChrootDirectory /home/$UserName">>/etc/ssh/sshd_config
else
echo "The username $UserName was existed!"
fi
done
systemctl restart sshd
#----------END-----------------------
