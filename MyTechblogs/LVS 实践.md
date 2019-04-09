# LVS实践

## 一 基本概念及原理

## 二 系统架构

主机名|主机IP|角色|安装组件
:-:|:-:|:-:|:-:
gysl-lvs-master|10.1.1.51|主|keepalived
gysl-lvs-slave|10.1.1.52|备|keepalived
gysl-web-1|10.1.1.53|Web Server|httpd
gysl-web-2|10.1.1.54|Web Server|httpd
gysl-web-3|10.1.1.55|Web Server|httpd

## 三 操作过程

### 3.1 通用配置

```bash
#!/bin/bash
sed -i 's/SELINUX=enforcing/SELINUX=disable/g' /etc/selinux/config
systemctl disable firewalld
systemctl stop firewalld
reboot
```

### 3.2 配置主负载均衡服务器

```bash
#!/bin/bash
yum install -y keepalived
cat>/etc/keepalived/keepalived.conf<<EOF
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state MASTER
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.1.1.50
    }
}

virtual_server 10.1.1.50 80 {
    delay_loop 6
    lb_algo wrr
    lb_kind DR
    nat_mask 255.255.255.0
    persistence_timeout 50
    protocol TCP

    real_server 10.1.1.53 80 {
        weight 9
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
   real_server 10.1.1.54 80 {
        weight 8
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
    real_server 10.1.1.55 80 {
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
    interface ens33
    virtual_router_id 51
    priority 99
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.1.1.50
    }
}

virtual_server 10.1.1.50 80 {
    delay_loop 6
    lb_algo wrr
    lb_kind DR
    nat_mask 255.255.255.0
    persistence_timeout 50
    protocol TCP

    real_server 10.1.1.53 80 {
        weight 9
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
   real_server 10.1.1.54 80 {
        weight 8
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 80
        }
    }
    real_server 10.1.1.55 80 {
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
VIP=10.1.1.50
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
    <title>$(ip a|grep -o '10\.1\.1\.5[3-5]')</title>
</head>
<body>
<center>
<h1>This host's IP is $(ip a|grep -o '10\.1\.1\.5[3-5]').</h1>
</center>
</body>
</html>
EOF
systemctl enable httpd --now
/etc/init.d/realserver stop && /etc/init.d/realserver start

https://www.cnblogs.com/edisonchou/p/4281978.html
http://www.cnblogs.com/linkstar/p/6496477.html