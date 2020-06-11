# -*- coding:utf-8 -*-

import re
import os

def content(text):
    ob = open(text,'rb')
    try:
        context = [ string.decode('utf-8') for string in ob.readlines() ]
    except:
        context = [ string.decode('gbk') for string in ob.readlines() ]
    ob.close()
    return context

def keywords(target):
    all = ['四川','江西','湖南','江苏','海南','山东','fj','hl','jl','qh','山西','陕西','云南','广西','贵州','北京','辽宁','河南','湖北','nx','tj']
    part = ['fj','hl','jl','qh','辽宁','湖北']
    path = 'logs'
    fl =  os.path.join(os.getcwd(),path)
    count = []
    logs = os.listdir(fl)
    for city in all:
        for log in logs:
            if city in part and city in log:
                text =  os.path.join(fl,log)
                for keyword in content(text):
                    if target in keyword:
                        count.append(keyword.split(':')[1])
                    else:
                        pass
            elif city not in part and city in log:
                text =  os.path.join(fl,log)
                for keyword in content(text):
                    if target in keyword:
                        count.append(int(content(text)[(int(content(text).index(keyword))+1)].strip()))
                    else:
                        pass
            else:
                pass
            return count
if __name__ == "__main__":
    print(keywords('mrcp server'))


    def gen():
        for i in range(100):
            yield i
    