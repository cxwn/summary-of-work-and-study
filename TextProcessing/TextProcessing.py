#!/usr/bin/python3
#-*- coding:utf -8-*-
import os, sys, glob
import re, unicodedata
import argparse

def preclean(inputstring, pukstring):
	#process special tags in HYP files
	inputstring = re.sub(r'（([^\）]+)）', r'\1', inputstring)
	#process localization tokens, [\u4e00-\u9faf]+ is the range of CJK
	inputstring = re.sub(r'\[([\u4e00-\u9faf]+)\-[^\s]*\]', r'\1', inputstring)
	# inputstring = re.sub(r'[？|！|…|-|「|」|『|』|【|】|；|《|》|«|»|─|“|”|‘|’|－|～|〜|•|·|_|－|＊|／|：|；|■|▲|○|●|°|★|‰|①|②|④|⑤|⑦]', ' ', inputstring)
	inputstring = re.sub(pukstring, ' ', inputstring)
	
	return inputstring

def loadfils(input, output, col, externsionname, puk):
	OUT = open(output, 'w',encoding="utf8")
	print("Process Folder\t" +input+"/*." + externsionname+ "\n")
	for file in glob.glob(input+"/*." + externsionname):
		print("Load\t" + file + "\n")
		for line in open(file,encoding="utf8"):
			line = line.strip().rstrip("\r\n")
			contents = line.split('\t')
			if len(contents) < col+1:
				print("Warnning\tColumn number is incorrect\n")
				continue
			targetstring = preclean(inputstring = contents[col],  pukstring = puk)
			OUT.writelines(targetstring + '\t1' + '\n')
			
	OUT.close()

def loadinput(input, output, col, puk):
	OUT = open(output, 'w',encoding="utf8")
	for line in open(input,encoding="utf8"):
		line = line.strip().rstrip("\r\n")
		contents = line.split('\t')
		if len(contents) < col+1:
			print("Warnning\tColumn number is incorrect\n")
			continue
		targetstring = preclean(inputstring = contents[col], pukstring = puk)
		OUT.writelines(targetstring + '\t1' + '\n')
		
	OUT.close()

def loadpukfile(pukfile):
	forbidpunks = list()
	for line in open(pukfile, encoding="utf8"):
		line = line.strip().rstrip("\r\n")
		if line in  forbidpunks:
			print("Duplicate Punk\t" + line + "\n")
		else: forbidpunks.append(line)
	
	forbidpunkstring = "[" + "|".join(forbidpunks) + "]"
	print("ALL\t" + forbidpunkstring + "\n")
	return forbidpunkstring
	
if __name__ == '__main__':
	ap = argparse.ArgumentParser()
	ap.add_argument("-i", "--input", required=True, help="input file")
	ap.add_argument("-o", "--output", required=True, help="output file")
	ap.add_argument("-k", "--keepcolumn", required=True, help="the column need to be kept")
	ap.add_argument("-puk", "--puk", required=True, help="preclean target punctuations")
	ap.add_argument("-dir", "--filesuffix", required=False, default="false", help="read all files in the given folder, by *.extern")
	args = ap.parse_args()
	forbiddenpunks = loadpukfile(pukfile = args.puk)
	if args.filesuffix == "false":
		loadinput(input = args.input , output = args.output, col = int(args.keepcolumn), puk = forbiddenpunks)
	else:
		loadfils(input = args.input , output = args.output, col = int(args.keepcolumn), externsionname = args.filesuffix, puk = forbiddenpunks)