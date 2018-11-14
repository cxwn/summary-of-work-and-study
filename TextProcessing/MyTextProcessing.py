# -*- coding:utf-8 -*-
import chardet
import os
import re

class TextProcess():
    
    def __init__(self,input_file,output_file):
        self.input_file = input_file
        self.output_file = output_file

    def detect_encode(self):
        file_object = open(self.input_file,'rb')
        context = file_object.read()
        file_object.close()
        return chardet.detect(context)['encoding']

    def utf16_to_utf8(self):
        source_file_object = open(self.input_file, 'rb')
        content = source_file_object.read()
        source_file_object.close()
        dest_file_object = open(self.output_file, 'a+b')
        dest_file_object.write(content.decode('utf-16').encode('utf-8'))
        dest_file_object.close()

    def tab_to_blank(self):
        linux_cmd = "sed 's/\t/ /g'"+self.input_file+'>'+self.output_file
        os.system(linux_cmd)
    
    def find_BOM(self):
        linux_grep = "grep -r -I -l $'^\xEF\xBB\xBF'"+" "+self.input_file
        return os.popen(linux_grep)

    def delete_BOM(self):
        linux_delete = "sed 's/\xEF\xBB\xBF//g'"+" "+self.input_file+">"+self.output_file
        os.popen(linux_delete)

    def get_last_column(self):
        linux_awk = "awk '{print $NF}'"+self.input_file
        result_text = os.popen(linux_awk)
        with open(self.output_file,'a',encoding = 'utf-8') as file_ob:
            file_ob.write(result_text)

    def find_none_zh_en_char(self):
        dict_file = {}
        pattern=re.compile(r'[^\u4e00-\u9fa5a-zA-Z]{1}')
        try:
            with open(self.input_file,'rb') as text_object:
                text_context = text_object.read().decode('utf-8').rstrip()
        except FileNotFoundError:
            print('Input error!File not found!Error!')
        else:
            result_text = pattern.findall(text_context)
            result_text.sort()
        for n in range(0,(len(result_text)-1)):
            if result_text[n] != result_text[n+1] and result_text.count(result_text[n]) >1:
                dict_file[result_text[n]] = result_text.count(result_text[n])
            if result_text.count(result_text[n]) == 1:
                dict_file[result_text[n]] = result_text.count(result_text[n])
            if result_text.count(result_text[n+1]) == 1:
                dict_file[result_text[n+1]] = result_text.count(result_text[n+1])
        sorted_dict = sorted(dict_file.items(), key=lambda item: item[1], reverse=True)
        for stat in sorted_dict:
            new_stat = str(stat)
            with open(self.output_file,'a',encoding='utf-8') as fobj:
                fobj.write(new_stat+'\n')

    def find_tags(self):
        dict_file = {}
        result_text = []
        regex = [r'(?=(<{1}[^<]*>{1}))',r'(?=(\[{1}[^\[]*\]{1}))',r'(?=(（{1}[^（]*）{1}))',r'(?=(【{1}[^【]*】{1}))',r'(?=(《{1}[^《]*》{1}))']
        for reg in regex:
            pattern=re.compile(reg)
            with open(self.input_file,'rb') as text_object:
                text_context = text_object.read().decode('utf-8')
                result_text += pattern.findall(text_context)
        result_text.sort()
        for n in range(0,(len(result_text)-1)):
            if result_text[n] != result_text[n+1] and result_text.count(result_text[n]) > 1:
                dict_file[result_text[n]] = result_text.count(result_text[n])
            if result_text.count(result_text[n]) == 1:
                dict_file[result_text[n]] = result_text.count(result_text[n])
            if result_text.count(result_text[n+1]) == 1:
                dict_file[result_text[n+1]] = result_text.count(result_text[n+1])
        sorted_dict = sorted(dict_file.items(), key=lambda item: item[1], reverse=True)
        for stat in sorted_dict:
            new_stat = str(stat)
            with open(self.input_file,'a',encoding='utf-8') as output_fobj:
                output_fobj.write(new_stat+'\n')

if __name__=="__main__":
    input_file=input("Please input the path of source text:")
    output_file=input("Please input the path of output file:")
    text=TextProcess(input_file,output_file)
    text.find_none_zh_en_char()
    text.find_tags()
