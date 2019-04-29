# bash shell 中数组使用举例

## 一 背景

让我们先来看一个 shell 脚本的执行过程及结果：

```text
[gysl@gysl-DevOps ~]$ sh array.sh N2 N3 N4
The elements of this array 2-4 are: N2 N3 N4
N1 is in array.  
N2 is in array.  
N3 is in array.  
N4 is in array.  
The original array is as follows: N1 N2 N3 N4
The length of this array is 4. 
The array[2] is N3. 
Append an element at the end of this array. This array: N1 N2 N3 N4 N5
Modify an element in an array. This array: N1 N2 N6 N4 N5
```

## 二 实现

实现脚本如下：

```bash
#!/bin/bash
array=('N1' 'N2' 'N3' 'N4')
case $1 in 
  ${array[0]})
    echo "${array[0]}"
  ;;
  ${array[@]:1:3})
    echo "The elements of this array 2-4 are: ${array[@]:1:3}"
  ;;
  *)
    echo "ERROR"
  ;;
esac
for num in ${array[@]} ;do
   echo "${num} is in array. "
done
echo "The original array is as follows: ${array[@]}"
echo "The length of this array is ${#array[*]}. "
echo "The array[2] is ${array[2]}. "
array[${#array[@]}]=N5
echo "Append an element at the end of this array. This array: ${array[@]}"
array[2]=N6
echo "Modify an element in an array. This array: ${array[*]}"
```

## 三 总结

3.1 这个例子实现了数组的各种用法，我们可以通过执行结果进行直观理解。需要注意的是子数组的获取，元素的修改，追加。
3.2 shell 数组的使用与其他编程语言有所不同，可以类比理解。
