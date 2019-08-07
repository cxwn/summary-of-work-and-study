# -*- coding:utf-8 -*-
import os, re, shutil
dst_dir=r'D:\线性代数-强化-李永乐'
for file in os.listdir(dst_dir):
    shutil.move(os.path.join(dst_dir,file), os.path.join(dst_dir,re.sub('2020考研线代强化','线代-强化-',file)))