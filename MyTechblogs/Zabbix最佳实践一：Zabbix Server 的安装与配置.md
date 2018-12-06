# 一.概述
在开始之前，一些概念和定义需要我们提前了解一下（以下内容摘自官方网站）。
## 1.1 几个概念
**架构**

Zabbix 由几个主要的功能组件组成，其职责如下所示。

**Server**

Zabbix server 是Zabbix agent 向其报告可用性、系统完整性信息和统计信息的核心组件。是存储所有配置信息、统计信息和操作信息的核心存储库。

Zabbix Server 负责执行数据的主动轮询和被动获取，计算触发器条件，向用户发送通知。它是 Zabbix Agent 和 Proxy 报告系统可用性和完整性数据的核心组件。Server 自身可以通过简单服务远程检查网络服务（如Web服务器和邮件服务器）。

Zabbix Server是所有配置、统计和操作数据的中央存储中心，也是 Zabbix 监控系统的告警中心。在监控的系统中出现任何异常，将被发出通知给管理员。

基本的 Zabbix Server 的功能分解成为三个不同的组件。他们是：Zabbix server、Web前端和数据库。

Zabbix 的所有配置信息都存储在 Server 和 Web 前端进行交互的数据库中。例如，当你通过Web前端（或者API）新增一个监控项时，它会被添加到数据库的监控项表里。然后，Zabbix server 以每分钟一次的频率查询监控项表中的有效项，接着将它存储在 Zabbix server 中的缓存里。这就是为什么 Zabbix 前端所做的任何更改需要花费两分钟左右才能显示在最新的数据段的原因。

**数据库**

所有配置信息以及 Zabbix 收集到的数据都被存储在数据库中。

**Web 界面**

为了从任何地方和任何平台轻松访问 Zabbix ，我们提供了基于 web 的界面。该界面是 Zabbix server 的一部分，通常（但不一定）和 Zabbix server 运行在同一台物理机器上。

**Proxy**

Zabbix proxy 可以替 Zabbix server 收集性能和可用性数据。Zabbix proxy 是 Zabbix 环境部署的可选部分；然而，它对于单个 Zabbix server 负载的分担是非常有益的。

Zabbix proxy 是一个可以从一个或多个受监控设备采集监控数据并将信息发送到 Zabbix server 的进程，主要是代表 Zabbix server 工作。 所有收集的数据都在本地缓存，然后传输到 proxy 所属的 Zabbix server。

部署Zabbix proxy 是可选的，但可能非常有利于分担单个 Zabbix server 的负载。 如果只有代理采集数据，则 Zabbix server 上会减少 CPU 和磁盘 I/O 的开销。Zabbix proxy 是无需本地管理员即可集中监控远程位置、分支机构和网络的理想解决方案。Zabbix proxy 需要使用独立的数据库。

**Agent**

Zabbix agent 部署在被监控目标上，以主动监控本地资源和应用程序（硬盘、内存、处理器统计信息等）。

Zabbix agent 收集本地的操作信息并将数据报告给 Zabbix server 用于进一步处理。一旦出现异常 (例如硬盘空间已满或者有崩溃的服务进程)，Zabbix server 会主动警告管理员指定机器上的异常。

Zabbix agents 的极高效率缘于它可以利用本地系统调用来完成统计数据的采集。

Zabbix agent 可以运行被动检查和主动检查。

在被动检查 模式中 agent 应答数据请求。Zabbix server（或 proxy）询求数据，例如 CPU load，然后 Zabbix agent 返还结果。

主动检查 处理过程将相对复杂。Agent 必须首先从 Zabbix sever 索取监控项列表以进行独立处理，然后会定期发送采集到的新值给 Zabbix server。

是否执行被动或主动检查是通过选择相应的监控项类型来配置的。 Zabbix agent 处理“Zabbix agent”或“Zabbix agent（active）”类型的监控项。

**数据流**

首先，为了创建一个采集数据的监控项，您就必须先创建主机。其次，必须有一个监控项来创建触发器。最后，您必须有一个触发器来创建一个动作，这几个点构成了一个完整的数据流。因此，如果您想要收到 CPU load it too high on Server X 的告警，您必须首先为 Server X 创建一个主机条目，其次创建一个用于监视其 CPU 的监控项，最后创建一个触发器，用来触发 CPU is too high 这个动作，并将其发送到您的邮箱里。虽然这些步骤看起来很繁琐，但是使用模板的话，其实并不复杂。也正是由于这种设计，使得 Zabbix 的配置变得更加灵活易用。
## 1.2 一些定义
主机（host）

- 你想要监控的联网设备，有IP/DNS。

主机组（host group)

- 主机的逻辑组；可能包含主机和模板。一个主机组里的主机和模板之间并没有任何直接的关联。通常在给不同用户组的主机分配权限时候使用主机组。

