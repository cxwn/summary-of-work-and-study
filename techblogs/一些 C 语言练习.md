# 一些 C 语言练习

## 1.整数与浮点型两种数据类型相乘

```c
#include<stdio.h>
int main()
{
  int a = 20;
  float b = 20.34;
  printf("%f\n",a*b);
  return 0;
}
//406.799988
```

---

```c
#include<stdio.h>
int main()
{
  int a = 20;
  float b = 20.34;
  printf("%d\n",a*b);
  return 0;
}
//-1409143032
```

---

```c
#include<stdio.h>
int main()
{
  int a = 20;
  float b = 20.34;
  printf("%d\n",(int)(a*b));
  return 0;
}
//406
```

## 2.命令行传参

```c
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int main(int argc, char *argv[])
{
  int memory_num = 0;
  int i;
  char *cmd,*temp;
  for (i = 0; i < argc; i++)
      memory_num += strlen(argv[i]);
  cmd = (char *)malloc(memory_num + argc*strlen(" "));
  for (i = 1; i < argc; i++)
  {
     //printf("argv:%s\n",argv[i]);
     temp = (char *)malloc(strlen(argv[i])+strlen(" "));
     strcpy(temp,argv[i]);
     strcat(temp," ");
     //printf("argc[%d]:%s|\n",i,temp);
     strcat(cmd,temp);
     free(temp);
  }
  printf("%s\n",cmd);
  system(cmd);
  return 0;
}
```

---

## 3. 运算符优先级

```c
#include<stdio.h>

int main(int argc,char *argv[])
{
  int a = 5, b, c;
  c = (b = a + 2) - (a=1);
  printf("%d\t%d\n",c,a);
  return 0;
}

// 6       1
```

---

## 4. for 语句里面的逗号运算符

```c
#include<stdio.h>

int main(int argc,char *argv[])
{
  int a = 15, b = 26, i, j;
  for ( ; i < a, j < b;i++, j++)
  {}
  printf("%d\t%d\n",i,j);
  return 0;
}
// 26      26
```

---

```c
#include<stdio.h>

int main(int argc,char *argv[])
{
  int a = 15, b = 26, i, j;
  for ( ; i < a, j < b;i++, j++)
  ;//{}
  printf("%d\t%d\n",i,j);
  return 0;
}
// 26      26
```

---

```c
#include<stdio.h>

int main(int argc,char *argv[])
{
  int a = 15, b = 26, i, j;
  for ( ; i < a, j < b;i++, j++)
  //{}
  printf("%d\t%d\n",i,j);
  return 0;
}
/*
0       0
1       1
2       2
3       3
4       4
5       5
6       6
7       7
8       8
9       9
10      10
11      11
12      12
13      13
14      14
15      15
16      16
17      17
18      18
19      19
20      20
21      21
22      22
23      23
24      24
25      25
*/
```

---

```c
#include<stdio.h>

int main(int argc,char *argv[])
{
  int a = 15, b = 6, i, j;
  for ( ; i < a, j < b;i++, j++)
  {}
  printf("%d\t%d\n",i,j);
  return 0;
}
// 6       6
```

---

```c
#include<stdio.h>

int main(int argc,char *argv[])
{
  int a = 5, b = 6, i, j;
  for ( ; i < a, j < b;i++, j++)
  //{}
  printf("%d\t%d\n",i,j);
  return 0;
}
/*
0       0
1       1
2       2
3       3
4       4
5       5
*/
```

这种情况以后一个变量的值为上限。for 语句在循环结束之后循环体最后一部分仍会继续执行一次。

## 5. 各数据类型的长度

```c
#include<stdio.h>

int main(int argc,char *argv[])
{
  printf("int:%d\nlong int:%d\nshort int:%d\nunsigned int:%d\nunsigned long int:%d\nunsigned short int:%d\n",sizeof(int),sizeof(long int),sizeof(short int),sizeof(unsigned int),sizeof(unsigned long int),sizeof(unsigned short int));
  return 0;
}
/*
int:4
long int:8
short int:2
unsigned int:4
unsigned long int:8
unsigned short int:2
*/
```

## 6. 结构体

```c
#include <stdio.h>
struct stu{
    char *name;  //姓名
    int num;  //学号
    int age;  //年龄
    char group;  //所在小组
    float score;  //成绩
}stus[] = {
    {"Zhou ping", 5, 18, 'C', 145.0},
    {"Zhang ping", 4, 19, 'A', 130.5},
    {"Liu fang", 1, 18, 'A', 148.5},
    {"Cheng ling", 2, 17, 'F', 139.0},
    {"Wang ming", 3, 17, 'B', 144.5}
}, *ps;
int main(){
    //求数组长度
    int len = sizeof(stus) / sizeof(struct stu);
    printf("Name\t\tNum\tAge\tGroup\tScore\t\n");
    for(ps=stus; ps<stus+len; ps++){
        printf("%s\t%d\t%d\t%c\t%.1f\n", ps->name, ps->num, ps->age, ps->group, ps->score);
    }
    return 0;
}
// http://c.biancheng.net/cpp/html/94.html
```

---

## 7. 一些值得思考的问题

