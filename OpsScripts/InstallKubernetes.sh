#!/bin/bash
declare -A HostIP EtcdIP
HostIP=( [gysl-master]='10.1.1.60' [gysl-node1]='10.1.1.61' [gysl-node2]='10.1.1.62' [gysl-node3]='10.1.1.63' )
EtcdIP=( [etcd-master]='10.1.1.60' [etcd-01]='10.1.1.61' [etcd-02]='10.1.1.62' [etcd-03]='10.1.1.63' )
WorkDir=~/KubernetesDeployment
BinaryDir='/usr/local/bin'
KubeConf='/etc/kubernetes/conf.d'
KubeCA='/etc/kubernetes/ca.d'
EtcdConf='/etc/etcd/conf.d'
EtcdCA='/etc/etcd/ca.d'

ssh-keygen -b 1024 -t rsa -C 'Kubernetes'
for node_ip in ${HostIP[@]}
    do  
        if [ "${node_ip}" != "${HostIP[gysl-master]}" ] ; then
        ssh-copy-id -i root@${node_ip}
        fi
    done

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
cp -p kubernetes/server/bin/{kube-apiserver,kube-scheduler,kube-controller-manager,kubectl} $BinaryDir/
cp -p etcd-v3.3.12-linux-amd64/{etcd,etcdctl} $BinaryDir/

mkdir tmp
cat>tmp/kube-proxy.conf<<EOF
KUBE_PROXY_OPTS="--logtostderr=true \
--v=4 \
--hostname-override=${node_ip} \
--cluster-cidr=10.0.0.0/24 \
--kubeconfig=$KubeConf/kube-proxy.kubeconfig"
EOF

cat>tmp/kube-proxy.service<<EOF
[Unit]
Description=Kubernetes Proxy
After=network.target

[Service]
EnvironmentFile=-$KubeConf/kube-proxy.conf
ExecStart=$BinaryDir/kube-proxy \$KUBE_PROXY_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat>tmp/kubelet.yaml<<EOF
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: $node_ip
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS: ["10.0.0.2"]
clusterDomain: cluster.local.
failSwapOn: false
authentication:
  anonymous:
    enabled: true
EOF

cat>tmp/kubelet.conf<<EOF
KUBELET_OPTS="--logtostderr=true \
--v=4 \
--hostname-override=$IP \
--kubeconfig=$KubeConf/kubelet.kubeconfig \
--bootstrap-kubeconfig=$KubeConf/bootstrap.kubeconfig \
--config=$KubeConf/kubelet.yaml \
--cert-dir=$KubeCA \
--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"
EOF
cat>tmp/kubelet.service<<EOF
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service

[Service]
EnvironmentFile=$KubeConf/kubelet.conf
ExecStart=$BinaryDir/kubelet \$KUBELET_OPTS
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

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
    "${HostIP[gysl-master]}",
    "${HostIP[gysl-node1]}",
    "${HostIP[gysl-node2]}",
    "${HostIP[gysl-node3]}"
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
tree $EtcdCA

# The etcd configuration file.
cat>$EtcdConf/etcd.conf<<EOF
#[Member]
ETCD_NAME="etcd-master"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://${HostIP[gysl-master]}:2380"
ETCD_LISTEN_CLIENT_URLS="https://${HostIP[gysl-master]}:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://${HostIP[gysl-master]}:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://${HostIP[gysl-master]}:2379"
ETCD_INITIAL_CLUSTER="etcd-master=https://${HostIP[gysl-master]}:2380,etcd-01=https://$HostIP[gysl-node1]}:2380,etcd-02=https://$HostIP[gysl-node2]}:2380,etcd-03=https://$HostIP[gysl-node3]}:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF
# The etcd servcie configuration file.
cat>/usr/lib/systemd/system/etcd.service<<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=$EtcdConf/etcd.conf
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

for node_ip in ${EtcdIP[@]}
    do  
        if [ "${node_ip}" != "${HostIP[gysl-master]}" ] ; then
            scp -p etcd-v3.3.12-linux-amd64/{etcd,etcdctl} root@${node_ip}:$BinaryDir/
            scp -p /usr/lib/systemd/system/etcd.service root@${node_ip}:/usr/lib/systemd/system/etcd.service
            for etcd_name in ${!EtcdIP[@]}
                do
                    if [ "${node_ip}" == "${EtcdIP[${etcd_name}]}" ] ; then
                        sed "2s/etcd-master/${etcd_name}/g" $EtcdConf/etcd.conf>etcd.conf
                        sed "4,5s/10.1.1.60/${node_ip}/g" $EtcdConf/etcd.conf>etcd.conf
                        scp -p etcd.conf root@${node_ip}:$EtcdConf/etcd.conf
                    fi
                done
        fi
    done

