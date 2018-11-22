# 一.概述
Kubernetes通过Volume提供了良好的数据持久化方案，解决了一些在日常使用过程中的一些简单场景中关于数据持久化的一些问题。通过之前的文章，我们能够明显体会到Volume的局限性。通常情况下，Pod一般由开发人员进行使用和维护，而数据的存储则由系统运维人员或者存储管理人员进行维护。在规模较小的集群或者测试环境中，我们可能会经常看到开发人员既是Pod的使用和维护者，又是存储的管理或维护者。但是，对于大规模的集群或者要求较为严苛的生产环境，这样的管理模式造成了开发人员和运维人员工作职责的耦合，存在严重的管理缺陷和安全隐患。针对于这种情况，Kubernetes提供的解决方案是PersistentVolume（PV）和PersistentVolumeClaim（PVC）。PV是外部存储系统的一部分存储空间，由管理员创建，生命周期独立于Pod。PVC是对PV的申请，PVC通常由用户维护和使用，Kubernetes会根据用户的申请要求查找并提供满足条件的PV。
# 二.操作步骤
## 2.1 搭建NFS
实验环境资源有限，我就在Master节点部署了一个可以被任何主机以root身份挂载的NFS服务器。通过以下简单几步即可完成。
```bash
[root@k8s-m ~]# yum -y install nfs-utils
[root@k8s-m ~]# mkdir /nfs
[root@k8s-m ~]# echo "/nfs *(rw,no_root_squash)">/etc/exports
[root@k8s-m ~]# cat /etc/exports
/nfs *(rw,no_root_squash)
[root@k8s-m ~]# systemctl start rpcbind
[root@k8s-m ~]# systemctl enable rpcbind
[root@k8s-m ~]# systemctl start nfs
[root@k8s-m ~]# systemctl enable nfs
[root@k8s-m k8s-PV-PVC]# showmount -e
Export list for k8s-m:
/nfs *
```
## 2.2 创建PV
创建名称为gysl-pv的PV的YAML文件如下：
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gysl-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: nfs
  nfs:
    path: /nfs/gysl-pv
    server: 172.31.3.11
```
执行创建并查看新建的PV详情：
```bash
[root@k8s-m k8s-PV-PVC]# kubectl apply -f pv.yaml
persistentvolume/gysl-pv created
[root@k8s-m k8s-PV-PVC]# kubectl get persistentvolume
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
gysl-pv   1Gi        RWO            Recycle          Available           nfs                     28s
```
## 2.3 创建PVC
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gysl-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: nfs
```
```bash
[root@k8s-m k8s-PV-PVC]# kubectl apply -f pvc.yaml
persistentvolumeclaim/gysl-pvc created
[root@k8s-m k8s-PV-PVC]# kubectl get pvc
NAME       STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
gysl-pvc   Bound    gysl-pv   1Gi        RWO            nfs            48s
```
## 2.4 使用存储
```yaml

```
```bash
[root@k8s-m k8s-pv-pvc]# kubectl apply -f pod-pvc.yaml
pod/gysl-pod-pvc created
```
# 四.相关资料
4.1 [NFS相关](https://blog.csdn.net/solaraceboy/article/details/78743563)

4.2 [PV相关官方文档](https://kubernetes.io/docs/concepts/storage/persistent-volumes)
