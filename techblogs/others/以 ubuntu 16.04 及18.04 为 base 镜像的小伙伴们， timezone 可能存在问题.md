# 以 ubuntu 16.04 及18.04 为 base 镜像的小伙伴们，timezone 可能存在问题

在

/usr/share/zoneinfo/Asia/Shanghai:/usr/share/zoneinfo/Etc/UTC -TZ Asia/Shanghai NO
/usr/share/zoneinfo/Asia/Shanghai:/usr/share/zoneinfo/Etc/UTC +TZ Asia/Shanghai NO
/usr/share/zoneinfo/Asia/Shanghai:/usr/share/zoneinfo/Asia/Shanghai -OK
/usr/share/zoneinfo/Asia/Shanghai:/etc/localtime

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: timezone
spec:
  selector:
    matchLabels:
      app: timezone-example
  replicas: 8
  template:
    metadata:
      labels:
        app: timezone-example
    spec:
      containers:
      - name: timezone
        image: ubuntu:18.04
        volumeMounts:
          - name: timezone
            mountPath: /usr/share/zoneinfo/Asia/Shanghai
      volumes:
        - name: timezone
          hostPath:
            path: /usr/share/zoneinfo/Asia/Shanghai
```
