FROM centos:7.4
#ENV PATH_TRANSCRIBE=/usr/local/models/model_0103
#ENV TEMP_FILE=/TempFile
#ENV LOG_FILE=/LogFile
RUN yum -y install epel-release && \
    yum -y install stress stress-ng  bonnie++ strace iperf net-tools lsof ethtool sysbench hdparm
CMD ["/usr/bin/bash"]

# 1. sysbench --test=cpu --cpu-max-prime=20000 run
# cpu测试主要是进行素数的加法运算，在下图例子中，指定了最大的质数发生器数量为 20000，可以看出服务器此次测试 执行时间大约为10.0005s秒 
# sysbench --test=threads --num-threads=64 --thread-yields=100 --thread-locks=2 run
# 发送64次/个测试线程请求，每次/个线程请求产生/生成100个数量，每个线程的锁数量为2，下图的测试执行时间为10.0051s秒
# sysbench --test=memory --memory-block-size=8k --memory-total-size=4G run
# 上述参数指定了本次测试整个过程是在内存中传输 4G 的数据量，每个 block 大小为 8K。执行时间为0.3844秒，每秒传输速度为10586.47Mb每秒 
#  sysbench --test=oltp --mysql-table-engine=myisam --oltp-table-size=1000000 --mysql-socket=/tmp/mysql.sock --mysql-user=test --mysql-host=localhost --mysql-password=test prepare
# 上述参数指定了本次测试的表存储引擎类型为 myisam，这里需要注意的是，官方网站上的参数有一处有误，即 –mysql-table-engine，官方网站上写的是 –mysql-table-type，这个应该是没有及时更新导致的。另外，指定了表最大记录数为 1000000，其他参数就很好理解了，主要是指定登录方式。测试 OLTP 时，可以自己先创建数据库 sbtest，或者自己用参数 –mysql-db 来指定其他数据库。–mysql-table-engine 还可以指定为 innodb 等 MySQL 支持的表存储引擎类型。
# 1、磁盘IO，即输入/输出(Input/Output)，这是测试磁盘性能一个重要指标。
#      2、测试主机磁盘IO的性能可以执行以下两个命令：
#            dd if=/dev/zero of=test bs=64k count=4k oflag=dsync
#            dd if=/dev/zero of=test bs=8k count=256k conv=fdatasync
#       3、conv=fdatasync与oflag=dsync的区别在于：sync函数只是将所有修改过的块缓冲区排入写队列，然后就返回，它并不等待实际写磁盘操作结束。
#       4、而fsync函数只对由文件描述符filedes指定的单一文件起作用，并且等待写磁盘操作结束，然后返回。这是我电脑的硬盘IO测试结果。