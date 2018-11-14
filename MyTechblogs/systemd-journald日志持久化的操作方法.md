# 一、背景
每当遇到诸如网卡、数据库、Apache及其他一些应用无法正常启动时，系统会提示我们使用journalctl -ex命令进行查看，往往能迅速找到相关日志，分析日志后问题一般能够迅速被解决。虽然经常使用，但是也没有过多深究。

在CentOS7.X中，systemd统一管理着所有unit的启动日志，systemd-journald就是一个被systemd管理的进型日志管理服务，可以收集来自内核、系统早期启动阶段的日志、系统守护进程在启动和运行中的标准输出和错误信息，还有syslog的日志。该日志服务仅仅把日志集中保存在单一结构的日志文件/run/log中，由于日志是经过压缩和格式化的二进制数据，所以在查看和定位的时候很迅速，我们可以只用journalctl一条命令就能查看所有日志（内核日志和 应用日志）。
```
[root@ChatDevOps ~]# systemctl list-units|grep journal*
  systemd-journal-flush.service                                                       loaded active exited    Flush Journal to Persistent Storage
  systemd-journald.service                                                            loaded active running   Journal Service
  systemd-journald.socket                                                             loaded active running   Journal Socket
```
对于journal的配置，我们可以参见配置文件：/etc/systemd/journald.conf，可以根据实际情况进行自定义，默认情况下并不会持久化保存日志，只会保留一个月的日志。如果需要永久保留改日志文件呢？

# 二、操作步骤
1.创建相关的目录来存放journal日志，修改权限，重启systemd-journal服务。
```
[root@ChatDevOps ~]# mkdir /var/log/journal
[root@ChatDevOps ~]# chgrp systemd-journal /var/log/journal
[root@ChatDevOps ~]# chmod g+s /var/log/journal
[root@ChatDevOps ~]# systemctl restart systemd-journald
```

2.重启数次观察日志记录结果。
```
[root@ChatDevOps ~]# journalctl --list-boots
-2 3b8ad5992dc84becbee8e7d2c1a053cd 二 2018-06-12 10:54:34 CST—二 2018-06-12 11:03:57 CST
-1 13935fc1d8d9499baf4bbc453daf1e56 二 2018-06-12 11:04:05 CST—二 2018-06-12 20:08:03 CST
 0 eed68f873742408ca746a2272961f73d 二 2018-06-12 20:08:21 CST—二 2018-06-12 20:09:43 CST
```
从上面我们可以清晰地看到本日内的三次引导记录。

3.观察最近一次引导过程。
```
[root@ChatDevOps ~]# journalctl -b 0
```

4.之前/run/log/journal目录已经不存在，取而代之的是/var/log/journal目录。

# 三、总结
1.journalctl是一个非常好用的日志查看命令。

2.关于journal的使用可以参见下文：https://blog.csdn.net/zstack_org/article/details/72356864