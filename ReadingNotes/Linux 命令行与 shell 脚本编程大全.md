# Linux 命令行与 shell 脚本编程大全

## 一 章节细读 

### 1.1 安装软件程序

Redhat 系列：

```text
yum list installed：列出全部已经安装的软件。
yum list software：列出可安装的 xterm 的详细信息。
yum list installed software：列出已安装的 xterm 的详细信息。
yum list updates：列出所有已安装的软件的可用已安装包。
yum update software：更新相关软件包。
yum provides file_name：系统上的文件属于哪个软件包。
yum localinstall software：安装本地软件。
yum remove software：卸载相关软件包，保留配置和数据文件。
yum erease software：卸载相关软件包，删除配置和数据文件。
yum deplist software：列出相关软件的依赖关系。
```

### 1.2 使用编辑器

vim 系列：

```text
dw:删除光标所在位置的单词。
J：删除光标所在行的换行符（拼接符）。
R：替换光标所在位置的字符，直到按 ESC 为止。
:%s/old/new/gc：全部替换，每次替换都提示。
```

### 1.3 构建基本脚本

```text
双括号内的>和<无需使用转义字符。
Linux 的环境变量-内部字段分隔符 IFS(internal field separator) 定义了 bash shell 用作字段分隔符的一系列字符。默认值有：空格、制表符、换行符。
循环中，break n 表示循环跳出第几层循环，n 的值默认为1，表示跳出当前循环。continue 用法类似。
外部传参时，从第10个参数开始，花括号不可缺少。例如：${10}。
shift 移动传入的参数时，前面的参数会被删除，不可恢复，可以使用 shift n 指定移动的位置。
bash shell 中的局部变量定义格式：local variable，变量前面加 local。
```