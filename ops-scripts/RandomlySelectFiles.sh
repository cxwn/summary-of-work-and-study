#!/bin/bash
# There are many TextGrid and wav files in a directory.We need to randomly select specified number of files from these files.These TextGrid and wav files have same basename.
src='/home/src' #The path of source files.
dst='/home/dst' #The path of destination files.
counter=0
needs=100 #The total number of requested files.
for file in `ls ${src}/|sort -R`;do
	mv ${src}/$(echo ${file}|awk -F "." '{print $1}').{TextGrid,wav} ${dst}/;
	let counter=${counter}+1
	if [ ${counter} -eq ${needs} ];then
		break;
	fi
done