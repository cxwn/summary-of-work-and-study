
通过加速，国内用户能够快速访问最流行的 Docker 镜像。

仓库 registry.docker-cn.com 包含流行的公有镜像。私有镜像仍需要从 Docker Hub 镜像库中拉取。

以下命令直接从镜像加速地址进行拉取：

```bash
$ docker pull registry.docker-cn.com/myname/myrepo:mytag
```

例如:

```bash
$ docker pull registry.docker-cn.com/library/ubuntu:16.04
```

注: 除非您修改了 Docker 守护进程的 `--registry-mirror` 参数 (见下文), 否则您将需要完整地指定官方镜像的名称。例如，library/ubuntu、library/redis、library/nginx。

使用 --registry-mirror 配置 Docker 守护进程
您可以配置 Docker 守护进程默认使用镜像加速。这样您可以默认通过官方镜像加速拉取镜像，而无需在每次拉取时指定 registry.docker-cn.com。

您可以在 Docker 守护进程启动时传入 --registry-mirror 参数：

```bash
$ docker --registry-mirror=https://registry.docker-cn.com daemon
```

为了永久性保留更改，您可以修改 /etc/docker/daemon.json 文件并添加上 registry-mirrors 键值。

```json
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
```

修改保存后重启 Docker 以使配置生效。

注: 您也可以使用适用于 Mac 的 Docker 和适用于 Windows 的 Docker 来进行设置。

配置脚本如下：

```bash
#!/bin/bash
cat>/etc/docker/daemon.json<<EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF
systemctl restart docker
```