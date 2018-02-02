#!/usr/bin/perl -w
#
# MODULE 2	
# PREDICTION of TMH's
#
# Version 1.1 (January 24, 2018)
#
# Juan Carlos González Sánchez & Nicola Bordin
# Centro Andaluz de Biología del Desarrollo (CABD)
# Universidad Pablo de Olavide, Sevilla
#
# 
# Usage:
# 	~$ perl pipeline02_TMHprediction.pl -multifasta_input -outfile
#

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use IO::Compress::Gzip;

# DEFINE VARIABLES	
	my $input_file = $ARGV[0];
	my $output_name = $ARGV[1];
	my $tmhmm_path =$ARGV[2]; 

	# Output files
	my $tmhmm_output 	= "TMHMM_raw_results_$output_name".".tsv";
	my $parsed_output 	= "03_TMH_$output_name".".tsv";

	# 
	my (%tmhmm, $i,$protein);


## 1. RUN TMHMM
system ($tmhmm_path."tmhmm -short -noplot $input_file > $tmhmm_output");
system ("gzip -f $tmhmm_output");

## 2. PARSE Results
#if ($tmhmm_output =~ /\.gz$/) {
	open (IN, "gzip -dcf $tmhmm_output.gz |");
#	print $tmhmm_output,"\n";
#}else{
#	open (IN, "$tmhmm_output");
#}

$i=0;
while (<IN>) {
	# gi|497718942|ref|WP_010033126.1|	len=681	ExpAA=0.00	First60=0.00	PredHel=0	Topology=o	
	next unless ($_ =~ /(.+)\s+len.+First60=([^\s]+)\s+PredHel=(\d+)\s+Topology=([^\s]+)/); 
			
	$protein = $1;
	$tmhmm{ $protein }{ "sp" } = $2;			
	$tmhmm{ $protein }{ "tmh" } = $3;
	$tmhmm{ $protein }{ "topology" } = $4;
	$tmhmm{ $protein }{ "order" } = $i;
	$i++;
}

close (IN);

	
open (OUT, ">$parsed_output") or die $!;
		
print OUT "#Query\tTMHs\n";
	
foreach my $protein ( sort {$tmhmm{$a}{"order"} <=> $tmhmm{$b}{"order"}   } keys %tmhmm) {
	
	if ($tmhmm{$protein}{"sp"} >= 10){
		print OUT $protein,"\t",$tmhmm{$protein}{"tmh"}," [SP=y, topology=",$tmhmm{ $protein }{ "topology" },"]\n";
	} else {
		print OUT $protein,"\t",$tmhmm{$protein}{"tmh"}," [SP=n, topology=",$tmhmm{ $protein }{ "topology" },"]\n";

	}
	
}

close (OUT);

#system ("perl /home/JC/Pipeline/make_table_scripts/order_entries.pl $parsed_output 00_ini*");
#system ("gzip -f $parsed_output");




