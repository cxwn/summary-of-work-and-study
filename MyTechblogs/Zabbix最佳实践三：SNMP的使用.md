# 一.引言
一般情况下，打印机、交换机、路由器或UPS等设备，我们是没有办法通过 Zabbix agent 直接进行监控的，因为这些设备无法安装 Zabbix agent 。即便如此，只要这些设备支持标准SNMP协议，Zabbix依然能够轻松实现对这些设备进行监控。
# 二.重要概念
简单网络管理协议（SNMP），由一组网络管理的标准组成，包含一个应用层协议（application layer protocol）、数据库模型（database schema）和一组资源对象。该协议能够支持网络管理系统，用以监测连接到网络上的设备是否有任何引起管理上关注的情况。该协议是互联网工程工作小组（IETF，Internet Engineering Task Force）定义的internet协议簇的一部分。SNMP的目标是管理互联网Internet上众多厂家生产的软硬件平台，因此SNMP受Internet标准网络管理框架的影响也很大。SNMP已经出到第三个版本的协议，其功能较以前已经大大地加强和改进（引用自百度百科）。
# 三.配置过程
## 3.1 安装SNMP相关软件
```bash
[root@httpd ~]# yum -y install net-snmp net-snmp-utils
[root@httpd ~]# systemctl enable snmpd
[root@httpd ~]# systemctl start snmpd
```
net-snmp-utils并非必要安装项，这个软件包主要包括snmp的命令行工具。如果源码安装的话可以参考以下流程：
```bash
[root@httpd ~]# yum -y install gcc
[root@httpd ~]# curl -C - -O https://nchc.dl.sourceforge.net/project/net-snmp/net-snmp/5.8/net-snmp-5.8.tar.gz
[root@httpd ~]# tar -xvzf net-snmp-5.8.tar.gz
[root@httpd ~]# mkdir /usr/local/share/applications/net-snmp-5.8
[root@httpd ~]# cd net-snmp-5.8
[root@httpd net-snmp-5.8]# ./configure --prefix=/usr/local/share/applications/net-snmp-5.8/
[root@httpd net-snmp-5.8]# make && make install
[root@httpd ~]# echo 'export PATH=$PATH:/usr/local/share/applications/net-snmp-5.8/bin:/usr/local/share/applications/net-snmp-5.8/sbin'>>~/.bashrc
[root@httpd ~]# snmpd -v
NET-SNMP version:  5.8
Web:               http://www.net-snmp.org/
Email:             net-snmp-coders@lists.sourceforge.net
```
源码安装配置过程并不完整，请参阅[官方资料](http://www.net-snmp.org/docs/INSTALL.html)。

验证安装结果：
```bash
[root@httpd ~]# snmpwalk -v 2c -c public 172.31.3.41 sysName.0
SNMPv2-MIB::sysName.0 = STRING: httpd.gysl
```