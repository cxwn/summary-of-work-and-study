# 一.问题背景
在Zabbix安装完成之后，Web前端页面语音设置为中文之后，图表中部分中文文字显示为乱码，如下图所示：
![乱码](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/Zabbix-error-1.png)
# 二.解决方案
## 2.1 执行以下命令
```bash
[root@zabbix ~]# yum -y install wqy-microhei-fonts
[root@zabbix ~]# cp /usr/share/fonts/wqy-microhei/wqy-microhei.ttc /usr/share/fonts/dejavu/DejaVuSans.ttf
cp：是否覆盖"/usr/share/fonts/dejavu/DejaVuSans.ttf"？ y
```
## 2.2 处理结果
刷新页面后，再次观察：
![处理结果](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/Zabbix-error-2.png)
问题成功解决。