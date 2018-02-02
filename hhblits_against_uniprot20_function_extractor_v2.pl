#!/usr/bin/perl -w
#
# #1 for HHBLITS MODULE
# HHBlits' against UniProt20 function extractor from best hits.
#
# Version 1.0 (Jan 24 , 2018)
#
# Juan Carlos González Sánchez & Nicola Bordin
# Centro Andaluz de Biología del Desarrollo (CABD)
# Universidad Pablo de Olavide, Sevilla
#
# The script will take a "HHblits search against UniProt20 database" output/result file (usually .hhr)
# and extract, from the best hits, functional information for the query protein.
#
#
# Usage:
#	~$ perl this_script.pl HHblits_output_file.hhr output_name
#

use warnings;
#use strict;
use List::MoreUtils qw(uniq);
use IO::Compress::Gzip;

(scalar (@ARGV) == 2) or die "\nError: the script needs 2 arguments: \n\t - 1st: input file (usually .hhr) as parameter\n\t - 2nd: output file name\n";

# Variables
	my $input_file = $ARGV[0];
	my $output_file = "06_HHblits_annotation_$ARGV[1].tsv";

	# How many best hits we want to include in functional annotation
	my $n_best_hits = 3;

	# Cutoff for E-value above which best hits will not be taken
	my $evalue_cutoff = 0.001;

	# Auxiliar variables. Do not modify.
	my ($length,$coverage,$line,$annot,$any);
	my $i=0;
	my $hits = 0;
	my @hmm_cluster;
	my %cov;my %evals; my %probs;
	my ($prob,$eval,$hmm_id);

# We are gonna overwrite the output file each time we run the script to create the table.
# The first time, it will also print a header for each column

if ($input_file =~ /\.gz$/){
	open (IN, "gzip -dc $input_file |") or die "Error: could not open $input_file";
} else {
	open (IN, "$input_file") or die $!;
}

if (-e $output_file) {
	open (TABLE, ">>$output_file");
} else {
	open (TABLE, ">>$output_file");
	print TABLE "#Query\tHHblits vs Uniprot20 annotation\n";
}

while (<IN>) {

	last unless ($i < $n_best_hits);

	if ($_ =~ /^Query\s+([^\n]+)/) {
		print TABLE $1,"\t";
	} elsif ($_ =~ /^Match_columns\s+(\d+)/) {
		$length = $1;
		#print TABLE $length,"\t";
	}

	# Auxiliar variable $hits will be "1" when reading the hit list and "0" when not.
	if ($_ =~ /^\sNo\sHit/) {
		$hits = 1;
	} elsif ($_ =~ /^\sNo\s1/) {
		$hits = 0;
	}

	if (($hits == 1) && ($_ =~ /^\s*(\d+)\s(.{30})\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)/)){

		# $1 Number		# $5 P-value
		# $2 Hit		# $6 Score
		# $3 Prob		# $7 SS
		# $4 E-value		# $8 Cols

		$prob=$3;
		$eval=$4;
		$coverage = sprintf ("%.1f", $8*100/$length);
                $2 =~ /^([^\s]+)\s(.+)/; $hmm_id= $1;

		if ($eval < $evalue_cutoff) {	# if hit meets our requirements (number and e-value cutoff)...

			if (!defined $cov{$hmm_id}) {
				push (@hmm_cluster,$hmm_id);
				$cov{$hmm_id} = $coverage;
				$evals{$hmm_id}= $eval;
				$probs{$hmm_id}= $prob;
				$i++;
			}
		}
	}
}

my %covers; my %evals2; my %probs2;

close (IN);
$i=0;


if  (@hmm_cluster) {
	foreach my $hmm (@hmm_cluster) {

		# $hmm contains non-word characters that would cause problems in the next RE.
		# "quotemeta" function adds a backslash to all special characters in the string which will prevent this issue.
		my $quoted_hmm = quotemeta $hmm;

		last unless ($i < $n_best_hits);

		open (IN, "gzip -dc $input_file |") or die "Error: could not open $input_file";

		while (<IN>) {
			 if ($_ =~ /^>($quoted_hmm)\s([^\[]+)\[/) {
				$line = $2;

				if ($line =~ /(Uncharacterized|uncharacterized)/) {
					next;

				} else {
					my @values = split( /\sOX=\d+[\.\;]\s/ , $line);
					my @uniq= uniq(@values);
					foreach my $e(@uniq) {
						last unless ($i < $n_best_hits);

						if (exists $covers{$e}) {
							next;
						}else{
							$covers{$e}=$cov{$hmm};
							$evals2{$e}=$evals{$hmm};
							$probs2{$e}=$probs{$hmm};
							$i++;
						}

						next; # once we annotate a hit, we can go to the next one.
					}
				}
			 }
		}
		close (IN);
	}

}

$i=0;
foreach my $val( sort{$evals2{$b} <=> $evals2{$a} } keys%evals2 ){
	last unless ($i < $n_best_hits);

	$annot.= $val." [Cov=".$covers{$val}."\% Prob=".$probs2{$val}." Evalue=".$evals2{$val}."]; ";

	$i++;
}


if (! defined $annot) {
	$annot = "-";
}

print TABLE $annot,"\n";


close (TABLE);
