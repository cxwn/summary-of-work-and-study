#!/bin/bash
echo "$SSD *(fsid=0,rw,no_root_squash,no_subtree_check)">>/etc/exports
mount -t tmpfs -o size=100m  tmpfs $SSD
exportfs -r
rpcbind
rpc.nfsd
rpc.mountd
rpc.rquotad
rpc.statd