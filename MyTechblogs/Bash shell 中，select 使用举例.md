# Bash shell 中，select 使用举例

## 一 背景

在最近的运维工作中，写了很多脚本，在写这些脚本时发现了一些高效的用法，现将 select 的用法简单介绍一下。

## 二 使用举例

select 表达式是 bash 的一种扩展应用，擅长于交互式场合。用户可以从一组不同的值中进行选择。格式如下：

```bash
select var in ... ; do
    ...
done
```

### 2.1 单独使用 select

```bash
#!/bin/bash
Hostname=( 'host1' 'host2' 'host3' )
select host in ${Hostname[@]}; do
    if [[ "${Hostname[@]/${host}/}" != "${Hostname[@]}" ]] ; then
        echo "You select host: ${host}";
    else
        echo "The host is not exist! ";
        break;
    fi
done
```

运行结果展示：

```txt
[root@gysl ~]# sh select.sh
1) host1
2) host2
3) host3
#? 1
You select host: host1
#? 2
You select host: host2
#? 3
You select host: host3
#? 2
You select host: host2
#? 3
You select host: host3
#? 1
You select host: host1
#? 6
The host is not exist!
```

脚本中增加了一个判断，如果选择的主机不在指定范围，那么结束本次执行。

## 2.2 结合 case 使用

```bash
#!/bin/bash
Hostname=( 'host1' 'host2' 'host3' )
PS3="Pease input the number of host: "
select host in ${Hostname[@]}; do
    case ${host} in
    'host1')
        echo "This host is: ${host}. "
    ;;
    'host2')
        echo "This host is: ${host}. "
    ;;
    'host3')
        echo "This host is: ${host}. "
    ;;
    *)
        echo "The host is not exist! "
        break;
   esac
done
```

运行结果展示：

```txt
[root@gysl ~]# sh select.sh
1) host1
2) host2
3) host3
Pease input the number of host: 1
This host is: host1.
Pease input the number of host: 3
This host is: host3.
Pease input the number of host: 4
The host is not exist!
```

在很多场景中，结合 case 语句使用显得更加方便。上面的脚本中，重新定义了 PS3 的值，默认情况下 PS3 的值是:"#?"。

## 三 总结

3.1 select 看起来似乎不起眼，但是在交互式场景中却非常有用，各种用法希望大家多多总结。

3.2 文章中还涉及到了 bash shell 中判断值是否在数组中的用法。