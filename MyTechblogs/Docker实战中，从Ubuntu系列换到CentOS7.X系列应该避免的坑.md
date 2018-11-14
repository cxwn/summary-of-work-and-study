# 一、背景
在生产环境中部署、使用Docker已经有很长一段时间了。学习的时候大部分环境、资料都是在Ubuntu14.04、16.04及18.04中实现的。由于某些原因，需要在生产环境中的CentOS7.2和7.4中部署使用Docker。在这个过程中踩了不少坑，花了很多时间，走了很多弯路。

# 二、一些常见的坑及解决方案
## 2.1 SELinux
在Ubuntu系列系统中默认是没有SELinux的。因此也无需配置，如果安装了SELinux的话，禁用或者进行相关配置那是必须的。在CentOS7.2和7.4中，SELinux默认是启用的，如果不进行相关配置，那么在Docker卷挂载时是无法正常使用的。查看SELinux状态及关闭SELinux可以使用以下命令：
```
[root@ChatDevOps ~]# getenforce 
Enforcing
[root@ChatDevOps ~]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 
[root@ChatDevOps ~]# reboot
[root@ChatDevOps ~]# getenforce 
Disabled
```
操作过程中，重启是必须的。不禁用也是可以的，permissive也可以。

## 2.2 防火墙
CentOS7.2及7.4默认情况下使用的firewalld动态防火墙，并且CentOS7.4防火墙默认开机启动。Ubuntu系列使用iptables多一些。如果不用的话建议关闭，一般大型系统都有硬件防火墙，建议关闭。如果个人小规模使用就按照最小化原则进行配置。关闭及禁用开机启动命令可以参考如下：
```
[root@ChatDevOps ~]# systemctl stop firewalld
[root@ChatDevOps ~]# systemctl disable firewalld
```

## 2.3 IP转发
默认情况下，CentOS7.4的ip转发是关闭的，需要格外注意，这是造成很多故障的原因之一。这个情况在Ubuntu14.04及以上版本是不存在的，Ubuntu默认开启了的。查看ip转发是否开启可以使用以下命令：
```
[root@ChatDevOps ~]# sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 0
```
如果返回值是0,说明ip转发是关闭了的，需要开启。开启命令可以参考以下内容:
```
[root@ChatDevOps ~]# sysctl net.ipv4.ip_forward=1
net.ipv4.ip_forward = 1
```
命令执行后立即生效，重启之后需要再次操作。如果需要永久生效，那么使用以下命令：
```
[root@ChatDevOps ~]# echo "net.ipv4.ip_forward = 1">>/etc/sysctl.conf 
[root@ChatDevOps ~]# sysctl -p
net.ipv4.ip_forward = 1
[root@ChatDevOps ~]# sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
```

# 三、总结
3.1 Linux的各大发行版在细节方面差异较大，需要格外注意，不能按部就班的随便套用。

3.2 在使用的过程中需要发挥自己的思维变通能力，尽量做到触类旁通。

3.3 目前就发现这些问题了，其他问题希望诸位多多分享，交流。
