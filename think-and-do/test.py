# -*- coding:utf-8 -*-
lst_a = [1,2,3,4,5]
lst_b = [3,4,5,6,7]
set_a = set(lst_a)
set_b = set(lst_b)
set_c = set_b ^ set_a
print(list(set_c))