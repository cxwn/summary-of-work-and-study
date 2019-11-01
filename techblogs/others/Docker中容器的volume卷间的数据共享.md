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

3.3 当容器被删除时，volume不会被自动删除。如果数据不会再次被使用，那么可以通过手动来删除已经废弃的volume,命令如下：
```bash
[root@dev ~]# docker volume ls
DRIVER              VOLUME NAME
local               8126b3ad828a9a7e29ec04f4d7a1901be5e40ca6157fde62dca3421322e5de7a
local               bf80e1eb66685161cb6bf6943079de4a68a7bc3db3bba241347ed051fe59fc46
[root@dev ~]# docker volume prune
WARNING! This will remove all volumes not used by at least one container.
Are you sure you want to continue? [y/N] y
Total reclaimed space: 0 B
```
也可以：
```bash
docker volume rm volume_name
```
还可以（在删除容器的同时强制删除volume）：
```bash
docker rm -vf container_name
```
