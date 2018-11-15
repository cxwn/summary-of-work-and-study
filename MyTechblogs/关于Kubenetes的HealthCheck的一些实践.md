# 一.概述
强大的自愈能力是Kubenetes这一类容器编排管理引擎的一个重要特性。通常情况下，Kubenetes通过重启发生故障的容器来实现自愈。除此之外，我们还有其他方式来实现基于Kubenetes编排的容器的健康检查吗？Liveness和Readiness就是不错的选择。

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
[root@k8s-m ~]# kubectl apply -f HealthCheck.yaml
pod/healthcheck created
[root@k8s-m ~]# kubectl get pod
NAME          READY   STATUS             RESTARTS   AGE
healthcheck   0/1     CrashLoopBackOff   3          4m52s
```
我们可以看到，这个pod并未正常运行，重启了3次。具体的重启日志我们可以通过describe命令来查看，此处不再赘述。我们来执行一下以下命令：
```bash
[root@k8s-m ~]# sh -c "sleep 2;exit 1"
[root@k8s-m ~]# echo $?
1
```
我们可以看到，命令正常执行，返回值为1。默认情况下，Linux命令执行之后返回值为0说明命令执行成功。因为执行成功后的返回值不为0，Kubenetes默认为容器发生故障，不断重启。

