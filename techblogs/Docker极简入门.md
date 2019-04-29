#### 一、Docker概述
Docker通过一个包括应用程序运行时所需的一切的可执行镜像启动容器，包括配置有代码、运行时、库文件、环境变量和配置文件等。

1.文件系统隔离：每个容器都有自己得root文件系统。

2.进程隔离：每个容器都运行再自己得进程环境中。

3.容器间得虚拟网络接口和IP地址都是分开的。

4.资源隔离和分组：使用cgroup将CPU和内存之类的资源独立分配给每个Docker容器。

5.写时复制：文件系统都是通过写时复制创建的，这就意味着文件系统是分层的、快速的，并且占用磁盘空间小。

6.日志：容器产生的STDOUT、STDIN和STDERR这些IO流都会被收集并记入日志，用来进行日志分析和故障排除。

7.交互式shell：用户可以创建一个伪tty终端、将其连接到STDIN，为容器提供一个交互式shell。

8.灵活性：大多数应用程序均能被装箱。

9.轻量级：容器利用并共享主机内核。

10.可交互：可以即时的更新和升级。

11.可移植：一处构建，到处运行。

12.可扩展性：可以增加和分发容器副本。

#### 二、Docker容器的安装与入门
1.Docker的安装过程很简单，本次试验是在CentOS7.4中进行的，因此不存在内核版本及系统平台不支持的情况。简单的安装配置如下：
```
[root@ChatDevOps ~]# yum -y install docker
[root@ChatDevOps ~]# docker --version
Docker version 1.13.1, build 94f4240/1.13.1
[root@ChatDevOps ~]# systemctl start docker
[root@ChatDevOps ~]# systemctl status docker
[root@ChatDevOps ~]# systemctl enable docker
[root@ChatDevOps ~]# docker info

```
2.docker info：返回所有容器和镜像的数量、Docker使用的执行驱动和存储驱动及Docker的基本配置。
```
[root@ChatDevOps ~]# docker info
Containers: 15
 Running: 1
 Paused: 0
 Stopped: 14
Images: 4
Server Version: 1.13.1
... ...
```
3.docker images：列出当前系统中本地镜像。例如，列出本地镜像中REPOSITORY为ubuntu的镜像：
```
[root@ChatDevOps ~]# docker images ubuntu
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
docker.io/ubuntu    latest              452a96d81c30        3 weeks ago         79.6 MB
```
这个命令也相当于：
```
[root@ChatDevOps ~]# docker image ls
```
4.docker ps：列出所有正在运行的容器。
```
[root@ChatDevOps ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
e93e508dbc38        centos              "/bin/bash"         2 hours ago         Up 2 minutes                            fervent_turing
```
这个命令也类似于：
```
[root@ChatDevOps ~]# docker container ls
```
加上选项-a则列出的是所有的容器，包括正在运行的和未运行的。加选项-n则代表列出前n个容器，n后面跟需要列出的容器的个数。
```
[root@ChatDevOps ~]# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
dfd4fe17d6ce        httpd               "/bin/bash"         2 hours ago         Exited (0) 43 minutes ago                       stoic_gates
7b4ddbb18811        ubuntu              "/bin/bash"         2 hours ago         Exited (0) 43 minutes ago                       priceless_bassi
e93e508dbc38        centos              "/bin/bash"         2 hours ago         Up About a minute                               fervent_turing
[root@ChatDevOps ~]# docker ps -n 10
```
同样，加了选项-a也类似于：
```
[root@ChatDevOps ~]# docker container ls --all -n 10
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                    PORTS               NAMES
07939dcd012d        centos              "/bin/bash"         15 hours ago        Exited (0) 15 hours ago                       eloquent_engelbart
[root@ChatDevOps ~]# docker container ls -a -n 1
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                    PORTS               NAMES
07939dcd012d        centos              "/bin/bash"         15 hours ago        Exited (0) 15 hours ago                       eloquent_engelbart
```
docker run：创建一个新的容器并运行一个命令。
```
[root@ChatDevOps ~]# docker run --name ivandu -i -t  centos /bin/bash
[root@009c8df5e30d /]# 
```
上面例子中创建了一个名为ivandu的容器。Docker首先检查本地是否存在镜像centos，如果不存在，则会连接到Docker官方维护的Docker Hub Registry，查看Docker Hub是否存在该镜像，如果存在则下载该镜像并保存到本地宿主机。选项-i表示容器的stdin是开启的，选项-t表示为要被创建的容器分配一个伪tty终端，centos表示创建这个容器使用的是centos这个镜像，/bin/bash表示容器创建完成之后执行容器中的该命令。选项-d则会将容器置于后台运行。

5.docker start：启动一个容器，可以是容器的ID和名称（NAMES）。
```
[root@ChatDevOps ~]# docker start dfd4fe17d6ce
dfd4fe17d6ce
[root@ChatDevOps ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
dfd4fe17d6ce        httpd               "/bin/bash"         4 hours ago         Up 10 seconds       80/tcp              stoic_gates
e93e508dbc38        centos              "/bin/bash"         4 hours ago         Up 2 hours                              fervent_turing
[root@ChatDevOps ~]# docker start stoic_gates
stoic_gates
[root@ChatDevOps ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
dfd4fe17d6ce        httpd               "/bin/bash"         4 hours ago         Up 8 minutes        80/tcp              stoic_gates
e93e508dbc38        centos              "/bin/bash"         5 hours ago         Up 2 hours                              fervent_turing
```
同理，docker stop及docker restart的用法大同小异。

