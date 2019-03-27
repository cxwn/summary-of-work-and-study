#!/bin/bash
echo "$SSD *(fsid=0,rw,no_root_squash,no_subtree_check)">>/etc/exports
mount -t tmpfs -o size=$SIZE tmpfs $SSD
/usr/sbin/exportfs -r
/usr/sbin/rpcbind
/usr/sbin/rpc.nfsd
/usr/sbin/rpc.mountd
/usr/sbin/rpc.rquotad
while true;
    do 
        sleep 6000;
    done