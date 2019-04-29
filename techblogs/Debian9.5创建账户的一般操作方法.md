之前一直使用的是CentOS7.X的系统，最近上新项目，操作系统被换成了Debian9.X系列。由于习惯了之前CentOS7.X的操作，直接useradd用户名就完事。使用新账户登陆后才发现情况不对劲，看了一下用户设置才知道跟CentOS7.X完全不一样：

Debian9.5：
```
root@Debian-95:/home# useradd -D
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/sh
SKEL=/etc/skel
CREATE_MAIL_SPOOL=no
```
CentOS7.X:
```
[root@CentOS-1804 ~]# useradd -D
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```
姿势不对，改进一下：
```
root@Debian-95:/home# useradd -m -c "ChatDevOps account!" -s /bin/bash ivan
```
选项-m，指定在创建账户的同时创建用户的home目录，该目录默认路径为：/home/$USER。如果需要指定其他目录，可以使用选项-d（需要提前建好相关目录）。选项-c则指定了账户注释，简明扼要介绍一下账户的用途。选项-s指定账户的登陆shell。如果不指定要加入的组，则在创建账户的同时会创建与账户同名的组。同时也会将/etc/skel目录下的相关文件复制过来。当然，如果嫌以上步骤麻烦，也可以使用adduser命令来直接添加用户，根据提示填写必要信息就行，省时省力，简明扼要。在CentOS7.X系列下，useradd和adduser是一样的。
```
root@Debian-95:~# adduser ivan
Adding user `ivan' ...
Adding new group `ivan' (1000) ...
Adding new user `ivan' (1000) with group `ivan' ...
Creating home directory `/home/ivan' ...
Copying files from `/etc/skel' ...
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
Changing the user information for ivan
Enter the new value, or press ENTER for the default
        Full Name []:
        Room Number []:
        Work Phone []:
        Home Phone []:
        Other []:
Is the information correct? [Y/n] y
```

**问题：**
这样创建出来的账户在使用方面是没有问题的，但是仍然存在一个缺陷，那就是缺少mail spool。在使用命令userdel -r ivan删除账户的时候会提示找不到邮件池：
```
root@Debian-95:~# userdel -r ivan
userdel: ivan mail spool (/var/mail/ivan) not found
```
Google查了很久也没找到合适的解决方案，修改/etc/login.defs及/etc/default/useradd都试过了，问题最终还是得不到解决，如果有知道的朋友麻烦告知一下，万谢。
