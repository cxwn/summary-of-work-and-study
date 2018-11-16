# 一.概述
强大的自愈能力是Kubernetes这一类容器编排管理引擎的一个重要特性。通常情况下，Kubernetes通过重启发生故障的容器来实现自愈。除此之外，我们还有其他方式来实现基于Kubernetes编排的容器的健康检查吗？Liveness和Readiness就是不错的选择。

# 二.实践步骤
2.1 系统默认的健康检查。
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: healthcheck
  name: healthcheck
spec:
  restartPolicy: OnFailure
  containers:
  - name: healthcheck
    image: busybox
    args:
    - /bin/sh
    - -c
    - sleep 10;exit 1
```
创建一个内容如上所述的yaml文件，命名为HealthCheck.yaml，apply：
```bash
[root@k8s-m health-check]# kubectl apply -f HealthCheck.yaml
pod/healthcheck created
[root@k8s-m health-check]# kubectl get pod
NAME          READY   STATUS             RESTARTS   AGE
healthcheck   0/1     CrashLoopBackOff   3          4m52s
```
我们可以看到，这个pod并未正常运行，重启了3次。具体的重启日志我们可以通过describe命令来查看，此处不再赘述。我们来执行一下以下命令：
```bash
[root@k8s-m health-check]# sh -c "sleep 2;exit 1"
[root@k8s-m health-check]# echo $?
1
```
我们可以看到，命令正常执行，返回值为1。默认情况下，Linux命令执行之后返回值为0说明命令执行成功。因为执行成功后的返回值不为0，Kubernetes默认为容器发生故障，不断重启。然而，也有不少情况是服务实际发生了故障，但是进程未退出。这种情况下，重启往往是简单而有效的手段。例如：访问web服务时显示500服务器内部错误，很多原因会造成这样的故障，重启可能就能迅速修复故障。

2.2 在Kubernetes中，可以通过Liveness探测告诉kebernetes什么时候实现重启自愈。
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness
spec:
  restartPolicy: OnFailure
  containers:
  - name: liveness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthcheck;sleep 30; rm -rf /tmp/healthcheck;sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthcheck
      initialDelaySeconds: 10
      periodSeconds: 5
```
创建名为Liveness.yaml的文件，创建Pod：
```bash
[root@k8s-m health-check]# kubectl apply -f Liveness.yaml
pod/liveness created
[root@k8s-m health-check]# kubectl get pod
NAME       READY   STATUS    RESTARTS   AGE
liveness   1/1     Running   1          5m50s
```
从yaml文件中，我们可以看出，容器启动后创建/tmp/healthcheck文件，30s后删除，删除后sleep该进程600s。通过cat /tmp/healthcheck来探测容器是否发生故障。如果该文件存在，则说明容器正常，该文件不存在，则杀该容器并重启。

initialDelaySeconds:10指定容器启动10s之后执行探测。一般该值要大于容器的启动时间。periodSeconds:5表示每5s执行一次探测，如果连续三次执行Liveness探测均失败，那么会杀死该容器并重启。

2.3 Readiness则可以告诉Kubenentes什么时候可以将容器加入到Service的负载均衡池中，对外提供服务。
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: readiness
  name: readiness
spec:
  restartPolicy: OnFailure
  containers:
  - name: readiness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthcheck;sleep 30; rm -rf /tmp/healthcheck;sleep 600
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/healthcheck
      initialDelaySeconds: 10
      periodSeconds: 5
