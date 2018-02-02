# - *- coding: utf- 8 - *-
#!/usr/bin/python
#Nicola Bordin CABD Universidad Pablo de Olavide, Sevilla
#Integrative Cell Biology Pipeline 1.0
#Executes scripts for automated analysis of proteomes
import sys,os,re,collections,argparse,glob,operator,subprocess,ConfigParser
from operator import itemgetter

parser = argparse.ArgumentParser(description='Integrative Cell Biology Pipeline')
print "\n"
print "+"+"-"*48+"+"
print "|"+" "*48+"|"
print "|"+" "*8+"Integrative Cell Biology Pipeline"+" "*7+"|"
print "|"+" "*48+"|"
print "|"+" "*13+"Nicola Bordin, CABD UPO"+" "*11+"|"
print "+"+"-"*48+"+"
#Argument parser
parser.add_argument("-o", "--output-directory", help="The directory where to write the output files. Defaults to WORKDIR.", metavar="PATH", default=".")
parser.add_argument("-i", "--i", help="The multiFASTA file to be processed. [mandatory]", metavar="PATH", required=True)
parser.add_argument("-psiblast", help="Use PSIBLAST module", action="store_true")
parser.add_argument("-ipr", help="Use InterProScan module", action="store_true")
parser.add_argument("-tmh", help="Use TMHMM module", action="store_true")
parser.add_argument("-hhpred", help="Use HHPred (PDB) module", action="store_true")
parser.add_argument("-hhblits", help="Use HHblits (UniProt) module", action="store_true")
parser.add_argument("-sigp", help="Use SignalP module", action="store_true")
parser.add_argument("-iup", help="Use IUPRED module", action="store_true")
parser.add_argument("-all", help="Run all modules",action="store_true")
args=parser.parse_args()
multifasta=args.i
psiblast=args.psiblast
interproscan=args.ipr
tmhmm=args.tmh
hhpred=args.hhpred
hhblits=args.hhblits
signalp=args.sigp
iupred=args.iup
allmodules=args.all
current_path=os.getcwd()
#Execution options block
print "Modules available:\n"
print "PSIBLAST"
print "TMHMM"
print "SignalP"
print "IUPRED"
print "InterProScan"
print "HHPred"
print "HHblits\n"
print "Execution Parameters"
#Parsing config file
config = ConfigParser.ConfigParser()
config_path = os.path.dirname(os.path.realpath(sys.argv[0]))+"/config.txt"
config.readfp(open(config_path))
blast_path = config.get('binaries', 'blast')
interproscan_path =config.get('binaries','interproscan')
tmhmm_path = config.get('binaries', 'tmhmm')
hhsuite_path =config.get('binaries','hhsuite')
swissprot_path = config.get('binaries', 'swissprot')
signalp_path =config.get('binaries','signalp')
iupred_path = config.get('binaries', 'iupred')
cpus = config.get('binaries','cpus')
sprot_reduced = config.get('binaries','sprot_reduced')
multithread = config.get('binaries','multithread')
uniprot = config.get('binaries','uniprot')
pdb = config.get('binaries','pdb')
print "Parsing headers\n"
psi_id=''
tmh_id=''
sig_id=''
hhpr_id=''
hhb_id=''
iup_id=''
ipr_id=''
os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/0_initial_parser.pl "+multifasta+" "+multifasta[:-11])

#Full pipeline
if allmodules==True:
	print "Running all modules\n"
	

#Calling PSIBLAST module
if psiblast or allmodules==True:
	psi_id="01*"
	#Runs PSIBLAST if output not found in cwd
	if os.path.isfile(current_path+"/PSIBLAST_raw_results_"+multifasta[:-11]+".txt") == False:
		print "Running PSIBLAST\n"
		os.system(blast_path+"psiblast -query "+multifasta+" -db "+swissprot_path+"/swissprot -num_iterations 3 -out PSIBLAST_raw_results_"+multifasta[:-11]+".txt -outfmt 7 -parse_deflines -num_threads "+cpus)
		os.system("gzip -f PSIBLAST_raw_results_"+multifasta[:-11]+".txt")
	else:
		print "\nPSIBLAST output detected in cwd!"
	print "Parsing PSIBLAST results\n"
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/parse_psiblast_simple.pl "+multifasta+" PSIBLAST_raw_results_"+multifasta[:-11]+".txt "+sprot_reduced+"/uniprot_sprot_reduced.dat "+multifasta[:-11])
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/order_entries.pl 01_PSIBLAST_"+multifasta[:-11]+".tsv 00_ini*")
	os.system("gzip -f 01_PSIBLAST_"+multifasta[:-11]+".tsv")

#Calling TMHMM Module
if tmhmm or allmodules==True:
	tmh_id='03*'
	print "Running TMHMM"
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/run_parse_TMHMM.pl "+multifasta+" "+multifasta[:-11]+" "+tmhmm_path)
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/order_entries.pl 03_TMH_"+multifasta[:-11]+".tsv 00_ini*")
	os.system("gzip -f 03_TMH_"+multifasta[:-11]+".tsv")
