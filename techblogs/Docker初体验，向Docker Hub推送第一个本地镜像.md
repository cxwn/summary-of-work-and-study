# 一、注册Docker Hub账号
打开Docker Hub网站，找到注册选项，按照常规注册流程进行注册即可。需要注意的是，有时候可能需要进行人机识别验证，这需要调用Google的验证服务。众所周知Google在国内的情况，需要自己想办法搞定。如果人机验证这一步过不去，那么Docker Hub的账号是无法注册成功的。
# 二、通过Dockerfile构建镜像
这一步在之前的文章中有所涉及，操作如下：
```
[root@ChatDevOps docker-test]# docker build -f /root/docker-test/Dockerfile -t chatdevops/myapp .
Sending build context to Docker daemon 157.4 MB
Step 1/7 : FROM python:2.7-slim
 ---> 46ba956c5967
Step 2/7 : WORKDIR /app
 ---> Using cache
 ---> 874ecbc1dfc0
Step 3/7 : ADD . /app
 ---> Using cache
 ---> fe2d0e196a64
Step 4/7 : RUN pip install --trusted-host pypi.python.org -r requirements.txt
 ---> Running in caf394f66822
... ...
```
以上命令中，选项-f指定了Dockerfile的路径，选项-t指定了新的镜像的仓库名称及镜像名称，还可以指定镜像的标签。命令末尾的点代表构建新镜像的当前目录，也可以写成完整路径。
```
[root@ChatDevOps docker-test]# docker build -f /root/docker-test/Dockerfile -t chatdevops/myapp:1.01 /root/docker-test/
```
# 三、登录Docker Hub
我在Docker Hub注册的账号为chatdevops，现在使用该账号进行登录。完整命令如下：
```
[root@ChatDevOps docker-test]# docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username (chatdevops): chatdevops
Password: 
Login Succeeded
```
# 四、给新构建的本地镜像打标签
如果本地镜像的仓库名与你新注册的Docker Hub账号名称不一致，就需要使用docker tag进行重新打标签，具体命令格式为：
```
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
```
因为我注册的账号与我本地仓库的名称都是chatdevops，所以我在操作过程中省略了tag这一步。但是为了演示这个例子，我再次tag一下。
```
[root@ChatDevOps docker-test]# docker tag chatdevops/myapp:1.01 chatdevops/myapp:1.02
[root@ChatDevOps docker-test]# docker image ls chatdevops/myapp
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
chatdevops/myapp    1.01                c4bec2582bf3        47 minutes ago      309 MB
chatdevops/myapp    1.02                c4bec2582bf3        47 minutes ago      309 MB
chatdevops/myapp    latest              c4bec2582bf3        47 minutes ago      309 MB
```
# 五、将新构建的本地镜像推送到Docker Hub
通过docker push命令可以将一个或多个本地镜像推送到Docker Hub。
```
[root@ChatDevOps docker-test]# docker push chatdevops/myapp
```
该命令将镜像myapp的所有标签全部推送到Docker Hub。我们看一下效果：
![效果](https://camo.githubusercontent.com/6b50336f04f6caba21ca064bae561e994606420c/68747470733a2f2f6e6f74652e796f7564616f2e636f6d2f7977732f6170692f706572736f6e616c2f66696c652f34344346354642443735333934414238384538373239373237414632333939443f6d6574686f643d646f776e6c6f61642673686172654b65793d3466666164663636663334623338333761666430366364666364333735613831)
我们可以在其他机器上直接创建容器。例如：我们使用镜像chatdevops/myapp:1.02在10.1.1.12这台机器上创建一个名为test-app的容器。
```
[root@ChatDevOps ~]# docker run -i -t --name test-app chatdevops/myapp:1.02
Unable to find image 'chatdevops/myapp:1.02' locally
Trying to pull repository docker.io/chatdevops/myapp ... 
1.02: Pulling from docker.io/chatdevops/myapp
4d0d76e05f3c: Pull complete 
da828db4a2d5: Pull complete 
dae8f1abda34: Pull complete 
7f80c063ca4d: Pull complete 
4ad5318a2b9b: Pull complete 
95a59aa8e00b: Pull complete 
776fee21eb8e: Pull complete 
Digest: sha256:4de441303d87d392b36fc1218a1be18e3b2bf5b81c9e88eed8688c402f06a793
Status: Downloaded newer image for docker.io/chatdevops/myapp:1.02
[root@ChatDevOps ~]# docker ps
CONTAINER ID        IMAGE                   COMMAND             CREATED              STATUS              PORTS               NAMES
09fe7a428ecc        chatdevops/myapp:1.02   "python app.py"     About a minute ago   Up About a minute   80/tcp              test-app
```
在运行这个容器的过程中，docker会从Docker Hub拉取镜像chatdevops/myapp:1.02存放于本地，再创建容器。当然也可以先将Docker Hub的镜像拉取到本地再创建容器。
# 六、总结
通过以上步骤，我们将自己创建的容器上传的Docker Hub的仓库中，无论我们在哪里，只要网络能顺利与Docker Hub互联，我们就可以随时随地运行我们自己构建的镜像创建的容器，非常方便。此处我们使用的是公开的仓库，还可以将我们的镜像共享给其他需要的人呢，非常方便。可以通过关键字搜索一下我刚刚创建的镜像。
