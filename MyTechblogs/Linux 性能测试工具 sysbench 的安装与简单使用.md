
[TOC]

# Linux 性能测试工具 sysbench 的安装与简单使用

## 一 背景

sysbench是一款开源的多线程性能测试工具，可以执行CPU/内存/线程/IO/数据库等方面的性能测试。
**sysbench 支持以下几种测试模式 ：**

- 1、CPU运算性能
- 2、磁盘IO性能
- 3、调度程序性能
- 4、内存分配及传输速度
- 5、POSIX线程性能
- 6、数据库性能(OLTP基准测试)。目前sysbench主要支持 mysql,drizzle,pgsql,oracle 等几种数据库。

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
Usage:
sysbench [options]... [testname] [command]

Commands implemented by most tests: prepare run cleanup help

General options:
  --threads=N                     number of threads to use [1]
  --events=N                      limit for total number of events [0]
  --time=N                        limit for total execution time in seconds [10]
  --forced-shutdown=STRING        number of seconds to wait after the --time limit before forcing shutdown, or 'off' to disable [off]
  --thread-stack-size=SIZE        size of stack per thread [64K]
  --rate=N                        average transactions rate. 0 for unlimited rate [0]
  --report-interval=N             periodically report intermediate statistics with a specified interval in seconds. 0 disables intermediate reports [0]
  --report-checkpoints=[LIST,...] dump full statistics and reset all counters at specified points in time. The argument is a list of comma-separated values representing the amount of time in seconds elapsed from start of test when report checkpoint(s) must be performed. Report checkpoints are off by default. []
  --debug[=on|off]                print more debugging info [off]
  --validate[=on|off]             perform validation checks where possible [off]
  --help[=on|off]                 print help and exit [off]
  --version[=on|off]              print version and exit [off]
  --config-file=FILENAME          File containing command line options
  --tx-rate=N                     deprecated alias for --rate [0]
  --max-requests=N                deprecated alias for --events [0]
  --max-time=N                    deprecated alias for --time [0]
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

sysbench 的测试过程分为三个阶段：

- prepare：准备阶段，准备测试数据。
- run：执行测试阶段。
- cleanup：清理垃圾数据阶段。

## 五 总结

```bash
sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw prepare
sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw run
sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw cleanup
```
http://www.cnblogs.com/zhoujinyi/archive/2013/04/19/3029134.html