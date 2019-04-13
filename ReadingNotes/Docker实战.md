# Docker 实战

1. A 容器名称为：AA，缺少相关调试工具，比如：top，先需要对 A 容器进行调试，可使用 --pid 选项从另外一个包含该工具的镜像创建一个容器进行调试。命令格式如下：

```bash
docker run -it --rm --pid=container:AA NewImage /bin/bash
```