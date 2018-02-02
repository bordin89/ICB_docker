#!/usr/bin/perl

# INTERPROSCAN RESULTS PARSER
# Interproscan to html table
use warnings;
use strict;
use IO::Compress::Gzip;

my $input_file	= $ARGV[0]; 
my $output_file = "05_InterPro_$ARGV[1]".".tsv";
$output_file =~ s/\.gz//;
my $i = 0;
my $query; my %annotation;

open (IN,"gzip -dc $input_file |") or die "\nCould not open $input_file\n";


while (<IN>) {
	if ( $_ =~ /\<xref desc=\"(.*)\" db=\"(.*)\" id=\"(.*)\" name=\"(.*)\"\/\>/) {
		$query = $3;
		$annotation{$query}{"order"} 		= $i;
		$annotation{$query}{"Pfam"} 		= "-";
		$annotation{$query}{"TIGRFAM"} 		= "-";
		$annotation{$query}{"Gene3D"} 		= "-";
		$annotation{$query}{"PANTHER"} 		= "-";
		$annotation{$query}{"ProSiteProfiles"} 	= "-";
		$annotation{$query}{"Hamap"} 		= "-";
		$annotation{$query}{"SUPERFAMILY"} 	= "-";
		$annotation{$query}{"PRINTS"} 		= "-";
		$annotation{$query}{"PIRSF"}		= "-";
		$annotation{$query}{"SMART"}		= "-";
		$annotation{$query}{"GO_BIO"}		= "-";
		$annotation{$query}{"GO_MOL"}		= "-";
		$annotation{$query}{"GO_CEL"}		= "-";
		$annotation{$query}{"IPRO"}		= "-";
		$annotation{$query}{"pathway"}		= "-";


		$i++;
		
	} elsif ( $_ =~ /\<signature ac=\"(PF.*)\" desc=\"(.*)\" name=\"(.*)\">/ ) {  				# Pfam 
			if ($annotation{$query}{"Pfam"} eq "-"){
				$annotation{$query}{"Pfam"} = "$1: $2";
		}else{
				$annotation{$query}{"Pfam"} .= "; $1: $2";
			} 
		
	} elsif ( $_ =~ /\<signature ac=\"(TIGR.*)\" desc=\"(.*)\" name=\"(.*)\">/ ) {				# TIGRFAM
		if ($annotation{$query}{"TIGRFAM"} eq "-"){
				$annotation{$query}{"TIGRFAM"} = "$1: $2";
		}else{
				$annotation{$query}{"TIGRFAM"} .= "; $1: $2";
			} 
	
	} elsif ( $_ =~ /\<signature ac=\"(G3DSA:.*)\">/ ) {   	  								# Gene3D
		if ($annotation{$query}{"Gene3D"} eq "-"){
				$annotation{$query}{"Gene3D"} = "$1";
			}else{
			$annotation{$query}{"Gene3D"} .= "; $1";
			} 

	} elsif ( $_ =~ /\<signature ac=\"(PTHR.*)\" name=\"(.*)\"\>/ ) {     						# PANTHER
		if ($annotation{$query}{"PANTHER"} eq "-"){
				$annotation{$query}{"PANTHER"} = "$1: $2";
		}else{
				$annotation{$query}{"PANTHER"} .= "; $1: $2";
			} 
			
	} elsif ( $_ =~ /\<signature ac=\"(PS.*)\" desc=\"(.*)\">/ ) {     						# ProSiteProfiles
		if ($annotation{$query}{"ProSiteProfiles"} eq "-"){
				$annotation{$query}{"ProSiteProfiles"} = "$1: $2";
		}else{
				$annotation{$query}{"ProSiteProfiles"} .= "; $1: $2";
			} 
				
	} elsif ( $_ =~ /\<signature ac=\"(MF.*)\" desc=\"(.*)\" name=\"(.*)\">/ ) {				# Hamap
		if ($annotation{$query}{"Hamap"} eq "-"){
				$annotation{$query}{"Hamap"} = "$1: $2";
		}else{
				$annotation{$query}{"Hamap"} .= "; $1: $2";
			} 
		
	} elsif ( $_ =~ /\<signature ac=\"(SSF.*)\" name=\"(.*)\">/ ) { 							# SUPERFAMILY
		if ($annotation{$query}{"SUPERFAMILY"} eq "-"){
				$annotation{$query}{"SUPERFAMILY"} = "$1: $2";
			}else{
				$annotation{$query}{"SUPERFAMILY"} .= "; $1: $2";
			} 
			
	} elsif ( $_ =~ /\<signature ac=\"(PR.*)\" desc=\"(.*)\" name=\"(.*)\"\>/ ) {
		if ($annotation{$query}{"PRINTS"} eq "-"){
				$annotation{$query}{"PRINTS"} = "$1: $2";
		}else{
				$annotation{$query}{"PRINTS"} .= "; $1: $2";
			} 

	} elsif ( $_ =~ /\<signature ac=\"(PIRSF.*)\" name=\"(.*)\">/ ) {
		if ($annotation{$query}{"PIRSF"} eq "-"){
				$annotation{$query}{"PIRSF"} = "$1: $2";
		}else{
				$annotation{$query}{"PIRSF"} .= "; $1: $2";
			} 

	} elsif ( $_ =~ /\<signature ac=\"(SM.*)\" desc=\"(.*)\" name=\"(.*)\"\>/ ) {
		if ($annotation{$query}{"SMART"} eq "-"){
				$annotation{$query}{"SMART"} = "$1: $2";
		}else{
				$annotation{$query}{"SMART"} .= "; $1: $2";
			}
			
	} elsif ( $_ =~ /\<go-xref category="BIOLOGICAL_PROCESS" db="GO" id="(GO:.*)" name="(.*)"\/>/ ) {
		if ($annotation{$query}{"GO_BIO"} eq "-"){
				$annotation{$query}{"GO_BIO"} = "$1: $2";
		}else{
				$annotation{$query}{"GO_BIO"} .= "; $1: $2";
			} 
			
	} elsif ( $_ =~ /\<go-xref category="MOLECULAR_FUNCTION" db="GO" id="(GO:.*)" name="(.*)"\/>/ ) {
		if ($annotation{$query}{"GO_MOL"} eq "-"){
				$annotation{$query}{"GO_MOL"} = "$1: $2";
		}else{
				$annotation{$query}{"GO_MOL"} .= "; $1: $2";
			} 

	} elsif ( $_ =~ /\<go-xref category="CELLULAR_COMPONENT" db="GO" id="(GO:.*)" name="(.*)"\/>/ ) {
		if ($annotation{$query}{"GO_CEL"} eq "-"){
				$annotation{$query}{"GO_CEL"} = "$1: $2";
		}else{
				$annotation{$query}{"GO_CEL"} .= "; $1: $2";
			} 

	} elsif ( $_ =~ /\<pathway-xref db="(.*)" id="(.*)" name="(.*)"\/>/ ) {
		if ($annotation{$query}{"pathway"} eq "-"){
				$annotation{$query}{"pathway"} = "$1-$2: $3";
		} elsif ($annotation{$query}{"pathway"} =~ /$2/) {
			next;
		}else{
				$annotation{$query}{"pathway"} .= "; $1-$2: $3";
			} 



	} elsif ( $_ =~ /\<entry ac="(IP.*)" desc="(.*)" name="(.*)" type="(.*)">/ ) {
		if ($annotation{$query}{"IPRO"} eq "-"){
				$annotation{$query}{"IPRO"} = "$1: $2";
		} elsif ($annotation{$query}{"IPRO"} =~ /$1/) {
			next;
		}else{
				$annotation{$query}{"IPRO"} .= "; $1: $2";
			} 

	} elsif ( $_ =~ /\<\/protein\-matches\>/ ) {
	
	}
}
close (IN);

