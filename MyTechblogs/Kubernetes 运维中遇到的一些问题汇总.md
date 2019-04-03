# Kubernetes 运维中遇到的一些问题汇总

**问题 一** 进入容器时报错。

```bash
$ kubectl exec -it app-5f9c4c4c46-zwm4s sh
----------------------------------------------
error: unable to upgrade connection: Forbidden (user=system:anonymous, verb=create, resource=nodes, subresource=proxy)
```

**解决方案：** 绑定一个cluster-admin的权限。

```bash
$ kubectl create clusterrolebinding system:anonymous   --clusterrole=cluster-admin   --user=system:anonymous
-----------------PartingLine------------------------
clusterrolebinding.rbac.authorization.k8s.io/system:anonymous created
```