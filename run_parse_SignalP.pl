#!/usr/bin/perl -w
#
# MODULE 4	
# SIGNAL PEPTIDE prediction
#
# Version 1.0 (August 29, 2014)
#
# Juan Carlos González Sánchez
# Centro Andaluz de Biología del Desarrollo (CABD)
# Universidad Pablo de Olavide, Sevilla
#
# 
# Usage: run_parse_SignalP fasta speciesname signalp_path

use strict;
use warnings;
use Cwd;
use Getopt::Long;
use IO::Compress::Gzip;

# DEFINE VARIABLES
my $input_file = $ARGV[0];
my $output_name = $ARGV[1];
my $signalp_path = $ARGV[2];

#Output files
my $signalp_output = "SignalP_raw_results_$output_name".".tsv";
my $parsed_output = "02_SP_$output_name".".tsv";


## 1. RUN SIGNALP

system ($signalp_path."/signalp -f short $input_file > $signalp_output"); 

system ("gzip -f $signalp_output");

# 2. PARSE results                                                                                                                    
open (IN, "gzip -dcf $signalp_output.gz |") or die $!;
	
open (OUT, ">$parsed_output") or die $!;
print OUT "#Query\tSignal_Peptide\n";	
while (<IN>) {

	if ($_ =~ /([^\s][^\#]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+(\w)\s+([^\s]+)\s+([^\s]+)/) {

        #name $1 #Cmax $2 #pos $3 #Ymax $4 #pos $5 #Smax $6 #pos $7 #Smean $8 #D $9 #? $10 #Dmaxcut $11 #Networks-used $12
		print OUT "$1\t";
	
		if ($10 eq "Y") {
  			print OUT "1-",($3-1),"\n";
        	} elsif ($10 eq "N") {
                	print OUT "-\n";
        	}
	}
}

close (IN);
close (OUT);


exit 1;
