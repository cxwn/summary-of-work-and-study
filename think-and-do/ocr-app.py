# -*- coding:utf-8 -*-
from aip import AipOcr

config = {
    'appId': '',
    'apiKey': '1Gh4su3Ffoqj8qomRcWLUWfi',
    'secretKey': 'ZvBowoOqQU5mg1HTFHF711wGT1GOPY6m'
}

client = AipOcr(**config)

imagePath = r'C:\Users\v-ruidu\Desktop\1.png'

def get_file_content(filePath):
    with open(filePath, 'rb') as fp:
        return fp.read()

def img_to_str(imagePath):
    image = get_file_content(imagePath)
    result = client.basicGeneral(image)
    if 'words_result' in result:
        return '\n'.join([w['words'] for w in result['words_result']])

print(img_to_str(imagePath))
