# -*- coding:utf-8 -*-
# Rename some files.

import os, re, shutil
dst_dir = r'C:\Users\v-ruidu\Documents\数据结构（洪教授）【31课时，全】'
file_list = os.listdir(dst_dir)
for file in file_list:
    new_name = re.findall(r'^.{25}|\.mp4$',file)  # \u4E00-\u9FA5
    if len(new_name) == 2 and file != new_name[0] + new_name[1]:
        shutil.move(os.path.join(dst_dir,file),os.path.join(dst_dir,new_name[0]+new_name[1]))