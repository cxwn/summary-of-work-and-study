
[TOC]

# Linux 性能测试工具 sysbench 的安装与简单使用

## 一 背景

sysbench是一款开源的多线程性能测试工具，可以执行CPU/内存/线程/IO/数据库等方面的性能测试。
**sysbench 支持以下几种测试模式 ：**

- 1、CPU运算性能
- 2、内存分配及传输速度
- 3、磁盘IO性能
- 4、POSIX线程性能
- 5、互斥性测试
- 6、数据库性能(OLTP基准测试)。目前sysbench主要支持 MySQL,PostgreSQL 等几种数据库。

## 二 实验环境

### 2.1 操作系统

```bash
[gysl@gysl-DevOps ~]$ cat /etc/centos-release
CentOS Linux release 7.6.1810 (Core) 
```

### 2.2 其他配置

安装EPEL，安装方法之前的文章有介绍。

## 三 安装

安装命令如下：

```bash
[gysl@gysl-DevOps ~]$ sudo yum -y install sysbench
```

## 四 简单使用过程

### 4.1 查看软件版本

```bash
[gysl@gysl-DevOps ~]$ sysbench --version
sysbench 1.0.9
```

### 4.2 查看系统帮助

```bash
[gysl@gysl-DevOps ~]$ sysbench --help

See 'sysbench --test=<name> help' for a list of options for each test. #查看每个测试项目的更多选项列表
Usage:
sysbench [options]... [testname] [command]

Commands implemented by most tests: prepare run cleanup help

General options:
  --threads=N                     number of threads to use [1] #创建测试线程的数目。默认为1。  
  --events=N                      limit for total number of events [0]
  --time=N                        limit for total execution time in seconds [10]
  --forced-shutdown=STRING        number of seconds to wait after the --time limit before forcing shutdown, or 'off' to disable [off] #超过max-time强制中断。默认是off。  
  --thread-stack-size=SIZE        size of stack per thread [64K] #每个线程的堆栈大小。默认是32K。  
  --rate=N                        average transactions rate. 0 for unlimited rate [0]
  --report-interval=N             periodically report intermediate statistics with a specified interval in seconds. 0 disables intermediate reports [0]
  --report-checkpoints=[LIST,...] dump full statistics and reset all counters at specified points in time. The argument is a list of comma-separated values representing the amount of time in seconds elapsed from start of test when report checkpoint(s) must be performed. Report checkpoints are off by default. []
  --debug[=on|off]                print more debugging info [off]
  --validate[=on|off]             perform validation checks where possible [off]
  --help[=on|off]                 print help and exit [off]
  --version[=on|off]              print version and exit [off]
  --config-file=FILENAME          File containing command line options
  --tx-rate=N                     deprecated alias for --rate [0]
  --max-requests=N                deprecated alias for --events [0] #请求的最大数目。默认为10000，0代表不限制。  
  --max-time=N                    deprecated alias for --time [0] #最大执行时间，单位是s。默认是0,不限制。  
  --num-threads=N                 deprecated alias for --threads [1]

Pseudo-Random Numbers Generator options:
  --rand-type=STRING random numbers distribution {uniform,gaussian,special,pareto} [special]
  --rand-spec-iter=N number of iterations used for numbers generation [12]
  --rand-spec-pct=N  percentage of values to be treated as 'special' (for special distribution) [1]
  --rand-spec-res=N  percentage of 'special' values to use (for special distribution) [75]
  --rand-seed=N      seed for random number generator. When 0, the current time is used as a RNG seed. [0]
  --rand-pareto-h=N  parameter h for pareto distribution [0.2]

Log options:
  --verbosity=N verbosity level {5 - debug, 0 - only critical messages} [3]

  --percentile=N       percentile to calculate in latency statistics (1-100). Use the special value of 0 to disable percentile calculations [95]
  --histogram[=on|off] print latency histogram in report [off]

General database options:

  --db-driver=STRING  specifies database driver to use ('help' to get list of available drivers)
  --db-ps-mode=STRING prepared statements usage mode {auto, disable} [auto]
  --db-debug[=on|off] print database-specific debug information [off]

Compiled-in database drivers:
  mysql - MySQL driver
  pgsql - PostgreSQL driver

mysql options:
  --mysql-host=[LIST,...]          MySQL server host [localhost]
  --mysql-port=[LIST,...]          MySQL server port [3306]
  --mysql-socket=[LIST,...]        MySQL socket
  --mysql-user=STRING              MySQL user [sbtest]
  --mysql-password=STRING          MySQL password []
  --mysql-db=STRING                MySQL database name [sbtest]
  --mysql-ssl[=on|off]             use SSL connections, if available in the client library [off]
  --mysql-ssl-cipher=STRING        use specific cipher for SSL connections []
  --mysql-compression[=on|off]     use compression, if available in the client library [off]
  --mysql-debug[=on|off]           trace all client library calls [off]
  --mysql-ignore-errors=[LIST,...] list of errors to ignore, or "all" [1213,1020,1205]
  --mysql-dry-run[=on|off]         Dry run, pretend that all MySQL client API calls are successful without executing them [off]

pgsql options:
  --pgsql-host=STRING     PostgreSQL server host [localhost]
  --pgsql-port=N          PostgreSQL server port [5432]
  --pgsql-user=STRING     PostgreSQL user [sbtest]
  --pgsql-password=STRING PostgreSQL password []
  --pgsql-db=STRING       PostgreSQL database name [sbtest]

Compiled-in tests:
  fileio - File I/O test
  cpu - CPU performance test
  memory - Memory functions speed test
  threads - Threads subsystem performance test
  mutex - Mutex performance test

See 'sysbench <testname> help' for a list of options for each test.

```

