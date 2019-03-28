#!/bin/bash
MasterIP='10.1.1.80'
NodeHostname=('gysl-01' 'gysl-02' 'gysl-03')
NodeIP=('10.1.1.81' '10.1.1.82' '10.1.1.83')
WorkDir='~/'
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
        fi
    done
if [ `sha512sum $PackageName`==$Sha512sum ];
    then
        tar -cvzf kubernetes-server-linux-amd64.tar.gz
        ssh-keygen -b 1024 -t rsa -C 'Kubernetes'
        for node_ip in ${NodeIP[@]}
            do
                ssh-copy-id -i root@$node_ip
                scp 
            done
    else
        echo "Installation failed. Please try again!"
        exit 101
fi