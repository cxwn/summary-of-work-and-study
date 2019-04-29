# 一.背景
随着Kubernetes的进一步深入使用，我们越来越体会到它给我们的工作带来的高效与便利。Rolling Update是Kubernetes系统中的一个强大的功能，能够为我们的运维工作带来极大的便利。
# 二.步骤
## 2.1 部署最初始版本Deployment。
初始Deployment的YAML如下：
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: deployment-rollout
spec:
  replicas: 4
  template:
    metadata:
      labels:
        test: httpd
    spec:
      containers:
      - name: httpd-rollout-test
        image: httpd:2.2.31
        ports:
        - containerPort: 80
```
执行命令：
```bash
[root@k8s-m ~]# kubectl get deployment -o wide
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS           IMAGES         SELECTOR
deployment-rollout   4         4         4            4           107s   httpd-rollout-test   httpd:2.2.31   test=httpd
[root@k8s-m ~]# kubectl get replicaset -o wide
NAME                            DESIRED   CURRENT   READY   AGE    CONTAINERS           IMAGES         SELECTOR
deployment-rollout-5fb9c69c5c   4         4         4       116s   httpd-rollout-test   httpd:2.2.31   pod-template-hash=5fb9c69c5c,test=httpd
```

## 2.2 将初始版本升级。
升级到2.4.31，YAML如下：
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: deployment-rollout
spec:
  revisionHistoryLimit: 10
  replicas: 4
  template:
    metadata:
      labels:
        test: httpd
    spec:
      containers:
      - name: httpd-rollout-test
        image: httpd:2.4.33
        ports:
        - containerPort: 80
```
执行命令：
```bash
[root@k8s-m ~]# kubectl apply -f Httpd-Deployment-rollout-v1.yaml
deployment.apps/deployment-rollout configured
[root@k8s-m ~]# kubectl get deployment -o wide
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS           IMAGES         SELECTOR
deployment-rollout   4         5         2            3           3m57s   httpd-rollout-test   httpd:2.4.33   test=httpd
[root@k8s-m ~]# kubectl get replicaset -o wide
NAME                            DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES         SELECTOR
deployment-rollout-54766f574f   2         2         0       93s     httpd-rollout-test   httpd:2.4.33   pod-template-hash=54766f574f,test=httpd
deployment-rollout-5fb9c69c5c   3         3         3       4m12s   httpd-rollout-test   httpd:2.2.31   pod-template-hash=5fb9c69c5c,test=httpd
[root@k8s-m ~]# kubectl get pod -o wide
NAME                                  READY   STATUS              RESTARTS   AGE     IP             NODE     NOMINATED NODE
deployment-rollout-54766f574f-668pc   0/1     ContainerCreating   0          114s    <none>         k8s-n1   <none>
deployment-rollout-54766f574f-ssz67   0/1     ContainerCreating   0          115s    <none>         k8s-n2   <none>
deployment-rollout-5fb9c69c5c-m5dvs   1/1     Running             0          4m34s   10.244.2.47    k8s-n2   <none>
deployment-rollout-5fb9c69c5c-p9grr   1/1     Running             0          4m34s   10.244.1.113   k8s-n1   <none>
deployment-rollout-5fb9c69c5c-tzm7w   1/1     Running             0          4m34s   10.244.2.48    k8s-n2   <none>
```
一会儿后再观察一下：
```bash
[root@k8s-m ~]# kubectl get replicaset -o wide
NAME                            DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES         SELECTOR
deployment-rollout-54766f574f   4         4         4       4m24s   httpd-rollout-test   httpd:2.4.33   pod-template-hash=54766f574f,test=httpd
deployment-rollout-5fb9c69c5c   0         0         0       7m3s    httpd-rollout-test   httpd:2.2.31   pod-template-hash=5fb9c69c5c,test=httpd
[root@k8s-m ~]# kubectl get deployment -o wide
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS           IMAGES         SELECTOR
deployment-rollout   4         4         4            4           7m18s   httpd-rollout-test   httpd:2.4.33   test=httpd
[root@k8s-m ~]# kubectl get pod -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE
deployment-rollout-54766f574f-668pc   1/1     Running   0          4m48s   10.244.1.114   k8s-n1   <none>
deployment-rollout-54766f574f-h7gf9   1/1     Running   0          99s     10.244.2.50    k8s-n2   <none>
deployment-rollout-54766f574f-ssz67   1/1     Running   0          4m49s   10.244.2.49    k8s-n2   <none>
deployment-rollout-54766f574f-vklvr   1/1     Running   0          41s     10.244.1.115   k8s-n1   <none>
```
在此过程中，我们会发现，ReplicaSet deployment-rollout-5fb9c69c5c逐步被deployment-rollout-54766f574f取代，创建新版本的Pod之后，原始版本的Pod被终止。这是一个平滑的升级过程。Kubernetes提供了两个参数maxSurge和maxUnavailable来精细控制Pod的替换数量。

