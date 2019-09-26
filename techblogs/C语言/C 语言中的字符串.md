# C 语言中的字符串

## 一 概述

## 二 认识 C 语言中的字符串

### 2.1 字符串的定义及其长度

```c
# include<stdio.h>
# include<string.h>

int main(int argc,char *argv[]){
  const char *str1 = "My blog is:  https://ivandu.blog.csdn.net";
  const char *str2 = "My blog is:  https://ivandu.blog.csdn.net\0";
  char str3[] = {'g', 'y', 's', 'l'};
  char str4[] = {'g', 'y', 's', 'l', '\0'};
  char str5[6] = {'g', 'y', 's', 'l'};
  char str6[4] = "gysl";
  char str7[5] = "gysl\0";
  char str8[] = "gysl";
  char str9[] = "gysl\0";
  char str10[] = "gysl\0\0";
  char str11[10] = "gysl\0\023";
  printf("Length of the str1: %d\n\
Length of the str2: %d\n\
Length of the str3: %d\n\
Length of the str4: %d\n\
Length of the str5: %d\n\
Length of the str6: %d\n\
Length of the str7: %d\n\
Length of the str8: %d\n\
Length of the str9: %d\n\
Length of the str10: %d\n\
Length of the str11: %d\n",strlen(str1),strlen(str2),strlen(str3),strlen(str4),strlen(str5),strlen(str6),strlen(str7),strlen(str8),strlen(str9),strlen(str10),strlen(str11));
  return 0;
}
/*
Length of the str1: 41
Length of the str2: 41
Length of the str3: 4
Length of the str4: 4
Length of the str5: 4
Length of the str6: 4
Length of the str7: 4
Length of the str8: 4
Length of the str9: 4
Length of the str10: 4
Length of the str11: 4
*/
```

以上例子展示了字符串及字符数组在 C 语言中的各种定义方式，并用函数 strlen() 测试了各种定义中，字符串及字符数组的长度。

从该例子中我们可以看出：字符串及字符数组默认以'\0'为结束标识符。只要出现'\0',即代表该字符串或字符数组结束，无论后面是什么内容，均全部忽略。'\0'是占用存储空间的。

例子中使用的编译器能够进行数组下标检查。例如：“char str7[4] = "gysl\0"”是无法通过编译的。该编译器的版本是：gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-36)。

### 2.2 字符数组与字符指针

```c
# include<stdio.h>
# include<string.h>

int main(int argc, char *argv[]){
  char *a = "My name is ivan.";
  for (int i = 0; i < strlen(a); a++)
    printf("%c",*a);
  printf("\n");
  return 0;
}
// My name is ivan.
```

```c
# include<stdio.h>
# include<string.h>

int main(int argc,char *argv[]){
  char *a = "My name is ivan.";
  printf("%c",*(a+3));
  printf("\n");
  return 0;
}
// n
```

```c
# include<stdio.h>
# include<string.h>

int main(int argc,char *argv[]){
  char *a = "My name is ivan.";
  printf("%c",a[3]);
  printf("\n");
  return 0;
}
// n
```

```c
# include<stdio.h>
# include<string.h>

int main(int argc,char *argv[]){
  char ch = "My name is ivan."[3];
  printf("%c",ch);
  printf("\n");
  return 0;
}
// n
```

以上四个例子展示字符指针的几种遍历方式，通过这些例子，我们可以看出字符数组和字符指针在一些场景下是可以互换的。

### 2.3 字符串的输入

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  char str[10] = {'M', 'y', 'n', 'a', 'm', 'i', 's', 'i', 'v', 'a'};
  scanf("%s",str);
  printf("%s\n",str);
  return 0;
}
```

字符串的输入依然可以使用 scanf() 函数进行输入，并且无需使用 & 运算符。此时被输入的字符串是数组名，编译器把它传给函数时会当作指针来处理。scanf() 会跳过空白字符，遇到空白字符即终止输入。

使用 gets() 来测试输入功能时，会出现以下提示：

```text
any_test.c:5:3: 警告：不建议使用‘gets’(声明于 /usr/include/stdio.h:638)
```

既然直接使用 scanf() 和 gets() 函数来输入字符串都有缺陷，那么使用 scanf() 函数逐个字符输入字符串试试看：

```c
# include<stdio.h>
# define LENGTH 16

int main(int argc,char *argv[]){
  char str[LENGTH + 1];
  for ( int i = 0; i < LENGTH; i++)
    scanf("%c",&str[i]);
  str[LENGTH] = '\0';
  printf("%s\n",str);
  return 0;
}
/*
my name is ivan.
my name is ivan.
*/
```

“str[LENGTH] = '\0';”这一行不能省略。printf() 函数会逐个写字符串中的字符，直到遇到 '\0' 为止，如果省略了 '\0'，printf() 将不知道字符串何时结束，会越过字符串末尾继续写，直到在内存的某个地方找到 '\0' 为止。具体我们可以删除这一行代码看一下效果。

### 2.4 使用字符串库函数

```c
# include<stdio.h>
# include<string.h>

int main(int argc,char *argv[]){
  char str1[100] = "My name is ivan.", str2[] = " My blog is ivandu.blog.csdn.net";
  strcat(str1,str2);
  printf("%s\n",str1);
  return 0;
}
// My name is ivan. My blog is ivandu.blog.csdn.net
```

与 strcpy() 函数类似，使用 strcat() 函数时，str1 的长度必须比 str2 大，且 str1 的长度必须明确。

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  char str1[] = "my computer is good.\n\0";
  printf(str1);
  return 0;
}
//my computer is good.
```
