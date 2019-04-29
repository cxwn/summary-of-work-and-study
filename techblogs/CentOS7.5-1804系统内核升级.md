# 一.背景
根据Linux官方网站（https://www.kernel.org）显示，目前Linux的最新内核是4.19，但是Redhat最新版系统中内核版本还是3.10.*，明显落后很多版本。有些软件对系统内核版本就有要求，因此我们就需要把系统内核升级到指定版本（RPM下载地址：https://elrepo.org/linux/kernel ），本文升级到了最新的内核版本。在CentOS中，ELRope是使用较广泛的源。
# 二.操作步骤
1. 配置ELRepo仓库。
```bash
[root@gysl ~]# rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
[root@gysl ~]# rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
获取http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
获取http://elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
准备中...                          ################################# [100%]
正在升级/安装...
1:elrepo-release-7.0-3.el7.elrepo  ################################# [100%]
```
2. 列出可以安装的Kernel及相关组件。
```bash
[root@gysl ~]# yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
已加载插件：fastestmirror
Determining fastest mirrors
 * elrepo-kernel: mirrors.tuna.tsinghua.edu.cn
elrepo-kernel                                                                                                                                                         | 2.9 kB  00:00:00     
elrepo-kernel/primary_db                                                                                                                                              | 1.8 MB  00:00:02     
可安装的软件包
kernel-lt.x86_64                                                                              4.4.162-1.el7.elrepo                                                              elrepo-kernel
kernel-lt-devel.x86_64                                                                        4.4.162-1.el7.elrepo                                                              elrepo-kernel
kernel-lt-doc.noarch                                                                          4.4.162-1.el7.elrepo                                                              elrepo-kernel
kernel-lt-headers.x86_64                                                                      4.4.162-1.el7.elrepo                                                              elrepo-kernel
kernel-lt-tools.x86_64                                                                        4.4.162-1.el7.elrepo                                                              elrepo-kernel
kernel-lt-tools-libs.x86_64                                                                   4.4.162-1.el7.elrepo                                                              elrepo-kernel
kernel-lt-tools-libs-devel.x86_64                                                             4.4.162-1.el7.elrepo                                                              elrepo-kernel
kernel-ml.x86_64                                                                              4.19.0-1.el7.elrepo                                                               elrepo-kernel
kernel-ml-devel.x86_64                                                                        4.19.0-1.el7.elrepo                                                               elrepo-kernel
kernel-ml-doc.noarch                                                                          4.19.0-1.el7.elrepo                                                               elrepo-kernel
kernel-ml-headers.x86_64                                                                      4.19.0-1.el7.elrepo                                                               elrepo-kernel
kernel-ml-tools.x86_64                                                                        4.19.0-1.el7.elrepo                                                               elrepo-kernel
kernel-ml-tools-libs.x86_64                                                                   4.19.0-1.el7.elrepo                                                               elrepo-kernel
kernel-ml-tools-libs-devel.x86_64                                                             4.19.0-1.el7.elrepo                                                               elrepo-kernel
perf.x86_64                                                                                   4.19.0-1.el7.elrepo                                                               elrepo-kernel
python-perf.x86_64                                                                            4.19.0-1.el7.elrepo                                                               elrepo-kernel
```
3. 安装最新版的内核。kernel-ml是Mainline版本(it=long-term)，这个版本的内核会引入所有新功能，新的Mainline内核每2-3 个月发布一次。
```bash
[root@gysl ~]# yum --enablerepo=elrepo-kernel install kernel-ml -y
已加载插件：fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.tuna.tsinghua.edu.cn
 * elrepo: mirrors.tuna.tsinghua.edu.cn
 * elrepo-kernel: mirrors.tuna.tsinghua.edu.cn
 * extras: mirrors.163.com
 * updates: mirrors.tuna.tsinghua.edu.cn
base                                                                                                                                                                  | 3.6 kB  00:00:00     
elrepo                                                                                                                                                                | 2.9 kB  00:00:00     
extras                                                                                                                                                                | 3.4 kB  00:00:00     
updates                                                                                                                                                               | 3.4 kB  00:00:00     
(1/3): extras/7/x86_64/primary_db                                                                                                                                     | 204 kB  00:00:01     
(2/3): updates/7/x86_64/primary_db                                                                                                                                    | 6.0 MB  00:00:07     
(3/3): elrepo/primary_db                                                                                                                                              | 530 kB  00:00:07     
正在解决依赖关系
--> 正在检查事务
---> 软件包 kernel-ml.x86_64.0.4.19.0-1.el7.elrepo 将被 安装
--> 解决依赖关系完成

依赖关系解决

=============================================================================================================================================================================================
 Package                                   架构                                   版本                                                   源                                             大小
=============================================================================================================================================================================================
正在安装:
 kernel-ml                                 x86_64                                 4.19.0-1.el7.elrepo                                    elrepo-kernel                                  46 M

事务概要
=============================================================================================================================================================================================
安装  1 软件包

总下载量：46 M
安装大小：205 M
Downloading packages:
kernel-ml-4.19.0-1.el7.elrepo.x86_64.rpm                                                                                                                          |  46 MB  00:01:54     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
警告：RPM 数据库已被非 yum 程序修改。
  正在安装    : kernel-ml-4.19.0-1.el7.elrepo.x86_64                           1/1 
  验证中      : kernel-ml-4.19.0-1.el7.elrepo.x86_64                                                                                                                                     1/1 
已安装:
  kernel-ml.x86_64 0:4.19.0-1.el7.elrepo                                                                                                                                                     
完毕！
[root@gysl ~]# reboot
```
4. 重启系统后，手动选择新内核，如果出现如下内容，则说明升级成功。