# Create CA.
cat>$KubeCA/ca-config.json<<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
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
cat>$KubeCA/ca-csr.json<<EOF
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
cat>$KubeCA/server-csr.json<<EOF
{
    "CN": "kubernetes",
    "hosts": [
      "10.0.0.1",
      "127.0.0.1",
      "${HostIP[gysl-master]}",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
cd $KubeCA
cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server

# Create kube-proxy CA.
cat>$KubeCA/kube-proxy-csr.json<<EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "BeiJing",
      "ST": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
tree $KubeCA
cd $WorkDir

cat>$KubeConf/token.csv<<EOF
$(head -c 16 /dev/urandom | od -An -t x | tr -d ' '),kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

# Deploy the node. 
        for node_ip in ${NodeIPs[@]}
            do  
                scp -p kubernetes/server/bin/{kubelet,kube-proxy} root@$node_ip:$BinaryDir/
                scp -p flanneld root@$node_ip:$BinaryDir/
                scp -p root@$node_ip:$KubeCA/{bootstrap.kubeconfig,kube-proxy.kubeconfig} $KubeConf
            done

systemctl daemon-reload
systemctl enable etcd.service --now
systemctl status etcd

# Create a kube-apiserver configuration file.
cat >$KubeConf/apiserver.conf<<EOF
KUBE_APISERVER_OPTS="--logtostderr=true \\
--v=4 \\
--etcd-servers=https://${HostIP[gysl-master]}:2379,https://$HostIP[gysl-node1]}:2379,https://$HostIP[gysl-node2]}:2379,https://$HostIP[gysl-node3]}:2379 \\
--bind-address=${HostIP[gysl-master]} \\
--secure-port=6443 \\
--advertise-address=${HostIP[gysl-master]} \\
--allow-privileged=true \\
--service-cluster-ip-range=10.0.0.0/24 \\
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction \\
--authorization-mode=RBAC,Node \\
--enable-bootstrap-token-auth \\
--token-auth-file=$KubeConf/token.csv \\
--service-node-port-range=30000-50000 \\
--tls-cert-file=$KubeCA/server.pem  \\
--tls-private-key-file=$KubeCA/server-key.pem \\
--client-ca-file=$KubeCA/ca.pem \\
--service-account-key-file=$KubeCA/ca-key.pem \\
--etcd-cafile=$EtcdCA/ca.pem \\
--etcd-certfile=$EtcdCA/server.pem \\
--etcd-keyfile=$EtcdCA/server-key.pem"
EOF

# Create the kube-apiserver service.
cat>/usr/lib/systemd/system/kube-apiserver.service<<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
After=etcd.service
Wants=etcd.service

[Service]
EnvironmentFile=-$KubeConf/apiserver.conf
ExecStart=$BinaryDir/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable kube-apiserver.service --now
systemctl status kube-apiserver.service -l

# Deploy the scheduler service.
cat>$KubeConf/scheduler.conf<<EOF
KUBE_SCHEDULER_OPTS="--logtostderr=true \
--v=4 \
--master=127.0.0.1:8080 \
--leader-elect"
EOF

# Create the kube-scheduler service. 
cat>/usr/lib/systemd/system/kube-scheduler.service<<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-$KubeConf/scheduler.conf
ExecStart=$BinaryDir/kube-scheduler \$KUBE_SCHEDULER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-scheduler.service --now
sleep 20
systemctl status kube-scheduler.service -l

# Deploy the controller-manager service.
cat>$KubeConf/controller-manager.conf<<EOF
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=true \
--v=4 \
--master=127.0.0.1:8080 \
--leader-elect=true \
--address=127.0.0.1 \
--service-cluster-ip-range=10.0.0.0/24 \
--cluster-name=kubernetes \
--cluster-signing-cert-file=$KubeCA/ca.pem \
--cluster-signing-key-file=$KubeCA/ca-key.pem  \
--root-ca-file=$KubeCA/ca.pem \
--service-account-private-key-file=$KubeCA/ca-key.pem"
EOF

# Create the kube-scheduler service. 
cat>/usr/lib/systemd/system/kube-controller-manager.service<<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-$KubeConf/controller-manager.conf
ExecStart=$BinaryDir/kube-controller-manager \$KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-controller-manager.service --now
sleep 20
systemctl status kube-controller-manager.service -l

cd $KubeCA
# Set cluster parameters.
kubectl config set-cluster kubernetes \
  --certificate-authority=./ca.pem \
  --embed-certs=true \
  --server=https://${HostIP[gysl-master]}:6443 \
  --kubeconfig=bootstrap.kubeconfig

# Set client parameters.
kubectl config set-credentials kubelet-bootstrap \
  --token=`awk -F "," '{print $1}' $KubeConf/token.csv` \
  --kubeconfig=bootstrap.kubeconfig

# Set context parameters. 
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

# Set context.
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

# Create kube-proxy kubeconfig file. 
kubectl config set-cluster kubernetes \
  --certificate-authority=./ca.pem \
  --embed-certs=true \
  --server=https://${HostIP[gysl-master]}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=./kube-proxy.pem \
  --client-key=./kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
cd $WorkDir

# Bind kubelet-bootstrap user to system cluster roles.
kubectl create clusterrolebinding kubelet-bootstrap \
  --clusterrole=system:node-bootstrapper \
  --user=kubelet-bootstrap
