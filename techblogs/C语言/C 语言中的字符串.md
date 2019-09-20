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

```c
# include<stdio.h>
# include<string.h>

int main(int argc,char *argv[]){
  char *a = "My name is ivan.";
  for (int i = 0; i < strlen(a); a++)
    printf("%c",*a);
  printf("\n");
  return 0;
}
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

```c