![VMWare](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/VMWare-Kernel.png)
5. 登入系统，查看相关系统信息。
```bash
[root@gysl ~]# hostnamectl 
   Static hostname: gysl
         Icon name: computer-vm
           Chassis: vm
        Machine ID: ec3aaeb5faad4f0dbe7121416e9af1c8
           Boot ID: 66ff8175b82641328795dbf951c63d7a
    Virtualization: vmware
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 4.19.0-1.el7.elrepo.x86_64
      Architecture: x86-64
[root@gysl ~]# uname -sr
Linux 4.19.0-1.el7.elrepo.x86_64
[root@gysl ~]# cat /etc/centos-release
CentOS Linux release 7.5.1804 (Core)
```
6. 将新内核设置为默认引导内核并创建新内核的配置文件。默认启动的顺序应该为1,升级以后内核是往前面插入，值为0（如果每次启动时需要手动选择哪个内核，该步骤可以省略）
```bash
[root@gysl ~]# grub2-set-default 0
[root@gysl ~]# grub2-mkconfig -o /etc/grub2.cfg 
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-4.19.0-1.el7.elrepo.x86_64
Found initrd image: /boot/initramfs-4.19.0-1.el7.elrepo.x86_64.img
Found linux image: /boot/vmlinuz-3.10.0-862.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-ec3aaeb5faad4f0dbe7121416e9af1c8
Found initrd image: /boot/initramfs-0-rescue-ec3aaeb5faad4f0dbe7121416e9af1c8.img
done
```
7. 安装命令自动提示包。此步骤仅仅是为了使用更加方便而提及，并非必须步骤。安装这个包之后，键入命令后能够进一步提示，比如 键入systemctl后，按tab建即可进一步提示，该包安装完成之后需要重启。
```bash
[root@gysl ~]# yum install  -y bash-completion
[root@gysl ~]# reboot
[root@gysl ~]# systemctl re
reboot                 reload                 reload-or-try-restart  reset-failed
reenable               reload-or-restart      rescue                 restart
```
8. 使用官方源进行内核更新。官方也提供内核更新，但是比较有局限性，智能升级到官方指定的最新版，可能达不到要求。
```bash
[root@gysl ~]# yum -y update kernel
```
9. 删除旧版本的内核。
```bash
[root@gysl ~]# rpm -qa|grep kernel
kernel-tools-3.10.0-862.el7.x86_64
kernel-ml-4.19.0-1.el7.elrepo.x86_64
kernel-tools-libs-3.10.0-862.el7.x86_64
kernel-3.10.0-862.el7.x86_64
kernel-3.10.0-862.14.4.el7.x86_64
```
使用rpm和yum remove命令均可删除旧版本的内核或组件(以下命令删除的是最新版本的内核，操作类似)。可以安装新的组件之后再删除旧版本的组件。
```bash
[root@gysl ~]# rpm -e kernel-ml-4.19.0-1.el7.elrepo.x86_64
```

# 三.总结
1. 系统的内核升级是一个需要谨慎操作的过程，需要我们胆大心细。需要在测试环境内进行了严格的测试才能上线到生产环境。
2. 在写本文时，我已经在VMWare和Hyper-V平台上均进行过相同步骤的操作，发现在Hyper-V平台上升级完成之后无法正常启动，找不到相关日志记录。我的系统信息如下：
```bash
[root@gysl ~]# hostnamectl
   Static hostname: gysl
         Icon name: computer-vm
           Chassis: vm
        Machine ID: ca4cb61abf7748a7bae1dd5a94c4c9da
           Boot ID: ff1263b7386f49bd9f4681fd6b6bc964
    Virtualization: microsoft
  Operating System: CentOS Linux 7 (Core)
       CPE OS Name: cpe:/o:centos:centos:7
            Kernel: Linux 3.10.0-862.el7.x86_64
      Architecture: x86-64
```
启动界面如下：
![Hyper-V](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/Hyper-V-Kernel.png)
目前还未在kvm平台上进行过测试，不知道具体情况。

如果有知道怎么解决在Hyper-V虚拟化环境中内核升级后不能正常进入系统的办法的小伙伴，敬请赐教，不胜感激。
# 四.参考资料
1. http://elrepo.org/tiki/kernel-ml
2. https://www.kernel.org