open (OUT, ">$output_file") or die "\nCould not open $output_file\n";
print OUT "Query\tInterPro Entry\tInterPro: pathways\tInterPro: GO terms - Molecular Function\tInterPro: GO terms - Biological Proccess\tInterPro: GO terms - Cellular Component\t";
print OUT "InterPro: Pfam\tInterPro: TIGRFAM\tInterPro: PANTHER\tInterPro: ProSiteProfiles\tInterPro: Hamap\t";
print OUT "InterPro: PIRSF\tInterPro: Gene3D\tInterPro: SUPERFAMILY\tInterPro: PRINTS\tInterPro: SMART\n";

foreach my $query (sort {$annotation{$a}{"order"} <=> $annotation{$b}{"order"}} keys %annotation ) {
	print OUT $query,"\t",$annotation{$query}{"IPRO"},"\t",$annotation{$query}{"pathway"},"\t",$annotation{$query}{"GO_MOL"},"\t",$annotation{$query}{"GO_BIO"},"\t",$annotation{$query}{"GO_CEL"},"\t";
	print OUT $annotation{$query}{"Pfam"},"\t",$annotation{$query}{"TIGRFAM"},"\t",$annotation{$query}{"PANTHER"},"\t";
	print OUT $annotation{$query}{"ProSiteProfiles"},"\t",$annotation{$query}{"Hamap"},"\t",$annotation{$query}{"PIRSF"},"\t";
	print OUT $annotation{$query}{"Gene3D"},"\t",$annotation{$query}{"SUPERFAMILY"},"\t",$annotation{$query}{"PRINTS"},"\t";
	print OUT $annotation{$query}{"SMART"},"\n";
}

close (OUT);

#system ("perl /home/JC/Pipeline/make_table_scripts/order_entries.pl $output_file 00_*");
#system ("gzip $output_file");

exit 1; 
