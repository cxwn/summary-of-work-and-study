# 一键批量关闭 Linux 的 tty 的方法

## 一 背景

在日常工作中，由于各种原因，可能需要关闭一些不必要的 tty。比如：服务器被非法登录、忘记关闭某些设备上已登录的 tty、终止一些不使用的tty等场景就需要批量强制关闭 tty。

## 二 解决方案

解决方案主要使用了几个常用的命令，不做介绍。

```bash
#!/bin/bash
#===============================================================================
#          FILE: anytest.sh
#         USAGE: . ${YOUR_PATH}/anytest.sh
#   DESCRIPTION:
#        AUTHOR: IVAN DU
#        E-MAIL: mrivandu@hotmail.com
#        WECHAT: ecsboy
#      TECHBLOG: https://ivandu.blog.csdn.net
#        GITHUB: https://github.com/mrivandu
#       CREATED: 2019-10-31 14:56:24
#       LICENSE: GNU General Public License.
#     COPYRIGHT: © IVAN DU 2019
#      REVISION: v1.0
#===============================================================================

#!/bin/bash

for tty in `w -s|awk 'NR>2{print $2}'`;
do
  if [ "/dev/${tty}" != $(tty) ] ;
    then ps -t /dev/${tty}|awk 'NR>1{print $1}'|xargs kill -9;
  fi;
done
```

## 三 总结

- 3.1 脚本加了一个 if 判断，主要是判断杀死的 tty 并非当前在使用的 tty。

- 3.2 以下 ```3.2 w -s|awk 'NR>2{print $2}'``` 这一部分命令，可以替换成 ```w -sh|awk '{print $2}'```。

- 3.3 刚好用到，随手分享一下，感谢您的阅读。