### 4.3 测试过程

sysbench 的测试过程一般分为三个阶段：

- prepare：准备阶段，准备测试数据。
- run：执行测试阶段。
- cleanup：清理垃圾数据阶段。

### 4.4 CPU 性能测试

找出指定范围内最大质数，时间越短 CPU 性能越好。

#### 4.4.1 查看帮助信息

```bash
[gysl@gysl-DevOps ~]$ sysbench --test=cpu help
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

cpu options:
  --cpu-max-prime=N upper limit for primes generator [10000]
```

#### 4.4.2 测试过程

```bash
[gysl@gysl-DevOps ~]$ sudo sysbench --test=cpu --cpu-max-prime=5000 run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time

Prime numbers limit: 5000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:  3059.82

General statistics:
    total time:                          10.0002s
    total number of events:              30603

Latency (ms):
         min:                                  0.29
         avg:                                  0.33
         max:                                  6.10
         95th percentile:                      0.50
         sum:                               9979.54

Threads fairness:
    events (avg/stddev):           30603.0000/0.00
    execution time (avg/stddev):   9.9795/0.00
```

本次测试中，线程数为1，质数个数为5000。

### 4.5 内存测试

#### 4.5.1 查看帮助信息

```bash
[gysl@gysl-DevOps ~]$ sysbench --test=memory help
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

memory options:
  --memory-block-size=SIZE    size of memory block for test [1K]
  --memory-total-size=SIZE    total size of data to transfer [100G]
  --memory-scope=STRING       memory access scope {global,local} [global]
  --memory-hugetlb[=on|off]   allocate memory from HugeTLB pool [off]
  --memory-oper=STRING        type of memory operations {read, write, none} [write]
  --memory-access-mode=STRING memory access mode {seq,rnd} [seq]
```

#### 4.5.2 测试过程

```bash
[gysl@gysl-DevOps ~]$ free -h
              total        used        free      shared  buff/cache   available
Mem:           972M        137M        313M        7.6M        521M        637M
Swap:            0B          0B          0B
[gysl@gysl-DevOps ~]$ sudo sysbench --test=memory --memory-block-size=8k --memory-total-size=972M run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time

Running memory speed test with the following options:
  block size: 8KiB
  total size: 972MiB
  operation: write
  scope: global

Initializing worker threads...

Threads started!

Total operations: 124416 (1603394.35 per second)

972.00 MiB transferred (12526.52 MiB/sec)

General statistics:
    total time:                          0.0761s
    total number of events:              124416

Latency (ms):
         min:                                  0.00
         avg:                                  0.00
         max:                                  0.93
         95th percentile:                      0.00
         sum:                                 61.24

Threads fairness:
    events (avg/stddev):           124416.0000/0.00
    execution time (avg/stddev):   0.0612/0.00
```

### 4.6 磁盘I/O测试

#### 4.6.1 查看帮助信息

```bash
[gysl@gysl-DevOps ~]$ sysbench --test=fileio help
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

fileio options:
  --file-num=N              number of files to create [128]
  --file-block-size=N       block size to use in all IO operations [16384]
  --file-total-size=SIZE    total size of files to create [2G]
  --file-test-mode=STRING   test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}
  --file-io-mode=STRING     file operations mode {sync,async,mmap} [sync]
  --file-async-backlog=N    number of asynchronous operatons to queue per thread [128]
  --file-extra-flags=STRING additional flags to use on opening files {sync,dsync,direct} []
  --file-fsync-freq=N       do fsync() after this number of requests (0 - don't use fsync()) [100]
  --file-fsync-all[=on|off] do fsync() after each write operation [off]
  --file-fsync-end[=on|off] do fsync() at the end of test [on]
  --file-fsync-mode=STRING  which method to use for synchronization {fsync, fdatasync} [fsync]
  --file-merged-requests=N  merge at most this number of IO requests if possible (0 - don't merge) [0]
  --file-rw-ratio=N         reads/writes ratio for combined test [1.5]
```

#### 4.6.2 测试过程

