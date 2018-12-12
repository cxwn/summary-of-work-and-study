# 一.登录与配置用户
## 1.1 登陆

这是Zabbix的“欢迎”界面。输入用户名 Admin 以及密码 zabbix 以作为 Zabbix超级用户登陆。

登陆后，你将会在页面右下角看到“以管理员连接（Connected as Admin）”。同时会获得访问配置（Configuration） 和 管理（Administration） 菜单的权限。

点击右上角的用户头像，将显示语言设置为中文。

## 1.2 增加用户
可以在管理（Administration） → 用户（Users）下查看用户信息。

Zabbix在安装后只定义了两个用户。'Admin' 用户是Zabbix的一个超级管理员，拥有所有权限。'Guest' 用户是一个特殊的默认用户。如果你没有登陆，你访问Zabbix的时候使用的其实是“guest”权限。默认情况下，“guest”用户对Zabbix中的对象没有任何权限。

页面右上角点击“创建用户（Create user）”即可增加用户。在添加用户的表单中，确认将新增的用户添加到了一个已有的用户组，比如：Zabbix administrators 。带星号选项均为必填项目。

切换选项卡，完成相关设置，点击“添加”即可。在Zabbix中，主机的访问权限是被分配到用户组，而不是单个用户。现在我们可以尝试使用这个新用户的凭证进行登录了。

# 二.新建主机
Zabbix中的主机（Host）是一个你想要监控的网络实体（物理的，或者虚拟的）。Zabbix中，对于主机的定义非常灵活。它可以时一台物理服务器，一个网络交换机，一个虚拟机或者一些应用。

# 2.1 添加主机
Zabbix中，可以通过配置（Configuration） → 主机（Hosts）菜单，查看已配置的主机信息。默认已有一个名为'Zabbix server'的预先定义好的主机。点击右上角创建主机（Create host）以添加新的主机，带星号项为必填项。

以下字段为必填项：

- **主机名称（Host name）**

输入一个主机名称，可以使用字母数字、空格、点”.“、中划线”-“、下划线”_“。
- **群组**

从右边的选择框中，选择一个或者多个组，然后点击 “选择”进行添加。
所有访问权限都分配到主机组，而不是单独的主机。这也是主机需要属于至少一个组的原因。
- **IP地址**

输入主机的IP地址。注意如果这是Zabbix server的IP地址，它必须是Zabbix agent配置文件中‘Server’参数的值。
暂时保持其他选项的默认值。当完成后，点击添加（Add）。你可以在主机列表中看到你新添加的主机。

此外，还要在“模板”选项卡，选择一个模板。具体操作方式：“链接指示器
”框后点击选择按钮 → 添加（链接指示器框内） → 添加（框外）。 

如果可用性（Availability）列中的ZBX图标是红色的，Zabbix Server 与Zabbix Agent 之间通信可能存在一些问题。将你的鼠标移动到上面查看错误信息。如果这个图标是灰色的，说明目前状态还没更新。确认Zabbix server正在运行，同时尝试过会儿刷新这个页面。（这个过程在前面的文章中有进行介绍）
# 三.新建监控项
监控项是Zabbix中获得数据的基础。没有监控项，就没有数据——因为一个主机中只有监控项定义了单一的指标或者需要获得的数据。所有的监控项都是依赖于主机的。这就是当我们要配置一个监控项时，先要进入 配置 → 主机 页面查找到新建的主机。

因为我们在创建主机时对“模板”选项卡进行过选择，所以监控项不为0。如果没有选择模板，监控项是为0的。点击右上角创建监控项（Create item），将会显示一个监控项定义表格，带星号选项均为必填项。

需要输入如图所示的以下必要的信息：
![Item](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/zabbix-item.png)

当完成后，点击添加（Add）。当一个监控项定义完成后，你可能好奇它具体获得了什么值。前往监控（Monitoring） → 最新数据（Latest data）, 在过滤器中选择刚才新建的主机，然后点击应用（Apply)。如下图：
![监控图形](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/zabbix-item-picture.png)
测试CPU负载命令如下：
```bash
[root@httpd ~]# cat /dev/urandom | gzip -9 | gzip -d | gzip -9 | gzip -d > /dev/null
```

