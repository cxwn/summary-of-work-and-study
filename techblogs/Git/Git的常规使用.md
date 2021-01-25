# Git的常规使用


git config user.name "杜睿鸿"
git config user.email "duruihong@cmos.chinamobile.com"

git checkout master
git checkout -b release # 创建新分支并切换到新分支
git checkout -b develop
git checkout -b feature
git push origin feature
git branch --set-upstream-to=origin/feature

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
Using default branch names.
Branch name for "next release" development: [develop] 

How to name your supporting branch prefixes?

Bugfix branches? [bugfix/] 
Support branches? [support/] 
Hooks and filters directory? [H:/Real-time-ASR-docker/.git/hooks] 
执行成功

git -c diff.mnemonicprefix=false -c core.quotepath=false --no-optional-locks push -v --tags --set-upstream origin develop:develop
POST git-receive-pack (202 bytes)
remote: 
remote: To create a merge request for develop, visit:        
remote:   http://192.168.26.170:8888/speech/Real-time-ASR-docker/merge_requests/new?merge_request%5Bsource_branch%5D=develop        
remote: 


Branch 'develop' set up to track remote branch 'develop' from 'origin'.
Pushing to http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
To http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
 * [new branch]      develop -> develop
updating local tracking ref 'refs/remotes/origin/develop'




git -c diff.mnemonicprefix=false -c core.quotepath=false --no-optional-locks push -v --tags origin master:master
Pushing to http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
To http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
 = [up to date]      master -> master
updating local tracking ref 'refs/remotes/origin/master'
Everything up-to-date

git -c diff.mnemonicprefix=false -c core.quotepath=false --no-optional-locks push -v --tags --set-upstream origin develop:develop
POST git-receive-pack (202 bytes)
remote: 
remote: To create a merge request for develop, visit:        
remote:   http://192.168.26.170:8888/speech/Real-time-ASR-docker/merge_requests/new?merge_request%5Bsource_branch%5D=develop        
remote: 


Branch 'develop' set up to track remote branch 'develop' from 'origin'.
Pushing to http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
To http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
 * [new branch]      develop -> develop
updating local tracking ref 'refs/remotes/origin/develop'




git -c diff.mnemonicprefix=false -c core.quotepath=false --no-optional-locks push -v --tags origin master:master
Pushing to http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
To http://127.0.0.1:8888/speech/Real-time-ASR-docker.git
 = [up to date]      master -> master
updating local tracking ref 'refs/remotes/origin/master'
Everything up-to-date

git flow feature finish -k 测试
git flow feature finish -r -D 测试
```

```git
git flow feature start 通过火眼日志平台实现日志统一收集 develop
git -c diff.mnemonicprefix=false -c core.quotepath=false --no-optional-locks push -v --tags --set-upstream origin feature/通过火眼日志平台实现日志统一收集:feature/通过火眼日志平台实现日志统一收集
```


https://www.cnblogs.com/bwar/p/9191305.html
https://www.cnblogs.com/zgq123456/articles/10314069.html