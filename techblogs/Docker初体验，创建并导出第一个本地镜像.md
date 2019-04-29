准备工作，创建一个目录docker-test，用来存放创建镜像所需的文件，同事完成相关文件的创建。
```
[root@ChatDevOps ~]# mkdir docker-test
[root@ChatDevOps ~]# cd docker-test/
[root@ChatDevOps docker-test]# touch Dockerfile
[root@ChatDevOps docker-test]# touch app.py
[root@ChatDevOps docker-test]# touch requirements.txt
```
在Dockerfile中加入以下内容：
```
# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
```
在app.py中增加以下内容：
```
from flask import Flask
from redis import Redis, RedisError
import os
import socket

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```
在requirements.txt中添加以下内容：
```
Flask
Redis
```
安装pip，并使用pip安装Flask和Redis：
```
[root@ChatDevOps docker-test]#  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
[root@ChatDevOps docker-test]# python get-pip.py 
[root@ChatDevOps docker-test]# pip install -r requirements.txt
[root@ChatDevOps docker-test]# rm -rf get-pip.py 
[root@ChatDevOps docker-test]# ls
app.py  Dockerfile  requirements.txt
```
执行构建命令，使用-t选项指定镜像的仓库、标签。注意，镜像名称必须小写。
```
[root@ChatDevOps docker-test]# docker build -t local/chatdevops .
Sending build context to Docker daemon 4.608 kB
Step 1/7 : FROM python:2.7-slim
Trying to pull repository docker.io/library/python ... 
2.7-slim: Pulling from docker.io/library/python
... ...
[root@ChatDevOps docker-test]# docker image ls 
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
local/chatdevops        latest              fc26e265213a        21 minutes ago      151 MB
docker.io/fedora        latest              cc510acfcd70        2 weeks ago         253 MB
```
使用刚刚创建的镜像构建一个容器，并将容器的80端口映射到本机的4000端口。
```
[root@ChatDevOps docker-test]# docker run -p 4000:80 local/chatdevops
 * Serving Flask app "app" (lazy loading)
 * Environment: production
   WARNING: Do not use the development server in a production environment.
   Use a production WSGI server instead.
 * Debug mode: off
 * Running on http://0.0.0.0:80/ (Press CTRL+C to quit)
172.17.0.1 - - [23/May/2018 04:21:04] "GET / HTTP/1.1" 200 -
172.17.0.1 - - [23/May/2018 04:21:04] "GET /favicon.ico HTTP/1.1" 404 -
172.17.0.1 - - [23/May/2018 04:22:24] "GET / HTTP/1.1" 200 -
```
在浏览器看一下效果：
![效果](https://camo.githubusercontent.com/c6c7671d66d0320023a5a2e36c7ed06c0e959702/68747470733a2f2f6e6f74652e796f7564616f2e636f6d2f7977732f6170692f706572736f6e616c2f66696c652f36373333423036303637454434423334423134423437374435453034363246463f6d6574686f643d646f776e6c6f61642673686172654b65793d6562666133336437643833316334323435356663363135343063653364616464)
镜像制作完成，导出镜像，选项-o表示将导出内容写入一个文件，替代了标准输出。
```
[root@ChatDevOps docker-test]# docker save -o chatdevops.tar local/chatdevops
[root@ChatDevOps docker-test]# ll
总用量 153716
-rw-r--r--. 1 root root       666 5月  23 09:52 app.py
-rw-------. 1 root root 157392896 5月  23 11:47 chatdevops.tar
-rw-r--r--. 1 root root       509 5月  23 11:12 Dockerfile
-rw-r--r--. 1 root root        12 5月  23 09:51 requirements.txt
```
在异机上导入刚刚创建的镜像。
```
[root@ChatDevOps docker-test]# scp chatdevops.tar root@10.1.1.1.12:/root/
[root@ChatDevOps ~]# ll
总用量 153704
-rw-------. 1 root root 157392896 5月  23 14:30 chatdevops.tar
[root@ChatDevOps ~]# docker load --input chatdevops.tar 
ba291263b085: Loading layer [==================================================>] 82.94 MB/82.94 MB
10dd6271862c: Loading layer [==================================================>] 7.487 MB/7.487 MB
4e1a46391216: Loading layer [==================================================>] 46.96 MB/46.96 MB
a40d037570f2: Loading layer [==================================================>] 7.649 MB/7.649 MB
d9bad830e350: Loading layer [==================================================>] 1.536 kB/1.536 kB
16b29278858d: Loading layer [==================================================>]  5.12 kB/5.12 kB
b6e1c4419841: Loading layer [==================================================>] 12.32 MB/12.32 MB
Loaded image: local/chatdevops:latest
[root@ChatDevOps ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
local/chatdevops    latest              dea564c3cb05        3 hours ago         151 MB
```
本文是Docker官方文档的实例的实践与拓展，刚刚学习Docker，诸多问题还望大家海涵和指教。
