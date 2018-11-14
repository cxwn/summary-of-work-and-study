# 一.背景
理想状态下，我们可以认为Kubernetes Pod是健壮的。但是，理想与现实的差距往往是非常大的。很多情况下，Pod中的容器可能会因为发生故障而死掉。Deployment等Controller会通过动态创建和销毁Pod来保证应用整体的健壮性。众所周知，每个pod都拥有自己的IP地址，当新的Controller用新的Pod替代发生故障的Pod时，我们会发现，新的IP地址可能跟故障的Pod的IP地址可能不一致。此时，客户端如何访问这个服务呢？Kubernetes中的Service应运而生。

# 二.实践步骤
## 2.1 创建Deployment：httpd。
Kubernetes Service 逻辑上代表了一组具有某些label关联的Pod，Service拥有自己的IP，这个IP是不变的。无论后端的Pod如何变化，Service都不会发生改变。创建YAML如下：
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: httpd
spec:
  replicas: 4
  template:
    metadata:
      labels:
        run: httpd
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80
```
配置命令：
```bash
[root@k8s-m ~]# kubectl apply -f Httpd-Deployment.yaml
deployment.apps/httpd created
```
稍后片刻：
```
[root@k8s-m ~]# kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE
httpd-79c4f99955-dbbx7   1/1     Running   0          7m32s   10.244.2.35    k8s-n2   <none>
httpd-79c4f99955-djv44   1/1     Running   0          7m32s   10.244.1.101   k8s-n1   <none>
httpd-79c4f99955-npqxz   1/1     Running   0          7m32s   10.244.1.102   k8s-n1   <none>
httpd-79c4f99955-vkjk6   1/1     Running   0          7m32s   10.244.2.36    k8s-n2   <none>
[root@k8s-m ~]# curl 10.244.2.35
<html><body><h1>It works!</h1></body></html>
[root@k8s-m ~]# curl 10.244.2.36
<html><body><h1>It works!</h1></body></html>
[root@k8s-m ~]# curl 10.244.1.101
<html><body><h1>It works!</h1></body></html>
[root@k8s-m ~]# curl 10.244.1.102
<html><body><h1>It works!</h1></body></html>
```

## 2.2 创建Service：httpd-svc。
创建YAML如下：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: httpd-svc
spec:
  selector:
    run: httpd
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
```
配置完成并观察：
```bash
[root@k8s-m ~]# kubectl apply -f Httpd-Service.yaml
service/httpd-svc created
[root@k8s-m ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
httpd-svc    ClusterIP   10.110.212.171   <none>        8080/TCP   14s
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    11d
[root@k8s-m ~]# curl 10.110.212.171:8080
<html><body><h1>It works!</h1></body></html>
[root@k8s-m ~]# kubectl describe service httpd-svc
Name:              httpd-svc
Namespace:         default
Labels:            <none>
Annotations:       kubectl.kubernetes.io/last-applied-configuration:
                     {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"httpd-svc","namespace":"default"},"spec":{"ports":[{"port":8080,"...
Selector:          run=httpd
Type:              ClusterIP
IP:                10.110.212.171
Port:              <unset>  8080/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.101:80,10.244.1.102:80,10.244.2.35:80 + 1 more...
Session Affinity:  None
Events:            <none>
```
从以上内容中的Endpoints可以看出服务httpd-svc下面包含我们指定的labels的Pod，cluster-ip通过iptables成功映射到Pod IP，成功。再通过iptables-save命令看一下相关的iptables规则。
```bash
[root@k8s-m ~]# iptables-save |grep "10.110.212.171"
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.110.212.171/32 -p tcp -m comment --comment "default/httpd-svc: cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.110.212.171/32 -p tcp -m comment --comment "default/httpd-svc: cluster IP" -m tcp --dport 8080 -j KUBE-SVC-RL3JAE4GN7VOGDGP
[root@k8s-m ~]# iptables-save|grep -v 'default/httpd-svc'|grep 'KUBE-SVC-RL3JAE4GN7VOGDGP'
:KUBE-SVC-RL3JAE4GN7VOGDGP - [0:0]
-A KUBE-SVC-RL3JAE4GN7VOGDGP -m statistic --mode random --probability 0.25000000000 -j KUBE-SEP-R5YBMKYSG56R4KDU
-A KUBE-SVC-RL3JAE4GN7VOGDGP -m statistic --mode random --probability 0.33332999982 -j KUBE-SEP-7G5ANBWSVVLRNZAH
-A KUBE-SVC-RL3JAE4GN7VOGDGP -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-2PT6QZGNQHS4OL4I
-A KUBE-SVC-RL3JAE4GN7VOGDGP -j KUBE-SEP-I4PXZ6UARQLLOV4E
```
我们可以进一步查看相关的转发规则，此处省略。iptables将访问Service的流量转发到后端Pod，使用类似于轮询的的负载均衡策略。

