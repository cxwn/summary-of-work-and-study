# Linux 系统中查找正在运行的进程的完整命令、当前工作目录等信息的方法

## 一 引言

在某些系统故障的排查过程中，需要找出某个应用程序的工作目录、完整命令行等信息。通常会通过ps及top等命令来查看进程信息，但往往只能查到相对路径、部分命令行等。遇到这种情况时，有些小伙伴可能就束手无策，不知所措直接去问研发的同事了。遇到这样的情况，是不是真的没有办法了呢？

## 二 知识要点

众所周知，/proc是Linux系统内的一个伪文件系统，，存储的是当前内核运行状态的一系列特殊文件，用户可以通过这些文件查看有关系统硬件及当前正在运行进程的信息，甚至可以通过更改其中某些文件来改变内核的运行状态。按照这样的思路，通过/proc目录下面的相关信息查找到对应的蛛丝马迹。Linux在启动一个进程时，系统会在/proc下创建一个以进行PID命名的目录，在该目录下保存着该进程的各种信息。具体可以通过ls命令来进行查看。

针对一些常见的内容及要点，收集整理如下：

- cmdline：启动当前进程的完整命令，但僵尸进程目录中的此文件不包含任何信息；
- cwd：指向当前进程运行目录的一个符号链接；
- environ：当前进程的环境变量列表，彼此间用空字符（NULL）隔开；变量用大写字母表示，其值用小写字母表示；
- exe：指向启动当前进程的可执行文件（完整路径）的符号链接，通过/proc/PID/exe可以启动当前进程的一个拷贝；
- fd：这是个目录，包含当前进程打开的每一个文件的文件描述符（file descriptor），这些文件描述符是指向实际文件的一个符号链接；
- limits：当前进程所使用的每一个受限资源的软限制、硬限制和管理单元；此文件仅可由实际启动当前进程的UID用户读取；（2.6.24以后的内核版本支持此功能）；
- maps：当前进程关联到的每个可执行文件和库文件在内存中的映射区域及其访问权限所组成的列表；
- mem：当前进程所占用的内存空间，由open、read和lseek等系统调用使用，不能被用户读取；
- root：指向当前进程运行根目录的符号链接；在Unix和Linux系统上，通常采用chroot命令使每个进程运行于独立的根目录；
- stat：当前进程的状态信息，包含一系统格式化后的数据列，可读性差，通常由ps命令使用；
- statm：当前进程占用内存的状态信息，通常以“页面”（page）表示；
- status：与stat所提供信息类似，但可读性较好，如下所示，每行表示一个属性信息；其详细介绍请参见 proc的man手册页；
- task：目录文件，包含由当前进程所运行的每一个线程的相关信息，每个线程的相关信息文件均保存在一个由线程号（tid）命名的目录中，这类似于其内容类似于每个进程目录中的内容（内核2.6版本以后支持此功能）

## 三 操作细节

以 dockerd 进程为例。

3.1 .查看进程执行的完整命令行：

```bash
[ivandu@cmos ~]$ cat /proc/`pgrep dockerd`/cmdline
/usr/bin/dockerd-Hfd://--containerd=/run/containerd/containerd.sock
```

3.2 查看进程的工作路径：

```bash
[ivandu@cmos ~]$ sudo ls -l /proc/`pgrep dockerd`/cwd
lrwxrwxrwx 1 root root 0 8月  13 20:25 /proc/1040/cwd -> /
```

3.2 查看每一个打开的文件描述符：

```bash
[ivandu@cmos ~]$ sudo ls -l /proc/`pgrep dockerd`/fd
总用量 0
lr-x------ 1 root root 64 8月  13 09:37 0 -> /dev/null
lrwx------ 1 root root 64 8月  13 09:37 1 -> socket:[28315]
lrwx------ 1 root root 64 8月  13 09:37 10 -> socket:[29043]
lr-x------ 1 root root 64 8月  13 09:37 11 -> net:[4026531962]
lrwx------ 1 root root 64 8月  13 09:37 12 -> socket:[30060]
lrwx------ 1 root root 64 8月  13 09:37 13 -> socket:[30061]
lrwx------ 1 root root 64 8月  13 09:37 14 -> socket:[30062]
lrwx------ 1 root root 64 8月  13 09:37 15 -> socket:[30613]
lrwx------ 1 root root 64 8月  13 09:37 16 -> /var/lib/docker/builder/fscache.db
lrwx------ 1 root root 64 8月  13 09:37 17 -> /var/lib/docker/buildkit/snapshots.db
lrwx------ 1 root root 64 8月  13 09:37 18 -> /var/lib/docker/buildkit/metadata.db
lrwx------ 1 root root 64 8月  13 09:37 19 -> /var/lib/docker/buildkit/cache.db
lrwx------ 1 root root 64 8月  13 09:37 2 -> socket:[28315]
l--------- 1 root root 64 8月  13 09:37 24 -> /run/docker/containerd/e0da6617cfbe727fb24a25887bbaf07cdc3a09042ce11250a7c883229ce2920b/init-stdin
l--------- 1 root root 64 8月  13 09:37 25 -> /run/docker/containerd/e0da6617cfbe727fb24a25887bbaf07cdc3a09042ce11250a7c883229ce2920b/init-stdout
l-wx------ 1 root root 64 8月  13 09:37 26 -> /var/lib/docker/containers/e0da6617cfbe727fb24a25887bbaf07cdc3a09042ce11250a7c883229ce2920b/e0da6617cfbe727fb24a25887bbaf07cdc3a09042ce11250a7c883229ce2920b-json.log
l-wx------ 1 root root 64 8月  13 09:37 27 -> /run/docker/containerd/e0da6617cfbe727fb24a25887bbaf07cdc3a09042ce11250a7c883229ce2920b/init-stdin
lr-x------ 1 root root 64 8月  13 09:37 28 -> /run/docker/containerd/e0da6617cfbe727fb24a25887bbaf07cdc3a09042ce11250a7c883229ce2920b/init-stdout
lrwx------ 1 root root 64 8月  13 09:37 3 -> socket:[29955]
lrwx------ 1 root root 64 8月  13 09:37 32 -> socket:[32813]
lrwx------ 1 root root 64 8月  13 09:37 4 -> socket:[29025]
lrwx------ 1 root root 64 8月  13 09:37 5 -> anon_inode:[eventpoll]
lrwx------ 1 root root 64 8月  13 09:37 6 -> socket:[22204]
lrwx------ 1 root root 64 8月  13 09:37 7 -> socket:[29957]
lrwx------ 1 root root 64 8月  13 09:37 8 -> socket:[29037]
lrwx------ 1 root root 64 8月  13 09:37 9 -> /var/lib/docker/volumes/metadata.db
```
