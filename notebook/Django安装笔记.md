1. 创建虚拟环境。
```
python -m venv my-site
```

2. 进入虚拟环境。
```
my-site\Scripts\activate
```
在创建虚拟环境的当前目录下执行，上面命令是在windows环境下执行的。Linux环境下可以如此执行：
```
source ./myvenv/bin/activate
```
若source不可用也可以使用其他可执行的方式。

3. 在虚拟环境中升级pip.
```
python -m pip install --upgrade pip
```
如果速度慢可以使用国内源：
```
pip install django==1.8 -i https://pypi.douban.com/simple/
```

4. 创建项目mysite。
```
django-admin startproject mysite .
```
别忘了那个点！

5. 第一次运行Django Server。
```
cd mysite
python manage.py runserver 0.0.0.0:8000
```