# 一.引言
存储的选型、规划与管理等工作一直以来都是日常系统运维工作中的重点。MBR与GPT两种类型的分区表的选择与使用则是在磁盘管理中需要根据应用场景来注或考虑的要点。结合笔者多年的运维工作经验，引发了对这些问题的一些思考，借此文进行一些分享。
# 二.相关知识点
## 2.1 MBR 
主引导记录（Master Boot Record，缩写：MBR），又叫做主引导扇区，是计算机开机后访问硬盘时所必须要读取的首个扇区，它在硬盘上的三维地址为（柱面，磁头，扇区）＝（0，0，1）。在深入讨论主引导扇区内部结构的时候，有时也将其开头的446字节内容特指为“主引导记录”（MBR），其后是4个16字节的“磁盘分区表”（DPT），以及2字节的结束标志（55AA）。因此，在使用“主引导记录”（MBR）这个术语的时候，需要根据具体情况判断其到底是指整个主引导扇区，还是主引导扇区的前446字节。

主引导扇区记录着硬盘本身的相关信息以及硬盘各个分区的大小及位置信息，是数据信息的重要入口。如果它受到破坏，硬盘上的基本数据结构信息将会丢失，需要用繁琐的方式试探性的重建数据结构信息后才可能重新访问原先的数据。主引导扇区内的信息可以通过任何一种基于某种操作系统的分区工具软件写入，但和某种操作系统没有特定的关系，即只要创建了有效的主引导记录就可以引导任意一种操作系统（操作系统是创建在高级格式化的硬盘分区之上，是和一定的文件系统相联系的）。

对于硬盘而言，一个扇区可能的字节数为128×2n（n=0,1,2,3）。大多情况下，取n=2，即一个扇区（sector）的大小为512字节。
## 2.2 GPT
全局唯一标识分区表（GUID Partition Table，缩写：GPT）是一个实体硬盘的分区表的结构布局的标准。它是可扩展固件接口（EFI）标准（被Intel用于替代个人计算机的BIOS）的一部分，被用于替代BIOS系统中的一32bits来存储逻辑块地址和大小信息的主引导记录（MBR）分区表。对于那些扇区为512字节的磁盘，MBR分区表不支持容量大于2.2TB（2.2×1012字节）的分区，然而，一些硬盘制造商（诸如希捷和西部数据）注意到这个局限性，并且将他们的容量较大的磁盘升级到4KB的扇区，这意味着MBR的有效容量上限提升到16 TiB。 这个看似“正确的”解决方案，在临时地降低人们对改进磁盘分配表的需求的同时，也给市场带来关于在有较大的块（block）的设备上从BIOS启动时，如何最佳的划分磁盘分区的困惑。GPT分配64bits给逻辑块地址，因而使得最大分区大小在264-1个扇区成为可能。对于每个扇区大小为512字节的磁盘，那意味着可以有9.4ZB（9.4×1021字节）或8 ZiB个512字节（9,444,732,965,739,290,426,880字节或18,446,744,073,709,551,615（264-1）个扇区×512（29）字节每扇区）。
## 2.3 MBR与GPT的关系
与支持最大卷为2TB（Terabytes）并且每个磁盘最多有4个主分区（或3个主分区，1个扩展分区和无限制的逻辑驱动器）的MBR磁盘分区的类型相比，GPT磁盘分区样式支持最大为128个分区，一个分区最大18EB（Exabytes），只受到操作系统限制（由于分区表本身需要占用一定空间，最初规划硬盘分区时，留给分区表的空间决定了最多可以有多少个分区，IA-64版Windows限制最多有128个分区，这也是EFI标准规定的分区表的最小尺寸）。与MBR分区的磁盘不同，至关重要的平台操作数据位于分区，而不是位于非分区或隐藏扇区。另外，GPT分区磁盘有备份分区表来提高分区数据结构的完整性。在UEFI系统上，通常是通过ESP分区中的EFI应用程序文件启动GPT硬盘上的操作系统，而不是活动主分区上的引导程序。

在RHEL7系列及周边发行版中，MBR类型的分区表是系统缺省配置，如需使用GPT类型的分区表，还需要进行特殊配置（下文会进行介绍）。

