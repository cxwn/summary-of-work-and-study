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
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state MASTER
    interface ${INTERFACE}
    virtual_router_id 51
    priority 100
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
cat>/var/www/html/index.html<<EOF
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
systemctl enable httpd --now
/etc/init.d/realserver stop && /etc/init.d/realserver start

https://www.cnblogs.com/edisonchou/p/4281978.html
http://www.cnblogs.com/linkstar/p/6496477.html

cat>/etc/sysctl.d/lvs-start.conf<<EOF
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
EOF
sysctl -p /etc/sysctl.d/lvs-start.conf