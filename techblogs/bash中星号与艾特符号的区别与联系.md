# bash shell 中，$* 与 $@ 的区别与联系

让我们来看两段脚本及其运行结果。

**脚本1** :

```bash
#!/bin/bash
for num1 in $* ;
  do
    echo '------------show:$*-----------';
    echo 'Show $*:'${num1};
  done
for num2 in $@ ;
  do
    echo '------------show:$@-----------';
    echo 'Show $@:'${num2};
  done
```

**脚本1运行结果**：

```text
[gysl@gysl-dev ~]$ sh test.sh i tell you
------------show:$*-----------
Show $*:i
------------show:$*-----------
Show $*:tell
------------show:$*-----------
Show $*:you
------------show:$@-----------
Show $@:i
------------show:$@-----------
Show $@:tell
------------show:$@-----------
Show $@:you
```

**脚本2**：

```bash
#!/bin/bash
for num1 in "$*" ;
  do
    echo '------------show:$*-----------';
    echo 'Show $*:'${num1};
  done
for num2 in "$@" ;
  do
    echo '------------show:$@-----------';
    echo 'Show $@:'${num2};
  done
```

**脚本2运行结果**：

```text
[gysl@gysl-dev ~]$ sh test.sh i tell you
------------show:$*-----------
Show $*:i tell you
------------show:$@-----------
Show $@:i
------------show:$@-----------
Show $@:tell
------------show:$@-----------
Show $@:you
```

两段脚本差别很小，只是多了两个引号而已。也就是说：$* 是带了引号分割的；$@ 是没有带引号的，原模原样的字符串。使用的时候注意区分即可。让我们再来看几行命令。

```bash
[gysl@gysl-dev ~]$ array=(1 2 3)
[gysl@gysl-dev ~]$ for a in "${array[*]}";do echo "a="${a};done
a=1 2 3
[gysl@gysl-dev ~]$ for a in "${array[@]}";do echo "a="${a};done
a=1
a=2
a=3
[gysl@gysl-dev ~]$ sum=0
[gysl@gysl-dev ~]$ for a in "${array[*]}";do let sum+=${a};done&&echo ${sum}
1
[gysl@gysl-dev ~]$ for a in "${array[@]}";do let sum+=${a};done&&echo ${sum}
7
```

总结一下：可以看到不加引号时,二者都是返回传入的参数,但加了引号后,此时\$*把参数作为一个字符串整体(单字符串)返回,$@把每个参数作为一个字符串返回。