# C Language Learning

1.C语音中的几个字符串的操作函数使用对比。

```c
# include <stdio.h>
# include <string.h>
int main(void)
 {
  char str1[100]="I am string one. I am longer. "; //length=30
  char str2[50]="I'm string two. I'm shorter. "; //length=29
  printf("Strcat:%s\n",strcat(str1,str2));
  printf("str1:%sstr2:%s\n",str1,str2);
  // strcat 函数将 str1 和 str2 连接到 str1，str1 的长度要足够.
  printf("Strcpy:%s\n",strcpy(str1,str2));
  printf("str1:%sstr2:%s\n",str1,str2);
  printf("Strcmp:%d\n",strcmp(str1,str2));
  return 0;
 }
```