# C 语言中两个函数 getc() 与 putc() 使用详解

示例代码：

```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  FILE * source,* destination;
  int ch;
  if (argc != 3)
  {
    fprintf(stderr, "Usage: fcopy file1 file2\n");
    exit(EXIT_FAILURE);
  }
  if ((source = fopen(argv[1], "rb")) == NULL)
  {
    fprintf(stderr, "The file %s is not exist.\n", argv[1]);
    exit(EXIT_FAILURE);
  }
  if ((destination = fopen(argv[2], "wb")) == NULL)
  {
    fprintf(stderr, "The file %s is not exist.\n",argv[2]);
    exit(EXIT_FAILURE);
  }
  while ( (ch = getc(source)) != EOF)
  {
    putc(ch, destination);
  }
  fclose(source);
  fclose(destination);
  return 0;
}
```
