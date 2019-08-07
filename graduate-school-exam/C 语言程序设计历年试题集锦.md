# C 语言程序设计历年试题集锦

1.已知数字0的ASCII码为48，请写出下列程序的正确输出（20180504）。

```c
#include <stdio.h>

int main()
{
     char c = 48;
     int i, mask = 01;
     for (i=1; i<=5; i++)
     {
         printf("%c",c|mask);
         mask = mask << 1;
     }
    return 0;
}
```

答案(0807)： 12480

---

2.对于下列代码（20180604）：

```c
#include <stdio.h>

int main()
{
    char option = 'W';
    switch(option)
    {
    case 'H':
        printf("Hello ");
    case 'W':
        printf("Welcome ");
    case 'B':
        printf("Bye ");
    }
    return 0;
}
```

若 option 的值为'W',则该段代码的输出结果是__。

答案（0807）：Welcome Bye

---
