# C Language Learning

1 . C 语言中的几个字符串的操作函数使用对比。

```c
# include <stdio.h>
# include <string.h>
int main(void)
 {
  char str1[100]="I am string one. I am longer. "; //length=30
  char str2[50]="I'm string two. I'm shorter. "; //length=29
  printf("Strcat:%s\n",strcat(str1,str2));
  printf("str1:%sstr2:%s\n",str1,str2);
  // strcat 函数将 str1 和 str2 连接并赋值给 str1，str1 的长度要足够。
  printf("Strcpy:%s\n",strcpy(str1,str2));
  printf("str1:%sstr2:%s\n",str1,str2);
  printf("Strcmp:%d\n",strcmp(str1,str2));
  return 0;
 }
```

2 . C 语言中，字符数组可以改变数组中其中一个字符的值，指针数组中的字符的值是不能改变的。

```c
# include <stdio.h>
int main(void)
 {
  char *string1 = "My name is ivan." ;
  char string2[] = "My blog is gysl." ;
  // Change string1 and string2.
  // *(string1+2) = '_' ;
  // printf("string1:%s\n ", string1) ;
  *(string2+2) = '_' ;
  printf("string2:%s\n", string2);
  string1 = "My wechat is ecsboy." ;
  printf("string1:%s\n", string1) ;
  return 0;
 }
```