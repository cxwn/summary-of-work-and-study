# Docker 镜像多阶段构建最佳实践（包含gcc版本升级）

## 一 背景

通常情况下，构建镜像通常会采用两种方式：

1. 将全部组件及其依赖库的编译、测试、打包等流程封装进一个 Docker 镜像中。采用这种方式往往忽略了以下这些问题：
   - Dockefile 特别长，可维护性降低。
   - 镜像的层次多，体积大，部署时间长。
   - 源代码存在泄漏的风险。
2. 分散到多个 Dockerfile。事先在一个 Dockerfile 将项目及其依赖库编译测试打包好后，再将其拷贝到运行环境中，这种方式需要我们编写两个 Dockerfile 和一些编译脚本才能将其两个阶段自动整合起来，这种方式虽然可以很好地规避第一种方式存在的风险，但明显部署过程较复杂。

为了解决以上这些问题，Docker v17.05 开始支持多镜像阶段构建 (multistage builds)。只需要编写一个 Dockerfile 即可。本文将以 Redis 镜像的构建为例来进行验证。

## 二 实践步骤

### 2.1 只通过一个 Dockerfile 来构建

### 2.2 多个 Dockerfile 实现多阶段构建

Dockerfile-1:

```dockerfile
FROM    centos:7.8.2003
WORKDIR /usr/local/redis
RUN     yum install -y centos-release-scl && \
        yum install -y devtoolset-8 && \
        curl -O http://download.redis.io/releases/redis-6.0.5.tar.gz && \
        tar -xvzf redis-6.0.5.tar.gz && \
        cd redis-6.0.5 && \
        scl enable devtoolset-8 make && \
        rm -f /usr/local/redis/redis-6.0.5.tar.gz
```

Dockerfile-2:

```dockerfile

```

### 2.3 一个 Dockerfile 实现多阶段构建
