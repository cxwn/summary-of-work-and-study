# -*- coding:utf-8 -*-
from aip import AipOcr

config = {
    'appId': '17170052',
    'apiKey': '1Gh4su3Ffoqj8qomRcWLUWfi',
    'secretKey': 'ZvBowoOqQU5mg1HTFHF711wGT1GOPY6m'
}

client = AipOcr(**config)

imagePath = r'C:\Users\v-ruidu\Desktop\4.png'

def get_file_content(filePath):
    with open(filePath, 'rb') as fp:
        return fp.read()

def img_to_str(imagePath):
    image = get_file_content(imagePath)
    result = client.basicGeneral(image)
    if 'words_result' in result:
        return '\n'.join([w['words'] for w in result['words_result']])

print(img_to_str(imagePath))


# https://cloud.baidu.com/doc/OCR/OCR-Python-SDK.html#.E9.80.9A.E7.94.A8.E6.96.87.E5.AD.97.E8.AF.86.E5.88.AB
# https://segmentfault.com/a/1190000012861561?utm_source=tag-newest
