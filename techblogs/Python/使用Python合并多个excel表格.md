# 使用 Python 将多个格式一致的 Excel 合并成一个

## 一 问题描述

最近朋友在工作中遇到这样一个问题，她每天都要处理如下一批 Excel 表格：每个表格的都只有一个 sheet，表格的前两行为表格标题及表头，表格的最后一行是相关人员签字。最终目标是将每个表格的内容合并到一个 Excel 表格中，使之成为一张表格。在她未咨询我之前，每天复制粘贴这一类操作占用了她绝大部分时间。表格样式如下：
![样表](https://raw.githubusercontent.com/mrivandu/summary-of-work-and-study/master/image-hosting-service/%E7%94%A8python%E5%90%88%E5%B9%B6%E5%A4%9A%E4%B8%AAexcel%E8%A1%A8%E6%A0%BC.jpg)

## 二 需求分析

根据她的描述，最终需求应该是这样的：在这一批表格中选取任意一个表格的前两行作为新表格的标题与表头，将这两行内容以嵌套列表的形式插入一个名为 data 空列表中。取每张表格的第3至倒数第二行，剔除空白行的内容。并将所有表格的内容以子列表的方式依次插入 data 列表中。任取一表格的最后一行以子列表的方式插入 data 列表中。最后将 data 列表的内容写入一个新的 Excel 表格中。

## 三 查阅资料

通过几分钟的上网查询，得出以下结论：

- 3.1 通过 xlrd 和 xlsxwriter 模块即可解决次需求；

- 3.2 之所以使用 xlrd 和 xlsxwriter 是因为： xlrd擅长读取 Excel 文件，不适合写入，用 xlsxwriter 来进行大规模写入 Excel 表格不会出现报错。

## 四 编码

一切以解决当前问题为向导，说干就干。 coding ... ...

```python
# -*- coding:utf-8 -*-
import os, xlrd, xlsxwriter

source_dir = r'input'
new_execl = "All in one.xlsx"
raw_excels = os.listdir(source_dir)
keyword = "油站经理" # 除包括此关键字的行均插入
data = []

filename = os.path.join(source_dir, raw_excels[0])
wb = xlrd.open_workbook(filename)
sheet = wb.sheets()[0]
data.append(sheet.row_values(0))
data.append(sheet.row_values(1))

for excel in raw_excels:
    filename = os.path.join(source_dir, excel)
    wb = xlrd.open_workbook(filename)
    sheet = wb.sheets()[0]
    for row_num in range(2, sheet.nrows):
        row_values = [str(i) for i in sheet.row_values(row_num)]
        if len(''.join(row_values)) and (keyword not in ''.join(row_values)):
            data.append(sheet.row_values(row_num))
data.append(sheet.row_values(sheet.nrows-1))

new_wb = xlsxwriter.Workbook(new_execl)
worksheet = new_wb.add_worksheet()
font = new_wb.add_format({"font_size":11})
for i in range(len(data)):
    for j in range(len(data[i])):
        worksheet.write(i, j, data[i][j], font)
new_wb.close()
```

半小时后，大功告成！

## 五 使用说明

- 5.1 下载安装 Python3.X(具体安装步骤自己查一下)；

- 5.2 安装 xlrd 和 xlsxwriter 模块，参考命令： `pip install xlrd xlsxwriter`。开始此步骤之前可能需要先升级pip，具体升级命令系统会提示，复制粘贴即可；

- 5.3 新建一个名为 input 的文件夹，将需要合并的文件复制到这个文件夹下；

- 5.4 把以上代码复制以 excels_merge.py 的文件名保存在与 input 文件夹同级别的文件夹中，双击鼠标稍后即可。如果没有关联打开方式，那么就在资源管理器的地址栏输入“cmd”，在打开的命令窗口输入：`python excels_merge.py`。生成的 All in one.xlsx 即为合并后的新 Excel 文件。

## 六 总结

- 6.1 `[str(i) for i in sheet.row_values(row_num)]`这一部分代码实现了将列表内的元素统一转化为字符串，主要是为了下一行代码实现将列表转换为字符串；

- 6.2 遇到问题之后，分析清楚动手干就对了！不要犹豫，不动手怎么知道自己不行呢？

- 6.3 此的脚本不对源 Excel 文件进行任何操作，可是放心使用；

- 6.4 以上脚本就是随手一写，都没有优化，以后如果数据量太大估计会考虑优化，希望大家多提意见或建议;

- 资源管理器的地址栏输入“cmd”，在打开的命令窗口 源代码可以访问我的同名 CSDN 博客及 GitHub 获取。
这一部分这一部分dda代码实现了将列表内的元素统一转化为字符串，主要是为了下一行代码实现将列表转换为字符串；

- 6.2 遇到问题之后，分析清楚动手干就对了！不要犹豫，不动手怎么知道自己不行呢？

- 6.3 以上脚本就是随手一写，都没有优化，以后如果数据量太大估计会考虑优化，希望大家多提意见或建议;

- 6.4 源代码可以访问我的同名 CSDN 博客及 GitHub 获取。# 使用 Python 将多个格式一致的 Excel 合并成一个

## 一 问题描述

最近朋友在工作中遇到这样一个问题，她每天都要处理如下一批 Excel 表格：每个表格的都只有一个 sheet，表格的前两行为表格标题及表头，表格的最后一行是相关人员签字。最终目标是将每个表格的内容合并到一个 Excel 表格中，使之成为一张表格。在她未咨询我之前，每天复制粘贴这一类操作占用了她绝大部分时间。表格样式如下：
![样表](https://raw.githubusercontent.com/mrivandu/summary-of-work-and-study/master/image-hosting-service/%E7%94%A8python%E5%90%88%E5%B9%B6%E5%A4%9A%E4%B8%AAexcel%E8%A1%A8%E6%A0%BC.jpg)

## 二 需求分析

根据她的描述，最终需求应该是这样的：在这一批表格中选取任意一个表格的前两行作为新表格的标题与表头，将这两行内容以嵌套列表的形式插入一个名为 data 空列表中。取每张表格的第3至倒数第二行，剔除空白行的内容。并将所有表格的内容以子列表的方式依次插入 data 列表中。任取一表格的最后一行以子列表的方式插入 data 列表中。最后将 data 列表的内容写入一个新的 Excel 表格中。

## 三 查阅资料

通过几分钟的上网查询，得出以下结论：

- 3.1 通过 xlrd 和 xlsxwriter 模块即可解决次需求；

- 3.2 之所以使用 xlrd 和 xlsxwriter 是因为： xlrd擅长读取 Excel 文件，不适合写入，用 xlsxwriter 来进行大规模写入 Excel 表格不会出现报错。

## 四 编码

一切以解决当前问题为向导，说干就干。 coding ... ...

```python
# -*- coding:utf-8 -*-
import os, xlrd, xlsxwriter

source_dir = r'input'
new_execl = "All in one.xlsx"
raw_excels = os.listdir(source_dir)
keyword = "油站经理" # 除包括此关键字的行均插入
data = []

filename = os.path.join(source_dir, raw_excels[0])
wb = xlrd.open_workbook(filename)
sheet = wb.sheets()[0]
data.append(sheet.row_values(0))
data.append(sheet.row_values(1))

for excel in raw_excels:
    filename = os.path.join(source_dir, excel)
    wb = xlrd.open_workbook(filename)
    sheet = wb.sheets()[0]
    for row_num in range(2, sheet.nrows):
        row_values = [str(i) for i in sheet.row_values(row_num)]
        if len(''.join(row_values)) and (keyword not in ''.join(row_values)):
            data.append(sheet.row_values(row_num))
data.append(sheet.row_values(sheet.nrows-1))

new_wb = xlsxwriter.Workbook(new_execl)
worksheet = new_wb.add_worksheet()
font = new_wb.add_format({"font_size":11})
for i in range(len(data)):
    for j in range(len(data[i])):
        worksheet.write(i, j, data[i][j], font)
new_wb.close()
```

半小时后，大功告成！

## 五 使用说明

- 5.1 下载安装 Python3.X(具体安装步骤自己查一下)；

- 5.2 安装 xlrd 和 xlsxwriter 模块，参考命令： `pip install xlrd xlsxwriter`。开始此步骤之前可能需要先升级pip，具体升级命令系统会提示，复制粘贴即可；

- 5.3 新建一个名为 input 的文件夹，将需要合并的文件复制到这个文件夹下；

- 5.4 把以上代码复制以 excels_merge.py 的文件名保存在与 input 文件夹同级别的文件夹中，双击鼠标稍后即可。如果没有关联打开方式，那么就在资源管理器的地址栏输入“cmd”，在打开的命令窗口输入：`python excels_merge.py`。

## 六 总结

- 6.1 `[str(i) for i in sheet.row_values(row_num)]`这一部分代码实现了将列表内的元素统一转化为字符串，主要是为了下一行代码实现将列表转换为字符串；

- 6.2 遇到问题之后，分析清楚动手干就对了！不要犹豫，不动手怎么知道自己不行呢？

- 6.3 以上脚本就是随手一写，都没有优化，以后如果数据量太大估计会考虑优化，希望大家多提意见或建议;

- 6.4 源代码可以访问我的同名 CSDN 博客及 GitHub 获取。
# 使用 Python 将多个格式一致的 Excel 合并成一个

## 一 问题描述

最近朋友在工作中遇到这样一个问题，她每天都要处理如下一批 Excel 表格：每个表格的都只有一个 sheet，表格的前两行为表格标题及表头，表格的最后一行是相关人员签字。最终目标是将每个表格的内容合并到一个 Excel 表格中，使之成为一张表格。在她未咨询我之前，每天复制粘贴这一类操作占用了她绝大部分时间。表格样式如下：
![样表](https://raw.githubusercontent.com/mrivandu/summary-of-work-and-study/master/image-hosting-service/%E7%94%A8python%E5%90%88%E5%B9%B6%E5%A4%9A%E4%B8%AAexcel%E8%A1%A8%E6%A0%BC.jpg)

## 二 需求分析

根据她的描述，最终需求应该是这样的：在这一批表格中选取任意一个表格的前两行作为新表格的标题与表头，将这两行内容以嵌套列表的形式插入一个名为 data 空列表中。取每张表格的第3至倒数第二行，剔除空白行的内容。并将所有表格的内容以子列表的方式依次插入 data 列表中。任取一表格的最后一行以子列表的方式插入 data 列表中。最后将 data 列表的内容写入一个新的 Excel 表格中。

## 三 查阅资料

通过几分钟的上网查询，得出以下结论：

- 3.1 通过 xlrd 和 xlsxwriter 模块即可解决次需求；

- 3.2 之所以使用 xlrd 和 xlsxwriter 是因为： xlrd擅长读取 Excel 文件，不适合写入，用 xlsxwriter 来进行大规模写入 Excel 表格不会出现报错。

## 四 编码

一切以解决当前问题为向导，说干就干。 coding ... ...

```python
# -*- coding:utf-8 -*-
import os, xlrd, xlsxwriter

source_dir = r'input'
new_execl = "All in one.xlsx"
raw_excels = os.listdir(source_dir)
keyword = "油站经理" # 除包括此关键字的行均插入
data = []

filename = os.path.join(source_dir, raw_excels[0])
wb = xlrd.open_workbook(filename)
sheet = wb.sheets()[0]
data.append(sheet.row_values(0))
data.append(sheet.row_values(1))

for excel in raw_excels:
    filename = os.path.join(source_dir, excel)
    wb = xlrd.open_workbook(filename)
    sheet = wb.sheets()[0]
    for row_num in range(2, sheet.nrows):
        row_values = [str(i) for i in sheet.row_values(row_num)]
        if len(''.join(row_values)) and (keyword not in ''.join(row_values)):
            data.append(sheet.row_values(row_num))
data.append(sheet.row_values(sheet.nrows-1))

new_wb = xlsxwriter.Workbook(new_execl)
worksheet = new_wb.add_worksheet()
font = new_wb.add_format({"font_size":11})
for i in range(len(data)):
    for j in range(len(data[i])):
        worksheet.write(i, j, data[i][j], font)
new_wb.close()
```

半小时后，大功告成！

## 五 使用说明

- 5.1 下载安装 Python3.X(具体安装步骤自己查一下)；

- 5.2 安装 xlrd 和 xlsxwriter 模块，参考命令： `pip install xlrd xlsxwriter`。开始此步骤之前可能需要先升级pip，具体升级命令系统会提示，复制粘贴即可；

- 5.3 新建一个名为 input 的文件夹，将需要合并的文件复制到这个文件夹下；

- 5.4 把以上代码复制以 excels_merge.py 的文件名保存在与 input 文件夹同级别的文件夹中，双击鼠标稍后即可。如果没有关联打开方式，那么就在资源管理器的地址栏输入“cmd”，在打开的命令窗口输入：`python excels_merge.py`。

## 六 总结

- 6.1 `[str(i) for i in sheet.row_values(row_num)]`这一部分代码实现了将列表内的元素统一转化为字符串，主要是为了下一行代码实现将列表转换为字符串；

- 6.2 遇到问题之后，分析清楚动手干就对了！不要犹豫，不动手怎么知道自己不行呢？

- 6.3 以上脚本就是随手一写，都没有优化，以后如果数据量太大估计会考虑优化，希望大家多提意见或建议;

- 6.4 源代码可以访问我的同名 CSDN 博客及 GitHub 获取。

