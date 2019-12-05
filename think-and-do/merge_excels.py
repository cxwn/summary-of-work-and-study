# -*- coding:utf-8 -*-
import os, xlrd, xlsxwriter

source_dir = r'input'
new_execl = "All in one.xlsx"
raw_excels = os.listdir(source_dir)
keyword = "油站经理" # 除包括此关键字的行均插入
data = []

filename = os.path.join(source_dir, raw_excels[0])
wb = xlrd.open_workbook(filename)
sheet = wb.sheets()[0]
data.append(sheet.row_values(0))
data.append(sheet.row_values(1))

for excel in raw_excels:
    filename = os.path.join(source_dir, excel)
    wb = xlrd.open_workbook(filename)
    sheet = wb.sheets()[0]
    for row_num in range(2, sheet.nrows):
        row_values = [str(i) for i in sheet.row_values(row_num)]
        if len(''.join(row_values)) and (keyword not in ''.join(row_values)):
            data.append(sheet.row_values(row_num))
data.append(sheet.row_values(sheet.nrows-1))

new_wb = xlsxwriter.Workbook(new_execl)
worksheet = new_wb.add_worksheet()
font = new_wb.add_format({"font_size":11})
for i in range(len(data)):
    for j in range(len(data[i])):
        worksheet.write(i, j, data[i][j], font)
new_wb.close()