监控项（item）

- 你想要接收的主机的特定数据，一个度量/指标数据。

值预处理（value preprocessing）

- 转化/预处理接收到的指标数据 存入数据库之前。

触发器（trigger）

- 一个被用于定义问题阈值和“评估”监控项接收到的数据的逻辑表达式。当接收到的数据高于阈值时，触发器从“OK”变成“Problem”状态。当接收到的数据低于阈值时，触发器保留/返回“OK”的状态。

事件（event）

- 一次发生的需要注意的事情，例如触发器状态改变、发现/监控代理自动注册。

事件标签（event tag）

- 提前设置的事件标记可以被用于事件关联，权限细化设置等。

事件关联（event correlation）

- 自动灵活的、精确的关联问题和解决方案。

比如说，你可以定义触发器A告警的异常可以由触发器B解决，触发器B可能采用完全不同的数据采集方式。

异常（problems） 
- 一个处在“异常”状态的触发器。

异常更新（problem update）

- Zabbix提供的问题管理选项，例如添加评论、确认异常、改变问题级别或者手动关闭等。

动作（action）

- 预先定义的应对事件的操作。一个动作由操作(例如发出通知)和条件(什么时间进行操作)组成。

升级（escalation）

- 一个在动作内执行操作的自定义方式; 发送通知/执行远程命令的顺序安排。

媒介（media）

- 发送告警通知的方式，传送途径。

通知（notification）

- 关于事件的信心，将通过选设定的媒介途径发送给用户。

远程命令（remote command）

- 一个预定义好的，满足特定条件的情况下，可以在被监控主机上自动执行的命令。

模版（template）

- 一组可以被应用到一个或多个主机上的实体（监控项，触发器，图形，聚合图形，应用，LLD，Web场景）的集合。模版的应用使得主机上的监控任务部署快捷方便；也可以使监控任务的批量修改更加简单。模版是直接关联到每台单独的主机上。

应用（application）

- 一组监控项组成的逻辑分组。

Web场景（web scenario）

- 检查网站可浏览性的一个或多个HTTP请求。

前端（frontend)

- Zabbix提供的web界面。

Zabbix API

- Zabbix API允许用户使用JSON RPC协议来创建、更新和获取Zabbix对象（如主机、监控项、图形和其他）信息或者执行任何其他的自定义的任务。

Zabbix server

- Zabbix监控的核心程序，主要功能是与Zabbix proxies和Agents进行交互、触发器计算、发送告警通知；并将数据集中保存等。

Zabbix agent

- 部署在监控对象上的，能够主动监控本地资源和应用的程序。

Zabbix proxy

- 一个帮助Zabbix Server收集数据，分担Zabbix Server的负载的程序。

加密（encryption）

- 支持Zabbix组建之间的加密通讯(server, proxy, agent, zabbix_sender 和 zabbix_get 程序) 使用TLS（Transport Layer Security ）协议。
# 二.环境
由于实验环境资源有限，本实验中只有一台 Zabbix Server 和一台被监控的Host，配置如下：

