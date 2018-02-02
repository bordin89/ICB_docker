#!/usr/bin/perl

# ENTRY ORGANISER
# Orders the entries according to another file


# perl entry_order.pl file_to_order.tsv 00_ini_file.tsv.gz

use warnings;
#use strict;
use IO::Compress::Gzip;

(scalar (@ARGV) == 2) or die "\nError: the script needs 2 parameters\n";

my $input = $ARGV[0];
my $order = $ARGV[1];
my $output = "temp.txt";
my $header; my $pt;
my %data;my %found;


my $i=0;
open (IN, $input);
while (<IN>){
	if ($i == 0) {
		$header = $_;
	}elsif ($_ =~ /^([^\s]+)/) {
		$data{$1}=$_;
		$found{$1}=0;
	}
	$i++;
}
$i=0;
close (IN);


open (OUT, ">$output");
print OUT $header;

my $flag;
open (IN2,"gzip -dcf $order |");
while (<IN2>){
	if ($i ==0){
		$i++;
		next;

	} elsif ($_ =~ /^([^\s]+)/){
		$pt = $1;
		$flag=0;

		foreach my $query(keys %data){

			if ( index($pt, $query) != -1 ) {
				$flag++;
				$found{$query}++;
				print OUT $data{$query};
			}
		}
		# if (!$flag==1){
		# 	print "Error in: ",$pt,"\n";
		# }
	}
	$i++;
}	
close (IN2);
close (OUT);

rename $output, $input;


