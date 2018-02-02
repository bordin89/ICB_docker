#!/usr/bin/perl -w
#
# #2 for HHBLITS MODULE
# HHBlits' against PDB function extractor from best hits.
#
# Version 1.0 (Jan 24, 2018)
#
# Juan Carlos González Sánchez & Nicola Bordin
# Centro Andaluz de Biología del Desarrollo (CABD)
# Universidad Pablo de Olavide, Sevilla
#
# The script will take a "HHblits search against PDB database" output/result file (fold assignment)
# and extract, from the best hits, functional information for the query protein.
#
#
# Usage:
#	~$ perl this_script.pl HHpred_output_file output_name
#


use warnings;
use strict;
use POSIX;
use IO::Compress::Gzip;

# 1 file as argument
(scalar (@ARGV) == 2) or die "\nError: the script needs 2 parameters\n";

# Define Variables
	my $input_file = $ARGV[0];
	my $output_file = "07_HHpred_annotation_$ARGV[1].tsv";
	my $n_hits = 3;
	# Do not modify
	my ($pdb_info, $query_name, $query_length) = file_hit_parser($input_file);
	my (%folds);


# We are gonna overwrite the output file each time we run the script to create the table.
# The first time, it will also print a header for each column
if (-e $output_file) {
	open (TABLE, ">>$output_file");
} else {
	open (TABLE, ">>$output_file");
	print TABLE "#Query\tHHpred (vs PDB)\n";
}

print TABLE $query_name,"\t";

my $x=0;my $string;
foreach my $key (sort {$$pdb_info{$a}{"hit_no"} <=> $$pdb_info{$b}{"hit_no"} } keys %$pdb_info) {

	last if ($x > $n_hits);
	if (defined $$pdb_info{$key}{"desc"}){
		$string .= $key." (".$$pdb_info{$key}{"inicio"}."-".$$pdb_info{$key}{"final"}.") ".$$pdb_info{$key}{"desc"}." [Prob=".$$pdb_info{$key}{"prob"}." Evalue=".$$pdb_info{$key}{"evalue"}."]; ";
#	} else {
#		print TABLE $key, " ERROR";
	}
	$x++;
}

if (!defined $string) {
	$string = "-";
}
print TABLE $string,"\n";

close (TABLE);


exit;
############################################ SUBROUTINES / FUNCTIONS ############################################

sub open_file {
	my $file = $_[0];
	open (IN, $file) or die "Error: could not open $file";
	my @file = <IN>;
	close (IN);
	return @file;
}

sub file_hit_parser {
	my %pdb_info;
	my ($query_name, $query_length) = ("","");
	my $hits = 3;
	open (IN,"gzip -dc $_[0] |") or die "Error: could not open $_";

	# Custom parameters
	my $evalue_cutoff = 0.01; # Only hits below this E-value cutoff will be taken
	my $prob_cutoff = 80;
	my $thereshold = 30; 		# Thereshold para los límites de los dominios

	while(my $line= <IN> ) {

		# Get protein NAME and LENGTH
		if ($line =~ /^Query\s+([^\n]+)/) {
			$query_name = $1;
		} elsif ($line =~ /^Match_columns\s+(\d+)/) {
			$query_length = $1;
		}

		# Auxiliar variable $hits will be "1" when reading the hit list and "0" when not.
		if ($line =~ /^\sNo\sHit/) {
			$hits = 1;
		} elsif ($line =~ /No\s1\s/) {
			$hits = 0;
		}

		# If reading hit list ($hits=1) and reading a hit-like line (matching the long ER expression). We can extract:
		if (($hits == 1) && ($line =~ /^\s*(\d+)\s([^\s]+)\s(.{23})\s+([\d]+\.[\d])\s+([^\s]+)\s+([^\s]+)\s+([\d]+\.[\d])\s+([\d]+\.[\d])\s+(\d+)\s+([\d]+)\-([\d]+)\s+([^\s]+)\s+([^\s]+)/)){
			# $1 No Hit
			# $2 PDB id
			# $3 description
			# $4 Prob
			# $5 E-value
			# $6 P-value
			# $7 Score
			# $8 SS
			# $9 Cols
			# $10 Query HMM inicio
			# $11 Query HMM final
			# $12 Template HMM
			if ($5 < $evalue_cutoff) { # and $4 > $prob_cutoff) {

				if (!exists $pdb_info{$2}) {
					$pdb_info{$2}{"hit_no"} = $1;
					$pdb_info{$2}{"prob"} 	= $4;
					$pdb_info{$2}{"evalue"} = $5;
					$pdb_info{$2}{"pvalue"} = $6;
					$pdb_info{$2}{"inicio"} = $10;
					$pdb_info{$2}{"final"}  = $11;
					$pdb_info{$2}{"cov"} = ($11-$10+1)/$query_length*100;
					$pdb_info{$2}{"fold"}   = 0;

				}
			}

		} elsif ($hits == 0 && $line =~ /^>([^\s]+)\s(.+);/ ) {
			if (exists $pdb_info{$1} and !exists $pdb_info{$1}{"desc"}) {
				$pdb_info{$1}{"desc"} = $2.";";
			}
		}
	}
#	print $query_name,"\t",$query_length,"\t";
#	foreach my $key (sort {$pdb_info{$a}{"hit_no"} <=> $pdb_info{$b}{"hit_no"} } keys %pdb_info) {
#		print $key, " (",$pdb_info{$key}{"inicio"},"-",$pdb_info{$key}{"final"},") ",$pdb_info{$key}{"desc"}," [Prob=",$pdb_info{$key}{"prob"}," Evalue=",$pdb_info{$key}{"evalue"},"]; ";
#	}

	return (\%pdb_info, $query_name, $query_length);

}