## 2.3 版本的回滚。
默认情况下，Kubernetes只会保留最近几个revision。在上面的升级过程中，通过revisionHistoryLimit设置了revision的数量。我们通过命令来看一下：
```bash
[root@k8s-m ~]# kubectl rollout history deployment deployment-rollout
deployment.extensions/deployment-rollout
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

继续升级。新版的YAML如下：
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: deployment-rollout
spec:
  revisionHistoryLimit: 10
  replicas: 4
  template:
    metadata:
      labels:
        test: httpd
    spec:
      containers:
      - name: httpd-rollout-test
        image: httpd:2.4.34
        ports:
        - containerPort: 80
```
执行升级并记录升级日志。
```bash
[root@k8s-m ~]# kubectl apply -f Httpd-Deployment-rollout-v2.yaml --record
deployment.apps/deployment-rollout configured
[root@k8s-m ~]# kubectl rollout history deployment deployment-rollout
deployment.extensions/deployment-rollout
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         kubectl apply --filename=Httpd-Deployment-rollout-v2.yaml --record=true
[root@k8s-m ~]# kubectl get deployment deployment-rollout -o wide
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES         SELECTOR
deployment-rollout   4         4         4            4           31m   httpd-rollout-test   httpd:2.4.34   test=httpd
[root@k8s-m ~]# kubectl get replicaset -o wide
NAME                            DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES         SELECTOR
deployment-rollout-54766f574f   0         0         0       29m     httpd-rollout-test   httpd:2.4.33   pod-template-hash=54766f574f,test=httpd
deployment-rollout-54fc66bb6    4         4         4       6m12s   httpd-rollout-test   httpd:2.4.34   pod-template-hash=54fc66bb6,test=httpd
deployment-rollout-5fb9c69c5c   0         0         0       32m     httpd-rollout-test   httpd:2.2.31   pod-template-hash=5fb9c69c5c,test=httpd
[root@k8s-m ~]# kubectl get pod -o wide
NAME                                 READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE
deployment-rollout-54fc66bb6-2zvhk   1/1     Running   0          6m26s   10.244.1.116   k8s-n1   <none>
deployment-rollout-54fc66bb6-7rsj6   1/1     Running   0          4m16s   10.244.1.117   k8s-n1   <none>
deployment-rollout-54fc66bb6-nlx4h   1/1     Running   0          6m26s   10.244.2.51    k8s-n2   <none>
deployment-rollout-54fc66bb6-xxnrg   1/1     Running   0          6m24s   10.244.2.52    k8s-n2   <none>
```

