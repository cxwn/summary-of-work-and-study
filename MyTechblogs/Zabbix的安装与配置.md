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

- 自动灵活的、精确的关联问题和解决方案

比如说，你可以定义触发器A告警的异常可以由触发器B解决，触发器B可能采用完全不同的数据采集方式。

异常（problems） 
- 一个处在“异常”状态的触发器

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
Server：
```bash
[root@zabbix ~]# cat /etc/centos-release
CentOS Linux release 7.5.1804 (Core)
[root@zabbix ~]# ip addr show |grep eth0|egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9]+'
172.31.3.21/22
```

```bash
[root@httpd ~]# systemctl enable httpd
Created symlink from /etc/systemd/system/multi-user.target.wants/httpd.service to /usr/lib/systemd/system/httpd.service.
[root@httpd ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since 二 2018-12-04 14:38:56 CST; 2min 41s ago
[root@httpd ~]# firewall-cmd --permanent --add-service=http
success
[root@httpd ~]# firewall-cmd --reload
success
```