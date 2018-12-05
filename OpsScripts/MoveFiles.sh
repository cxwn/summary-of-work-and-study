#!/bin/bash
#原始目录/raw_data中有若干文件，现需将这些文件的前10个合并成一个文件1.tsv，11-20各合并成一个文件2.tsv,其余文件合并为3.tsv。
count=0
s_directory=/raw_data
d_directory=/new_data
for file in `ls $s_directory`;
    do 
        if [ $count -lt 11 ];
            then
                cat $s_directory/$file >>$d_directory/1.tsv
                let count=($count+1)
        elif [[ $count > "10" && $count < "21" ]];
            then
                cat $s_directory/$file >>$d_directory/2.tsv
                let count=($count+1)      
        else
            cat $s_directory/$file >>$d_directory/3.tsv
        fi
    done