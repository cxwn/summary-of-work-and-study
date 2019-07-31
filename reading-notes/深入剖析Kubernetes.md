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

再看一个例子：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gysl-share-namespace
spec:
  hostPID: true
  hostIPC: true
  hostNetwork: true
  nodeName: 172.31.2.11
  shareProcessNamespace: true
  containers:
  - name: nginx-gysl
    image: nginx
    imagePullPolicy: IfNotPresent
  - name: busybox-gysl
    image: busybox
    stdin: true
    tty: true
    imagePullPolicy: Always
    lifecycle:
      postStart:
        exec:
          command: ['/bin/sh','-c','echo "This is a test of gysl. ">/gysl.txt']
      preStop:
        exec:
          command: ['/bin/sh','-c','echo "This is a demo of gysl."']
```

上面的例子中，定义了共享宿主机的 Network、IPC 和 PID Namespace。这就意味着，这个 Pod 里的所有容器，会直接使用宿主机的网络、直接与宿主机进行 IPC 通信、看到宿主机里正在运行的所有进程。

除此之外，ImagePullPolicy 和 Lifecycle 也是值得我们关注的两个字段。

**ImagePullPolicy** 字段定义了镜像拉取的策略。而它之所以是一个 Container 级别的属性，是因为容器镜像本来就是 Container 定义中的一部分。ImagePullPolicy 的值默认是 Always，即每次创建 Pod 都重新拉取一次镜像。如果它的值被定义为 Never 或者 IfNotPresent，则意味着 Pod 永远不会主动拉取这个镜像，或者只在宿主机上不存在这个镜像时才拉取。

**Lifecycle** 字段。它定义的是 Container Lifecycle Hooks。顾名思义，Container Lifecycle Hooks 的作用，是在容器状态发生变化时触发一系列“钩子”。在这个字段中，我们看到了 postStart 和 preStop 两个参数。postStart 参数在容器启动后，立刻执行一个指定的操作。需要明确的是，postStart 定义的操作，虽然是在 Docker 容器 ENTRYPOINT 执行之后，但它并不严格保证顺序。也就是说，在 postStart 启动时，ENTRYPOINT 有可能还没有结束。如果 postStart 执行超时或者错误，Kubernetes 会在该 Pod 的 Events 中报出该容器启动失败的错误信息，导致 Pod 也处于失败的状态。preStop 发生的时机，则是容器被杀死之前（比如，收到了 SIGKILL 信号）。而需要明确的是，preStop 操作的执行，是同步的。所以，它会阻塞当前的容器杀死流程，直到这个 Hook 定义操作完成之后，才允许容器被杀死，这跟 postStart 不一样。

### 2.2 Projected Volume

作为 Kubernetes 比较核心的编排对象，Pod 携带的信息极其丰富。在 Kubernetes 中，有几种特殊的 Volume，它们存在的意义不是为了存放容器里的数据，也不是用来进行容器和宿主机之间的数据交换。这些特殊 Volume 的作用，是为容器提供预先定义好的数据。从容器的角度来看，这些 Volume 里的信息就是仿佛是被 Kubernetes“投射”。Kubernetes 支持的 Projected Volume 有如下四种：

- Secret

- ConfigMap

- DownWarAPI

- ServiceAccountToken

#### 2.2.1 Secret

Kubernetes 把 Pod 想要访问的东西存放在 etcd 中，然后通过在 Pod 的容器里挂载 volume 的方式来进行访问。存放数据库的凭证信息就是 Secret 最典型的应用场景之一。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-gysl
spec:
  containers:
  - name: secret-gysl
    image: busybox
    args:
    - sleep
    - "3600"
    volumeMounts:
    - name: secret-mysql-gysl
      mountPath: "/projected-volume-secret"
      readOnly: true
  volumes:
  - name: secret-mysql-gysl
    projected:
      sources:
      - secret:
          name: user
      - secret:
          name: passwd
```

在这个例子中，声明挂载的 Volume 的类型是 projected 类型。这个 Volume 的数据来源（sources）是名为 user 和 passwd 的 Secret 对象，分别对应的是数据库的用户名和密码。

在 apply 以上 yaml 文件之后，我们会发现 Pod 的状态一直是 ContainerCreating ，原因是我们还没有创建相关的 secret 。使用以下命令进行创建：

```bash
kubectl create secret generic user --from-file=username.txt
kubectl create secret generic passwd --from-file=passwd.txt
```

username.txt 和 passwd.txt 两个文件的内容分别如下：

```txt
cat username.txt
gysl
cat passwd.txt
E#w23%dj2JK@
```

也可以通过 yaml 文件的方式来进行创建，以上命令转化为 yaml 如下：

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: user
type: Opaque
data:
  passwd: Z3lzbAo=
---
apiVersion: v1
kind: Secret
metadata:
  name: passwd
type: Opaque
data:
  passwd: RSN3MjMlZGoySktACg==
```

该yaml 文件中的 data 部分的字段都是经过 base64 转码的：

```bash
cat username.txt |base64
Z3lzbAo=
cat passwd.txt |base64
RSN3MjMlZGoySktACg==
```

验证一下这些 Secret 对象是不是已经在容器里了：

```bash
kubectl exec -it secret-gysl sh
/ # ls /projected-volume-secret/
passwd
/ # cat /projected-volume-secret/passwd
E#w23%dj2JK@
```

挂载的目录才有一个文件 passwd 。这是为什么呢？
