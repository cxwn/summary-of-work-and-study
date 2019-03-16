# test

```bash
sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw prepare
sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw run
sysbench --test=fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw cleanup
```
http://www.cnblogs.com/zhoujinyi/archive/2013/04/19/3029134.html