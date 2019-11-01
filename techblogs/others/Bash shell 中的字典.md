# Bash shell 中的字典

## 一 背景

在一些运维工作中，使用字典能让当前工作事半功倍，类似 Python ，在 GNU bash 4.2.46 中，我们也可以很方便的使用字典来完成一些工作了。本文以一段 bash shell 为例展示一下 Bash 中字典的使用。

## 二 脚本

```bash
#!/bin/bash
# Declare a dictionary.
declare -A Host
Host=( [node1]='10.1.1.11' [node2]='10.1.1.12' [node3]='10.1.1.13' [node4]='10.1.1.14' )

# Traversing dictionary values.
for node_ip in ${Host[@]};
do
  echo "One IP of these hosts is ${node_ip} .";
done

# Traversing dictionary keys.
for node in ${!Host[@]};
do
  echo "One hostname of these hosts is: ${node}. ";
done

# Traverse keys and values at the same time.
for node in ${!Host[@]};
do
  echo "Hostname: ${node}, IP: ${Host[${node}]}. "
done

# Get the length of this dictionary.
echo "The length of this dictionary is ${#Host[@]}. "

# Append a key and a value.
Host[node5]='10.1.1.15'
echo "The value of new dictionary is: ${Host[@]}. "
echo "The length of dictionary is: ${#Host[*]}. "

# Modify a value of the dictionary .
Host[node1]='10.1.1.111'
echo "The value of new dictionary is: ${Host[@]}. "
```

执行结果：

```text
One IP of these hosts is 10.1.1.14 .
One IP of these hosts is 10.1.1.11 .
One IP of these hosts is 10.1.1.12 .
One IP of these hosts is 10.1.1.13 .
One hostname of these hosts is: node4.
One hostname of these hosts is: node1.
One hostname of these hosts is: node2.
One hostname of these hosts is: node3.
Hostname: node4, IP: 10.1.1.14.
Hostname: node1, IP: 10.1.1.11.
Hostname: node2, IP: 10.1.1.12.
Hostname: node3, IP: 10.1.1.13.
The length of this dictionary is 4.
The value of new dictionary is: 10.1.1.14 10.1.1.15 10.1.1.11 10.1.1.12 10.1.1.13.
The length of dictionary is: 5.
The value of new dictionary is: 10.1.1.14 10.1.1.15 10.1.1.111 10.1.1.12 10.1.1.13.
```

## 三 总结

脚本的注释解释了后面相关代码的功能。通过脚本，我们对 Bash 中的字典有了一些新的认识。