# 再议 C 语言中的指针与数组

```c
# include<stdio.h>

int main(int argc,char *argv[]){
  int a[10] = {1,2,3,4,6,5,7,8,9,0};
  int *p;
  // p = a;
  p = &a[0];
  for (int i = 0; i < 10; i++){
    printf("%d\n",*p);
    p++;
  }
  return 0;
}
```
