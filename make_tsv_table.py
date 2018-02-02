#!/usr/bin/env python

import re,sys,os
import gzip
from collections import defaultdict

Data=defaultdict(str)

infile=gzip.open( sys.argv[1] )
for line in infile:
    if line.startswith("NAME"):
        continue
    line=line.rstrip()
    splitter=line.split("\t")
    Data[splitter[0]]=splitter[1]+"\t"+splitter[2]+"\t"+splitter[3]

infile.close()

infile=gzip.open(sys.argv[2])
for line in infile:
    check=0
    line=line.rstrip()
    if "Query" in line:
        continue
    else:
        identifier=line.split("\t")[0]
        info=line.replace(identifier,"")
        for i in Data:
            split_i=i.split("|")[1]
            if split_i==identifier:
                Data[i]+=info
infile.close()

for file in (sys.argv[3:]):
    infile=gzip.open(file)
    for line in infile:
        line=line.rstrip()
        if "Query" in line:
            continue
        else:
            identifier=line.split("\t")[0]
            info=line.replace(identifier,"")
            identifier_pipe=identifier.split("|")[1]
            for i in Data:
                split_i=i.split("|")[1]
                if split_i==identifier_pipe:
                    Data[i]+=info
    infile.close()

print "NAME/ID\tDescription\tOrganism\tProtein length (aa)\t Best PSIBLAST Hit: UniProt Accession [+stats]\tBest PSIBLAST Hit: Gene\tBest PSIBLAST Hit: Description\t Best PSIBLAST Hit: GO Terms\tBest PSIBLAST Hit: Keywords\t Best PSIBLAST Hits: EC Number\tSignal Peptide\tTMHs\tDisorder % [Globular Domains]\tHHblits vs UniProt\tHHpred vs PDB"
for i in Data:
    print i+"\t"+Data[i]
			
