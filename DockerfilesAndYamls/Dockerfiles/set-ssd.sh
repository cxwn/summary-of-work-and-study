#!/bin/bash
mkdir $SSD
echo "$SSD *(fsid=0,rw,no_root_squash,no_subtree_check)">>exportfs
mount -t tmpfs -o size=100m  tmpfs $SSD