#Calling Interproscan Module
if interproscan or allmodules==True:
	print "Running InterProScan"
	ipr_id='05*'
	if os.path.isdir(current_path+"/InterProScan_results") == False:
		os.system("mkdir InterProScan_results")
		os.system("cp "+multifasta+" InterProScan_results/"+multifasta)
		os.system("cd InterProScan_results/")
		os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/splitfasta_mod.pl "+multifasta)
		os.system("for file in *.seq; do "+interproscan_path+"/interproscan.sh -mode cluster -clusterrunid iproscan -i $file -d InterProScan_results -f tsv,xml -iprlookup -goterms -pa; done")
		os.system("cd ../")
		os.system("cat InterProScan_results/*.xml > InterProScan_results/InterProScan_dump_"+multifasta[:-11])
		os.system("rm *.seq && rm -rf temp/")
	else:
		os.system("cat InterProScan_results/*.xml > InterProScan_results/InterProScan_dump_"+multifasta[:-11])
		print "InterProScan results folder already present!"
		print "Parsing InterProScan output"
	os.system("gzip -f InterProScan_results/InterProScan_dump_"+multifasta[:-11])
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/interproscan_parser.pl InterProScan_results/InterProScan_dump_"+multifasta[:-11]+".gz "+multifasta[:-11])
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/order_entries.pl 05_InterPro_"+multifasta[:-11]+".tsv 00_ini*")
	os.system("gzip -f 05_InterPro_"+multifasta[:-11]+".tsv")

#Calling HHblits module
if hhblits or allmodules==True:
	print "Running HHblits"
	hhb_id='06*'
	if os.path.isdir(current_path+"/HHblits_results") == False:
		os.system("mkdir HHblits_results")
		os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/splitfasta_mod.pl "+multifasta)
		#os.system("mv *.seq HHblits_results/")
		os.system("find . -type d -o -prune -name '*.seq' -exec mv -t HHblits_results/ {} +")
		os.system("perl "+multithread+"/multithread.pl 'HHblits_results/*.seq' '"+hhsuite_path+"/hhblits -i $file -d "+uniprot+" -oa3m $name.a3m -n 2' -cpu "+cpus+" -v 0")
		os.system("gzip -f HHblits_results/*.hhr")
	else:
		print "HHblits results folder already present!"
	
	print "Parsing HHblits output"
	os.system("for file in HHblits_results/*.hhr.gz; do perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/hhblits_against_uniprot20_function_extractor_v2.pl $file "+multifasta[:-11]+"; done")
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/order_entries.pl 06_HHblits_annotation_"+multifasta[:-11]+".tsv 00_ini*")
	os.system("gzip -f 06_HHblits_annotation_"+multifasta[:-11]+".tsv")

#Calling HHpred module
if hhpred or allmodules==True:
	print "Running HHpred"
	hhpr_id='07*'
	if os.path.isdir(current_path+"/HHpred_results") == False:
		os.system("mkdir HHpred_results")
		os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/splitfasta_mod.pl "+multifasta)
		#os.system("mv *.seq HHpred_results/")
		os.system("find . -type d -o -prune -name '*.seq' -exec mv -t HHpred_results/ {} +")
		os.system("perl "+multithread+"/multithread.pl 'HHpred_results/*.seq' '"+hhsuite_path+"/hhblits -i $file -d "+uniprot+" -oa3m $name.a3m -n 2' -cpu "+cpus)
		os.system("perl "+multithread+"/multithread.pl 'HHpred_results/*.a3m' '"+multithread+"/addss.pl $file' -cpu "+cpus+" -v 0")
		os.system("perl "+multithread+"/multithread.pl 'HHpred_results/*.a3m' '"+hhsuite_path+"/hhmake -i $file' -v 0 -cpu "+cpus+" -v 0")
		os.system("perl "+multithread+"/multithread.pl 'HHpred_results/*.hhm' '"+hhsuite_path+"/hhsearch -i $file -d "+pdb+" -v 0' -cpu "+cpus+" -v 0")
		os.system("gzip -f HHpred_results/*.hhr")
	else:
		print "HHpred results folder already present!"
	print "Parsing HHpred output"
	
	os.system("for file in HHpred_results/*.hhr.gz; do perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/hhblits_against_pdb_function_extractor_v2.pl $file "+multifasta[:-11]+"; done")
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/order_entries.pl 07_HHpred_annotation_"+multifasta[:-11]+".tsv 00_ini*")
	os.system("gzip -f 07_HHpred_annotation_"+multifasta[:-11]+".tsv")
#Calling SignalP Module
if signalp or allmodules==True:
	sig_id='02*'
	print "Running SignalP"
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/run_parse_SignalP.pl "+multifasta+" "+multifasta[:-11]+" "+signalp_path)
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/order_entries.pl 02_SP_"+multifasta[:-11]+".tsv 00_ini*")
	os.system("gzip -f 02_SP_"+multifasta[:-11]+".tsv")
#Calling IUPRED Module
if iupred or allmodules==True:
	print "Running IUPred"
	iup_id='04*'
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/run_parse_IUPRED.pl "+multifasta+" "+multifasta[:-11]+" "+iupred_path)
	os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/order_entries.pl 04_DIS_"+multifasta[:-11]+".tsv 00_ini*")
	os.system("gzip -f 04_DIS_"+multifasta[:-11]+".tsv")

os.system("python "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/make_tsv_table.py 00* "+psi_id+" "+sig_id+" "+tmh_id+" "+iup_id+" "+ipr_id+" "+hhb_id+" "+hhpr_id+" > "+multifasta[:-11]+"_table.tsv")
os.system("perl "+os.path.dirname(os.path.realpath(sys.argv[0]))+"/tsv_to_html.pl "+multifasta[:-11])
