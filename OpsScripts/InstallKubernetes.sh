#!/bin/bash
MasterIP='10.1.1.60'
MasterHostname='gysl-master'
NodeIPs=('10.1.1.61' '10.1.1.62' '10.1.1.63')
NodeHostnames=('gysl-01' 'gysl-02' 'gysl-03')
WorkDir=~/KubernetesDeployment
BinaryDir='/usr/local/bin'
KubeConf='/etc/kubernetes/conf.d'
KubeCA='/etc/kubernetes/ca.d'
EtcdConf='/etc/etcd/conf.d'
EtcdCA='/etc/etcd/ca.d'
EtcdService='/usr/lib/systemd/system/etcd.service'
mkdir $WorkDir
cd $WorkDir

# Download relevant softwares. Please verify sha512 yourself.
while true;
    do
        echo "Downloading... ... Please wait a moment! " && \
        curl -L -C - -O https://dl.k8s.io/v1.14.0/kubernetes-server-linux-amd64.tar.gz && \
        curl -L -C - -O https://github.com/etcd-io/etcd/releases/download/v3.3.12/etcd-v3.3.12-linux-amd64.tar.gz && \
        curl -L -C - -O https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 && \
        curl -L -C - -O https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 && \
        curl -L -C - -O https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 && \
        curl -L -C - -O https://github.com/coreos/flannel/releases/download/v0.11.0/flannel-v0.11.0-linux-amd64.tar.gz
        if [ $? -eq 0 ];
            then
                echo "Congratulations! All software packages have been downloaded."
                break
            else
                echo "Downloading failed. Please try again!"
                exit 101
        fi
    done

# Deploy the master. 
for tgz_file in `ls *.tar.gz`
    do
        tar -xvzf $tgz_file
done

chmod +x cfssl*
cp -p cfssl_linux-amd64 $BinaryDir/cfssl
cp -p cfssljson_linux-amd64 $BinaryDir/cfssljson
cp -p cfssl-certinfo_linux-amd64 $BinaryDir/cfssl-certinfo
cp -p kubernetes/server/bin/{kube-apiserver,kube-scheduler,kube-controller-manager} $BinaryDir/
cp -p etcd-v3.3.12-linux-amd64/{etcd,etcdctl} $BinaryDir/
mkdir -p {$KubeConf,$KubeCA,$EtcdConf,$EtcdCA}

# Create some CA certificates for etcd cluster.
cat>$EtcdCA/ca-config.json<<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "www": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF
cat>$EtcdCA/ca-csr.json<<EOF
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF
cat>$EtcdCA/server-csr.json<<EOF
{
    "CN": "etcd",
    "hosts": [
    "${MasterIP}",
    "${NodeIPs[0]}",
    "${NodeIPs[1]}",
    "${NodeIPs[2]}"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF
cd $EtcdCA
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=www server-csr.json | cfssljson -bare server
cd $WorkDir
# Show *.pem.
# ca-key.pem  ca.pem  server-key.pem  server.pem
ls $EtcdCA/*.pem

cat>$EtcdConf/etcd.conf<<EOF
#[Member]
ETCD_NAME="etcd-master"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://$MasterIP:2380"
ETCD_LISTEN_CLIENT_URLS="https://$MasterIP:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://$MasterIP:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://$MasterIP:2379"
ETCD_INITIAL_CLUSTER="etcd-master=https://${MasterIP}:2380,etcd-01=https://${NodeIP[0]}:2380,etcd-02=https://${NodeIP[1]}:2380,etcd-03=https://${NodeIP[2]}:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF
# The etcd servcie configuration file.
cat>$EtcdService<<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=$EtcdConf/etcd.conf
WorkingDirectory=/var/lib/etcd
ExecStart=$BinaryDir/etcd \\
--name=\${ETCD_NAME} \\
--data-dir=\${ETCD_DATA_DIR} \\
--listen-peer-urls=\${ETCD_LISTEN_PEER_URLS} \\
--listen-client-urls=\${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \\
--advertise-client-urls=\${ETCD_ADVERTISE_CLIENT_URLS} \\
--initial-advertise-peer-urls=\${ETCD_INITIAL_ADVERTISE_PEER_URLS} \\
--initial-cluster=\${ETCD_INITIAL_CLUSTER} \\
--initial-cluster-token=\${ETCD_INITIAL_CLUSTER_TOKEN} \\
--initial-cluster-state=\${ETCD_INITIAL_CLUSTER_STATE} \\
--cert-file=$EtcdCA/server.pem \\
--key-file=$EtcdCA/server-key.pem \\
--peer-cert-file=$EtcdCA/server.pem \\
--peer-key-file=$EtcdCA/server-key.pem \\
--trusted-ca-file=$EtcdCA/ca.pem \\
--peer-trusted-ca-file=$EtcdCA/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable etcd.service --now
systemctl status etcd

if [ $? -eq 0 ];
    then
        ssh-keygen -b 1024 -t rsa -C 'Kubernetes'
        for node_ip in ${NodeIPs[@]}
            do
                ssh-copy-id -i root@$node_ip
                scp 
            done
    else
        echo "Installation failed. Please try again!"
        exit 102
fi