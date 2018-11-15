#-*- coding:utf-8 -*-
import os, sys, glob
import re, unicodedata
import argparse

def ExtractTxtfromTextgrid(input, output):
	contentstart = 0
	starttime = 0.0
	endtime = 0.0
	dialognumbers = 0
	OUT = open(output, 'w',encoding="utf8")
	
	with open(input,encoding="utf-16'") as fileobj:
		for line in fileobj:
			line = line.strip().rstrip("\r\n")
			
			#check contents
			if line == "\"IntervalTier\"" :
				print("find IntervalTier\n")
				line = next(fileobj).strip().rstrip("\r\n")
				
				#Move to the next line if current line start with #
				if line.startswith( "#") :
					line = next(fileobj).strip().rstrip("\r\n")
				
				print(line)
				#check whether content starts
				if line == "\"CONTENT\"" :
					print("find CONTENT\n")
					contentstart = 1
					
					if line.startswith( "#") : 
						continue
					starttime = float(next(fileobj).strip().rstrip("\r\n"))
					endtime = float(next(fileobj).strip().rstrip("\r\n"))
					dialognumbers = int(next(fileobj).strip().rstrip("\r\n"))
					continue
				else :
					contentstart = 0
			
			if line.startswith( "#") : 
				continue
			line = re.sub(r'\[[^\]\u4e00-\u9faf]+\]', r' ', line)
			if contentstart == 1 and line.startswith("\"") :
				line = re.sub(r'\"', r'', line)
				if line.strip():
					OUT.writelines(line + '\n')
	
if __name__ == '__main__':
	ap = argparse.ArgumentParser()
	ap.add_argument("-i", "--input", required=True, help="input file")
	ap.add_argument("-o", "--output", required=True, help="output file")
	args = ap.parse_args()
	ExtractTxtfromTextgrid(input = args.input , output = args.output)
