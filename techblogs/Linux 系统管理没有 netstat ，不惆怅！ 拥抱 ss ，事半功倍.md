# Linux 系统管理没有 netstat ，不惆怅！ 拥抱 ss ，事半功倍

## 一 背景

在目前众多较新的 Linux 发行版中，已经移除了 net-tools 套件，ifconfig、route、netstat、arp 等一系列工具均无法使用。缺少这些工具，在对系统进行管理时，会不会变得举步维艰呢？

答案是：不会。官方既然删除了 net-tools 套件，就会有新的替代方案。比如：在 CentOS 7.6 中，官方就使用了 iproute-4.11.0-14.el7.x86_64 替代了 net-tools 相关版本。新的工具 ip 代替了 ifconfig, ss 代替了 netstat。这两个工具都是系统管理中非常重要的工具。接下来将在 CentOS Linux release 7.6.1810 (Core) 对 ss 工具进行实践。

## 二 认识 ss

ss 是 socket statistics 的缩写。顾名思义，ss 命令可以用来获取socket 统计信息，它可以显示与 netstat 类似的内容。但 ss 的优势在于它能够显示更多更详细的有关TCP和连接状态的信息，而且比netstat更快速更高效。

当服务器的socket连接数量变得非常大时，无论是使用netstat命令还是 cat  /proc/net/tcp，执行速度都会很慢。可能你不会有切身的感受，但请相信我，当服务器维持的连接达到上万个的时候，使用 netstat 等于浪费生命，而用 ss 才是最正确的选择。

天下武功唯快不破。 ss 快的秘诀在于，他利用了TCP协议栈中 tcp_diag. tcp_diag 是一个用于分析统计的模块，可以获得 Linux 内核中第一手的信息，这就确保了ss的快捷高效。当然，如果你的系统中没有 tcp_diag, ss 也可以正常运行，只是效率会变得稍慢，但仍然比 netstat 要快。

说到这里，大家是不是非常激动了？是不是都想跃跃欲试了？

按照常规 Linux 学习路线，我们先查看一下系统帮助。

```text
Usage: ss [ OPTIONS ]
       ss [ OPTIONS ] [ FILTER ]
   -h, --help          this message
   -V, --version       output version information
   -n, --numeric       don't resolve service names # 不解析服务名称
   -r, --resolve       resolve host names # 不解析主机名
   -a, --all           display all sockets # 显示所有的 sockets
   -l, --listening     display listening sockets # 显示监听的 sockets
   -o, --options       show timer information # 显示定时器信息
   -e, --extended      show detailed socket information # 显示详细的 socket 信息
   -m, --memory        show socket memory usage # 显示内存的使用情况
   -p, --processes     show process using socket # 显示使用套接字的进程
   -i, --info          show internal TCP information # 显示 tcp 内部信息
   -s, --summary       show socket usage summary # 显示套接字（socket）使用概况
   -b, --bpf           show bpf filter socket information
   -E, --events        continually display sockets as they are destroyed
   -Z, --context       display process SELinux security contexts
   -z, --contexts      display process and socket SELinux security contexts
   -N, --net           switch to the specified network namespace name

   -4, --ipv4          display only IP version 4 sockets # 仅显示 IPv4 的套接字
   -6, --ipv6          display only IP version 6 sockets # 仅显示 IPv6 的套接字
   -0, --packet        display PACKET sockets # 显示 PACKET 套接字
   -t, --tcp           display only TCP sockets # 仅显示 TCP 套接字
   -S, --sctp          display only SCTP sockets # 仅显示 SCTP 套接字
   -u, --udp           display only UDP sockets # 仅显示  UDP 套接字
   -d, --dccp          display only DCCP sockets # 仅显示 DCCP 套接字
   -w, --raw           display only RAW sockets # 仅显示  RAW 套接字
   -x, --unix          display only Unix domain sockets # 仅显示 Unix 套接字
       --vsock         display only vsock sockets
   -f, --family=FAMILY display sockets of type FAMILY
       FAMILY := {inet|inet6|link|unix|netlink|vsock|help} # 显示 FAMILY 类型的套接字，FAMILY可选  Unix， inet, inet6, link ,  netlink

   -K, --kill          forcibly close sockets, display what was closed
   -H, --no-header     Suppress header line

   -A, --query=QUERY, --socket=QUERY
       QUERY := {all|inet|tcp|udp|raw|unix|unix_dgram|unix_stream|unix_seqpacket|packet|netlink|vsock_stream|vsock_dgram}[,QUERY]

   -D, --diag=FILE     Dump raw information about TCP sockets to FILE
   -F, --filter=FILE   read filter information from FILE # 从文件中都去过滤信息
       FILTER := [ state STATE-FILTER ] [ EXPRESSION ]
       STATE-FILTER := {all|connected|synchronized|bucket|big|TCP-STATES}
         TCP-STATES := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|last-ack|listen|closing}
          connected := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}
       synchronized := {established|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}
             bucket := {syn-recv|time-wait}
                big := {established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listen|closing}
```

