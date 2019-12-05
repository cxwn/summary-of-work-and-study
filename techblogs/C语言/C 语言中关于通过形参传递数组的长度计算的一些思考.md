# C 语言中关于通过形参传递数组的长度计算的一些思考

## 一 背景

学习 C 语言的过程中，计算数组的长度经常会碰到。在字符型的数组中我们可以使用 strlen() 来获取当前数组的长度，对于其他类型的数组，这个方法就不适用了。由于经常会遇到计算数组长度的问题，经过思考，考虑通过一个函数来实现数组长度的计算。思路是这样的：通过形参将数组传递给长度计算函数，长度计算函数计算完成之后返回数组长度。但是在实际实践过程中遇到了问题，请继续往下看！

## 二 实现代码

根据以上构想，写了如下一段 demo:

```c
# include<stdio.h>

int main(int argc, char * argv[])
{
  int a[] = {2, 6, 3, 5, 9};
//  int length(int *);
  int length(int []);
  printf("The length of this array is: %d\n",length(a));
  printf("The length of this array is: %d\n",sizeof a /sizeof a[0]);
  return 0;
}

// int length(int *a)
int length(int a[])
{
  int length;
  length =  sizeof a / sizeof a[0];
  return length;
}
```

执行结果：

```c
The length of this array is: 2
The length of this array is: 5
```

## 三 结果分析及总结

- 3.1 第一个结果，通过形参传递给数组长度计算函数来计算数组长度，得到的结果是： 2。很明显，这是一个错误的结果。

- 3.2 第二个结果，直接计算数组长度，符合预期。

- 3.3 通过查阅相关资料，得出以下结论：

a[] 是长度计算的形式参数，在 main)() 函数中调用时，a 是一个指向数组第一个元素的指针。在执行 main() 函数时，不知道 a 所表示的地址有多大的数据存储空间，只是告诉函数：一个数据存储空间首地址。

sizoef a 的结果是指针变量 a 占内存的大小，一般在 64 位机上是8个字节。a[0] 是 int 类型，sizeof a[0] 是4个字节，结果是2。为此，我们再来看一下下面一段代码：

```c
# include<stdio.h>


int main(int argc, char * argv[])
{
  int a[] = {2, 6, 3, 5, 9};
//  int length(int *);
  int length(int []);
  int *p;
  p = a;
  printf("The length of this array is: %d\n", length(a));
  printf("The length of this array is: %d\n", sizeof a /sizeof a[0]);
  printf("The length of this pointer is: %d\n", sizeof p);
  return 0;
}

// int length(int *a)
int length(int a[])
{
  int length;
  length =  sizeof a / sizeof a[0];
  return length;
}
```

执行结果：

```c
The length of this array is: 2
The length of this array is: 5
The length of this pointer is: 8
```
