#!/usr/bin/perl -w
#
# INITIAL PARSER
#
# Version 2.0 January 2018
#
# Juan Carlos González Sánchez & Nicola Bordin
# Centro Andaluz de Biología del Desarrollo (CABD)
# Universidad Pablo de Olavide, Sevilla
#
# The script takes the protein sequences FASTA-format file which constitute the primary INPUT of the pipeline and extract basic info: 
# - Protein name or ID, and description (from FASTA header)
# - Belonging organism (if possible)
# - Protein length
# - Total number of proteins
#
# Usage:
# 	~$ perl <this_script.pl> <input_file> identifier 

use strict;
use warnings;
use Cwd;
use Compress::Raw::Zlib;

scalar (@ARGV) == 2 or die $!;

# DEFINE VARIABLES #####################################################################
my $input_file = $ARGV[0];
my $identifier = $ARGV[1];
my $output_file = "00_ini_".$identifier.".tsv.gz"; 

my %proteins;
my ($name, $sequence, $organism, $i, $total_pts) = ("","","",0,0);
########################################################################################################################################


# NCBI FASTA header:
#		>gi|168697872|ref|ZP_02730149.1| hypothetical protein GobsU_00010 [Gemmata obscuriglobus UQM 2246]
#
# UniProt FASTA header:
#		>sp|B2UQS2|ACP_AKKM8 Acyl carrier protein OS=Akkermansia muciniphila (strain ATCC BAA-835) GN=acpP PE=3 SV=1	
open (IN, "$input_file");

while (my $line = <IN>) {
	
	# NCBI like header	
	if ($line =~ /^>([^\s]+)\s+(.+)OS=(.+)\sGN=/) {		
		$i++;
		$name =$1;
		$proteins{$name}{"description"} = $2;
		$proteins{$name}{"organism"} = $3;
		$proteins{$name}{"order"}  = $i;
		$proteins{$name}{"sequence"} = '';
	
	# UniProt like header
	} elsif ($line =~ /^>([^\s]+)\s+(.+)\[(.+)\]/) {		
		$i++;
		$name =$1;
		$proteins{$name}{"description"} = $2;
		$proteins{$name}{"organism"} = $3;
		$proteins{$name}{"order"}  = $i;
		$proteins{$name}{"sequence"} = '';
	
	# Other header (not possible to extract info)	
	} elsif ($line =~ /^>(.+)/) {
		
		$i++;
		$name = $1;
		$proteins{$name}{"description"} = " - ";
		$proteins{$name}{"organism"} = "unknown organism";
		$proteins{$name}{"order"}  = $i;
		$proteins{$name}{"sequence"} = '';
		
		
	} elsif ($line =~ /^\w/) {
		
		$proteins{$name}{"sequence"} .= $line;
		chomp $proteins{$name}{"sequence"};
		$proteins{$name}{"length"} = length $proteins{$name}{"sequence"};
		
	}
}
close (IN);

	## Keep total number of proteins (for future use)
		$total_pts = $i; $i=0;



# CREATE OUTPUT FILE(s) 
open (OUT, " | gzip > $output_file") or die $!;	
	
## Print extracted info in an EXCEL-like table (columns separated by "tab").
print OUT "NAME / ID\tDescription\tOrganism\tProtein Length (aa)\n";
	
foreach my $name (sort {$proteins{$a}{"order"} <=> $proteins{$b}{"order"}} keys %proteins) {
	print OUT $name,"\t",$proteins{$name}{"description"},"\t",$proteins{$name}{"organism"},"\t",$proteins{$name}{"length"},"\n";#,$proteins{$name}{"sequence"},"\n";
}

close (OUT);

exit 7;
