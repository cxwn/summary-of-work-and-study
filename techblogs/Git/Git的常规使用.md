# Git的常规使用


git config user.name "name"
git config user.email "demo@hotmail.com"

git checkout master
git checkout -b release # 创建新分支并切换到新分支
git checkout -b develop
git checkout -b feature
git push origin feature
git branch --set-upstream-to=origin/feature

git config --global credential.helper store

## 删除分支

先切换到新分支，再执行以下命令：

```git
　　1 先切换到别的分支: git checkout dev20180927

　　2 删除本地分支： git branch -d dev20181018

　　3 如果删除不了可以强制删除，git branch -D dev20181018

　　4 有必要的情况下，删除远程分支(慎用)：git push origin --delete dev20181018

　　5 在从公用的仓库fetch代码：git fetch origin dev20181018:dev20181018

　　6 然后切换分支即可：git checkout dev20181018
```

git fetch origin 同步远程服务器的数据到本地


## 一 切换并创建新分支

1) 切换到基础分支，如主干

git checkout master

2）创建并切换到新分支

git checkout -b develop

git branch可以看到已经在panda分支上

3)更新分支代码并提交

git add *

git commit -m "init panda"

git push origin panda

## 合并分支

切换到被合并的分支，执行：

git merge 当前分支

```
git flow init -d
```


https://www.cnblogs.com/bwar/p/9191305.html
https://www.cnblogs.com/zgq123456/articles/10314069.html
https://blog.51cto.com/9291927/2173509?source=dra