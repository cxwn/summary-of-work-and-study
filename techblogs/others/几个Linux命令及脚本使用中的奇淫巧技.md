**实例1**.创建一个别名，删除原始文件，同时在用户的home目录下backup中保存副本。
```bash
#/bin/bash
cp $@ ~/backup && rm -rf $@
```
**实例2**.Fork炸弹。
```bash
:(){:|:&};:
```
**实例3**.生成一个11位的随机密码，包括大小写字母、数字及特殊（/与+）符号。
```bash
openssl rand -base64 200|cut -b 1-11|head -n 1
```
**实例4**.不切换当前工作目录，使用cd命令并显示切换后目标目录的内容。
```bash
(cd /bin;ls)
```
本例子中，使用()定义了一个子shell，对当前的shell并无影响，所有改变仅限于子shell中，上述操作在某些场景中特别有用。

**实例5**.为防止当前工作终端退出造成正在执行的任务被中断，我们可以在屏幕上随机打印一些数字字母。下面命令用来装X有时候也挺有用。
```bash
while true ; do display=`echo $RANDMOM|md5sum` ; echo $display $display ; done
```
**实例6**.使用一条命令随机创建一个指定格式的文件或目录。
```bash
mktemp gyslXXX
mktemp -d gyslXXX
```
此命令一般不常见，gysl为指定的前缀，之后的大写X为占位符，这些大写的X不能位于名称最前面，并且至少保证存在3个X占位符，这些大写X在创建新文件和新目录是会被随机字母所替代。如果直接执行mktemp命令，那么会在本机的/tmp目录下创建临时文件或目录。执行该命令创建的文件默认权限为：600，目录权限为700，并不受umask所影响，这一点需要特别注意。
**实例7**.删除文本中的空白行。
```bash
sed -i '/^$/d' a.txt
```
实现这个功能的命令很多，可能这是最简单一个命令了。

**实例8**.通过正则表达式的匹配，将匹配内容使用&替代，按照指定格式输出。
```bash
echo "My name is Ivan."|sed 's/\w\+/[&]/g'
echo "My name is Ivan. My phone number is 010-87654321"|sed 's/[a-zA-Z0-9]\+/{&}'
```
上面例子分别匹配出了目标字符串中的单词（包括数字和字母），并把匹配内容分别使用[]和{}包起来。
**实例9**.通过sed命令直接编辑文本时，在编辑之前先将源文件进行备份。
```bash
sed -i.1010.bak 's/ChatDevOps/gysl/' test.txt
```
执行完该命令后，源文件里面的每一行第一个匹配的ChatDevOps替换为gysl，并将源文件备份为test.txt.1010.bak。
