# Bash shell 中，三种子 shell 实践

## 一 背景

让我们先来看一下下面这个简单的例子：

```bash
#!/bin/bash
#===============================================================================
#          FILE: process_test.sh
#         USAGE: . ${YOUR_PATH}/process_test.sh
#   DESCRIPTION:
#        AUTHOR: IVAN DU
#        E-MAIL: mrivandu@hotmail.com
#        WECHAT: ecsboy
#      TECHBLOG: https://ivandu.blog.csdn.net
#        GITHUB: https://github.com/mrivandu
#       CREATED: 2019-05-01 23:56:32
#       LICENSE: GNU General Public License.
#     COPYRIGHT: © IVAN DU 2019
#      REVISION: v1.0
#===============================================================================

test_num=${RANDOM};
echo "Test start. Current process is: $$. Parent process is: ${PPID}. Test_num is: ${test_num}. ";
# &
{
echo '-----------&------------';
echo "& test start. test_num is: ${test_num} ";
sleep 30
echo "& test. Now pid is:$$";
test_num=${RANDOM}
echo "& test_num is: ${test_num}. ";
}&
echo "& test end. Test_num is: ${test_num}. ";
# |
echo ""|\
{
echo '-----------|------------';
echo "| test start. test_num is: ${test_num} ";
sleep 30
echo "| test. Now pid is:$$";
test_num=${RANDOM}
echo "| test_num is: ${test_num}. ";
}
echo "| test end. Test_num is: ${test_num}. ";
# ()
(
echo '-----------()------------';
echo "() test start. test_num is: ${test_num} ";
sleep 30
echo "() test. Now pid is:$$";
test_num=${RANDOM}
echo "() test_num is: ${test_num}. ";
)
echo "() test end. Test_num is: ${test_num}. ";
echo "All tests stop. Parent process is: $$. Test_num is: ${test_num}.";
```

这个例子展示了三种创建子 shell 的方法，每个子 shell 的内容基本都一致。接下来让我们看一下执行结果：

```text
[gysl@gysl-dev ~]$ sh process_test.sh
Test start. Current process is: 10432. Parent process is: 6118. Test_num is: 1457.
& test end. Test_num is: 1457.
-----------&------------
& test start. test_num is: 1457
-----------|------------
| test start. test_num is: 1457
& test. Now pid is:10432
& test_num is: 26453.
| test. Now pid is:10432
| test_num is: 17987.
| test end. Test_num is: 1457.
-----------()------------
() test start. test_num is: 1457
() test. Now pid is:10432
() test_num is: 28781.
() test end. Test_num is: 1457.
All tests stop. Parent process is: 10432. Test_num is: 1457.
```

## 二 分析求证

执行该脚本的当前 shell 的 PID 是 6118 ，也就是当前 shell 的 PPID 。脚本开始时，我们使用一个随机数对 test_num 进行了赋值，在当前脚本中的值是 1457 。在三种子 shell 的执行过程中，test_num 传入了子 shell ，依然为 1457 。子 shell 中再次对 test_num 赋值能覆盖传入的 test_num 的值，但子shell 执行完毕之后，返回的值依然为 1457 。三种方式都出奇的的一致，这说明：子 shell 在执行过程中能引用父 shell 的变量，父 shell 中的变量在子 shell 中被修改后不返回父 shell ，作用域只存在于子 shell 中。简而言之，父 shell 中的值能被子 shell 调用，父 shell 中的变量能被子 shell 修改，子 shell 中的变量值不能传回父 shell 。

继续分析，“& test end. Test_num is: 1457. ”出现在第二行，这一行原本是在 & 子 shell 执行完毕后才执行的，但是却提前执行了。进一步观察，我们发现，& 子 shell 和 | 子 shell 的执行结果混在一起了。而 () 子 shell 却中规中矩的按照预期执行。这是为什么呢？让我们来看一下 pstree 命令返回的结果：

```text
[gysl@gysl-dev ~]$ pstree -c -p 6118
bash(6118)───sh(10432)─┬─sh(10433)───sleep(10436)
                       └─sh(10435)───sleep(10437)
[gysl@gysl-dev ~]$ pstree -c -p 6118
bash(6118)───sh(10432)───sh(10439)───sleep(10440)
```

当前 shell 10432 在执行初期，先后产生了两个子 shell，30 秒后，这两个子 shell 执行结束，执行 () 子 shell 。结果显而易见，& 子 shell 支持异步执行！

### 三 总结

3.1 实现子 shell 的方式有三种：&/|（管道）/()。

3.2 子 shell 能调用并修改父 shell 的变量值，但是子 shell 的变量值不返回父 shell 中，要牢记。

3.3 & 方式实现的子 shell 能异步执行，这是与其他两种实现方式最大的不同之处。
