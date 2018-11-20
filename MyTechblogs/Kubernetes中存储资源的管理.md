# 一.背景
存储资源在所有计算资源中扮演着十分重要的角色，大部分业务场景下都有可能使用到各类存储资源。在Kubernetes中，系统通过Volume对集群中的容器动态或静态提供存储资源。通常情况下，我们可以认为容器或者Pod的生命周期时短暂的，当容器被销毁时，容器内部的数据也同时被清除。为了持久化保存容器的数据，Kubernetes引入了Volume，类似于Docker的Volume(Docker also has a concept of volumes, though it is somewhat looser and less managed. In Docker, a volume is simply a directory on disk or in another Container. Lifetimes are not managed and until very recently there were only local-disk-backed volumes. Docker now provides volume drivers, but the functionality is very limited for now)。这个Volume被某个Pod挂载之后，这个Pod里面的所有容器都能使用这个Volume。Kubernetes目前支持的volume类型可以参考文末官方资料。

# 二.几种Volume使用举例
## 2.1 emptyDir

**emptyDir：**emptyDir是最基础的Volume类型。每个emptyDir Volume是主机上的一个空目录,可以被Pod中所有的容器共享。它对于容器来说是持久的，对于Pod则不是。删除容器并不会对它造成影响，只有删除整个Pod时，它才会被删除，它的生命周期与所挂载的Pod一致。简而言之，emptyDir类型的Volume在Pod分配到Node上时被创建，Kubernetes会在Node主机上自动分配一个目录，因此无需指定Node主机上对应的目录文件。 这个目录的初始内容为空，当Pod从Node上移除时，emptyDir中的数据会被永久删除。emptyDir主要用于一些无需永久保留的数据，例如临时目录，多容器共享目录等。我们通过实际案例来理解一下，Pod gysl的yaml如下：
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gysl
spec:
  containers:
  - image: busybox
    name: gysl-01
    volumeMounts:
    - mountPath: /gysl-01
      name: gysl-volume
    args:
    - /bin/sh
    - -c
    - echo "This is a test file.">/gysl-01/test.gysl;sleep 20000

  - image: busybox
    name: gysl-02
    volumeMounts:
    - mountPath: /gysl-02
      name: gysl-volume
    args:
    - /bin/sh
    - -c
    - cat /gysl-02/test.gysl;sleep 20000

  volumes:
  - name: gysl-volume
    emptyDir: {}
```
创建Pod gysl，并查看相关信息：
```bash
[root@k8s-m k8s-volumes]# kubectl apply -f emptyDir.yaml
pod/gysl created
[root@k8s-m k8s-volumes]# kubectl get pod
NAME   READY   STATUS    RESTARTS   AGE
gysl   2/2     Running   0          10m
[root@k8s-m k8s-volumes]# kubectl logs gysl gysl-02
This is a test file.
```
该例中，我们创建了一个名为gysl的Pod，这个pod里面包含gysl-01和gysl-02两个容器，这两个容器同时挂载了名为gysl-volume的emptyDir，gysl-01的挂载点为/gysl-01，gysl-02的挂载点为gysl-02，容器gysl-01创建了一个test.gysl的文件，内容为：“This is a test file.”在容器gysl-02中，成功显示了gysl-01创建的文件的内容。


2.2  **hostPath：**hostPath的主要作用是将主机的文件或目录挂载给Pod的容器使用，使得容器能以较为良好的性能来存储数据。

2.3 **persistentVolume：**简称PV，是外部系统张的独立的一块存储空间，由管理员创建和维护。

# 五.相关资料
5.1 [Volumes基本概念](https://kubernetes.io/docs/concepts/storage/volumes/)

5.2 [Kubernetes支持的Volume类型](https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes)

5.3 [PV基本概念](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)