**Zabbix Server**
```bash
[root@zabbix ~]# cat /etc/centos-release
CentOS Linux release 7.5.1804 (Core)
[root@zabbix ~]# ip addr show |grep eth0|egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+'
172.31.3.21/22
[root@zabbix ~]# zabbix_server --version
zabbix_server (Zabbix) 4.0.2
```
**Host**
```bash
[root@httpd ~]# cat /etc/centos-release
CentOS Linux release 7.5.1804 (Core)
[root@httpd ~]# ip addr show |grep eth0|egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+'
172.31.3.41/22
[root@httpd ~]# zabbix_agentd -V
zabbix_agentd (daemon) (Zabbix) 4.0.2
```
Host主机的防火墙已关闭。
# 三.安装与配置过程
## 3.1 Zabbix Server 的安装与配置 
### 3.1.1 安装仓库配置包
```bash
[root@zabbix ~]# rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
```
如果这一步无法正常执行，那么我们还可以去[官方仓库](https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/)下载相关repo的rpm包进行安装。
```bash
[root@zabbix ~]# rpm -ivh zabbix-release-4.0-1.el7.noarch.rpm
警告：zabbix-release-4.0-1.el7.noarch.rpm: 头V4 RSA/SHA512 Signature, 密钥 ID a14fe591: NOKEY
准备中...                          ################################# [100%]
正在升级/安装...
   1:zabbix-release-4.0-1.el7         ################################# [100%]
```
### 3.1.2 安装 zabbix-server-mysql、zabbix-web-mysql 及zabbix-agent
```bash
[root@zabbix ~]# yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent
已安装:
  zabbix-agent.x86_64 0:4.0.2-1.el7                     zabbix-server-mysql.x86_64 0:4.0.2-1.el7                     zabbix-web-mysql.noarch 0:4.0.2-1.el7
作为依赖被安装:
  OpenIPMI-libs.x86_64 0:2.0.23-2.el7        OpenIPMI-modalias.x86_64 0:2.0.23-2.el7    apr.x86_64 0:1.4.8-3.el7_4.1                   apr-util.x86_64 0:1.5.2-6.el7
  dejavu-fonts-common.noarch 0:2.33-6.el7    dejavu-sans-fonts.noarch 0:2.33-6.el7      fontpackages-filesystem.noarch 0:1.44-8.el7    fping.x86_64 0:3.10-1.el7
  gnutls.x86_64 0:3.3.26-9.el7               httpd.x86_64 0:2.4.6-80.el7.centos         httpd-tools.x86_64 0:2.4.6-80.el7.centos       iksemel.x86_64 0:1.4-2.el7.centos
  libX11.x86_64 0:1.6.5-1.el7                libX11-common.noarch 0:1.6.5-1.el7         libXau.x86_64 0:1.0.8-2.1.el7                  libXpm.x86_64 0:3.5.12-1.el7
  libevent.x86_64 0:2.0.21-4.el7             libjpeg-turbo.x86_64 0:1.2.90-5.el7        libpng.x86_64 2:1.5.13-7.el7_2                 libtool-ltdl.x86_64 0:2.4.2-22.el7_3
  libxcb.x86_64 0:1.12-1.el7                 libxslt.x86_64 0:1.1.28-5.el7              libzip.x86_64 0:0.10.1-8.el7                   mailcap.noarch 0:2.1.41-2.el7
  net-snmp-libs.x86_64 1:5.7.2-32.el7        nettle.x86_64 0:2.7.1-8.el7                php.x86_64 0:5.4.16-45.el7                     php-bcmath.x86_64 0:5.4.16-45.el7
  php-cli.x86_64 0:5.4.16-45.el7             php-common.x86_64 0:5.4.16-45.el7          php-gd.x86_64 0:5.4.16-45.el7                  php-ldap.x86_64 0:5.4.16-45.el7
  php-mbstring.x86_64 0:5.4.16-45.el7        php-mysql.x86_64 0:5.4.16-45.el7           php-pdo.x86_64 0:5.4.16-45.el7                 php-xml.x86_64 0:5.4.16-45.el7
  t1lib.x86_64 0:5.1.2-14.el7                trousers.x86_64 0:0.3.14-2.el7             unixODBC.x86_64 0:2.3.1-11.el7                 zabbix-web.noarch 0:4.0.2-1.el7
完毕！
```
### 3.1.3 安装mariadb（MySQL）
在某些CentOS版本中，MySQL已经被替换为mariadb，mariadb完全兼容MySQL，并且不存在法律风险，是MySQL良好的替代品。当然，如果要安装MySQL，那么也是没有问题的，我之前的博文有关各类MySQL的安装教程，可供参考。由于实验环境资源有限，本人把 mariadb 也安装在了与 Zabbix Server 相同的主机上。生产环境的话还是尽量把数据库独立处理安装与配置。 
```bash
[root@zabbix ~]# yum -y install mariadb-server
已安装:
  mariadb-server.x86_64 1:5.5.60-1.el7_5
作为依赖被安装:
  mariadb.x86_64 1:5.5.60-1.el7_5
完毕！
[root@zabbix ~]# systemctl start mariadb
[root@zabbix ~]# systemctl enable mariadb
Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
```
### 3.1.3 创建相关数据库并设置
```bash
[root@zabbix ~]# mysql -uroot -p
MariaDB [(none)]> create database zabbix character set utf8 collate utf8_bin;
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
| zabbix             |
+--------------------+
MariaDB [(none)]> show variables like 'character_set_database';
+------------------------+--------+
| Variable_name          | Value  |
+------------------------+--------+
| character_set_database | latin1 |
+------------------------+--------+
1 row in set (0.00 sec)
MariaDB [(none)]> grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix.gysl';
MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)
MariaDB [(none)]> SET PASSWORD FOR 'root'@'localhost' = PASSWORD('zabbix.gysl');
MariaDB [(none)]> quit
Bye
```
Mariadb 安装完成之后默认无密码，在提示输入密码那一步直接按回车键即可登入。等入数据库之后，创建了数据库zabbix，授予所有的权限并设置密码。最后顺便给mariadb设置了密码。
### 3.1.4 修改相关配置
```bash
[root@zabbix ~]# sed -i.bak '/^DBUser/a DBPassword=zabbix.gysl' /etc/zabbix/zabbix_server.conf
[root@zabbix ~]# cat /etc/zabbix/zabbix_server.conf |grep -v ^#|grep ^"\S"
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=0
PidFile=/var/run/zabbix/zabbix_server.pid
SocketDir=/var/run/zabbix
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix.gysl
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
Timeout=4
AlertScriptsPath=/usr/lib/zabbix/alertscripts
ExternalScripts=/usr/lib/zabbix/externalscripts
LogSlowQueries=3000
```
### 3.1.5 数据初始化
```bash
[root@zabbix ~]# zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
Enter password:
[root@zabbix ~]# mysql -u zabbix -p
Enter password:
MariaDB [(none)]> use zabbix;
MariaDB [zabbix]> show tables;
144 rows in set (0.00 sec)
MariaDB [zabbix]> exit
Bye
```
输入之前我们设置的密码，回车键稍后即可。144张表，确认无误。
### 3.1.6 修改时区
```bash
[root@zabbix ~]# sed -i.bak '/Europe\/Riga/a \tphp_value date.timezone Asia/Shanghai' /etc/httpd/conf.d/zabbix.conf
```
### 3.1.7 完成最后设置并重启服务器
```bash
[root@zabbix ~]# systemctl stop firewalld
[root@zabbix ~]# systemctl disable firewalld
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
[root@zabbix ~]# systemctl start httpd
[root@zabbix ~]# systemctl enable httpd
Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.
[root@zabbix ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
[root@zabbix ~]# systemctl restart zabbix-server zabbix-agent
[root@zabbix ~]# systemctl enable zabbix-server zabbix-agent
Created symlink from /etc/systemd/system/multi-user.target.wants/zabbix-server.service to /usr/lib/systemd/system/zabbix-server.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/zabbix-agent.service to /usr/lib/systemd/system/zabbix-agent.service.
[root@zabbix ~]# reboot
```
重启之后如果无其他异常，那么 Zabbix Server 已经正常运行，等待进一步配置。
## 3.2 配置 Zabbix Web 
### 3.2.1 初始化Web设置
在浏览器地址栏输入：http://172.31.3.21/zabbix 
（http://server_ip_or_name/zabbix）后按下回车键。 
点击Next setup按钮，按照提示输入必填内容，填写完毕之后界面大致如下：
![安装确认](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/Pre-Install.png)
出现以下界面说明安装成功。
![安装成功](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/Zabbix-success.png)
点击Finish即可。
### 3.2.2 登录并简单设置
输入用户名 Admin 以及密码 zabbix 以作为 Zabbix 超级用户登录。页面右上角找到用户头像标志，把语言设置为中文。
### 3.3 在Host主机上安装agent程序并设置
```bash
[root@httpd ~]# rpm -ivh zabbix-release-4.0-1.el7.noarch.rpm
[root@httpd ~]# yum -y install zabbix-agent
[root@httpd ~]# sed -i.bak 's/Server=127.0.0.1/Server=172.31.3.21/g' /etc/zabbix/zabbix_agentd.conf
[root@httpd ~]# systemctl start zabbix-agent
[root@httpd ~]# systemctl enable zabbix-agent
Created symlink from /etc/systemd/system/multi-user.target.wants/zabbix-agent.service to /usr/lib/systemd/system/zabbix-agent.service.
```
### 3.4 添加第一台被监控主机
登录系统之后，依次点击：配置->创建主机（右上角）。依次填入或者选择如下图所示项目：
![Add Host](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/Zabbix-addHost0.png)

