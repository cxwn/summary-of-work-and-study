# Docker 实战

1.A 容器名称为：AA，缺少相关调试工具，比如：top，先需要对 A 容器进行调试，可使用 --pid 选项从另外一个包含该工具的镜像创建一个容器进行调试。命令格式如下：

```bash
docker run -it --rm --pid=container:AA NewImage /bin/bash
```

2.Docker 中 stop 和 kill 的区别：kill 直接执行 kill -9，强行终止；stop 先给容器发送一个 TERM 信号，让容器做一些退出前必须的保护性、安全性操作，然后让容器自动停止运行。如果在一段时间内，容器还是没有停止，那么再进行 kill -9，强行终止。

3.将创建的容器的 ID 写入指定文件： --cidfile /${CustomFile} ,例如：

```bash
docker run -it --rm --cidfile ~/cid.txt centos:7.4.1708
```

需要注意的是：该文件末尾无空格也无换行符。如果该文件已经存在，无论该文件是否为空，那么是无法创建新容器的。

4.使用了 host 网络模式的容器不再支持 -p 选项指定暴露端口，直接由原容器进程绑定的端口向外暴露端口。

5.Docker 中，支持多个主机端口同时映射到同一个容器端口。如：

```bash
docker run -itd -p 8089:80 -p 8090:80 --rm httpd:latest
```

6.Docker 中，docker port container_name/id 可以直接获取容器内端口映射关系。如：

```bash
 docker port 52
```

显示如下：

```text
80/tcp -> 0.0.0.0:8090
80/tcp -> 0.0.0.0:8089
```

7.Docker 中，--expose 可以增加一个对外暴露的端口。如：

```bash
docker run -it --rm --expose 8080 --expose 8088 httpd:latest
```

8.Docker 中，--icc=false 选项可以禁止容器间通信。