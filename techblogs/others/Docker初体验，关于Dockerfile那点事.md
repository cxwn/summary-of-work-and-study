# 一、Dockerfile的格式
Dockerfile的格式如下：
> \# Comment

以“#”开头的行为注释行。跨行注释也必须加“#”，Dockerfile不支持连续字符“\”。命令解析指令也是以“#”开头，命令解析器是一个可选项，位于Dockerfile的首行，只允许出现一次，第二次出现则被认为是注释，在解析器中换行符同样是不被支持的，但是其中的非断行空格是允许的。
```
#directive=value
# directive =value
#   directive= value
# directive = value 
```
> \# escap

Escape在dockerfile中被用作转义字符和换行符，如果不特别指定，系统默认的转义字符为：\ (反斜杠)。转义不能在RUN命令中执行，除非位于行末进行格式换行。作为换行符时，escape允许Dockerfile指令跨行执行。反引号在Windows下非常有用（举例可以参阅[官方文档](https://docs.docker.com/engine/reference/builder/#escape)）
```
# escape=\ (反斜杠)
或
# escape=` (反引号)
```
>INSTRUCTION arguments

INSTRUCTION一般被称为指令或者命令，对大小写不敏感，为了与其他参数区别开，习惯大写。
>.dockerfileignore file

使用Dockerfile构建镜像时最好是将Dockerfile放置在一个新建的空目录下。然后将构建镜像所需要的文件添加到该目录中。为了提高构建镜像的效率，你可以在目录下新建一个.dockerignore文件来指定要忽略的文件和目录。.dockerignore文件的排除模式语法和 Git的.gitignore文件相似。
# 二、相关指令详解
>FROM

每个Dockerfile必须以FROM指令开头，FROM指明了当前镜像创建的基镜像，也就是说每个镜像必须基于一个已存在的镜像进行创建。FROM指令后直接跟基镜像的名称或者镜像名称加标签。镜像的名称和标签可以去Docker Hub或者使用命令docker search keyword 进行搜索。用法如下：
```
FROM <image>
```
或
```
FROM <image>[:<tag>] 
```

>ARG

ARG指令定义了用户可以在创建镜像时或者运行时传递的变量，申明于调用类似于shell中的变量申明与定义。
```
ARG  CODE_VERSION=latest
FROM base:${CODE_VERSION}
```

>ENV

ENV指令用来定义镜像的环境变量，并且可以引用已经存在的环境变量，例如：HOME、HOSTNAME、PATH。ENV的值跟ARG指令申明的变量一样可以传递、被引用，定义方法也基本一致。
```
FROM busybox
ENV foo /bar

# WORKDIR /bar
WORKDIR ${foo}
```
Dockerfile中的ENV支持以下变量的访问：ADD、COPY、ENV、EXPOSE、FROM、LABEL、STOPSIGNAL、USER、VOLUME、WORKDIR。

>RUN

RUN指令在当前镜像的顶层中执行命令并提交结果，新产生的镜像用于下一步的Dockerfile。分层执行指令和生成提交符号Docker的核心概念，提交很方便，容器可以从镜像历史中的任意点创建，类似于源码控制。在shell形式中，可以使用\（反斜杠）将单个RUN指令继续到下一行。RUN指令有两种使用格式：
```
RUN <command>（shell形式，该命令在shell中运行，默认情况下/bin/sh -c在Linux中运行，cmd /S /CWindows中运行）
RUN ["executable", "param1", "param2"]（exec执行形式）
```
```
[root@ChatDevOps ~]# cat Dockerfile 
FROM centos
RUN mkdir /chatdevops
RUN ["touch","/chatdevops/chatdevops.log"]
RUN /bin/bash 
[root@ChatDevOps ~]# docker run -it --name chatdevops chatdevops /bin/bash
[root@99484f802e71 /]# ll /chatdevops/chatdevops.log 
-rw-r--r--. 1 root root 0 May 29 03:00 /chatdevops/chatdevops.log
```
>CMD

CMD的主要是为一个正运行的容器提供默认执行命令。如果存在多个CMD指令，那么只有最后一个会被执行。如果在容器运行时指定了命令，则CMD指定的默认内容会被替代。CMD一共有三种格式：
```
CMD ["executable","param1","param2"]  #(执行形式，这是比较常见的一种形式)
CMD ["param1","param2"] #(以json数组的形式将两个参数存储下来，在指定了ENTRYPOINT		指令后，用CMD指定具体的参数，此处必须用双引号将涉及到的变量引起来)
CMD command param1 param2 #(shell形式)
```
```
[root@ChatDevOps ~]# cat Dockerfile 
FROM centos
CMD echo "chatdevops"
CMD ["echo","Hello world"]
[root@ChatDevOps ~]# docker run -it --rm --name chatdevops chatdevops
Hello world
```
>ENTRYPOINT

ENTRYPOINT的格式和RUN指令格式一样，分为exec格式和shell格式。ENTRYPOINT的目的和CMD一样，都是在指定容器启动程序及参数。ENTRYPOINT在运行时 也可以替代，不过比CMD要略显繁琐，需要通过docker	run的参数--entrypoint来指定。
当指定了ENTRYPOINT后，CMD的含义就发生了改变，不再是直接的运行其命令，而是将CMD的内容作为参数传给ENTRYPOINT指令。
```
[root@ChatDevOps ~]# cat Dockerfile 
FROM ubuntu:18.04
RUN apt-get update \
 && apt-get install -y curl \
 && rm -rf /var/lib/apt/lists/*
ENTRYPOINT [ "curl","-s","http://ip.cn" ]
[root@ChatDevOps ~]# docker run e317e4042076
当前 IP：71.184.25.21 来自：北京市 
[root@ChatDevOps ~]# docker run e317e4042076 -i
HTTP/1.1 200 OK
Date: Tue, 29 May 2018 09:00:10 GMT
Content-Type: text/html; charset=UTF-8
Transfer-Encoding: chunked
Connection: keep-alive
Set-Cookie: __cfduid=d4439884e43e37c36aac129e9f4d0507f1527584410; expires=Wed, 29-May-19 09:00:10 GMT; path=/; domain=.ip.cn; HttpOnly
Server: cloudflare
CF-RAY: 4227c4e460886d9c-SJC
```
	 
>LABEL

LABEL指令用于添加一个元数据到镜像，键和值配对存在。例如可以给容器添加辅助说明信息。值中支持换行字符斜杠（\）。如果Docker中出现重复的键，则新的值会覆盖原来的值。为了减少Docker的层数，可以在单一LABEL指令中指定多个标签：
```
LABEL multi.label1="value1" \
      multi.label2="value2" \
      other="value3"
```

>MAINTAINER 

MAINTAINER在新版本中已经废弃，可以使用LABEL来替代MAINTAINER进行声明。

>EXPOSE

EXPOSE指定容器在运行中监听的端口。默认情况下，EXPOSE指定的是TCP端口，若要指定监听udp端口：
```
EXPOSE 80/udp
```
>COPY

COPY能够从构建上下文中复制文件到新的一层中镜像中，COPY指令有两种形式：
```
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```
chown属性只支持Linux容器的构建。COPY命令支持通配符，可以把多个源文件复制到目标文件下。
>ADD

ADD的格式和用法基本与COPY一致，并在COPY的基础上新增了一些功能。ADD的源文件可以是一个URL。如果本地源路径的文件为一个tar压缩文件的话，压缩格式为gzip,bzip2以及xz的情况 下，ADD指令将会自动解压缩这个压缩文件到目标路径，来自于URL的远程文件则不会被解压。

>VOLUME

VOLUME旨在创建一个具有名称的挂载点。容器在运行时尽量保持存储层不发生数据写入操作。一个卷可以存在于一个或多个容器的特定目录，这个目录可以绕过联合文件系统，并提供数据共享或数据持久化功能。卷可以在容器间共享或重用，对卷的修改是及时生效的。对卷的修改不会对新的镜像产生影响，卷会一直存在直到没有容器使用它。可以使用数组的形式指定多个卷。使用方式如下：
```
VOLUME /data
VOLUME ["/data"]
VOLUME ["data","test","chatdevops"]
```
VOLUME也可以在创建容器时进行声明：
```
[root@ChatDevOps docker]# docker run -it -v /myvolume --name myvolume  chatdevops
```
以上命令创建一个名为myvolume的容器，同时挂载/myvolume。/myvolume在之前并不存在，在创建myvolume时同时创建了该目录。
>USER

USER指令为Dockerfile中全部RUN，CMD，ENTRYPOINT设置运行Image时使用的用户名或UID。这个用户或组必须事先在系统中存在。若不存在则下一层镜像以root用户进行执行。
```
USER <user>[:<group>]
USER <UID>[:<GID>]
```
>WORKDIR

WORKDIR用来为Dockerfile下文中的RUN, CMD, ENTRYPOINT, COPY和ADD等指令指定当前工作目录。如果存在多个WORKDIR则以指令钱最近的一条为参考。如果该目录不存在，则系统会自动创建该目录。如果要改变当前的工作目录，不能使用cd命令来切换，需要使用WORKDIR来进行切换。

>ONBUILD 

这是一个特殊的指令，它后面跟的是其它指令，比如 RUN , COPY等，而这些指令，
在当前镜像构建时并不会被执行。只有当以当前镜像为基础镜像，去构建下一级镜像的时候才会被执行。

>STOPSIGNAL

STOPSIGNAL指令设置唤醒信号并将其发送到容器后退出。后跟信号值（无符号整数）或者SIGNAME格式的信号名称，例如SIGKILL。
```
STOPSIGNAL signal
```
>HEALTHCHECK

Docker提供了HEALTHCHECK指令，通过该指令指定一行命令，用这行命令来判断容器主进程的服务状态是否还正常，从而比较真实的反应容器实际状态。当在一个镜像指定了HEALTHCHECK指令后，用其启动容器，初始状态会为 starting ，在HEALTHCHECK指令检查成功后变为healthy，如果连续一定次数失败，则会变为
unhealthy。格式如下：
```
    HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
    HEALTHCHECK NONE (disable any healthcheck inherited from the base image)
```
HEALTHCHECK 支持下列选项：
- --interval=<间隔> ：两次健康检查的间隔，默认为 30 秒；
- --timeout=<时长> ：健康检查命令运行超时时间，如果超过这个时间，本次健康检查就被视为失败，默认 30 秒；
- --retries=<次数> ：当连续失败指定次数后，则将容器状态视为 unhealthy ，默认3次。

HEALTHCHECK在Dockerfile中只能出现一次，如果出现多次则最后一个生效。
>SHELL

SHEELL指令允许默认的shell形式被命令形式覆盖。在Linux系统中默认shell形式为 [“/bin/sh”, “-c”], 在 Windows上是[“cmd”, “/S”, “/C”]。SHELL指令必须用Dockerfile中的JSON格式写入。SHELL指令在Windows上特别有用，其中有两个常用的和完全不同的本机shell：cmd和powershell，以及包括sh的备用shell。 SHELL指令可以出现多次。每个SHELL指令都会覆盖所有以前的SHELL指令，并影响所有后续指令。

# 三、参考文献
https://docs.docker.com/engine/reference/builder/#usage
