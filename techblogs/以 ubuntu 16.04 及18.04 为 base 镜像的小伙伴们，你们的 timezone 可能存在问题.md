# 以 ubuntu 16.04 及18.04 为 base 镜像的小伙伴们，你们的 timezone 可能存在问题

/usr/share/zoneinfo/Asia/Shanghai:/usr/share/zoneinfo/Etc/UTC -TZ Asia/Shanghai NO
/usr/share/zoneinfo/Asia/Shanghai:/usr/share/zoneinfo/Etc/UTC +TZ Asia/Shanghai NO
/usr/share/zoneinfo/Asia/Shanghai:/usr/share/zoneinfo/Asia/Shanghai -OK
/usr/share/zoneinfo/Asia/Shanghai:/etc/localtime
