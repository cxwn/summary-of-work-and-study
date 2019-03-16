# 在CentOS/RHEL 7.X安装 EPEL repo 的方法

## 一 背景

RHEL以及他的衍生发行版如CentOS、Scientific Linux为了稳定，官方的rpm repository提供的rpm包往往是很滞后的，而EPEL恰恰可以解决这两方面的问题。EPEL的全称叫 Extra Packages for Enterprise Linux 。EPEL是由 Fedora 社区打造，为 RHEL 及衍生发行版如 CentOS、Scientific Linux 等提供高质量软件包的项目。装上了 EPEL之后，就相当于添加了一个第三方源。在某些情况下，通过 EPEL repo 安装一些软件比其他安装方式方便很多。

众所周知，rpmfusion.org 主要为桌面发行版提供大量rpm包，而EPEL则为服务器版本提供大量的rpm包，而且大多数rpm包在官方 repository 中是找不到的。绝大多数rpm包要比官方 repository 的rpm包版本要新。

## 二 操作步骤

### 2.1 执行安装命令

```bash
yum -y install epel-release
```

### 2.2 查看结果

```bash
yum repolist
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: ap.stykers.moe
 * epel: mirror01.idc.hinet.net
 * extras: mirrors.cn99.com
 * updates: mirrors.njupt.edu.cn
repo id                                                              repo name                                                                                           status
base/7/x86_64                                                        CentOS-7 - Base                                                                                     10019
*epel/x86_64                                                         Extra Packages for Enterprise Linux 7 - x86_64                                                      12973
extras/7/x86_64                                                      CentOS-7 - Extras                                                                                     371
updates/7/x86_64                                                     CentOS-7 - Updates                                                                                   1163
repolist: 24526
```

我们可以与安装之前对比一下：

```bash
yum repolist
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: mirrors.nwsuaf.edu.cn
 * extras: mirrors.nwsuaf.edu.cn
 * updates: mirrors.nwsuaf.edu.cn
repo id                                                                            repo name                                                                             status
base/7/x86_64                                                                      CentOS-7 - Base                                                                       10019
extras/7/x86_64                                                                    CentOS-7 - Extras                                                                       371
updates/7/x86_64                                                                   CentOS-7 - Updates                                                                     1163
repolist: 11553
```

效果不言而喻。

### 2.3 其他安装方式

通过 rpm 包可以安装，下载地址如下：<https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm>