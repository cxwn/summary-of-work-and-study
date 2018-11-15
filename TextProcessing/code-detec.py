#!/usr/bin/python3
# -*- coding:utf-8 -*-
import chardet
def detectEncode(filePath): # 检测文本的编码函数
    fileObject=open(filePath,'rb')
    context=fileObject.read()
    fileObject.close()
    return chardet.detect(context)['encoding']

if __name__=="__main__":
    print(detectEncode("/home/ivan/lmtrainer/samples/cmcc/sample/10086.service.txt"))
    
    
sourceFilePath='/home/ivan/lmtrainer/samples/cmcc/sample/simulate_machineData.txt'
destFilePath='/home/ivan/cmcc-utf-8.txt'
sourceFileObject = open(sourceFilePath, 'rb')
destFileObject = open(destFilePath, 'w+b')
contents = sourceFileObject.read()
sourceFileObject.close()
destFileObject.write(contents.decode('utf-16').encode('utf-8'))
destFileObject.close()
