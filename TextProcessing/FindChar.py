#!/usr/bin/python3
# -*- coding:utf-8 -*-
import re
dictionary = {}
pattern=re.compile(r'[^\u4e00-\u9fa5a-zA-Z]{1}')
source_text = input("Please input the path of file:")
with open(source_text,'rb') as text_object:
    text_context = text_object.read().decode('utf-8')
    result_text = pattern.findall(text_context)
    result_text.sort()
for n in range(0,(len(result_text)-1)):
    if result_text[n] != result_text[n+1] and result_text.count(result_text[n]) !=1:
        dictionary[result_text[n]] = result_text.count(result_text[n])
    if result_text.count(result_text[n]):
        dictionary[result_text[n]] = result_text.count(result_text[n])
sorted_dict = sorted(dictionary.items(), key=lambda item: item[1], reverse=True)
print(sorted_dict)