6.docker attach：可以进入一个已经在运行的容器。命令后面的容器id也可以换成容器名称。需要注意的是，如果退出容器的shell，容器也会随之停止运行。
```
[root@ChatDevOps ~]# docker start 7b4ddbb18811
7b4ddbb18811
[root@ChatDevOps ~]# docker attach 7b4ddbb18811
root@7b4ddbb18811:/# cat /etc/issue
Ubuntu 18.04 LTS \n \l
root@7b4ddbb18811:/# exit
[root@ChatDevOps ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```
7.docker rm：删除一个已经停止的容器。如果这个容器正在运行，需要先停止该容器的运行或者使用选项-f进行强制删除。
```
[root@ChatDevOps ~]# docker rm -f 009c8df5e30d
009c8df5e30d
```
**一次性删除所有的容器**：
```
[root@ChatDevOps ~]# docker rm `docker ps -a -q`
```
8.docker logs：获取容器的日志，我们可以通过该日志了解容器内部正在进行什么样的操作。可以跟选项-f，类似于tail命令，显示日志最后部分。选项-t则为每条日志加上了时间戳。
```
[root@ChatDevOps ~]# docker logs -tf  dfd4fe17d6ce
2018-05-22T05:35:24.196281000Z root@dfd4fe17d6ce:/usr/local/apache2# exit
root@dfd4fe17d6ce:/usr/local/apache2# 
2018-05-22T08:56:00.809591000Z root@dfd4fe17d6ce:/usr/local/apache2# ls
2018-05-22T08:56:00.811456000Z bin  build  cgi-bin  conf  error  htdocs  icons  include  logs	modules
2018-05-22T08:56:06.779932000Z root@dfd4fe17d6ce:/usr/local/apache2# ps -aux
2018-05-22T08:56:06.782810000Z USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
2018-05-22T08:56:06.783173000Z root          1  0.0  0.1  20236  1980 ?        Ss   08:40   0:00 /bin/bash
2018-05-22T08:56:06.783462000Z root          6  0.0  0.1  17492  1144 ?        R+   08:56   0:00 ps -aux
2018-05-22T08:56:19.520653000Z root@dfd4fe17d6ce:/usr/local/apache2# httpd -k start
2018-05-22T08:56:19.550996000Z AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.3. Set the 'ServerName' directive globally to suppress this message
2018-05-22T08:57:01.656035000Z root@dfd4fe17d6ce:/usr/local/apache2# cat /etc/issue       
2018-05-22T08:57:01.656305000Z Debian GNU/Linux 8 \n \l
2018-05-22T08:57:01.656609000Z 
2018-05-22T08:57:07.888609000Z root@dfd4fe17d6ce:/usr/local/apache2# exit
2018-05-22T08:57:07.888981000Z exit
```
9.docker top：查看正在运行的容器内部的进程运行情况。停止的容器并不支持此法进行查看。
```
[root@ChatDevOps ~]# docker start 7bc9a41a53cd
7bc9a41a53cd
[root@ChatDevOps ~]# docker top 7bc9a41a53cd
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                6869                6855                0                   17:26               pts/0               00:00:00            /bin/bash
```

10.docker exec：在一个运行中的容器内部执行命令或者进入一个正在运行的容器内。选项-d表示命令在后台执行，-d后跟容器名和要执行的命令。也可以通过选项-i和-t搭配使用进入一个正在运行的容器，与attach不同的是，如果退出容器的shell，该容器并不会停止运行。
```
[root@ChatDevOps ~]# docker exec -d 7bc9a41a53cd touch /home/ChatDevOps.log
[root@ChatDevOps ~]# docker exec -i -t 7bc9a41a53cd /bin/bash
[root@7bc9a41a53cd /]# ll /home/ChatDevOps.log 
-rw-r--r--. 1 root root 0 May 22 09:40 /home/ChatDevOps.log
```
11.docker inspect：返回一个低水平的Docker对象信息。可以用选项-f或--format来获取选定结果。支持完整的go语音模板，可以充分利用go语音的优势。
```
[root@ChatDevOps ~]# docker inspect dfd4fe17d6ce
[
    {
        "Id": "dfd4fe17d6ce1e17ca55e741c6979b16b32383c909ad2145f1c1fcb231612ecf",
        "Created": "2018-05-22T04:03:10.289044219Z",
        "Path": "/bin/bash",
        "Args": [],
        "State": {
        ... ...
[root@ChatDevOps ~]# docker inspect --format='{{.State.Running}}' dfd4fe17d6ce 
false
[root@ChatDevOps ~]# docker inspect --format='{{.NetworkSettings.IPAddress}}' 7bc9a41a53cd
172.17.0.2
```
12.docker kill：杀死一个或多个正在运行的容器。
```
[root@ChatDevOps ~]# docker kill 7bc9a41a53cd
7bc9a41a53cd
```

#### 三、总结
通过本篇，我们了解了Docker的优点及简单入门知识。文中并未进行大量详细的原理性的内容阐述，主要通过实践来演示一入门常用的一些命令及其使用注意事项。以此来加深对Docker原理的理解。本篇博文是来北京工作后的第一篇文章，纪念一下。
