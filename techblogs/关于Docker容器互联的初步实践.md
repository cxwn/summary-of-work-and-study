# 一、Docker容器之间的互联
Docker现在已经成为一种轻量级的虚拟化方案，在同一宿主机下，所有的容器都可以通过网桥进行互联。如果之前有docker的使用经验，可能已经习惯了使用--link来对容器进行互联。随着docker的逐步完善，强烈推荐大家使用网桥（bridge）来对容器进行互联。

# 二、实践过程
1.创建一个网络my-net：
```
[root@ChatDevOps ~]# docker network create my-net
71b42506de62797889372ea4a5270f905f79a19cf80e308119c02e529b89c94e
[root@ChatDevOps ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
3dec5cbb852e        bridge              bridge              local
6dd6dcfc2f26        host                host                local
71b42506de62        my-net              bridge              local
4c142a02cd6b        none                null                local
```
2.在创建docker容器的时候就指定桥接网络：
```
[root@ChatDevOps docker]# docker create -it --name d1 --network my-net -p 8080:80 ubuntu:14.04
4776b65db566f370cad5da3a9354a12c7e4f9badab53647b7e30e1e8f343ae3d
[root@ChatDevOps docker]# docker start d1
d1
```
在该命令中，docker create也可以用docker container create，二者等价。--name指定了容器的名称，--network指定了该容器的网络名称，桥接形式默认为网桥，-p或--publish指定了映射的端口。如果在这一步指定的网络没有预先被创建，那么这个容器时无法正常启动的。此时，可以为该容器创建网络后再次启动容器即可。

3.还可以在运行一个docker容器的时候指定一个已经创建好的网络：
```
[root@ChatDevOps docker]# docker run -it --name d2 --network my-net --publish 8081:80 ubuntu:14.04 /bin/bash
root@07fd516911d0:/# ping d1
PING d1 (172.18.0.2) 56(84) bytes of data.
64 bytes from d1.my-net (172.18.0.2): icmp_seq=1 ttl=64 time=0.115 ms
root@4776b65db566:/# ping d2
PING d2 (172.18.0.3) 56(84) bytes of data.
64 bytes from d2.my-net (172.18.0.3): icmp_seq=1 ttl=64 time=0.062 ms
```
通过容器名称即可ping通在同一网桥的容器。也可以直接ping其IP。
# 三、总结
1.在docker安装完成之后，docker容器有三个网络，如下：
```
[root@ChatDevOps ~]# docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
3dec5cbb852e        bridge              bridge              local
6dd6dcfc2f26        host                host                local
4c142a02cd6b        none                null                local
```
2.在同一网络中的所有容器网络都是互通的。
3.容器的网络配置中的dns配置可以在主机的/etc/docker/daemon.json文件进行配置，参照官方格式：
```
{
  "bip": "192.168.1.5/24",
  "fixed-cidr": "192.168.1.5/25",
  "fixed-cidr-v6": "2001:db8::/64",
  "mtu": 1500,
  "default-gateway": "10.20.1.1",
  "default-gateway-v6": "2001:db8:abcd::89",
  "dns": ["10.20.1.2","10.20.1.3"]
}
```
根据实际情况进行配置即可。
