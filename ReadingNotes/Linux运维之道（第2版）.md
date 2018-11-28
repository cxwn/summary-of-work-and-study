# 一.常用快捷键
```
1.Ctrl+u：删除光标至行首的字符。
2.Ctrl+k：删除光标至行末的字符。
3.Ctrl+w：删除光标前一个单词。
4.Ctrl+d：删除光标后的一个单词。
5.ctrl+f：光标向右移一个字符。
```
# 二.一些常用的sed实例
2.1 在匹配行之前插入指定内容。
```bash
sed -i '/^hello/i hi' text
```
在文件text中匹配以hello开头的一行，并在其前一行插入hi。
```bash
sed -i '/hello/a hi' text
```
在文件text中匹配带hello的一行，并在其后一行插入hi。

2.2 在固定行前后一行插入指定内容。
```bash
sed -i '30i gysl' text
sed -i '31a gysl' text
```
分别在文件text的第30行前一行插入gysl、31后一行插入gysl，空格可以省略。

2.3 删除指定行的内容。
```bash
sed -i '3,5d' text
sed -i '1d' text
sed -i '1,$d' text
```
分别删除文件text第3-5行的内容、第1行的内容、清空整个文件(等价于：sed -i 'd' text)。

2.4 删除匹配行的内容。
```bash
sed -i '/gysl/d' text
``` 