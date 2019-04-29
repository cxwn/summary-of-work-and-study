# Kubernetes Dashboard的安装与配置

## 一 背景

通过kubeadm快速完成了kubernetes的安装，即可迅速地体验到kubernetes的强大功能。美中不足的是，只能通过命令来查看或操作，没有一个直观且简洁的Web UI来感受一下这种成功的喜悦。此外，国内的网络环境，也在某种程度上增加了一些门槛。面对如此种种，依然有办法体验kunernetes dashboard。

## 二 操作步骤

因为不清楚Pod会被调度到哪一个Node上，所以在每一个节点上执行以下脚本：

```bash
#!/bin/bash
docker pull registry.cn-qingdao.aliyuncs.com/wangxiaoke/kubernetes-dashboard-amd64:v1.10.0
# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.0
docker tag registry.cn-qingdao.aliyuncs.com/wangxiaoke/kubernetes-dashboard-amd64:v1.10.0 k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0
docker image rm registry.cn-qingdao.aliyuncs.com/wangxiaoke/kubernetes-dashboard-amd64:v1.10.0
```

在Master节点上执行：

```bash
[root@k8s-m ~]# curl -O kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.0/src/deploy/recommended/kubernetes-dashboard.yaml
[root@k8s-m ~]# kubectl apply -f kubernetes-dashboard.yaml
```

查看pod是否创建成功:

```bash
[root@k8s-m ~]#  kubectl get pods --namespace=kube-system
NAME                                    READY   STATUS    RESTARTS   AGE
coredns-576cbf47c7-xg4xm                1/1     Running   1          72m
coredns-576cbf47c7-xq9mc                1/1     Running   1          80m
etcd-k8s-m                              1/1     Running   2          79m
kube-apiserver-k8s-m                    1/1     Running   2          79m
kube-controller-manager-k8s-m           1/1     Running   21         80m
kube-flannel-ds-amd64-9fzm7             1/1     Running   1          72m
kube-flannel-ds-amd64-nddqf             1/1     Running   2          72m
kube-proxy-6js29                        1/1     Running   2          80m
kube-proxy-lp2v2                        1/1     Running   2          72m
kube-scheduler-k8s-m                    1/1     Running   19         80m
kubernetes-dashboard-77fd78f978-ngkvb   1/1     Running   1          25m
```

修改service配置，找到type，将ClusterIP改成NodePort：

```bash
[root@k8s-m ~]# kubectl edit service  kubernetes-dashboard --namespace=kube-system
```

查看暴露端口:

```bash
[root@k8s-m ~]#  kubectl get service --namespace=kube-system
NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP   87m
kubernetes-dashboard   NodePort    10.101.204.129   <none>        443:31269/TCP   32m
```

创建kubernetes-dashboard用户:

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
```

创建用户:

```bash
[root@k8s-m ~]#  kubectl create -f admin-token.yaml 
```

获取登录token:

```bash
[root@k8s-m ~]# kubectl get secret -n kube-system |grep admin|awk '{print $1}'
admin-token-6tkxm

[root@k8s-m ~]# kubectl describe secret admin-token-6tkxm -n kube-system|grep '^token'|awk '{print $2}'
eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi02dGt4bSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjQ4MjcxNTE5LTFkODgtMTFlOS1iMGZkLTAwMTU1ZDc0ZWUyNyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.TpBGEd-7VXrYjN_5fi0sOXMqLIrhDkgqIVVTagO4wvKOQloCJkpfvnVgBJ0Oi52-UQNBKBVH8v1wRBltPHKrjMqVU9re6-y3nd4UbwWtIZzmfMJ_oRwo2ne_UdU_Ya2I5EOH3qh1cUIhdG3NpZYXwFICsNZURJWZM_U7OqJrZPuMXw4sfD6iGRWeMtOiAI8YN1LAfpj1RHaeOa66DK_LEsSLBsb2W6m7wrugk7SBCJSkMyec7ZVGLHo5Ha-X5wNO5qAAKzud0lz2KVcvwJW8lkcc9_lPxPIoDIpdCFEoG5xZHr0B2PkatCS8f31VQzP6LAmvkmHxbENb6V3Ov90RGw
```

将以上内容复制备用。

## 三 查看结果

3.1 打开浏览器输入访问地址:<https://NodeIP:PORT>。此处输入Node-2的访问地址：<https://172.31.3.12:31269>，其他节点亦如此。如下图：
![添加例外](https://img-blog.csdnimg.cn/20190131214420608.png)

3.2 认证方式选择口令，输入刚才获取到的token，即可登陆成功。
![填入token](https://img-blog.csdnimg.cn/20190131214705832.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3NvbGFyYWNlYm95,size_16,color_FFFFFF,t_70)

3.3 登录成功后，如下图：
![登录成功](https://img-blog.csdnimg.cn/20190131215058826.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3NvbGFyYWNlYm95,size_16,color_FFFFFF,t_70)

## 四 总结

4.1 这是一个简单而快乐的过程，只要动手去做，其实很简单的！

4.2 这次实验是部署在kubernetes v1.12.1的。

4.3 实验使用的浏览器是Firefox v64.0.2，其他浏览器可能不支持。