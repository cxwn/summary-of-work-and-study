# Nginx 实战

## 一 Nginx 编译安装并启动服务

```bash
yum -y install gcc make pcre pcre-devel zlib zlib-devel
curl -L -C - -O https://nginx.org/download/nginx-1.18.0.tar.gz
tar -xvzf nginx-1.18.0.tar.gz
cd nginx-1.18.0
./configure --prefix=/usr/local/nginx
make && make install
cd /usr/local/nginx
./nginx
```

10.87.95.97:10021,10.87.95.97:10022,10.87.95.98:10021,10.87.95.98:10022,10.87.95.99:10021,10.87.95.99:10022