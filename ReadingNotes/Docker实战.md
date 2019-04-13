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