```
apply该文件：
```bash
[root@k8s-m health-check]# kubectl apply -f Readiness.yaml
pod/readiness created
[root@k8s-m health-check]# kubectl get pod
NAME        READY   STATUS    RESTARTS   AGE
readiness   0/1     Running   0          84s
[root@k8s-m health-check]# kubectl get pod
NAME        READY   STATUS      RESTARTS   AGE
readiness   0/1     Completed   0          23m
```
从yaml文件中我们可以看出，Readiness和Liveness两种探测的配置基本是一样的，只需稍加改动就可以套用。通过kubectl get pod我们发现这两种Health Check主要不同在于输出的第二列和第三列。Readiness第三列一直都是running，第二列一段时间后由1/1变为0/1。当第二列为0/1时，则说明容器不可用。具体可以通过以下命令来查看一下：
```bash
[root@k8s-m health-check]# while true;do kubectl describe pod readiness;done
```
Liveness和Readiness是两种Health Check机制，不互相依赖，可以同时使用。

# 三.拓展
3.1 Health Check在Scale Up中的应用。
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  template:
    metadata:
      labels:
        run: web
    spec:
      containers:
      - name: web
        image: httpd
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            scheme: HTTP
            path: /health-check
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
spec:
  selector:
    run: web
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
```
通过以上yaml，创建了一个名为web-svc的服务和名为web的Deployment。
```bash
[root@k8s-m health-check]# kubectl apply -f HealthCheck-web-deployment.yaml
deployment.apps/web unchanged
service/web-svc created
[root@k8s-m health-check]# kubectl get service web-svc
NAME      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
web-svc   ClusterIP   10.101.1.6   <none>        8080/TCP   2m20s
[root@k8s-m health-check]# kubectl get deployment web
NAME   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
web    3         3         3            0           3m26s
[root@k8s-m health-check]# kubectl get pod
NAME                   READY   STATUS    RESTARTS   AGE
web-7d96585f7f-q5p4d   0/1     Running   0          3m35s
web-7d96585f7f-w6tqx   0/1     Running   0          3m35s
web-7d96585f7f-xrqwm   0/1     Running   0          3m35s
```
重点关注一下17-23行，第17行指出本案例中使用的Health Check机制为Readiness，探测方法为httpGet。Kubernetes对于该方法探测成功的判断条件时http请求返回值在200-400之间。schema指定了协议，可以为http（默认）和https。path指定访问路径，port指定端口。

容器启动10s后开始探测，如果 http://container_ip:8080/health-check 的返回值不是200-400,表示容器没有准备就绪，不接收Service web-svc的请求。/health-check则是我们实现探测的代码。探测结果示例如下：
```bash
[root@k8s-m health-check]# kubectl describe pod web
Warning  Unhealthy  57s (x219 over 19m)  kubelet, k8s-n2    Readiness probe failed: Get http://10.244.2.61:8080/healthy: dial tcp 10.244.2.61:8080: connect: connection refused
```
3.2 Health Check在滚动更新（Rolling Update）中的应用。

默认情况下，在Rolling Update过程中，Kubernetes会认为容器已经准备就绪，进而会逐步替换旧副本。如果新版本的容器出现故障，那么在版本更新完成之后可能导致整个应用无法处理请求，无法对外提供服务。此类事件若发生在生产环境中，后果会非常严重。正确配置了Health Check，只有通过了Readiness探测的新副本才能添加到Service，如果没有通过探测，现有副本就不会呗替换，业务依然正常运行。

接下来，我们分别创建yaml文件app.v1.yaml和app.v2.yaml:
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 8
  template:
    metadata:
      labels:
        run: app
    spec:
      containers:
      - name: app
        image: busybox
        args:
        - /bin/sh
        - -c
        - sleep 10;touch /tmp/health-check;sleep 30000
        readinessProbe:
          exec:
            command:
            - cat
            - /tmp/health-check
          initialDelaySeconds: 10
          periodSeconds: 5
