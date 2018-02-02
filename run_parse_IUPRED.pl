#!/usr/bin/perl -w
#
# MODULE 3	
# DISORDER prediction
#
# Version 1.1 (24 January, 2018)
#
# Juan Carlos González Sánchez & Nicola Bordin
# Centro Andaluz de Biología del Desarrollo (CABD)
# Universidad Pablo de Olavide, Sevilla
#
# 
# Usage:
# 	~$ perl pipeline03_disorder.pl input_fasta strain_name
#

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use IO::Compress::Gzip;

# DEFINE VARIABLES
my $input_file = $ARGV[0];
my $output_name = $ARGV[1];
my $iupred_path = $ARGV[2];
 
	my $output_specific_directory;
	my $current_directory = getcwd;
	#my $iupred_directory  = "/home/programs/iupred-1.0/";

	
# Output files
my $module3_iupred 	= "IUPred_raw_results_$output_name".".txt";
my $module3_output 	= "04_DIS_$output_name".".tsv";	
my $temp_file		= "iu_temp_$output_name";

#
my (@heads, @sequences_length, @fasta_proteins);
my ($seq,$i) = ("",-1);



##### 1. Extraction of proteins from a FASTA file #####			
if ($input_file =~ /\.gz$/) {
	open (IN, "gzip -dcf $input_file |") or die "Error: can't open $input_file";
}else{
	open (IN, $input_file) or die "Error: can't open $input_file";
}

while (<IN>) {

	if ($_ =~ /^>(.*)/) {
		$i++;
		$seq = '';
		$heads[$i] = $1;
	} elsif ($_ =~ /^\w/) {
		$seq .= $_;
		$sequences_length[$i] = length $seq;	
		$fasta_proteins[$i] = '>'.$heads[$i]."\n".$seq;
	}
}
	
close (IN);

## 2. RUN IUPred
foreach my $fasta(@fasta_proteins) {
	open (OUT, ">$temp_file") or die $!;
	print OUT $fasta;					
	close (OUT);	
		
	system ($iupred_path."/iupred $temp_file long >> $module3_iupred");		
	system ($iupred_path."/iupred $temp_file glob >> $module3_iupred");		
	unlink "$temp_file";
}

system ("gzip -f $module3_iupred");


## 3. PARSE results
my @pt_names; my $flag; my $score; my $pt_name;	
my %aas_scores;my %glob_doms;
my ($total_aas,$disordered_aas,$disorder_per100) = (0,0,0);

$flag=0;
$i=0;
open (IN, "gzip -dcf $module3_iupred.gz |") or die $!;

while (<IN>) {
	if ($_ =~ /^# Prediction output/ && $flag==0) {
		$flag = 1;
	}elsif (($_ =~ /^#\s([^\s][^\n]+)/) && $flag==1) {
		$pt_name = $1;
		$pt_names[$i] = $pt_name;
		$i++;
	}elsif ($_ =~ /^\s+\d+\s\w\s+([^s]+)\n$/){
		$score = $1;
		push (@{$aas_scores{$pt_name}}, $score);
		$flag=2;
	}elsif ($_ =~ /Number of globular domains\:\s+(\d+)/ ) {
		if ($1 == 0) {
			$glob_doms{$pt_name}=0; 	
		}
		$flag=0;	
	}elsif ($_ =~ /\s+globular domain\s+\d+\.\s+(\d+)\s\-\s(\d+)/ ){
		$glob_doms{$pt_name}.= "(".$1."-".$2.")";
	
	}
}
	
close (IN);

# 4. PRINT results
# WHAT DO I WANT HERE. Several parameters can be calculated from the raw output. Right now, just general % of disorder is calculated

open (OUT, ">$module3_output") or die "ERROR in Module 3: could not create $module3_output";
print OUT "#Query\tDisorder \% [Globular Domains]\n";

foreach my $pt_name (@pt_names) {
	$total_aas=0;	
	$disordered_aas=0;
	foreach my $score (@{$aas_scores{$pt_name}}) {
		if ($score > 0.5) {
			$disordered_aas++;
		}		
		$total_aas++;
	}
	$disorder_per100 = sprintf ("%.2f", $disordered_aas*100/$total_aas);

	print OUT "$pt_name\t","$disorder_per100"," % [GlobDoms=",$glob_doms{$pt_name},"]\n";
}
close (OUT);

#system ("perl /home/JC/Pipeline/make_table_scripts/order_entries.pl $module3_output 00_ini*");
#system ("gzip -f $module3_output");