## 三 操作步骤

### 3.1 显示系统内的 TCP 连接

**命令**：ss -at

**结果**：

```log
State       Recv-Q Send-Q                                        Local Address:Port                                                         Peer Address:Port
LISTEN      0      128                                                       *:ssh                                                                     *:*
```

### 3.2 显示 socket 摘要

**命令**：ss -s
**结果**：

```log
Total: 558 (kernel 1020)
TCP:   5 (estab 1, closed 0, orphaned 0, synrecv 0, timewait 0/0), ports 0

Transport Total     IP        IPv6
*         1020      -         -
RAW       1         0         1
UDP       2         1         1
TCP       5         3         2
INET      8         4         4
FRAG      0         0         0
```

### 3.3 显示监听的 sockets

**命令**：ss -l
**结果**：

```log
Netid State      Recv-Q Send-Q                                      Local Address:Port                                                       Peer Address:Port
nl    UNCONN     0      0                                                    rtnl:NetworkManager/13282                                                   *
nl    UNCONN     0      0                                                    rtnl:kernel                                                                 *                                                             *
```

### 3.4 显示进程使用的 sockets

**命令**：ss -lp
**结果**：

```log
Netid  State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port
nl     UNCONN     0      0      audit:auditd/3760            *
u_dgr  UNCONN     0      0      /var/run/chrony/chronyd.sock 26487                 * 0                     users:(("chronyd",pid=3918,fd=5))
udp    UNCONN     0      0         ::1:323                  :::*                     users:(("chronyd",pid=3918,fd=2))
u_seq  LISTEN     0      128    /run/udev/control 18173                 * 0                     users:(("systemd-udevd",pid=2040,fd=3),("systemd",pid=1,fd=42))
```

### 3.5 显示所有 UDP 监听的 socket

**命令**：ss -au
**结果**：

```log
State       Recv-Q Send-Q                                        Local Address:Port                                                         Peer Address:Port
UNCONN      0      0                                                 127.0.0.1:323                                                                     *:*
UNCONN      0      0                                                       ::1:323                                                                    :::*
```

### 3.6 显示 dst IP 为 172.31.2.25 且状态为 established  的 TCP 连接，同时显示 timer

**命令**：ss -t -o state established dst 172.31.2.25
**结果**：

```log
Recv-Q Send-Q                                             Local Address:Port                                                              Peer Address:Port
0      64                                                  172.31.2.101:ssh                                                                172.31.2.25:61159                 timer:(on,461ms,0)
```

### 3.7 显示 src IP 为 172.31.2.101 且状态为 established  的 TCP 连接，同时显示 timer

**命令**：ss -ato state established src 172.31.2.102
**结果**：

```log
Recv-Q Send-Q Local Address:Port                 Peer Address:Port
0      64     172.31.2.102:ssh                  172.31.2.25:61179                 timer:(on,398ms,0)
```

state 可以参考以下：

```txt
       STATE-FILTER := {all|connected|synchronized|bucket|big|TCP-STATES}
         TCP-STATES := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|closed|close-wait|last-ack|listen|closing}
          connected := {established|syn-sent|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}
       synchronized := {established|syn-recv|fin-wait-{1,2}|time-wait|close-wait|last-ack|closing}
             bucket := {syn-recv|time-wait}
                big := {established|syn-sent|fin-wait-{1,2}|closed|close-wait|last-ack|listen|closing}
```

### 3.8 匹配远程地址和端口号

**命令**：ss dst 172.31.2.25:61895
**结果**：

```log
Netid State      Recv-Q Send-Q                                      Local Address:Port                                                       Peer Address:Port
tcp   ESTAB      0      64                                           172.31.2.100:ssh                                                         172.31.2.25:61895
```

不指定端口号则匹配所有，查看本地的以此类推。

### 3.9  显示所有 IPv4 监听在 TCP 端口的进程

**命令**： ss -a4tlp
**结果**：

```log
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port
LISTEN     0      128        *:ssh                      *:*                     users:(("sshd",pid=4716,fd=3))
LISTEN     0      100    127.0.0.1:smtp                     *:*                     users:(("master",pid=4926,fd=13))
```

我们很方便的就能从结果中找到相关的有用信息，比如：pid，fd。

## 四 总结

4.1 ss 是 Linux 中非常有用的工具，在系统管理过程中很有必要掌握。

4.2 拥抱改变，接受现实，用学习来迎接新的挑战，没有了 netstat， 我们使用 ss 工具一样能完成之前的工作。