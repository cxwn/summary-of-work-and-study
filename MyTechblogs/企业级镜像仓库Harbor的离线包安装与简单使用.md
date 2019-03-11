# 企业级镜像仓库Harbor的离线包安装与简单使用

## 一 基本概念

## 二 安装环境

|软件|版本|
|:-:|:-:|
|OS|CentOS Linux release 7.6.1810|
|Docker|18.06.0-ce|
|Harbor||

```bashCentOS Linux release 7.6.1810
[root@gysl-master ~]# cat /etc/centos-release
CentOS Linux release 7.6.1810 (Core)
```

## 三 安装步骤

```bash
[root@gysl-master ~]# tar -xvzf harbor-offline-installer-v1.7.1.tgz -C /usr/local/
[root@gysl-master ~]# sed -i 's/reg.mydomain.com/172.31.2.11/g' /usr/local/harbor/harbor.cfg
[root@gysl-master ~]# curl -L -C - -O https://github.com/docker/compose/releases/download/1.24.0-rc1/docker-compose-Linux-x86_64
[root@gysl-master ~]# mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
[root@gysl-master ~]# chmod a+x /usr/local/bin/docker-compose
[root@gysl-master ~]# cd /usr/local/harbor/
[root@gysl-master harbor]# ./prepare



```

## 四 简单使用

## 五 总结