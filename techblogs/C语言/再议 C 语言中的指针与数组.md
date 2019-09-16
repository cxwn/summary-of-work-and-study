# 再议 C 语言中的指针与数组

## 一 概述

## 二 数组与指针

在 C 语言中，指向数组的指针是比较常见的，也是非常方便和适用的。

### 2.1 指向数组的指针

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int a[10] = {1,2,3,4,6,5,7,8,9,0};
  int *p;
  // p = a;
  p = &a[0];
  for (int i = 0; i < 10; i++){
    printf("%d\t",*p);
    p++;
  }
  return 0;
}
// 1       2       3       4       6       5       7       8       9       0
```

本例中，指针变量 p 指向了数组 a[10]，并演示了通过指针遍历数组的常规方法。 我们可以直接通过数组名直接将指针指向该数组的第一个元素，“p = a;” 和 “p = &a[10];”这两行代码在本质上是等价的。需要注意的是：通过这种方式使指针指向整个数组，数组名前面不能再使用运算符 &。 若指针指向数组的某一元素，运算符 & 不能省略。

### 2.2 指向复合常量的指针

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int *p = (int []){1,2,3,4,6,5,7,8,9,0};
  for (int i = 0; i < 10; i++){
    printf("%d\t",*p);
    p++;
  }
  return 0;
}
//1       2       3       4       6       5       7       8       9       0
```

本例声明并初始化了一个没有名称的数组。 通过这种方式，我们不需要先声明一个数组，然后再用指针指向数组的第一个元素。 在某些场景中，这个特性使用起来比较方便。 这是 C99 的一个特性。 另外， 在本例的 for 循环体，声明并初始化了 i, 这也是 C99 的一个特性，需要注意一下。

可以声明匿名数组的长度。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int *p = (int [10]){1,2,3,4,6,5,7,8,9,0};
  for (int i = 0; i < 10; i++){
    printf("%d\t",*p);
    p++;
  }
  return 0;
}
```

### 2.3 通过指针对数组进行操作

通过指针也可以很方便、高效地对数组进行操作，请看以下例子：

```c
# include<stdio.h>
# define N 10

int main(int argc,char *argv[]){
  int a[N];
  int *p;
  for (p = a; p < a + N; p++){
    printf("Please input a[%d]:",p - a);
    scanf("%d",p);
  }
    for (p = a; p < a + N; p++){
    printf("a[%d] = %d;\t ", p - a, *p);
  }
  printf("\n");
  return 0;
}
/*
Please input a[0]:1
Please input a[1]:2
Please input a[2]:3
Please input a[3]:4
Please input a[4]:5
Please input a[5]:66
Please input a[6]:7
Please input a[7]:7
Please input a[8]:8
Please input a[9]:9
a[0] = 1;        a[1] = 2;       a[2] = 3;       a[3] = 4;       a[4] = 5;       a[5] = 66;      a[6] = 7;       a[7] = 7;       a[8] = 8;       a[9] = 9;
*/
```

这个例子展示了通过操作指针对数组进行赋值，并通过指针的移动完成对数组的遍历。例子中使用了两个指针相减的方式确定了数组下标。使用指针操作对数组进行赋值或遍历的过程中，在操作开始之前需要将指针复位，指向数组的第一个元素。这个操作必不可少，否则将出错。

### 2.4 指针与数组在函数定义中的使用

在函数定义时，数组可以使用指针或显示声明来定义形式参数。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  unsigned int array[] = {3,5,6,7,1,2,0}, len;
  int find_max(unsigned int [], int n);
  len = sizeof array / sizeof array[0];
  printf("%d\n",find_max(array,len));
  return 0;
}

int find_max(unsigned int a[], int n){
  int max = 0;
  for (int i = 0; i < n; i++){
    if ( a[i] > max)
       max = a[i];
  }
  return max;
}
// 7
```

---

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  unsigned int array[] = {3,5,6,7,1,2,0}, len;
  int find_max(unsigned int [], int n);
// int find_max(unsigned int *, int n);
  len = sizeof array / sizeof array[0];
  printf("%d\n",find_max(array,len));
  return 0;
}

int find_max(unsigned int *a, int n){
  int max = 0;
  for (int i = 0; i < n; i++){
    if ( a[i] > max)
       max = a[i];
  }
  return max;
}
// 7
```

在以上2段代码中，写法不一样，但执行效果却一致。事实上数组作为形参时，是以指针进行传递的。也就是说，对于形参而言，声明为数组与声明为指针是一样的，但是对于变量来说，声明为数组与声明为指针是不一样的。指定长度的数组会导致编译器预留指定数据类型长度的空间，申明为指针会导致编译器为指针变量分配空间。

### 2.5 多维数组与指针

使用指针遍历多维数组：

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int *p, array[2][3] = {{12,43,11},{10,56,89}};
  for (p = &array[0][0]; p <= &array[1][2]; p++)
    printf("array[%d][%d]: %d\n",(p - &array[0][0])/3, (p - &array[0][0])%3, *p);
  return 0;
}
/*
array[0][0]: 12
array[0][1]: 43
array[0][2]: 11
array[1][0]: 10
array[1][1]: 56
array[1][2]: 89
*/
```

以上代码等价于：

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int *p, array[2][3] = {{12,43,11},{10,56,89}};
  for (p = array[0]; p <= &array[1][2]; p++)
    printf("array[%d][%d]: %d\n",(p - &array[0][0])/3, (p - &array[0][0])%3, *p);
  return 0;
}
```

对比以上两端代码，乍一看，并没有什么差异！举着个例子的重点在第四行的 “p = &array[0][0]” 和 “p = array[0]”。通过这两行代码，不难看出：二维数组中，指针 p 不是指向 array[0][0] 的指针，而是指向 array[0] 的指针。

多维数组是不能以数组名直接作为指针指向的对象，需要稍微做一些调整才能使用数组名作为指针。在 C 语言中，多维数组实际上就是以一维数组来进行处理的。结合上面的例子，C 语言把 array 当作一维数组来进行处理，而这个一维数组的美一个元素又是一个一维数组。由此，可以推广到多维数组。

那么，在多维数组内是否可以直接以数组名为作为指针呢？请看以下例子：

```c
# include<stdio.h>
# define ROWS 2
# define COLS 3

int main(int argc,char *argv[]){
  int *p, i, array[ROWS][COLS] = {{12,43,11},{10,56,89}};
  for (i = 0; i < ROWS; i++){
    for (p = array[i]; p < array[i] + COLS; p++){
      printf("array[%d][%d]: %d\n",i, p - array[i], *p);
    }
  }
  return 0;
}
/*
array[0][0]: 12
array[0][1]: 43
array[0][2]: 11
array[1][0]: 10
array[1][1]: 56
array[1][2]: 89
*/
```