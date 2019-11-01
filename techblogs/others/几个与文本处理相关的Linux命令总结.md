1.当前目录下有若干文件，找出扩展名为TextGrid的所有文件，并复制到../file_set。
```bash
find . -name "*.TextGrid" \-exec cp {} ../file_set/ \;
```
---

2.当前目录下有若干文件，找出扩展名为“TextGrid”且非UTF-8（UTF-8 Unicode Text，with CRLF line terminators）编码的文件，并将其移动到../trash。该类型的文件命名规则为16位随机数字。
```bash
for s_file in `for t_file in $(ls *.TextGrid);do file $t_file|grep -v "UTF-8 Unicode Text，with CRLF line terminators"|grep -o -E [0-9]{16}\.TextGrid;done` do mv $s_file ../trash ;done
```
---

3.产生一个含有大写字母和数字长度为8的随机字符串。
```bash
echo $RANDOM|md5sum|tr -t [a-z] [A-Z]|cut -b 1-8
```

---
4.批量删除文本中以某指定字符串匹配的行。
```
sed -i '/^sid/d' test.txt
```
5.查看系统中所有人可读写执行的不安全文件。
```bash
find / -perm 777 -a \! -type s -a \! -type l -a \! \( -type d -a -perm 1777 \)
```