选择模板并添加：
![选择模板](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/Zabbix-addHost.png)

选择完成之后，点击添加，查看：

![查看状态](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/Zabbix-status.png)

出现如上图所示内容则代表配置成功，可以进一步探索Zabbix强大的功能了。

# 四.总结
4.1 总体来说，Zabbix是非常容易安装、使用的，但是在安装过程中还是需要注意一些细节。

4.3 Zabbix 的官方文档很详细，还提供中文版，但是也还有一些坑需要我们去思考、总结。

4.4 如果使用二进制安装，那么进程管理账户那是非常有必要考虑的。在官方文档中有提到，zabbix server 和 zabbix agent 在同一台主机上安装时，需要使用不通的进程管理账户。

4.4 这篇文章主要介绍的Zabbix的安装，截图较少，需要一些使用经验。进一步的使用会在后面的文章中具体展开介绍，不足之处万望海涵。愿大家与我一起成长！
# 五.相关资料
5.1 [官方仓库](https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/)

5.2 [下载地址及简要安装教程](https://www.zabbix.com/download)

5.3 [Zabbix安全最佳实践](https://www.zabbix.com/documentation/4.0/zh/manual/installation/requirements/best_practices)

5.4 [CentOS环境下官方安装教程](https://www.zabbix.com/documentation/4.0/zh/manual/installation/install_from_packages/rhel_centos)

5.5 [最新版官方中文文档](https://www.zabbix.com/documentation/4.0/zh/manual)