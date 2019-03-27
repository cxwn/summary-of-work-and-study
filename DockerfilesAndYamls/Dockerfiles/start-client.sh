#!/bin/bash
/usr/sbin/rpcbind
mount -t nfs 172.17.0.2:$SSD $DATA
while true; do sleep 6000; done