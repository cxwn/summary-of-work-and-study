# -*- coding:utf-8 -*-
import os,re,shutil
src_path = r'C:\src'
dst_path = r'C:\dst'
temp_dir = r'C:\temp'
for src_file in os.listdir(src_path):
    for dst_file in os.listdir(dst_path):
        new_dst_file = re.search(r'\d+\.wav',dst_file).group()
        if os.path.exists(os.path.join(src_path,new_dst_file)):
            shutil.move(os.path.join(src_path,new_dst_file),temp_dir)