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
  int a = 15, b = 6, i, j;
  for ( ; i < a, j < b;i++, j++)
  {}
  printf("%d\t%d\n",i,j);
  return 0;
}
// 6       6
```

这种情况以后一个变量的值为上限。
