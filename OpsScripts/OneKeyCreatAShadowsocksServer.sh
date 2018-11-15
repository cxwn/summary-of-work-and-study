#!/bin/bash - 
#===============================================================================
#
#          FILE: ~/OneKeyCreatAShadowsocks.sh
# 
#         USAGE: source ~/OneKeyCreatAShadowsocks.sh 
# 
#   DESCRIPTION: 如果在您新定义的用户下运行本服务，请注意在命令前加sudo。
#
#        AUTHOR: IVAN DU (GeekDevOps), GEEKLP@QQ.COM
#       CREATED: 2018年03月22日 18时13分26秒
#      REVISION: v1.1.1
#===============================================================================
set -o nounset                              # Treat unset variables as an error
yum -y install gcc openssl openssl-devel
curl -C - -O https://www.python.org/ftp/python/2.7.14/Python-2.7.14.tgz
tar -xvzf Python-2.7.14.tgz
useradd -d /usr/local/python/ Shadowsocks
echo "GeekDevOps"|passwd Shadowsocks --stdin
cd Python-2.7.14
sh configure --prefix=/usr/local/python/ --with-ssl
make && make install
cd ~
curl -O https://bootstrap.pypa.io/get-pip.py
/usr/local/python/bin/python get-pip.py 
rm -rf *
ln -s /usr/local/python/bin/pip /bin/pip
useradd -d /usr/local/python/ Shadowsocks
echo "GeekDevOps"|passwd Shadowsocks --stdin
chown -R Shadowsocks:Shadowsocks /usr/local/python/
pip install shadowsocks
ln -s /usr/local/python/bin/ssserver /bin/ssserver
sed -i '/^root/a\Shadowsocks ALL=(ALL) NOPASSWD:ALL' /etc/sudoers
service iptables stop
echo '{
        "server":"0.0.0.0",
        "port_password":{
                "88":"GeekDevOps",
                "89":"GeekDevOps",
                "90":"GeekDevOps",
                "91":"GeekDevOps",
                "92":"GeekDevOps"
        },
        "localhost_address":"127.0.0.1",
        "localhost":1080,
        "timeout":300,
        "method":"aes-256-cfb",
        "fast_open":false,
        "workers":100
}'>`awk -F ":" '/Shadowsocks/ {print $6}' /etc/passwd`/shadowsocks.json
chown Shadowsocks.Shadowsocks `awk -F ":" '/Shadowsocks/ {print $6}' /etc/passwd`/shadowsocks.json
ssserver -c shadowsocks.json -d start