```bash
[gysl@gysl-DevOps ~]$ sysbench --test=fileio help
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

fileio options:
  --file-num=N              number of files to create [128]
  --file-block-size=N       block size to use in all IO operations [16384]
  --file-total-size=SIZE    total size of files to create [2G]
  --file-test-mode=STRING   test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}
  --file-io-mode=STRING     file operations mode {sync,async,mmap} [sync]
  --file-async-backlog=N    number of asynchronous operatons to queue per thread [128]
  --file-extra-flags=STRING additional flags to use on opening files {sync,dsync,direct} []
  --file-fsync-freq=N       do fsync() after this number of requests (0 - don't use fsync()) [100]
  --file-fsync-all[=on|off] do fsync() after each write operation [off]
  --file-fsync-end[=on|off] do fsync() at the end of test [on]
  --file-fsync-mode=STRING  which method to use for synchronization {fsync, fdatasync} [fsync]
  --file-merged-requests=N  merge at most this number of IO requests if possible (0 - don't merge) [0]
  --file-rw-ratio=N         reads/writes ratio for combined test [1.5]

[gysl@gysl-DevOps ~]$ sudo sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw prepare
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

128 files, 8192Kb each, 1024Mb total
Creating files for the test...
Extra file open flags: 0
Creating file test_file.0
Creating file test_file.1
.......................
[gysl@gysl-DevOps ~]$ sudo sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time

Extra file open flags: 0
128 files, 8MiB each
1GiB total file size
Block size 16KiB
Number of IO requests: 0
Read/Write ratio for combined random IO test: 1.50
Periodic FSYNC enabled, calling fsync() each 100 requests.
Calling fsync() at the end of test, Enabled.
Using synchronous I/O mode
Doing random r/w test
Initializing worker threads...

Threads started!

File operations:
    reads/s:                      2042.32
    writes/s:                     1361.55
    fsyncs/s:                     4351.23

Throughput:
    read, MiB/s:                  31.91
    written, MiB/s:               21.27

General statistics:
    total time:                          10.0190s
    total number of events:              78021

Latency (ms):
         min:                                  0.00
         avg:                                  0.13
         max:                                105.19
         95th percentile:                      0.16
         sum:                               9932.94

Threads fairness:
    events (avg/stddev):           78021.0000/0.00
    execution time (avg/stddev):   9.9329/0.00
[gysl@gysl-DevOps ~]$ sudo sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw cleanup
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

Removing test files...
```

### 4.7 线程测试

#### 4.7.1 帮助信息

```bash
[gysl@gysl-DevOps ~]$ sysbench --test=threads help
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

threads options:
  --thread-yields=N number of yields to do per request [1000]
  --thread-locks=N  number of locks per thread [8]
```

#### 4.7.2 测试过程

```bash
[gysl@gysl-DevOps ~]$ sudo sysbench  --test=threads --num-threads=500 --thread-yields=100 --thread-locks=4 run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
WARNING: --num-threads is deprecated, use --threads instead
sysbench 1.0.9 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 500
Initializing random number generator from current time

Initializing worker threads...

Threads started!

General statistics:
    total time:                          10.5847s
    total number of events:              50140

Latency (ms):
         min:                                  0.15
         avg:                                104.54
         max:                               1874.74
         95th percentile:                    427.07
         sum:                            5241634.75

Threads fairness:
    events (avg/stddev):           100.2800/25.55
    execution time (avg/stddev):   10.4833/0.07
```

### 4.8 Mutex 测试

#### 4.8.1 帮助信息

```bash
[gysl@gysl-DevOps ~]$ sudo sysbench --test=mutex help
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

mutex options:
  --mutex-num=N   total size of mutex array [4096]
  --mutex-locks=N number of mutex locks to do per thread [50000]
  --mutex-loops=N number of empty loops to do outside mutex lock [10000]
```

#### 4.8.2 测试过程

```bash
[gysl@gysl-DevOps ~]$ sudo sysbench --test=mutex --mutex-num=2048 --mutex-locks=20000 --mutex-loops=5000 run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.9 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time

Initializing worker threads...

Threads started!

General statistics:
    total time:                          0.0342s
    total number of events:              1

Latency (ms):
         min:                                 33.58
         avg:                                 33.58
         max:                                 33.58
         95th percentile:                     33.72
         sum:                                 33.58

Threads fairness:
    events (avg/stddev):           1.0000/0.00
    execution time (avg/stddev):   0.0336/0.00
```

## 五 总结

5.1 对于数据库的测试，本文未进行介绍，后续遇到该情况时会进行介绍。

5.2 由于时间仓促，文章中大部分英文本人并未进行翻译，但是涉及到的英文都不算难。

5.3 磁盘I/O测试中，--file-extra-flags 选项比较重要，有的存储设备是直接I/O，其他详情还请查阅相关资料。

5.4 本文仅仅根据帮助信息整理完成，其他详情还请参考官方手册。