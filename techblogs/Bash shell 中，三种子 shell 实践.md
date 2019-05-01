# B

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

```text
[gysl@gysl-dev ~]$ pstree -c -p 6118
bash(6118)───sh(10432)─┬─sh(10433)───sleep(10436)
                       └─sh(10435)───sleep(10437)
[gysl@gysl-dev ~]$ pstree -c -p 6118
bash(6118)───sh(10432)───sh(10439)───sleep(10440)
```