# -*- coding:utf-8 -*-
import os
import re

path = r'logs'
all = ['四川','江西','湖南','江苏','海南','山东'] #,'fj','hl','jl','qh','山西','陕西','云南','广西','贵州','北京','辽宁','河南','湖北','nx','tj']
part = ['fj','hl','jl','qh','辽宁','河南','湖北']

for city in all:
  for log in os.listdir(path):
    if city in log:
      try:
        ob = open(os.path.join(path,log),'r', encoding='utf-8')
        context = ob.readlines()
      except:
        ob = open(os.path.join(path,log),'r',encoding='gbk')
        context = ob.readlines()
      ob.close()
      ip_list = []
      vip_list = []
      mrcp_list= []
      if city not in part:
        for line in context:
          if 'start' in line:
            pob = re.search(r'(?:(?:[01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])\.){3}(?:[01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])',line)
            if pob and pob.group(0) not in ip_list: # ip
              ip_list.append(pob.group(0))
              print(ip_list)
            else:
              print("Error: Host IP is not set!")
          elif 'listen=' in line: # vip
            pob = re.search(r'(?:(?:[01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])\.){3}(?:[01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])',line)
            if pob and pob.group(0) not in vip_list:
              vip_list.append(pob.group(0))
              print(vip_list)
            else:
              print("Error: Vip is not set!")
          elif 'kamailio ip port' in line: # kamailio ip port
            kammailio_ip_port = context[context.index(line)+1].strip() # kamailio count
          elif "kamilio:" in line:
            kammailio_count = int(context[context.index(line)+1].strip())
          elif 'mrcp list:' in line: # mrcp list
            if 'sip' in context[context.index(line)+1] or context[context.index(line)+1]:
              mrcp_list.append(context[context.index(line)+1].strip())
              mrcp_list.append(context[context.index(line)+2].strip())
              print(mrcp_list)
            else:
              print("Error: Mrcp list is None!")
      ips = '\n'.join(ip_list)
      vips = '\n'.join(vip_list)
      mrcps = '\n'.join(mrcp_list)
      mrcp_server = int(context[context.index("mrcp server:\n")+1])
      print(ips,vips,mrcps,mrcp_server)