修改YAML文件中镜像的版本继续升级，观察升级结果：
```bash
[root@k8s-m ~]# kubectl rollout history deployment deployment-rollout
deployment.extensions/deployment-rollout
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         kubectl apply --filename=Httpd-Deployment-rollout-v2.yaml --record=true
4         kubectl apply --filename=Httpd-Deployment-rollout-v3.yaml --record=true

[root@k8s-m ~]# kubectl get replicaset -o wide
NAME                            DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES         SELECTOR
deployment-rollout-54766f574f   0         0         0       33m     httpd-rollout-test   httpd:2.4.33   pod-template-hash=54766f574f,test=httpd
deployment-rollout-54fc66bb6    0         0         0       10m     httpd-rollout-test   httpd:2.4.34   pod-template-hash=54fc66bb6,test=httpd
deployment-rollout-5b99bbfbbc   4         4         4       2m33s   httpd-rollout-test   httpd:2.4.35   pod-template-hash=5b99bbfbbc,test=httpd
deployment-rollout-5fb9c69c5c   0         0         0       36m     httpd-rollout-test   httpd:2.2.31   pod-template-hash=5fb9c69c5c,test=httpd
[root@k8s-m ~]# kubectl get pod -o wide
NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE
deployment-rollout-5b99bbfbbc-7mdg9   1/1     Running   0          65s     10.244.1.119   k8s-n1   <none>
deployment-rollout-5b99bbfbbc-9mfbk   1/1     Running   0          2m40s   10.244.1.118   k8s-n1   <none>
deployment-rollout-5b99bbfbbc-jn5sb   1/1     Running   0          2m40s   10.244.2.53    k8s-n2   <none>
deployment-rollout-5b99bbfbbc-tr6t2   1/1     Running   0          2m38s   10.244.2.54    k8s-n2   <none>
```
httpd的image均已经升级到2.4.35，接下来我们试一下回滚到v2版本：
```bash
[root@k8s-m ~]# kubectl rollout undo deployment deployment-rollout --to-revision=3
deployment.extensions/deployment-rollout
[root@k8s-m ~]# kubectl get deployment -o wide
NAME                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS           IMAGES         SELECTOR
deployment-rollout   4         4         4            4           42m   httpd-rollout-test   httpd:2.4.34   test=httpd
[root@k8s-m ~]# kubectl get replicaset -o wide
NAME                            DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES         SELECTOR
deployment-rollout-54766f574f   0         0         0       39m     httpd-rollout-test   httpd:2.4.33   pod-template-hash=54766f574f,test=httpd
deployment-rollout-54fc66bb6    4         4         4       16m     httpd-rollout-test   httpd:2.4.34   pod-template-hash=54fc66bb6,test=httpd
deployment-rollout-5b99bbfbbc   0         0         0       8m35s   httpd-rollout-test   httpd:2.4.35   pod-template-hash=5b99bbfbbc,test=httpd
deployment-rollout-5fb9c69c5c   0         0         0       42m     httpd-rollout-test   httpd:2.2.31   pod-template-hash=5fb9c69c5c,test=httpd
[root@k8s-m ~]# kubectl get pod -o wide
NAME                                 READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE
deployment-rollout-54fc66bb6-bjskn   1/1     Running   0          68s   10.244.1.121   k8s-n1   <none>
deployment-rollout-54fc66bb6-c65th   1/1     Running   0          70s   10.244.2.55    k8s-n2   <none>
deployment-rollout-54fc66bb6-cwpbk   1/1     Running   0          70s   10.244.1.120   k8s-n1   <none>
deployment-rollout-54fc66bb6-lz9xt   1/1     Running   0          68s   10.244.2.56    k8s-n2   <none>
[root@k8s-m ~]# kubectl rollout history deployment deployment-rollout
deployment.extensions/deployment-rollout
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
4         kubectl apply --filename=Httpd-Deployment-rollout-v3.yaml --record=true
5         kubectl apply --filename=Httpd-Deployment-rollout-v2.yaml --record=true
```

每次升级或回滚操作之后REVISION的数字都会增加1。通过kubectl history，我们可以看到每次升级记录，--record记录了每次操作的详细过程。通过kubectl undo执行回滚操作，选项--to-revision指定了回滚的修订版本号。

# 三.总结
3.1. 再次被Kubernetes的魅力所折服，平常工作中的灰度升级/发布/更新（按批次停止老版本实例，启用新版本实例，新老版本共存，逐步扩大新版本范围，最终把所有用户迁移到新版本上），蓝绿升级/发布/更新（不停止老版本，另外部署一套新版本，新版本通过测试发布后删除老版本），滚动升级/发布/更新（一个或多个服务停止，执行更新，逐步将新版本投入使用，周而复始，最终完成整个集群中所有实例的版本更新）这些概念理解更加透彻。

3.2. 目前有些资料已经不适用于新版本了，不要被网上的资料所误导，一定要立足与官方文档和系统帮助。例如：

**Kubernetes 的Deploy相关的命令只有:**
```bash
Deploy Commands:
  rollout        Manage the rollout of a resource
  scale          为 Deployment, ReplicaSet, Replication Controller 或者 Job 设置一个新的副本数量
  autoscale      自动调整一个 Deployment, ReplicaSet, 或者 ReplicationController 的副本数量
```
**Rollout可用资源类型：**
```bash
Valid resource types include:
  * deployments
  * daemonsets
  * statefulsets
```
3.3 Rollout updat也可以通过YAML来实现，后续文章会介绍。

# 四.相关资料
4.1 [本文相关的yaml文件](https://github.com/mrivandu/DockerfilesAndYamls/tree/master/k8s-RollingUpdate)

4.2 [官方资料](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/)
