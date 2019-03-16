# 一个限制进程 CPU 使用率的解决方案

## 一 背景

在最近的一个项目中，需要限制 CPU 使用率。通过查阅各种资料，发现已经有直接可以使用的软件可以使用，这个软件就是cpulimit，这个软件使用非常简单。但是，结合实际使用场景，被限制的进程不能后台运行，一旦后台运行，进程即会立刻退出，而且该进程运行一段时间后会产生子进程及相关进程。针对这种情况，经过思考，通过以下解决方案解决该问题。

## 二 解决步骤

### 2.1 安装cpulimit

```bash
[root@gysl-dev ~]# yum -y install epel-release
[root@gysl-dev ~]# yum -y install cpulimit
```

### 2.2 执行脚本

```bash
[root@gysl-dev ~]# sh cpulimit.sh
```

cpulimit.sh脚本内容：

```bash
#!/bin/bash
while true;  
    do  
        sleep 30;
        pgrep palrun>&/dev/null;  
        if [ $? -eq 0 ]; then  
            for pid in `pgrep palrun`;  
                do  
                    cpulimit -l 70 -p $pid &  
                done;  
        break;
        fi;  
        done &
```

将以上脚本加入到需要限制 CPU 使用率的进行启动脚本的最前面，对该脚本的解释。

由于需要限制 CPU 使用率的进程不能在后台运行，所以把限制脚本加入到启动脚本的最前面，并切换到后台运行，sleep 30秒，待需要限制的进程启动并创建子进程后对其进行限制。

## 三 总结

### 3.1 官方帮助信息

```bash
[root@gysl-dev ~]# cpulimit --help
Usage: cpulimit [OPTIONS...] TARGET
   OPTIONS
      -l, --limit=N          percentage of cpu allowed from 0 to 100 (required) #限制 CPU 使用百分比
      -v, --verbose          show control statistics #显示控制统计
      -z, --lazy             exit if there is no target process, or if it dies
      -i, --include-children limit also the children processes #同时也限制子进程
      -h, --help             display this help and exit
   TARGET must be exactly one of these:
      -p, --pid=N            pid of the process (implies -z)
      -e, --exe=FILE         name of the executable program file or path name
      COMMAND [ARGS]         run this command and limit it (implies -z)
```

### 3.2 cpulimit命令使用实践

```txt
[root@gysl-dev ~]# cpulimit -l 70 -v -p 6258
1 cpu detected
Process 6258 found
Priority changed to -10
Members in the process group owned by 6258: 1

%CPU    work quantum    sleep quantum   active rate
70.09%   73424 us        26575 us       73.42%
69.86%   70778 us        29221 us       70.78%
69.94%   71703 us        28296 us       71.70%
69.77%   70495 us        29504 us       70.50%
69.91%   74194 us        25805 us       74.19%
69.49%   69281 us        30718 us       69.28%
69.78%   72668 us        27331 us       72.67%
70.35%   70634 us        29365 us       70.63%
69.66%   72786 us        27213 us       72.79%
70.27%   69679 us        30320 us       69.68%
69.56%   72325 us        27674 us       72.33%
70.40%   71926 us        28073 us       71.93%
69.43%   71330 us        28669 us       71.33%
69.50%   72184 us        27815 us       72.18%
70.16%   69835 us        30164 us       69.84%
69.37%   74080 us        25919 us       74.08%
69.84%   69417 us        30582 us       69.42%
69.95%   71415 us        28584 us       71.42%
70.81%   71334 us        28665 us       71.33%
```