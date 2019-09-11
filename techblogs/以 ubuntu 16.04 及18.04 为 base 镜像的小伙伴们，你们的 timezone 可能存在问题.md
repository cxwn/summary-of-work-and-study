# 以 ubuntu 16.04 及18.04 为 base 镜像的小伙伴们，你们的 timezone 可能存在问题

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
      app: timezone
  replicas: 8
  templates:
    metadata:
      labels:
        app: timezone
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
