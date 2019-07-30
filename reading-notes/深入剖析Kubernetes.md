# 深入剖析 Kubernetes

## 一 Pod

Pod 是一个逻辑概念，Kubernetes 真正处理的，还是宿主机操作系统上 Linux 容器的 Namespace 和 Cgroups，而并不存在一个所谓的 Pod 的边界或者隔离环境。 Pod 是一组共享了某些资源的容器，Pod里的所有容器，共享的是同一个 Network Namespace，并且可以声明共享同一个 Volume 。在 Kubernetes 项目里，Pod 的实现需要使用一个中间容器，这个容器叫做Infra容器（Infra容器（k8s.gcr.io/pause）占用极少的资源，它的镜像时用汇编语言编写的，永远处于“暂停”状态的容器）。 在Pod中，Infra 容器永远都是第一个被创建的容器，而其他用户定义的容器，则通过 join Network Namespace的方式，与Infra容器关联在一起，对于同一个Pod里面的所有用户容器，它们的进出流量都是通过Infra容器完成的。同一个 Pod 里面的所有用户容器来说，它们的进出流量，也可以认为都是通过 Infra 容器完成的。凡是调度、网络、存储，以及安全相关的属性，基本上是 Pod 级别的。

```bash
kubectl create namespace rook-ceph
kubectl apply -f https://raw.githubusercontent.com/rook/rook/master/cluster/examples/kubernetes/ceph/operator.yaml

```

### 2.1 Pod 中几个重要字段的含义和用法

**NodeSelector**：是一个供用户将 Pod 与 Node 进行绑定的字段，用法如下所示：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gysl-nodeselect
spec:
  nodeSelector:
    kubernetes.io/hostname: 172.31.2.12
  containers:
  - name: gysl-nginx
    image: nginx
```

这就意味着这个 Pod 只能在携带 kubernetes.io/hostname 标签的 Node 上运行了，否则，调度失败。

**NodeName**：一旦 Pod 的这个字段被赋值，Kubernetes 项目就会被认为这个 Pod 已经经过了调度，调度的结果就是赋值的节点名字。所以，这个字段一般由调度器负责设置，但用户也可以设置它来“骗过”调度器，当然这个做法一般是在测试或者调试的时候才会用到。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gysl-nodename
spec:
  nodeName: 172.31.2.12
  containers:
  - name: gysl-nginx
    image: nginx
```

**HostAliases**：定义了 Pod 的 hosts 文件（比如 /etc/hosts）里的内容。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gysl-hostaliases
spec:
  hostAliases:
  - ip: "10.0.0.20"
    hostnames:
    - "test.gysl"
    - "app.gysl"
  containers:
  - name: gysl-nginx
    image: nginx
```

最下面两行记录，就是我通过 HostAliases 字段为 Pod 设置的。需要指出的是，在 Kubernetes 项目中，如果要设置 hosts 文件里的内容，一定要通过这种方法。否则，如果直接修改了 hosts 文件的话，在 Pod 被删除重建之后，kubelet 会自动覆盖掉被修改的内容。

凡是跟容器的 Linux Namespace 相关的属性，也一定是 Pod 级别的。这个原因也很容易理解：Pod 的设计，就是要让它里面的容器尽可能多地共享 Linux Namespace，仅保留必要的隔离和限制能力。

继续看以下例子：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gysl-shareprocessnamespace
spec:
  shareProcessNamespace: true
  containers:
  - name: nginx
    image: nginx
  - name: busybox
    image: busybox
    tty: true
    stdin: true
```

使用以下命令进入指定的 container ：

```bash
kubectl attach -it gysl-shareprocessnamespace -c busybox
```

进入之后查看一下进程共享情况：

```bash
/ # ps aux
PID   USER     TIME  COMMAND
    1 root      0:00 /pause
    6 root      0:00 nginx: master process nginx -g daemon off;
   11 101       0:00 nginx: worker process
   12 root      0:00 sh
   32 root      0:00 ps aux
```

在这个容器里，我们不仅可以看到它本身的 ps aux 指令，还可以看到 nginx 容器的进程，以及 Infra 容器的 /pause 进程。这就意味着，整个 Pod 里的每个容器的进程，对于所有容器来说都是可见的：它们共享了同一个 PID Namespace。凡是 Pod 中的容器要共享宿主机的 Namespace，也一定是 Pod 级别的定义。
