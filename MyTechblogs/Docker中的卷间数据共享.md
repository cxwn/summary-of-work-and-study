# 一 背景
在实际使用过程中，我们可能会经常遇到容器间数据共享的情况，怎么处理呢？通过 docker 命令中的一些选项，我们即可完成容器间的数据共享。

# 二 实验步骤
## 2.1 创建容器
容器一：gysl-1
```bash
[root@dev ~]# docker run -it --rm --name gysl-1 -v /data-1 alpine
```
容器二：gysl-2
```bash
[root@dev ~]# docker run -it --rm --volumes-from gysl-1 --name gysl-2 alpine
```
## 2.2 验证数据共享情况
在容器gysl-1创建文件：gysl-1.txt
```bash
/ # cd data-1/
/data-1 # touch gysl-1.txt
```
在容器gysl-2创建文件：gysl-2.txt
```bash
/ # cd data-1/
/data-1 # touch gysl-2.txt
```
分别在两个容器查看：
```bash
/data-1 # ls -lh
total 0
-rw-r--r--    1 root     root           0 Jan 10 18:45 gysl-1.txt
-rw-r--r--    1 root     root           0 Jan 10 18:47 gysl-2.txt
```
两个容器的data-1目录下的内容完全一致。
# 三 总结
3.1 当一个容器的volume被其他容器共享时，其他容器是不需要创建共享目录的，共享目录会在其他容器内被自动创建，与被共享容器的目录名称一致。

3.2 一个容器的volume可以被多个容器同时共享。