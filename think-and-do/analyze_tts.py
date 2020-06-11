# -*- coding:utf-8 -*-
import re
import os

def readfile(text):
    ob = open(text,'rb')
    try:
        context = [ string.decode('utf-8') for string in ob.readlines() ]
    except:
        context = [ string.decode('gbk') for string in ob.readlines() ]
    else:
        context = [ string.decode('utf-8') for string in ob.readlines() ]
    ob.close()
    return context

def classify(province):
    provinces = ['fj','hl','jl','qh','辽宁','湖北']
    if province in provinces:
        return False
    else:
        return True

def find(readlines,keyword):
    for line in readlines:
        if keyword in line:
            return readlines.index(keyword)
        else:
            pass

if __name__ == "__main__":
    all = ['四川','江西','湖南','江苏','海南','山东','fj','hl','jl','qh','山西','陕西','云南','广西','贵州','北京','辽宁','河南','湖北','nx','tj']
    keywords = []
    fd = os.path.join(os.getcwd(),"logs")
    os.chdir(fd)
    for province in all:
        for fl in os.listdir(fd):
            if province in fl:
                content = readfile(fl)
                for keyword in keywords:
                    index = find(content,keyword)
                    print(index)
                    if classify(province): # 大部分省市的格式
                        target = content[index+1].strip()
                        print(target)
                    else: # 少数省市
                        target = content[index].split(":")[1].strip()
                        print(target)
