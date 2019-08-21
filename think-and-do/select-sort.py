# -*- coding:utf-8 -*-
array = [8,3,2,4,9,100,1,23,3,2,24,557,424,8,4645,24234,0,323,5]
for i in range(0,len(array)):
    for j in range(i+1,len(array)):
        if array[i] > array[j]:
            temp = array[i]
            array[i] = array[j]
            array[j] = temp
print(array)
