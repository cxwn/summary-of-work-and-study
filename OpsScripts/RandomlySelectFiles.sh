#!/bin/bash
src='/home/src'
dst='/home/dst'
counter=0
needs=100
for file in `ls ${src}/|sort -R`;do
	mv ${src}/$(echo ${file}|awk -F "." '{print $1}').{TextGrid,wav} ${dst}/;
	let counter=${counter}+1
	if [ ${counter} -eq ${needs} ];then
		break;
	fi
done
