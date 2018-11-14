# 一、 背景
在实际的生产环境中，对于某些服务器需要进行设置禁止ping，具体场景就不做讨论了，大家根据自己的实际情况进行设置即可。

# 二、实验环境
被ping主机IP：
```
10.1.1.11
```
执行ping的主机IP：
```
10.1.1.12及通过NAT连接的主机
```
操作系统版本：
```
[root@ChatDevOps ~]# cat /etc/redhat-release 
CentOS Linux release 7.4.1708 (Core) 
```

# 三、实验步骤
1.从主机10.1.1.12ping主机10.1.1.11。
```
[root@ChatDevOps ~]# ip address show ens33
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:76:62:6b brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.12/24 brd 10.1.1.255 scope global ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe76:626b/64 scope link 
       valid_lft forever preferred_lft forever
[root@ChatDevOps ~]# ping 10.1.1.11
PING 10.1.1.11 (10.1.1.11) 56(84) bytes of data.
64 bytes from 10.1.1.11: icmp_seq=1 ttl=64 time=0.842 ms
64 bytes from 10.1.1.11: icmp_seq=2 ttl=64 time=0.464 ms
64 bytes from 10.1.1.11: icmp_seq=3 ttl=64 time=0.533 ms
64 bytes from 10.1.1.11: icmp_seq=4 ttl=64 time=0.661 ms
64 bytes from 10.1.1.11: icmp_seq=5 ttl=64 time=0.654 ms
```
2.从通过NAT连接的主机ping10.1.1.11。
```
C:\Users\IVAN DU>ping 10.1.1.11
Pinging 10.1.1.11 with 32 bytes of data:
Reply from 10.1.1.11: bytes=32 time<1ms TTL=64
Reply from 10.1.1.11: bytes=32 time<1ms TTL=64
Reply from 10.1.1.11: bytes=32 time<1ms TTL=64
Reply from 10.1.1.11: bytes=32 time<1ms TTL=64
Ping statistics for 10.1.1.11:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
```
3.查看主机10.1.1.11的相关网络配置。默认情况下，CentOS7.4的配置如下：
```
[root@ChatDevOps ~]# sysctl net.ipv4.icmp_echo_ignore_all
net.ipv4.icmp_echo_ignore_all = 0
[root@ChatDevOps ~]# sysctl net.ipv4.icmp_echo_ignore_broadcasts
net.ipv4.icmp_echo_ignore_broadcasts = 1
```
4.修改配置，再次分别ping，观察结果。
```
[root@ChatDevOps ~]# sysctl net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_echo_ignore_all = 1
```
分别在10.1.1.12和NAT主机上ping10.1.1.11，结果如下：
```
[root@ChatDevOps ~]# ping 10.1.1.11
PING 10.1.1.11 (10.1.1.11) 56(84) bytes of data.
```
```
C:\Users\IVAN DU>ping 10.1.1.11
Pinging 10.1.1.11 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
Request timed out.
Ping statistics for 10.1.1.11:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss)
```
效果非常显著，立马不能ping了。

5.重启主机，查看设置是否依然生效。
```
Last login: Wed Jul 18 16:08:36 2018 from 10.1.1.1
[root@ChatDevOps ~]# sysctl net.ipv4.icmp_echo_ignore_all
net.ipv4.icmp_echo_ignore_all = 0
```
另外两台主机立马就能ping通了，效果立竿见影。

6.再次修改设置。
```
[root@ChatDevOps ~]# echo '1'>/proc/sys/net/ipv4/icmp_echo_ignore_all
[root@ChatDevOps ~]# cat /proc/sys/net/ipv4/icmp_echo_ignore_all 
1
[root@ChatDevOps ~]# sysctl net.ipv4.icmp_echo_ignore_all
net.ipv4.icmp_echo_ignore_all = 1
```
7.重启验证一下，刚刚修改的配置是否仍然有效。我就不再贴运行结果了，依然能ping通。

8.设置禁ping之后我们来检测一下开放的端口是否受影响。
```
[root@ChatDevOps ~]# ping 10.1.1.11
PING 10.1.1.11 (10.1.1.11) 56(84) bytes of data.
[root@ChatDevOps ~]# nmap 10.1.1.11
Starting Nmap 6.40 ( http://nmap.org ) at 2018-07-18 17:05 CST
Nmap scan report for 10.1.1.11
Host is up (0.00030s latency).
Not shown: 998 filtered ports
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
MAC Address: 00:0C:29:4C:37:1B (VMware)
Nmap done: 1 IP address (1 host up) scanned in 12.39 seconds
```
# 四、总结
1.很多人都认为禁止ping主机能增加主机的安全性，这个观点在某种程度来说是有一定道理的，但是在绝大部分情况下，禁止ping主机并不可取，可以通过其他很多方式来提高网络的安全性。

2.使用修改net.ipv4.icmp_echo_ignore_all的值及/proc/sys/net/ipv4/icmp_echo_ignore_all的方法禁用ping主机IP的方法在下次重启后会失效。如果在主机启动阶段或者用户登录阶段就禁用ping功能可以修改启动过程中的执行参数及登录后执行脚本。修改配置文件/etc/sysctl.conf，也可以实现永久禁止ping。命令如下：
```
[root@ChatDevOps ~]# echo "net.ipv4.icmp_echo_ignore_all = 0">>/etc/sysctl.conf 
[root@ChatDevOps ~]# sysctl -p
net.ipv4.icmp_echo_ignore_all = 1
```
当然也可能有其他方法，再此就不进一步讨论，没有较大参考价值。

3.当然，如果系统启用防火墙，也是可以永久阻止主机被ping了，可以参考如下命令：
```
[root@ChatDevOps ~]# firewall-cmd --permanent --add-rich-rule='rule protocol value=icmp drop'
success
[root@ChatDevOps ~]# firewall-cmd --reload
success
```
4.ping不通跟端口不通在某种情况下并不是一回事，大家也看到我上面的实验了，不要把这两者混为一谈。常用的端口检测工具有：Nmap、Zmap、Masscan，nmap我最常用。当然也可以直接用telnet。

5.写得仓促，不足之处希望诸位多多指教。
