# 一.环境
1.1 操作系统（其他发行版亦可）：
```bash
[root@gysl ~]# cat /etc/centos-release
CentOS Linux release 7.5.1804 (Core)
```
1.2 Git版本：
```
[root@gysl ~]# git --version
git version 1.8.3.1
```
# 二.步骤
2.1 下载并安装Git软件。
```bash
[root@gysl ~]# yum -y install git
```

2.2 创建SSH key。
```bash
[root@gysl ~]# ssh-keygen -t rsa -b 2048 -C "gysl@github.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Created directory '/root/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:QYCyVkZQyuMZFG4vH8ulyo7L4x5Jz1ewWhhD69mVhI8 gysl@github.com
The key's randomart image is:
+---[RSA 2048]----+
|  +*o.oo.        |
| +o.=....        |
|  BO .oo.        |
| o+=*E+. .       |
| o++o+..S        |
|. ++o=.          |
| o +=.           |
|.+...            |
|=*=              |
+----[SHA256]-----+
```
这里简单提一下ssh-keygen的几个选项，-t指定加密算法，-b指定位数，-C可以理解为注释（comment)，随意填写，可以填写为管理员邮箱。连续按几次enter键即可，其余不必理会。

2.3 在GitHub的settings里面添加刚刚创建的SSH key的公钥。
```bash
[root@gysl /]# cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjI58Vk8kCQqu6PPng8/bjkZY2JrsH/kExR9JpZ9I+i71H744Mpi7VnaBnbgye15ri4jG7DKFVMUKU7dflplL4+th90B2QIAEBKrXbIUV9LJH5InL/uJQ9+Gu7NK/vIboFhFLKgSzE3EU3p5SQcCNkGFL9ygQ18FPE2d2mwm+fOhNC73OrlADqZwLJ99wXKoH+3wX/b0l+NBsCE7usPE4bxQK6ZDWtjjvsQ2QWtlGO4ia7m3VdDmumV2byFEyeEpAN2dbMmlkVeix8+VmVNkPbJKkeSyjIXaJcjDJdyeqCcV0Kwx9jY+yU13LVZIBJ4wUBvtjO/u/RKDDsz1Ie+QrJ gysl@github.com
```
上一步连续按了几次回车键，其实就是采用默认设置，默认情况下新生成的key位于~/.ssh/目录下。把id_rsa.pub的内容添加到GitHub。具体步骤为：settings(点击右上角用户头像) -> SSH and GPG keys -> New SSH key -> ADD SSH key.Title随便填，Key部分就是复制的内容。也可以在登陆后直接输入以下地址：https://github.com/settings/ssh/new

