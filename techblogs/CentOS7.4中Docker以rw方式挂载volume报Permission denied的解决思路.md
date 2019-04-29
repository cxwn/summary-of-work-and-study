# 一、问题背景
今天在CentOS7.4.1708上实践Docker挂载volume,一切按照正常流程进行操作，无论是创建目录、创建文件、还是查看、编辑主机上创建好的文件，都报“Permission denied”，具体如下：
```
[root@ChatDevOps ~]# docker run -it -v /data/chatdevops:/data/webapp:rw ubuntu /bin/bash
root@4b92ff9fbced:/data/webapp# mkdir test
mkdir: cannot create directory 'test': Permission denied
root@4b92ff9fbced:/# cd /data/webapp/
root@4b92ff9fbced:/data/webapp# ll
ls: cannot open directory '.': Permission denied
root@4b92ff9fbced:/data/webapp# exit
```
反复查阅各种资料，官方文档都拜读几遍了，都没找到原因。操作系统版本及docker版本信息如下：
```
[root@ChatDevOps ~]# cat /etc/redhat-release 
CentOS Linux release 7.4.1708 (Core) 
[root@ChatDevOps ~]# docker --version
Docker version 1.13.1, build 94f4240/1.13.1
```
# 二、解决过程
1.在CentOS7.4上出现这个问题，换个其他发行版是不是也出现一样的问题呢？平日里最常用的发行版莫过于CentOS和Ubuntu了，何不去Ubuntu上试试看呢？
2.说干就干，看一下我的Ubuntu系统信息及Docker版本信息：
```
root@chatdevops:~# cat /etc/issue
Ubuntu 18.04 LTS \n \l
root@chatdevops:~# docker --version
Docker version 17.12.1-ce, build 7390fc6
```
居然比CentOS7.4的yum安装的docker版本号高很多！不管了，先看看是否跟操作系统有关！

3.在本机创建相关目录，并执行docker运行命令：
```
root@chatdevops:~# mkdir -p /data/volume
root@chatdevops:~# docker run -it -v /data/volume:/data/webapp ubuntu /bin/bash
```
4.在Ubuntu新docker挂载点下创建目录：
```
root@84bf1bb983ac:/data/webapp# mkdir test
root@84bf1bb983ac:/data/webapp# ll
total 12
drwxr-xr-x 3 root root 4096 Jun  7 11:37 ./
drwxr-xr-x 3 root root 4096 Jun  7 11:37 ../
drwxr-xr-x 2 root root 4096 Jun  7 11:37 test/
```
创建成功！果然跟操作系统有关，而不是与docker版本有关！

5.分析问题。

CentOS7.4与Ubuntu18.04Server版有啥区别呢？内核？SELinux？

为啥会想到SELinux而不是首先考虑内核呢？因为内核问题解决起来比较麻烦，这两个发行版的内核版本相差较大，SELinux经常会成为一切问题的罪魁祸首！还有，刚刚ls的时候没看到Ubuntu发行版权限列末尾的点，这个才是重点！来看一下CentOS的文件属性：
```
[root@ChatDevOps data]# ll
总用量 0
drwxr-xr-x. 3 root root 18 6月   7 19:53 chatdevops
[root@ChatDevOps data]# ll -Z
drwxr-xr-x. root root unconfined_u:object_r:default_t:s0 chatdevops
[root@ChatDevOps ~]# getenforce 
Enforcing
```
以上三种办法都核实了一下，SELinux确实是开启的。

6.关闭SELinux看一下：
```
[root@ChatDevOps data]# sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
[root@ChatDevOps data]# reboot
```
```
[root@ChatDevOps ~]# docker run -it --rm -v /data/chatdevops:/data/chatdevops:rw ubuntu /bin/bash
root@816e6beff208:/data/chatdevops# mkdir test
root@816e6beff208:/data/chatdevops# ll
total 0
drwxr-xr-x. 3 root root 18 Jun  7 11:53 ./
drwxr-xr-x  3 root root 24 Jun  7 11:52 ../
drwxr-xr-x  2 root root  6 Jun  7 11:53 test/
```
问题圆满解决！
# 三、总结
1.遇到问题的时候尽可能换个思路来试一下，不能总在一个地方转圈。

2.验证一些问题的时候尽量保持基础软件环境一致，不要一次性验证多个条件，我今天这个操作就不太严谨。

3.CentOS7.4.1708默认是启用SELinux的，而Ubuntu18.04 Server版则未启用SELinux，禁用SELinux后需要重启系统。

4.在CentOS7.4.1708的生产环境中使用docker时建议禁用SELinux，当然如果是对SELinux十分熟悉不禁用也是无妨的！

5.目前仅对CentOS7.4进行了验证，其他开启了SELinux的发行版也需要注意此问题。