```c
# include<stdio.h>
# include<string.h>

int main(int argc,char *argv[])
{
  char e[4] = "20d0";
  int i;
  printf("Sizeof: %d\t%d\n",(sizeof e),strlen(e));
  printf("Sizeof int: %d\n",sizeof (int));
  printf("Sizeof e: %d\n",sizeof (e));
/*
  for ( i = 0; i < strlen(e); i++)
    printf("e[%d]: %c\n",i,e[i]);
*/
  printf("%lu\n",((unsigned long)sizeof(int)));
  return 0;
}
```

以上代码注释部分去掉之后，第一个printf输出的值会出现不一样。

## 8. 数组的初始化

```c
# include<stdio.h>

int main(int argc, char *argv[]){
  int a[10] = {1,2,4,5,[0] = 0,6,8,9,3};
  int i = 0;
  for ( i = 0; i < 10; i++)
    printf("a[%d]: %d\n",i, a[i]);
  return 0;
}
/*
a[0]: 0
a[1]: 6
a[2]: 8
a[3]: 9
a[4]: 3
a[5]: 0
a[6]: 0
a[7]: 0
a[8]: 0
a[9]: 0
*/
```

---

```c
# include<stdio.h>

int main(int argc, char *argv[]){
  int a[10] = {1,2,4,5,[3] = 0,6,8,9,3};
  int i = 0;
  for ( i = 0; i < 10; i++)
    printf("a[%d]: %d\n",i, a[i]);
  return 0;
}
/*
a[0]: 1
a[1]: 2
a[2]: 4
a[3]: 0
a[4]: 6
a[5]: 8
a[6]: 9
a[7]: 3
a[8]: 0
a[9]: 0
*/
```

这样的申明是不合法的。编译器在处理初始化列表是，会记录下一个待初始化的数组元素的位置。正常情况下，下一个元素是刚被初始化的元素后面的那个。但是，当列表种出现初始化式时，下一个元素会被强制为指示符对应的元素，即使该元素已经初始化了。

## 9. 变长数组的初始化

```c
# include<stdio.h>

int main(int argc, char *argv[]){
  int n, i, a[n];
  scanf("%d",&n);
  for ( i = 0; i < n; i++){
    scanf("%d",&a[i]);
  }
  for ( i = 0; i < n; i++){
    printf("a[%d]: %d\n",i,a[i]);
  }
  return 0;
}
/*
3
5
8
1
a[0]: 5
a[1]: 8
a[2]: 1
*/
```

代码第4行方括号内部的 n 不能省略。变长数组的长度是在执行时计算数组的长度的。变长数组也可以时多维的。

## 10. 函数的嵌套调用

```c
# include<stdio.h>

int main(int argc, char *argv[]){
  int array[10] = { 2,1,0,3,6,5,4,7,9,8};
  int ModifyNumber(int a[],int i);
  void show(int a[], int n);
  show(array,10);
  ModifyNumber(array,3);
  printf("The value has been updated. Please check: \n");
  show(array,10);
  return 0;
}
int ModifyNumber(int a[],int i){
  void PrintMsg();
  PrintMsg();
  scanf("%d",&a[i]);
  return 0;
}

void PrintMsg(){
  printf("Please input a new value:\n");
}

void show(int array[], int n){
  for (int i = 0; i < n; i++){
    printf("Array[%d]: %d\n", i, array[i]);
  }
}
/*
Array[0]: 2
Array[1]: 1
Array[2]: 0
Array[3]: 3
Array[4]: 6
Array[5]: 5
Array[6]: 4
Array[7]: 7
Array[8]: 9
Array[9]: 8
Please input a new value:
90
The value has been updated. Please check:
Array[0]: 2
Array[1]: 1
Array[2]: 0
Array[3]: 90
Array[4]: 6
Array[5]: 5
Array[6]: 4
Array[7]: 7
Array[8]: 9
Array[9]: 8
*/
```

在 C 语言种，允许定义函数互相调用（在一个函数种调用另外一个函数），但是函数嵌套定义（在一个函数种定义另外一个函数）是不允许的。类似于下面的函数定义，能通过系统编译，但是程序无法正常执行：

```c
# include<stdio.h>
int main(int argc,char *argv[]){
  void SendMsg();
  void PrintMsg();
  SendMsg();
  PrintMsg();
  return 0;
}

void SendMsg(){
  void PrintMsg();
  PrintMsg();
  printf("This  function is SendMsg.\n");
}

void PrintMsg(){
  void SendMsg();
  SendMsg();
  printf("This function is PrintMsg.\n");
}
```

这是一种间接递归的形式，必须保证两个函数能正常终止。

## 11. 静态变量

```c
# include<stdio.h>
int main(int argc,char *argv[]){
  int Sta(int);
  int  n;
  scanf("%d",&n);
  printf("First value: %d\n",Sta(n));
  printf("Second value: %d\n",Sta(n));
  return 0;
}

int Sta(int n){
  static int b = 0;
  b = b + n;
  return b;
}
/*
6
First value: 6
Second value: 12
*/
```

在 Sta() 函数第二次被调用时，静态变量 b 的值已经是6。也就是说，静态变量对其他函数隐藏数据，为将来再次调用保留这些数据。

## 12. 局部变量和外部变量

```c
# include<stdio.h>
int main(int argc,char argv[]){
  void test();
  extern int i;
  test();
  printf("%d\n",i);
  return 0;
}

int i = 1;

void test(){
  int j = i;
  int i =2;
  printf("%d\n",j);
}
// 1
// 1
```

代码是合法的。如果去掉关键字 extern， 那么第二个打印的值将是0。

## 13.