![New SSH key](https://raw.githubusercontent.com/mrivandu/MyImageHostingService/master/Linux%E4%B8%8BGitHub%E5%BF%AB%E9%80%9F%E9%85%8D%E7%BD%AE%E5%B9%B6%E4%BD%BF%E7%94%A8.png)

2.4 测试一下是否添加成功。
```bash
[root@gysl /]# ssh -T git@github.com
The authenticity of host 'github.com (52.74.223.119)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
RSA key fingerprint is MD5:16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'github.com,52.74.223.119' (RSA) to the list of known hosts.
Hi mrivandu! You've successfully authenticated, but GitHub does not provide shell access.
```
此处需要输入一个yes。出现以上内容，说明key已经添加成功。

2.5 Clone一个自己的仓库试一下。
```bash
[root@gysl /]# git clone git@github.com:mrivandu/MyImageHostingService
正克隆到 'MyImageHostingService'...
Warning: Permanently added the RSA host key for IP address '13.229.188.59' to the list of known hosts.
remote: Enumerating objects: 31, done.
remote: Counting objects: 100% (31/31), done.
remote: Compressing objects: 100% (27/27), done.
remote: Total 31 (delta 8), reused 15 (delta 2), pack-reused 0
接收对象中: 100% (31/31), 2.42 MiB | 563.00 KiB/s, done.
处理 delta 中: 100% (8/8), done.
```
Clone成功。

2.6 更新一个文件，并push。
```bash
[root@gysl MyImageHostingService]# git config --global user.email "mrivandu@hotmail.com"
[root@gysl MyImageHostingService]# git mv 20181107200317.png Linux下GitHub快速配置并使用.png
[root@gysl MyImageHostingService]# git commit
[master 4d7f9a1] Rename  20181107200317.png -> "Linux\344\270\213GitHub\345\277\253\351\200\237\351\205\215\347\275\256\345\271\266\344\275\277\347\224\250.png"
 1 file changed, 0 insertions(+), 0 deletions(-)
 rename 20181107200317.png => "Linux\344\270\213GitHub\345\277\253\351\200\237\351\205\215\347\275\256\345\271\266\344\275\277\347\224\250.png" (100%)
[root@gysl MyImageHostingService]# git push
Counting objects: 3, done.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 344 bytes | 0 bytes/s, done.
Total 2 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
To git@github.com:mrivandu/MyImageHostingService
   8bf8dfe..4d7f9a1  master -> master
```
至此，全部操作完成。**此过程中可能会提示输入用户名和密码。**

2.7 拓展一下。我们已经把公钥增添只GitHub，我们的私钥能否保存到U盘随身携带呢？答案是可以的。怎么操作呢？请往下看。
```bash
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA4yOfFZPJAkKrujz54PP245GWNia7B/5BMUfSaWfSPou9R++O
DKYu1Z2gZ24Mntea4uIxuwyhVTFClO3X5aZS+PrYfdAdkCABASq12yFFfSyR+SJy
/7iUPfhruzSv7yG6BYRSyoEsxNxFN6eUkHAjZBhS/coENfBTxNndpsJvnzoTQu9z
q5QA6mcCyffcFyqB/t8F/29JfjQbAhO7rDxOG8UCumQ1rY477ENkFrZRjuImu5t1
XQ5rpldm8hRMnhKQDdnWzJpZFXosfPlZlTZD2ySpHksoyF2iXIwyXcnqgnFdCsMf
Y2PslNdy1WSASeMFAb7Yzv7v0Sgw7M9SHvkKyQIDAQABAoIBADfbycKvrm484SiS
2EzHEn9SjWNR0QsdLwEkjY1Yd+7jxK/NLNzVfY0RD6KAAOCLW07Sm7JJX9+olpwz
hbW3Wo5aeiUuqiaIiFa2HzT9kK5A6MEhBLD4vpQi5LOMOHwRikLTEN02OUFMfkU6
lCGVQk7aYIaDSNfO+3rcrVLWXEcGtW7w7M116eWcZhYNjStO6yqv6vNpGQfAQVeD
bKrd5pWwWXw9GEiIx98pbFWuZYl6zFyPzMOHu3bvBhEnV83FTUthmuG/bvmlINie
OvRFFhllbeDUIkmWPlH7r/3pSUq+TCp205/mGJPJlH/upzUuazjqkgcd4Lcpb3sx
5XwI7qUCgYEA/tQyiZ5w1+bUQc4198T5ULLs3shi8AAvNrJBtmAF8YshkiuZ0dWH
G2IwIWVU0fczXl/mV8fUcspwnB7c0Gxsj4qkcYYcvMp3eOumO+EptONWIn7C4tTj
enaPnjJHshKwSSuhJYc2bJl+dvK5E5JiujlOXNilS06Iyq0kK8Zdpf8CgYEA5C7Y
7/xaRYBSAA0Ph1LHSZLNa2pByq7XbkhXwoRysnirtl+znsNQdNX6vm0p+xt3OTUP
PD/XxzouKI2HHI4zs2bHMHS5Oh0axgdbOTzrZyvZh23dAwFNtt2FOlpoxXPwLLe9
qwhrL2u5LAVv26b41AetITDqWN7nyavtR4M/nzcCgYEA6Cj0vfIuRlSTDjzLaCb5
KO9J5BHWKWdRnFg8i+XhpFSoSh4U7lnF1EnZJaPG6d932kQue8yfndEXVPS9IdmV
8hRSiuavKcSfofe2pBkXwSfYomawMK3ZbQm1AGA4d2CVYKQyFRmhmMEiuUWbHdyg
u55X6TirJveuok+pg4Qeb4sCgYEAySWy/vsJ6LKRlpHs2nHSU70hcEse7Djsl78V
/dcb9NADLqV2hcHPLu9iNnOsyjsQAlIPuCDfajSTdBQuwrFoSgGUHdcHYX8+lsrt
U6usKCqze3sRlRCVHVpxk1sXeNgXJJRkkly9f/QKLBAu5wZt2xtZNyUTsHvvAAyb
AqtkbkkCgYADUHQadxHZxNhwHNW/yhfGxSU/lOm2CMM5AbMrmemPNxAafw5QYNUq
iNA1pfQ0KJvciM0078lUEIrt4L3ehR85opLNIjeZ728V/r/OzZVS6TsxNy5ZXK2B
9fLSNix4p8BUMHxQ7ArQrOEWZMsrSqyZwjPLebhI87AaheIZzUvYMA==
-----END RSA PRIVATE KEY-----
```
这是与刚刚我们增添至GitHub配对的私钥，我现在已经将~/.ssh目录下及/tmp目录下的内容全部清空。
```bash
[root@gysl ~]# ll .ssh/ /tmp/
.ssh/:
总用量 0
/tmp/:
总用量 0
```
再次测试一下：
```bash
[root@gysl ~]# ssh -T git@github.com
The authenticity of host 'github.com (13.229.188.59)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
RSA key fingerprint is MD5:16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'github.com,13.229.188.59' (RSA) to the list of known hosts.
Permission denied (publickey).
```
此时已经可以确认连接我们的GitHub账户已经失败。
```bash
[root@gysl ~]# echo '-----BEGIN RSA PRIVATE KEY-----
> MIIEpAIBAAKCAQEA4yOfFZPJAkKrujz54PP245GWNia7B/5BMUfSaWfSPou9R++O
> DKYu1Z2gZ24Mntea4uIxuwyhVTFClO3X5aZS+PrYfdAdkCABASq12yFFfSyR+SJy
> /7iUPfhruzSv7yG6BYRSyoEsxNxFN6eUkHAjZBhS/coENfBTxNndpsJvnzoTQu9z
> q5QA6mcCyffcFyqB/t8F/29JfjQbAhO7rDxOG8UCumQ1rY477ENkFrZRjuImu5t1
> XQ5rpldm8hRMnhKQDdnWzJpZFXosfPlZlTZD2ySpHksoyF2iXIwyXcnqgnFdCsMf
> Y2PslNdy1WSASeMFAb7Yzv7v0Sgw7M9SHvkKyQIDAQABAoIBADfbycKvrm484SiS
> 2EzHEn9SjWNR0QsdLwEkjY1Yd+7jxK/NLNzVfY0RD6KAAOCLW07Sm7JJX9+olpwz
> hbW3Wo5aeiUuqiaIiFa2HzT9kK5A6MEhBLD4vpQi5LOMOHwRikLTEN02OUFMfkU6
> lCGVQk7aYIaDSNfO+3rcrVLWXEcGtW7w7M116eWcZhYNjStO6yqv6vNpGQfAQVeD
> bKrd5pWwWXw9GEiIx98pbFWuZYl6zFyPzMOHu3bvBhEnV83FTUthmuG/bvmlINie
> OvRFFhllbeDUIkmWPlH7r/3pSUq+TCp205/mGJPJlH/upzUuazjqkgcd4Lcpb3sx
> 5XwI7qUCgYEA/tQyiZ5w1+bUQc4198T5ULLs3shi8AAvNrJBtmAF8YshkiuZ0dWH
> G2IwIWVU0fczXl/mV8fUcspwnB7c0Gxsj4qkcYYcvMp3eOumO+EptONWIn7C4tTj
> enaPnjJHshKwSSuhJYc2bJl+dvK5E5JiujlOXNilS06Iyq0kK8Zdpf8CgYEA5C7Y
> 7/xaRYBSAA0Ph1LHSZLNa2pByq7XbkhXwoRysnirtl+znsNQdNX6vm0p+xt3OTUP
> PD/XxzouKI2HHI4zs2bHMHS5Oh0axgdbOTzrZyvZh23dAwFNtt2FOlpoxXPwLLe9
> qwhrL2u5LAVv26b41AetITDqWN7nyavtR4M/nzcCgYEA6Cj0vfIuRlSTDjzLaCb5
> KO9J5BHWKWdRnFg8i+XhpFSoSh4U7lnF1EnZJaPG6d932kQue8yfndEXVPS9IdmV
> 8hRSiuavKcSfofe2pBkXwSfYomawMK3ZbQm1AGA4d2CVYKQyFRmhmMEiuUWbHdyg
> u55X6TirJveuok+pg4Qeb4sCgYEAySWy/vsJ6LKRlpHs2nHSU70hcEse7Djsl78V
> /dcb9NADLqV2hcHPLu9iNnOsyjsQAlIPuCDfajSTdBQuwrFoSgGUHdcHYX8+lsrt
> U6usKCqze3sRlRCVHVpxk1sXeNgXJJRkkly9f/QKLBAu5wZt2xtZNyUTsHvvAAyb
> AqtkbkkCgYADUHQadxHZxNhwHNW/yhfGxSU/lOm2CMM5AbMrmemPNxAafw5QYNUq
> iNA1pfQ0KJvciM0078lUEIrt4L3ehR85opLNIjeZ728V/r/OzZVS6TsxNy5ZXK2B
> 9fLSNix4p8BUMHxQ7ArQrOEWZMsrSqyZwjPLebhI87AaheIZzUvYMA==
> -----END RSA PRIVATE KEY-----'>~/.ssh/id_rsa
[root@gysl ~]# chmod 600 .ssh/id_rsa
[root@gysl ~]# eval `ssh-agent`
Agent pid 4278
[root@gysl ~]# ssh-add .ssh/id_rsa
Identity added: .ssh/id_rsa (.ssh/id_rsa)
```
此步骤中需要注意的是，echo后面的引号不要用双引号，私钥的权限要求为600，后面的两条命令必不可少，不解释！
再次测试一下：
```bash
[root@gysl ~]# ssh -T git@github.com
Hi mrivandu! You've successfully authenticated, but GitHub does not provide shell access.
```
再次体会到成功的喜悦。以上内容是使用本人的GitHub账户亲自实战的，私钥已删除，请勿使用此私钥尝试连接本人GitHub仓库。

# 三.总结
3.1 很久之前就在使用Github了，但是一直未能写一片关于GitHub的使用教程。GitHub为我们的coding工作带来了极大便利，学会使用这个工具显得格外重要。

3.2 本文仅仅介绍了Git在Linux环境下的主要配置方法，其他环境也大同小异。

3.3 文中涉及到的git命令的使用极为简单，如需进一步使用，还需要进行系统话的学习，此步骤可以参阅本文相关资料部分。

3.4 我的GitHub除了代码托管之外，还被我当成了博客备份的地方及图床，一般人我都不告诉他。此处邪恶一笑~

# 四.相关资料
4.1 [Github官方文档](https://help.github.com/articles/connecting-to-github-with-ssh/)

4.2 [Git官方中文文档](https://git-scm.com/book/zh/v2)