# 三.实验过程
## 3.1 在CentOS7.5中以GPT类型安装操作系统
默认情况下，CentOS7系列是以MBR类型的分区表来安装操作系统的，如果不通过特殊设置，那么在GUI安装界面无法选择GPT分区表类型的。在安装操作系统选择的引导界面，讲光标移到第一行，按下Tab键，插入一个空格，输入inst gpt，按下回车键，继续引导，即可将操作系统安装到分区表类型为GPT的分区下。具体如下图：
![GPT](https://raw.githubusercontent.com/mrivandu/WorkAndStudy/master/MyImageHostingService/gpt.png)
其他安装、操作过程，大同小异。
## 3.2 查看、磁盘或分区的常用工具
```bash
[root@gpt ~]# lsblk
NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0                   2:0    1    4K  0 disk
sda                   8:0    0   10G  0 disk
├─sda1                8:1    0    1M  0 part
├─sda2                8:2    0    1G  0 part /boot
└─sda3                8:3    0    9G  0 part
  ├─centos_gpt-root 253:0    0    8G  0 lvm  /
  └─centos_gpt-swap 253:1    0    1G  0 lvm  [SWAP]
sr0                  11:0    1 1024M  0 rom
[root@gpt ~]# fdisk -l /dev/sda
WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.
磁盘 /dev/sda：10.7 GB, 10737418240 字节，20971520 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 4096 字节
I/O 大小(最小/最佳)：4096 字节 / 4096 字节
磁盘标签类型：gpt
Disk identifier: 3B24C802-3FC5-4D42-9D76-F9D7250B310B
#         Start          End    Size  Type            Name
 1         2048         4095      1M  BIOS boot
 2         4096      2101247      1G  Microsoft basic
 3      2101248     20969471      9G  Linux LVM
[root@gpt ~]# parted /dev/sda print
Model: Msft Virtual Disk (scsi)
Disk /dev/sda: 10.7GB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags: pmbr_boot
Number  Start   End     Size    File system  Name  标志
 1      1049kB  2097kB  1049kB                     bios_grub
 2      2097kB  1076MB  1074MB  xfs
 3      1076MB  10.7GB  9661MB                     lvm
[root@gpt ~]# cfdisk /dev/sda
                                                                          cfdisk (util-linux 2.23.2)
                                                                          磁盘驱动器：/dev/sda
                                                                     大小：10737418240 字节，10.7 GB
                                                       磁头数：255  每磁道扇区数：63        柱面数：1305

        名称                       标志                     分区类型               文件系统                            [标签]                         大小 (MB)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        sda1                       启动，不可用              主分区                GPT                                                                 10737.42               *
```
以上内容主要展示了lsblk、fdisk、parted、cfdisk等四款工具。lsblk主要用于查看磁盘及分区情况，fdisk为较为常用的分区工具，支持2TB以下容量的磁盘的分区操作，如果超过2TB以上容量的磁盘，则需要使用parted来进行分区，cfdisk则是一款比较容易上手的分区工具。这些工具在之前的文章中有介绍，可以查阅之前文章。
## 3.3 MBR类型的分区表使用心得
```bash
[root@mbr ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0               2:0    1    4K  0 disk
sda               8:0    0   10G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    9G  0 part
  ├─centos-root 253:0    0    8G  0 lvm  /
  └─centos-swap 253:1    0    1G  0 lvm  [SWAP]
sdb               8:16   0    1G  0 disk
sdc               8:32   0    1G  0 disk
sdd               8:48   0    1G  0 disk
sde               8:64   0    1G  0 disk
sr0              11:0    1 1024M  0 rom
[root@gpt ~]# fdisk -l /dev/sdb
WARNING: fdisk GPT support is currently new, and therefore in an experimental phase. Use at your own discretion.
设备      Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048      501759      249856   83  Linux
/dev/sdb2          501760      706559      102400   83  Linux
/dev/sdb3          706560      911359      102400   83  Linux
/dev/sdb4          911360     1105919       97280   83  Linux
命令(输入 m 获取帮助)：n
If you want to create more than four partitions, you must replace a
primary partition with an extended partition first.
命令(输入 m 获取帮助)：w
The partition table has been altered!
Calling ioctl() to re-read partition table.
正在同步磁盘。
[root@mbr ~]# partprobe
[root@mbr ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0               2:0    1    4K  0 disk
sda               8:0    0   10G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    9G  0 part
  ├─centos-root 253:0    0    8G  0 lvm  /
  └─centos-swap 253:1    0    1G  0 lvm  [SWAP]
sdb               8:16   0    1G  0 disk
├─sdb1            8:17   0  244M  0 part
├─sdb2            8:18   0  100M  0 part
├─sdb3            8:19   0  100M  0 part
└─sdb4            8:20   0   95M  0 part
sdc               8:32   0    1G  0 disk
sdd               8:48   0    1G  0 disk
sde               8:64   0    1G  0 disk
sr0              11:0    1 1024M  0 rom
```
从上面的实验，我们可以看出，MBR类型的分区表在使用过程中会造成h       储空间的浪费。也就是说，一块磁盘，创建了4个主分区，如果4个主分区的空间使用总和小于磁盘实际可用空间，那么就无法再继续进行分区操作，因此是无法充分利用这些磁盘空间的。

删除这些分区后，从该磁盘第4个分区开始，系统默认使用扩展分区，通过扩展分区新建分区，存储空间浪费的情况同样存在。
```bash
[root@mbr ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0               2:0    1    4K  0 disk
sda               8:0    0   10G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    9G  0 part
  ├─centos-root 253:0    0    8G  0 lvm  /
  └─centos-swap 253:1    0    1G  0 lvm  [SWAP]
sdb               8:16   0    1G  0 disk
├─sdb1            8:17   0  100M  0 part
├─sdb2            8:18   0  100M  0 part
├─sdb3            8:19   0  100M  0 part
├─sdb4            8:20   0    1K  0 part
├─sdb5            8:21   0   10M  0 part
├─sdb6            8:22   0   10M  0 part
└─sdb7            8:23   0   77M  0 part
sdc               8:32   0    1G  0 disk
sdd               8:48   0    1G  0 disk
sde               8:64   0    1G  0 disk
sr0              11:0    1 1024M  0 rom
```
下面依然使用fdisk对磁盘sdb进行分区，但是把磁盘的分区表类型改成了GPT，部分结果如下：
```bash
[root@gpt ~]# fdisk -l /dev/sdb
命令(输入 m 获取帮助)：g
Building a new GPT disklabel (GUID: 757B3774-B7F0-4650-80B1-EAA13E59C602)
将显示/记录单位更改为盲区。
命令(输入 m 获取帮助)：n
分区号 (1-128，默认 1)：
第一个扇区 (2048-2097118，默认 2048)：
Last sector, +sectors or +size{K,M,G,T,P} (2048-2097118，默认 2097118)：+100M
已创建分区 1
命令(输入 m 获取帮助)：p
磁盘 /dev/sdb：1073 MB, 1073741824 字节，2097152 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 4096 字节
I/O 大小(最小/最佳)：4096 字节 / 4096 字节
磁盘标签类型：gpt
Disk identifier: 757B3774-B7F0-4650-80B1-EAA13E59C602
#         Start          End    Size  Type            Name
 1         2048       206847    100M  Linux filesyste
[root@mbr ~]# partprobe
[root@mbr ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
fd0               2:0    1    4K  0 disk
sda               8:0    0   10G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0    9G  0 part
  ├─centos-root 253:0    0    8G  0 lvm  /
  └─centos-swap 253:1    0    1G  0 lvm  [SWAP]
sdb               8:16   0    1G  0 disk
├─sdb1            8:17   0  100M  0 part
├─sdb2            8:18   0  100M  0 part
├─sdb3            8:19   0  100M  0 part
├─sdb4            8:20   0  100M  0 part
├─sdb5            8:21   0  100M  0 part
├─sdb6            8:22   0  100M  0 part
└─sdb7            8:23   0  423M  0 part
sdc               8:32   0    1G  0 disk
sdd               8:48   0    1G  0 disk
sde               8:64   0    1G  0 disk
sr0              11:0    1 1024M  0 rom
```
从操作过程中，我们可用看到，分区号1-128，与前文所述一致。磁盘分区之后可用空间与实际空间差距不大，存储空间浪费较小。

# 四.总结
4.1 在RHEL7.X系列及周边发行版中，在磁盘空间小于2TB的系统安装过程中采用的默认的分区类型是MBR，如需使用GPT还需特殊设置。

4.2 对于存储空间大于2TB的存储设备，尽量在使用GPT类型的分区表，避免造成存储空间的浪费。

4.3 在存储空间的使用之前，要明确用途，对数据的总量有一个总体性的把握。

4.4 在基于VMware、KVM等技术架构的云计算平台中，磁盘空间的扩展尽量以独立磁盘设备的形式进行扩展，尽量减少在原磁盘上进行空间扩展这一类操作。因为在前文已经提及，默认情况下RHEL7.X的磁盘分区类型为MBR。也就是说，在原磁盘上进行空间扩展的话，每次都新建主分区，那么最多只能扩展4次，即使后期以扩展分区进行扩展，规划不慎，也是会造成存储空间的浪费。这一点笔者在过去两三年的运维生涯中深有感悟。

4.5 针对不同规格的存储设备，分区工具的选择也是有要求的，这一点需要特别注意。