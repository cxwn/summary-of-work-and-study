# LVS实践

## 一 基本概念及原理

## 二 系统架构

主机名|主机IP|角色|安装组件
:-:|:-:|:-:|:-:
gysl-lvs-master|172.31.2.100|主|ipvsadm/keepalived
gysl-lvs-slave|172.31.2.99|备|ipvsamd/keepalived
gysl-web-1|172.31.2.101|Web Server|httpd
gysl-web-2|172.31.2.102|Web Server|httpd
gysl-web-3|172.31.2.103|Web Server|httpd

## 三 操作过程

### 3.1 通用配置

```bash
#!/bin/bash
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
systemctl disable firewalld
systemctl stop firewalld
reboot
```

### 3.2 配置主负载均衡服务器

```bash
#!/bin/bash
VIP=172.31.2.88
INTERFACE=$(ip address show|grep -E '^[[:digit:]]'|grep 'MULTICAST'|awk -F ": " '{print $2}')
LOCAL_IP=$(ip -4 -h address show|grep 'global'|grep -E -o '(([[:digit:]]{1,3})\.){3}[[:digit:]]{1,3}/'|awk -F "/" '{print $1}')
RIP=('172.31.2.101' '172.31.2.102' '172.31.2.103')
yum -y install ipvsadm keepalived
cat>/etc/keepalived/keepalived.conf<<EOF
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL  # 设置lvs的id，在一个网络内应该是唯一的
}

vrrp_instance VI_1 {
    state MASTER    # 指定Keepalived的角色，MASTER为主，BACKUP为备 
    interface ${INTERFACE}
    virtual_router_id 51    # 虚拟路由编号，主备要一致
    priority 100     # 定义优先级，数字越大，优先级越高，主DR必须大于备用DR  
    advert_int 1     # 检查间隔，默认为1s
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        ${VIP}   #  可设多个，每行一个
    }
}

virtual_server ${VIP} 80 {
    delay_loop 6  # 设置健康检查时间，单位是秒
    lb_algo wrr  # 设置负载调度的算法
    lb_kind DR  # 设置LVS实现负载的机制，有NAT、TUN、DR三个模式
    nat_mask 255.255.255.0
    persistence_timeout 50
    protocol TCP

    real_server ${RIP[0]} 80 {
        weight 9  # 配置节点权值，数字越大权重越高
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
   real_server ${RIP[1]} 80 {
        weight 8
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
    real_server ${RIP[2]} 80 {
        weight 7
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
}
EOF
systemctl enable keepalived --now
systemctl status keepalived
```

### 3.3 配置从负载均衡服务器

```bash
#!/bin/bash
yum install -y keepalived
cat>/etc/keepalived/keepalived.conf<<EOF
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state BACKUP
    interface ${INTERFACE}
    virtual_router_id 51
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        ${VIP}
    }
}

virtual_server ${VIP} 80 {
    delay_loop 6
    lb_algo wrr
    lb_kind DR
    nat_mask 255.255.255.0
    persistence_timeout 50
    protocol TCP

    real_server ${RIP[0]} 80 {
        weight 9
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
   real_server ${RIP[1]} 80 {
        weight 8
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
    real_server ${RIP[2]} 80 {
        weight 7
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
}
EOF

systemctl enable keepalived --now
systemctl status keepalived
```

```bash
#!/bin/bash
rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum -y install nginx
cat>/etc/sysconfig/network-scripts/ifcfg-lo<<EOF
DEVICE=lo
IPADDR=10.1.1.55
NETMASK=255.255.255.255
NETWORK=10.1.1.0
BROADCAST=10.1.1.55
ONBOOT=yes
NAME=loopback
EOF
ifdown lo
ifup lo
cat>/etc/init.d/realserver<<EOF
VIP=${VIP}
IP=$(ip a|grep -o '10\.1\.1\.5[3-5]')
case "\$1" in
start)
       nmcli connection modify lo ipv4.addresses \${VIP}/32 ipv4.gateway 255.255.255.255
       ip route add \${IP}/32 via \${VIP} dev lo
       echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
       sysctl -p >/dev/null 2>&1
       echo "RealServer Start OK!"
       ;;
stop)
       ifdown lo
       route del \${VIP} >/dev/null 2>&1
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
       echo "RealServer Stoped!"
       ;;
*)
       echo "Usage: $0 {start|stop}"
       exit 1
esac
exit 0
EOF
chmod +x /etc/init.d/realserver
cat>/usr/share/nginx/html/index.html<<EOF
<html lang="zh-cn">
<head>
    <meta charset="utf-8" />
    <title>$(ip a|grep -o '172\.31\.2\.10[1-3]')</title>
</head>
<body>
<center>
<h1>This host's IP is $(ip a|grep -o '172\.31\.2\.10[1-3]').</h1>
</center>
</body>
</html>
EOF
systemctl enable nginx --now
/etc/init.d/realserver stop && /etc/init.d/realserver start

https://www.cnblogs.com/edisonchou/p/4281978.html
http://www.cnblogs.com/linkstar/p/6496477.html

cat>/etc/sysctl.d/lvs.conf<<EOF
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
EOF
sysctl -p /etc/sysctl.d/lvs.conf