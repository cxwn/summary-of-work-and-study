# Docker 镜像多阶段构建实战总结

## 一 背景

通常情况下，构建镜像通常会采用两种方式：

1. 将全部组件及其依赖库的编译、测试、打包等流程封装进一个 Docker 镜像中。采用这种方式往往忽略了以下这些问题：
   - Dockefile 特别长，可维护性降低。
   - 镜像的层次多，体积大，部署时间长。
   - 源代码存在泄漏的风险。
2. 分散到多个 Dockerfile。事先在一个 Dockerfile 将项目及其依赖库编译测试打包好后，再将其拷贝到运行环境中，这种方式需要我们编写两个 Dockerfile 和一些编译脚本才能将其两个阶段自动整合起来，这种方式虽然可以很好地规避第一种方式存在的风险，但明显部署过程较复杂。

为了解决以上这些问题，Docker v17.05 开始支持多镜像阶段构建 (multistage builds)。只需要编写一个 Dockerfile 即可。通过一段简单的 C 语言代码的编译、执行来具体演示。demo.c 的内容如下：

```c
# include<stdio.h>
int main()
{
  printf("%s\n","This is a demo!");
  return 0;
}
```

## 二 实践步骤

### 2.1 只通过一个 Dockerfile 来构建【方案一】

查看对应的 Dockerfile:

```Dockerfile
FROM centos:7.8.2003

ENV VERSION 1.0

WORKDIR /demo

COPY demo.c .

RUN yum install -y gcc && \
    gcc -v
RUN gcc demo.c -o demo && \
    rm -f demo.c && \
    yum erase -y gcc && \
    cp demo /usr/local/bin/

CMD ["demo"]
```

感兴趣的小伙伴可以直接将上面的 Dockerfile 和 docker-entrypoint.sh 在本地构建目录创建，执行 `docker build -t redis:6.0.5-buster` 进行尝试。

### 2.2 多个 Dockerfile 实现多阶段构建【方案二】

多阶段构建一般需要多个 Dockerfile 来完成，由于我们只需要源码编译后的产物。所以我们第一个阶段可以直接使用上文中镜像构建后的产物。第二阶段的 Dockerfile 内容如下：

```dockerfile
FROM centos:7.8.2003

ENV VERSION 1.0

WORKDIR /demo

COPY demo /usr/local/bin

CMD ["demo"]
```

执行构建脚本 `bash build.sh`, `build.sh` 的内容如下：

```bash
#!/bin/bash
cd stage-1
docker create --name bin demo:1.0
cd ../stage-2
docker cp bin:/usr/local/bin/demo .
docker rm -f bin
docker build -t demo:2.0 .
```

构建后得到的 Docker 容器运行结果：

```bash
$ docker run --rm -it demo:1.0
This is a demo!
$ docker run --rm -it demo:2.0
This is a demo!
```

两个容器的环境变量：

```bash
$ docker run --rm -it demo:1.0 env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=a52af1bec0af
TERM=xterm
VERSION=1.0
HOME=/root
$ docker run --rm -it demo:2.0 env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=f6618fd1244b
TERM=xterm
VERSION=2.0
HOME=/root
```

### 2.3 一个 Dockerfile 实现多阶段构建【方案三】

```dockerfile
FROM centos:7.8.2003

ENV VERSION 1.0

WORKDIR /demo

COPY demo.c .

RUN yum install -y gcc && \
    gcc -v
RUN gcc demo.c -o demo && \
    rm -f demo.c && \
    yum erase -y gcc && \
    cp demo /usr/local/bin/

FROM centos:7.8.2003
COPY --from=0 /usr/local/bin/demo /usr/local/bin/demo

CMD ["demo"]
```

这种方式构建的 Docker 容器运行结果：

```bash
$ docker run --rm -it demo:3.0
This is a demo!
```

```bash
$ docker run --rm -it demo:3.0 env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=7839b3d568db
TERM=xterm
HOME=/root
```

三个镜像大小对比：

```bash
$ docker images|grep demo
demo                3.0                  8766031d380a        39 seconds ago           203MB
demo                2.0                  7d9c479cb421        10 minutes ago           203MB
demo                1.0                  af331209572f        38 minutes ago           350MB
```

## 三 总结

- 3.1 通过观察，方案一构建得到镜像远比方案二和方案三大得多，方案二和方案三的镜像一样大小。
- 3.2 方案三并不会继承第一阶段构建的镜像的环境变量等配置，仅仅是复制了第一阶段的构建成果，需要特别注意。

## 四 参考文档

- 4.1 [官方文档-快速开始](https://redis.io/topics/quickstart)
- 4.2 [Docker Hub官方镜像](https://hub.docker.com/_/redis)
- 4.3 [GitHub 官方仓库](https://github.com/docker-library/redis)
- 4.4 [10 Docker Security Best Practices](https://snyk.io/blog/10-docker-image-security-best-practices)
- 4.5 [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices)