如果你在没有看到类似截图中的监控项信息，请确认：

- 你输入的监控项'值（Key）' 和 '信息类型（Type of information）' - 同截图中的一致
- agent和server都在运行状态
- 主机状态为'监控（Monitored）'并且它的可用性图标是绿色的
- 在主机的下拉菜单中已经选择了对应主机，且监控项处于启用状态

# 四.新建触发器
为监控项配置触发器，前往配置（Configuration） → 主机（Hosts），找到'新增的主机（本例中新增的主机为httpd）'，点击旁边的触发器（Triggers） ，然后点击创建触发器（Create trigger）。带星号项均为必填项。

对于触发器，填写内容如下图：
![触发器](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/zabbix-trigger.png)

这个的表达式大致是说如果3分钟内，CPU负载的平均值超过2，那么就触发了问题的阈值。完成后，点击添加（Add）。新的触发器将会显示在触发器列表中。
如果CPU负载超过了你在触发器中定义的阈值，这个问题将显示在监控（Monitoring） → 问题（Problems）中。
![问题](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/zabbix-trigger-result.png)
# 五.获取问题通知
当监控项收集了数据后，触发器会根据异常状态触发报警。根据一些报警机制，它也会通知我们一些重要的事件，而不需要我们直接在Zabbix前端进行查看。Zabbix中最初内置了一些预定义的通知发送方式。E-mail 通知是其中的一种。此部分在后面的文章中会进行专门介绍。
# 六.新建模板
## 6.1 添加模板
在配置（Configuration） → 模版（Templates）中，点击创建模版（Create template）。需要输入以下必填字段：

- 模版名称（Template name）

可以使用数字、字母、空格及下划线。
- 组（Groups）

使用选择（Select）按钮选择一个或者多个组。模版必须属于一个组。
完成后，点击添加（Add）。你新建的模版可以在模版列表中查看。

## 6.2 在模版中添加监控项
为了在模版中添加监控项，前往httpd的监控项列表。在配置（Configuration） → 主机（Hosts），点击旁边的监控项（Items）。

然后：

- 选中列表中'CPU Load'监控项的选择框。
- 点击列表下方的复制（Copy）。
- 选择想要复制这个监控项的目标模版。
- 点击复制（Copy）。
你现在可以前往配置（Configuration） → 模版（Templates），模板gysl中会有一个新的监控项。

## 6.3 链接模版到主机
准备一个模版后，将它链接到一个主机。前往配置（Configuration） → 主机（Hosts），点击'httpd'打开表单，前往模版（Templates）标签页。

点击链接新模版（Link new templates）旁边的选择（Select），在弹出的窗口中，点击我们创建模版的名称('gysl')，它会出现在链接新模版（Link new templates）区域，点击添加（Add）。这个模版会出现在已链接模版（Linked templates）列表中。

点击更新（Update）保存配置。新模版及其所有的对象被添加到了主机。

你可能会想到，我们可以使用同样的方法将模版应用到其他主机。任何在模版级别的监控项、触发器及其他对象的变更，也会传递给所有链接该模版的主机。最终结果应该如下图：
![最终结果](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/zabbix-template.png)

## 6.4 链接预定义模版到主机
你可能注意到，Zabbix为各种操作系统、设备以及应用准备一些预定义的模版。为了快速部署监控，你可能会将它们中的一些与主机关联。但请注意，一些模版需要根据你的实际环境进行合适的调整。比如：一些检查项是不需要的，一些轮询周期过于频繁。

至此，Zabbix的快速入门暂告一段落，在接下来的文章中我们将进一步探讨。

# 七.相关资料
7.1 [支持的监控项](https://www.zabbix.com/documentation/4.0/zh/manual/config/items/itemtypes/zabbix_agent)

7.2 [Zabbix中的模板](https://www.zabbix.com/documentation/4.0/zh/manual/config/templates)