## 2.3 通过域名访问Service。
我们的平台是通过kubeadm部署的，版本是v1.12.1，这个版本自带的dns相关组件是coredns。
```
[root@k8s-m ~]# kubectl get deployment --namespace=kube-system
NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
coredns   2         2         2            2           17d
```
通过创建一个临时的隔离环境来验证一下DNS是否生效。
```bash
[root@k8s-m ~]# kubectl run -it --rm busybox --image=busybox /bin/sh
kubectl run --generator=deployment/apps.v1beta1 is DEPRECATED and will be removed in a future version. Use kubectl create instead.
If you don't see a command prompt, try pressing enter.
/ # wget httpd-svc.default:8080
Connecting to httpd-svc.default:8080 (10.110.212.171:8080)
index.html           100% |*******************************************************************************************************************************|    45  0:00:00 ETA
/ # cat index.html
<html><body><h1>It works!</h1></body></html>
```
顺便提一下，在未来版本中，kubectl run可能不再被支持，推荐使用kubectl create替代。此处偷了个懒，后续不建议如此操作。

在以上例子中，临时的隔离环境的namespace为default，与我们新建的httpd-svc都在同一namespace内，httpd-svc.default的default可以省略。如果跨namespace访问的话，那么namespace是不能省略的。
## 2.4 外网访问Service。
通常情况下，我们可以通过四种方式来访问Kubeenetes的Service，分别是ClusterIP，NodePort，Loadbalance，ExternalName。在此之前的实验都是基于ClusterIP的，集群内部的Node和Pod均可通过Cluster IP来访问Service。NodePort是通过集群节点的静态端口对外提供服务。
接下来我们将以NodePort为例来进行实际演示。修改之后的Service的YAML如下：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: httpd-svc
spec:
  type: NodePort
  selector:
    run: httpd
  ports:
  - protocol: TCP
    nodePort: 31688
    port: 8080
    targetPort: 80
```
配置后观察：
```bash
[root@k8s-m ~]# kubectl apply -f  Httpd-Service.yaml
service/httpd-svc configured
[root@k8s-m ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
httpd-svc    NodePort    10.110.212.171   <none>        8080:31688/TCP   117m
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          12d
```
Service httpd-svc的端口被映射到了主机的31688端口。YAML文件如果不指定nodePort的话，Kubernetes会在30000-32767范围内为Service分配一个端口。此刻我们就可以通过浏览器来访问我们的服务了。在与node网络互通的环境中，通过任意一个Node的IP:31688即可访问刚刚部署好的Service。

# 三.总结
1. 这些天一直在看kubernetes相关的书籍和文档，也一直在测试环境中深度体验kubernetes带来的便捷，感触良多，综合自己的实践写下了这篇文章，以便后期温习。距离生产环境上线的时间越来越近，希望在生产环境上线之前吃透kubernetes。
2. 学习任何新东西都必须静下心来，光看还不够，还要结合适量的实际操作。操作完成之后要反复思考，总结，沉淀，这样才能成长。
3. Kubernetes确实是一个比较复杂的系统，概念很多，也比较复杂，在操作之前需要把基本概念理解清楚。

# 四.参考资料
1. [Kubernetes官方文档](https://kubernetes.io/docs/concepts/services-networking/service/)
