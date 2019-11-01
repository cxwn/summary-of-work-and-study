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

## 13. 指针的赋值与使用

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int i = 10, j, *p, *q, *x = &i;
  p = &i;
  q = p;
  j = *&i;
  printf("p = %d\n",*p);
  printf("q = %d\n",*q);
  printf("x = %d\n",*x);
  printf("j = %d\n",j);
  scanf("%d",&i);
  printf("p = %d\n",*p);
  printf("q = %d\n",*q);
  printf("x = %d\n",*x);
  printf("j = %d\n",j);
  return 0;
}
/*
p = 10
q = 10
x = 10
j = 10
98
p = 98
q = 98
x = 98
j = 10
*/
```

这个例子种，指针变量 x 在声明的同时进行了初始化工作，这种操作是合法的。在声明之后再进行初始化则需要以类似于指针变量 p 的方式进行初始化，仍然使用 *p = &i 这种声明方式是无法通过编译的。

通过 *p 这种方式使用指针值叫做间接寻址。此处的 \* 称之为间接寻址运算符。

多个指针变量指向同一变量时，该变量的值改变之后，指针变量的值也随之改变。

*&i 对变量 i 使用 & 运算符产生指向指针变量的指针，对指针使用 \* 运算符则可以返回到原始变量。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int *p, *q, i = 989, j = 2019;
  p = &i;
  q = &j;
  q = p;
  printf("p = %d\n",*p);
  printf("p : %p\n",p);
  printf("j = %d\n",j);
  printf("q = %d\n",*q);
  printf("q : %p\n",q);
  return 0;
}
/*
p = 989
p : 0x7fff51751e5c
j = 2019
q = 989
q : 0x7fff51751e5c
*/
```

同类型的指针变量可以相互复制，复制之后指向同一变量。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int *p, *q, i = 989, j = 2019;
  p = &i;
  q = &j;
  *q = *p;
  printf("p = %d\n",*p);
  printf("p : %p\n",p);
  printf("j = %d\n",j);
  printf("q = %d\n",*q);
  printf("q : %p\n",q);
  return 0;
}
/*
p = 989
p : 0x7ffc00d359ac
j = 989
q = 989
q : 0x7ffc00d359a8
*/
```

这段代码看起来跟上一段十分相似，但是运行结果却截然不同。赋值语句 *q = *p 把指针变量 p 的值复制到 q 指向的对象中,也就是 j 中，但是 p 和 q 的地址是不一样的。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  char i, *p;
  p = &i;
  scanf("%c",p);
  printf("p = %c\n",*p);
  printf("i = %c\n",i);
  return 0;
}
/*
e
p = e
i = e
*/

在这一段代码中，如果删除 “p = &i;” 这一句，那么这段代码是不能顺利通过编译的，函数 scanf() 中的 变量 p 就相当于 &i， scanf() 读入的字符并存储于 i 中。此时，scanf() 中不能再使用运算符 &。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int a, b;
  int *max(int *,int *);
  scanf("%d%d",&a,&b);
  printf("The max number is: %d\n",*max(&a,&b));
  return 0;
}

int *max(int *a, int *b){
  *a = *a + 5;
  if (*a > *b)
    return a;
  else
    return b;
}
/*
1 4
The max number is: 6
*/
```

指针变量作为形参进行传递、运算，并函数的返回值类型为指针。再继续看下一段代码：

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int a, b;
  int max(int *,int *);
  scanf("%d%d",&a,&b);
  printf("The max number is: %d\n",max(&a,&b));
  return 0;
}

int max(int *a, int *b){
  *a = *a + 5;
  if (*a > *b)
    return *a;
  else
    return *b;
}
/*
1 4
The max number is: 6
*/
```

同样的输入，一样的输出结果，形式不一样，实际上实现原理也是一样的，都返回指针，可以类比来理解。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int x = 2019, y=2023;
  int *a = &x, *b = &y, c;
  c = (*a + *b) * 2 + 20;
  printf("Sum: %d\n",c);
  return 0;
}
// Sum: 8104
```

以上代码的第4行和第5行互换，将不能通过编译。C 语言严格遵循先声明后使用的原则，指针也不例外。间接寻址在表达式中是可以直接使用的。需要说明的是：“int \*a = &x, \*b = &y, c;”这一行中的 \* 不是间接寻址运算符，其作用是告知编译器 a 和 b 是两个指向 int 类型变量的指针。 “c = (\*a + \*b) \* 2 + 20;”这一行的前两个 \* 是间接寻址运算符，第三个 \* 是乘法运算符。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int p;
  int example(int *);
  scanf("%d",&p);
  printf("%d\n",example(&p));
  return 0;
}

int example(int *p){
  int a = 10086;
  printf("The original value is: %d\n",*p);
  p = &a;
  return *p;
}
```

---

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int p;
  int example(int *);
  scanf("%d",&p);
  printf("%d\n",example(&p));
  return 0;
}

int example(int *p){
  printf("The original value is: %d\n",*p);
  *p = 10086;
  return *p;
}
```

---

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int p;
  int example(const int *);
  scanf("%d",&p);
  printf("%d\n",example(&p));
  return 0;
}

int example(const int *p){
  int x = 10086;
  printf("The original value is: %d\n",*p);
  p = &x;
  return *p;
}
/*
98
The original value is: 98
10086
*/
```

以上三段代码编译执行后均能得到一致的结果,但是如下代码却不能通过编译：

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int p;
  int example(const int *);
  scanf("%d",&p);
  printf("%d\n",example(&p));
  return 0;
}

int example(const int *p){
  printf("The original value is: %d\n",*p);
  *p = 10086;
  return *p;
}
```

这说明使用了 const 关键字之后，不能改变指针指向的整数，但是能改变指针自身。因为实参是按值进行传递的，所以通过指针指向其他地方的方法给 p 赋新值不会对函数外部产生任何影响。在声明时，关键字 const 是不能省略的。继续看下面的代码。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int p;
  int example(int * const);
  scanf("%d",&p);
  printf("%d\n",example(&p));
  return 0;
}

int example(int * const p){
  printf("The original value is: %d\n",*p);
  *p = 10086;
  // int x = 10086;
  // p = &x;
  return *p;
}
/*
98
The original value is: 98
10086
*/
```

本段代码中，如果取消注释部分，则不能通过编译。在此处，可以改变指针指向的整数，但是不能改变改变指针自身。进一步尝试：

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int p;
  int example(const int * const);
  scanf("%d",&p);
  printf("%d\n",example(&p));
  return 0;
}

int example(const int * const p){
  printf("The original value is: %d\n",*p);
  // *p = 10086;
  // int x = 10086;
  // p = &x;
  return *p;
}
/*
98
The original value is: 98
98
*/
```

本段代码中出现了两个 const 关键字。代码中被注释的3行，取消任意一部分均不能通过编译。这种情况说明：通过这种声明之后，既不能改变指针指向的整数，也不能改变指针自身。不过这种情况比较少见。
