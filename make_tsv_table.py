#!/usr/bin/env python

import re,sys,os
import gzip
from collections import defaultdict

Data=defaultdict(str)

i=0
infile=gzip.open( sys.argv[1] )
for line in infile:
	Data[i]=line.rstrip()
	i+=1
infile.close()

for file in (sys.argv[2:]):
	infile=gzip.open(file)
	i=0
	for line in infile:
		info = line.split("\t",1)[1].rstrip()
		info="".join(re.split("\s+", line.rstrip())[1:])
		Data[i]+="\t"+info
		i+=1
	infile.close()

for i in Data:
	print Data[i]
