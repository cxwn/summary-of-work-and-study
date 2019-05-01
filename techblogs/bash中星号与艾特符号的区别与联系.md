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

两段脚本差别很小，只是多了两个引号而已。也就是说：$* 是带了引号分割的；$@ 是没有带引号的，原模原样的字符串。使用的时候注意区分即可。