```
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 8
  template:
    metadata:
      labels:
        run: app
    spec:
      containers:
      - name: app
        image: busybox
        args:
        - /bin/sh
        - -c
        - sleep 3000
        readinessProbe:
          exec:
            command:
            - cat
            - /tmp/health-check
          initialDelaySeconds: 10
          periodSeconds: 5
```
apply文件app.v1.yaml:
```bash
[root@k8s-m health-check]# kubectl apply -f app.v1.yaml --record
deployment.apps/app created
[root@k8s-m health-check]# kubectl get pod
NAME                  READY   STATUS    RESTARTS   AGE
app-844b9b5bf-9nnrb   1/1     Running   0          2m52s
app-844b9b5bf-b8tw2   1/1     Running   0          2m52s
app-844b9b5bf-j2n9c   1/1     Running   0          2m52s
app-844b9b5bf-ml8c5   1/1     Running   0          2m52s
app-844b9b5bf-mtgr9   1/1     Running   0          2m52s
app-844b9b5bf-n4dn8   1/1     Running   0          2m52s
app-844b9b5bf-ppzh6   1/1     Running   0          2m52s
app-844b9b5bf-z55d4   1/1     Running   0          2m52s
```
更新到app.v2.yaml:
```bash
[root@k8s-m health-check]# kubectl apply -f app.v2.yaml --record
deployment.apps/app configured
[root@k8s-m health-check]# kubectl get pod
NAME                  READY   STATUS              RESTARTS   AGE
app-844b9b5bf-9nnrb   1/1     Running             0          3m30s
app-844b9b5bf-b8tw2   1/1     Running             0          3m30s
app-844b9b5bf-j2n9c   1/1     Running             0          3m30s
app-844b9b5bf-ml8c5   1/1     Terminating         0          3m30s
app-844b9b5bf-mtgr9   1/1     Running             0          3m30s
app-844b9b5bf-n4dn8   1/1     Running             0          3m30s
app-844b9b5bf-ppzh6   1/1     Terminating         0          3m30s
app-844b9b5bf-z55d4   1/1     Running             0          3m30s
app-cd49b84-bxvtc     0/1     ContainerCreating   0          6s
app-cd49b84-gkkj8     0/1     ContainerCreating   0          6s
app-cd49b84-jfzcm     0/1     ContainerCreating   0          6s
app-cd49b84-xl8ws     0/1     ContainerCreating   0          6s
```
稍后再观察：
```bash
[root@k8s-m health-check]# kubectl get pod
NAME                  READY   STATUS    RESTARTS   AGE
app-844b9b5bf-9nnrb   1/1     Running   0          4m59s
app-844b9b5bf-b8tw2   1/1     Running   0          4m59s
app-844b9b5bf-j2n9c   1/1     Running   0          4m59s
app-844b9b5bf-mtgr9   1/1     Running   0          4m59s
app-844b9b5bf-n4dn8   1/1     Running   0          4m59s
app-844b9b5bf-z55d4   1/1     Running   0          4m59s
app-cd49b84-bxvtc     0/1     Running   0          95s
app-cd49b84-gkkj8     0/1     Running   0          95s
app-cd49b84-jfzcm     0/1     Running   0          95s
app-cd49b84-xl8ws     0/1     Running   0          95s
```
此刻状态全部为running，但是依然有4个Pod的READY为0/1，再看一下：
```bash
[root@k8s-m health-check]# kubectl get deployment app
NAME   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
app    8         10        4            6           7m20s
```
DESIRED表示期待的副本数为8，CURRENT表示当前副本数为10，UP-TO-DATE表示升级了的副本数为4，AVAILABLE表示可用的副本数为6。如果不进行更改，该状态将一直保持下去。在此，需要注意的是，Rolling Update中删除了2个旧副本，创建建了4个新副本。这里留到最后再讨论。

版本回滚到v1：
```bash
[root@k8s-m health-check]# kubectl rollout history deployment app
deployment.extensions/app
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=app.v1.yaml --record=true
2         kubectl apply --filename=app.v2.yaml --record=true

[root@k8s-m health-check]# kubectl rollout undo deployment app --to-revision=1
deployment.extensions/app
[root@k8s-m health-check]# kubectl get pod
NAME                  READY   STATUS    RESTARTS   AGE
app-844b9b5bf-8qqhk   1/1     Running   0          2m37s
app-844b9b5bf-9nnrb   1/1     Running   0          18m
app-844b9b5bf-b8tw2   1/1     Running   0          18m
app-844b9b5bf-j2n9c   1/1     Running   0          18m
app-844b9b5bf-mtgr9   1/1     Running   0          18m
app-844b9b5bf-n4dn8   1/1     Running   0          18m
app-844b9b5bf-pqpm5   1/1     Running   0          2m37s
app-844b9b5bf-z55d4   1/1     Running   0          18m
```
# 四.总结
4.1 Liveness和Readiness是Kubernetes中两种不同的Health Check方式，他们非常类似，但又有区别。可以两者同时使用，也可以单独使用。具体差异在上文已经提及。

4.2 在上一篇关于Rolling Update的文章中，我曾经提到滚动更新过程中的替换规则。在本文中我们依然使用了默认方式进行更新。maxSurge和maxUnavailable两个参数决定了更新过程中各个状态下的副本个数，这两个参数的默认值都是25%。更新后，总副本数=8+8\*0.25=10；可用副本数：8-8\*0.25=6。此过程中，销毁了2个副本，创建了4个新副本。

4.3 在一般生产环境上线时，尽量使用Health Check来确保业务不受影响。这个过程的实现手段多样化，需要根据实际情况进行总结和选用。

# 五.参考资料
5.1 [官方文档：关于Liveness和Readiness](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)

5.2 [官方文档：关于maxSurge和maxUnavailable](https://kubernetes.io/zh/docs/concepts/workloads/controllers/deployment/)

5.3 [文中涉及到的代码](https://github.com/mrivandu/WorkAndStudy/tree/master/DockerfilesAndYamls/health-check)