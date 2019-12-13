# -*- coding:utf-8 -*-

string = 'my name is ivan'
string.__add__('du')
li = ['my', 'name', 'ivan']
li[2] = li[2].__add__(' du')
print(string)
print(li)