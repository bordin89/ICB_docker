#!/usr/bin/perl -w
#
# Juan Carlos Gonzalez Sanchez & Nicola Bordin
#
## Usage:
##       ~$ perl <this_script.pl> <fasta_file> <psiblast_output>


use strict;
use warnings;
use Cwd;
use Compress::Raw::Zlib;
use IO::Compress::Gzip;

# DEFINE VARIABLES ######################################################################################
my $fasta_file          		= $ARGV[0];
my $psiblast_output     		= $ARGV[1];
my $database 				= $ARGV[2];#"/home/db/Uniprot/UniProt_SwissProt_text/reduced_uniprot_sprot.dat";
my $output_file				= "01_PSIBLAST_".$ARGV[3].".tsv";

my $evalue_cutoff 			= 0.001; 	# Cutoff for E-value above which subjects will be discarded
my $coverage_cutoff 			= 0.75; 	# Cutoff for Coverage
my $subjects_to_include 		= 1; 		# Number of subjects to include in final annotation


###########################################################################################################

##  GET QUERY PROTEINS LENGTH (from file containing the sequences in FASTA)
# As the lengths are not printed in the tabular output PSIBLAST format, this step is necessary if we wanna calculate the coverage
my (	$name,
	$source,
	%protein_sequence,
	%protein_length);

my ($total_pts,	# for total of proteins
 			# for "hypothetical proteins"
	$hyp_per,		# and %
	$anno,			# for annotated proteins (all but "hypothetical" ones)
	$anno_per,
	$put,			# for "putative proteins"
	$put_per,		# and %
	$pred,			# for "predicted proteins"
	$pred_per,		# and %
	$like,			# for "-like proteins"
	$like_per,		# and %
	) = (0,0,0,0,0,0,0,0,0,0);
my %hyp;

open (IN, "$fasta_file") or die $!;

while (<IN>) {

    # NCBI like header
	if ($_ =~ /^>.*ref\|(.+)\|/ or $_ =~ /^>.*gi\|(.+)\|/ ){
		$name =$1;
	#	print $name,"\n";
		$source="NCBI";

		$total_pts++;
		if ($_ =~ /hypothetical protein/ or $_ =~ /unknown/ ) {
			$hyp{$name}++;
		}
		 elsif ($_ =~ /putative/) {
			$put++;
		}
		elsif ($_ =~ /predicted/) {
			$pred++;
		}
		elsif ($_ =~ /-like/) {
			$like++;
		}


	# UniProt like header
    } elsif ($_ =~ /^>.+\|([^\s]+)\|/) {
		$name =$1;

		$source="UniProt";

		$total_pts++;
		if ($_ =~ /[Uu]ncharacterized.*protein/ ) {
			$hyp{$name}++;
		}

    # Other
	} elsif ($_ =~ /^>(.+)/) {
		$name = $1;
		$total_pts++;

    # Sequence
	} elsif ($_ =~ /^\w/) {
        $protein_sequence{$name} .= $_;
        chomp $protein_sequence{$name};
        $protein_length{$name} = length $protein_sequence{$name};
    }
}
close (IN);
undef $name;undef %protein_sequence;

$hyp_per = sprintf ("%.1f", (scalar keys %hyp)*100/$total_pts);
$anno = $total_pts - (scalar keys %hyp);
$anno_per = 100 - $hyp_per;


# PARSE BLAST RESULTS
## We are going to keep PSI-BLAST results corresponding to the last BLAST iteration performed for each protein.
### First, we go over the whole file, linking proteins with the last iteration number.
my ($iteration,
	$query,
	%last_iteration);


open (IN2,"gzip -dcf  $psiblast_output |") or die $!;

while (<IN2>){

	if ($_ =~ /^\# Iteration:\s(\d)/) {
		$iteration = $1;

	} elsif ($_ =~ /^\# Query.*ref\|(.+)\|/ or $_ =~ /^\# Query.*gi\|(.+)\|/ or $_ =~ /^\# Query.+\|([^\s]+)\|/ or $_ =~ /^\# Query(.+)/) {
		$query = $1;
		$last_iteration{$query}=$iteration;
	}
	}

close (IN2);
undef $_ for $iteration, $query;


### Go over the file again. Now directly extract info from subjects in the last iteration.
my ($i,
	$query_length,
	%query_order,
	@values,
	$evalue,
	%all_subj,
	$identity,
	$coverage_query,
	$subject,
	%subject_order,
	%subject_coor,
	%coverages,
	%evalues);
my $n=0;

open (IN2,"gzip -dcf  $psiblast_output |") or die $!;
while (<IN2>){

	if ($_ =~ /^\# PSIBLAST/) {
		undef $iteration;
		$query = "";
		$i = 0;

	} elsif ($_ =~ /^\# Iteration:\s(\d)/) {
		$iteration = $1;

	} elsif ($_ =~ /^\# Query.*ref\|(.+)\|/ or $_ =~ /^\# Query.*gi\|(.+)\|/ or $_ =~ /^\# Query.+\|([^\s]+)\|/ or $_ =~ /^\# Query(.+)/){
		$query = $1;
		$query_length = $protein_length{$query};

		next if exists $query_order{$query};
		if ($iteration == $last_iteration{$query}) {
			$n++;
			$query_order{$query}=$n;
		}
	}

 	next unless (defined $iteration && defined $query_order{$query});
 	next if ($_ =~ /^\#/);

	### MODIFIY!!
 	#next if ($i >= $subjects_to_include); # IMPORTANT: this makes that we just keep the number of subjects we choose.

	# [0]query_id  [1]subject_id [2]identity [3]alignment_length [4]mismatches [5]gap opens [6]q.start [7]q.end [8]s.start [9]s.end [10]evalue [11]bit score
	@values = split("\t",$_); next if (scalar @values < 12);

	# RESTRICTIONS TO INCLUDE subjectS
	#1 EVALUE
	$evalue = $values[10];
	next unless ($evalue < $evalue_cutoff);

 	#2 COVERAGE
 	$coverage_query = sprintf ("%.3f", (($values[7]-$values[6]+1)/$query_length)); # This checks the coverage of the alignment respect the whole query sequence legth
	next unless ($coverage_query >= $coverage_cutoff) ;

	$values[1] =~ /\w+\|\d+\|\w+\|([^\.]+)\.\d\|.+/; $subject = $1;
	next if (exists $subject_order{$query}{$subject});
	next if ($query eq $subject);

	$all_subj{$subject}=1;
	$subject_order{$query}{$subject} = $i;
	$i++;

	$coverages{$query}{$subject} = $coverage_query*100;	# To print later
	$evalues{$query}{$subject} = $evalue;		# To print later
	$subject_coor{$query}{$subject} = $values[9] - $values[8]; # To calculate subject coverage later (should be also above the thereshold)
}

close (IN2);
undef $_ for $query,$query_length,$subject,$evalue,$coverage_query,@values;


## Annotate subject list and print it in a temporal file
my ($annot_prots_count,
	$unknown_and_annotated,
#	$subject_length,
	$ac_found,
	%annotation_subject,
	$coverage_subject,
	%hit);

my ($length,@acs,%subject_length,%subject_gene,%subject_desc,%subject_dr,%subject_kw,%subject_ec);
my ($gene,$desc,$dr,$kw,$ec,$info) = ("-","-","-","-","-","");

open (DATABASE, "$database") or die $!;
while (<DATABASE>) {

	if ($_ =~ /^ID\s+([^\s]+).+;\s+(\d+)\sAA.$/) {
		$length = $2;
		$gene="-";
		$desc="-";
		$ec="-";
		$dr="-";
		$kw="-";
		@acs=();

	} elsif ($_ =~ /^AC\s+(.+)/) {
		@acs = split(";",$1);

	} elsif ($_ =~ /^DE / and $desc eq "-") {
		$_ =~ /=(.+?)[;\{]/;
		$desc = $1;

	} elsif ($_ =~ /^DE\s+EC=(.+?)[\s;]/){
		$ec = "EC=".$1;

	} elsif ($_ =~ /^GN/ and $gene eq "-") {
		$_ =~ /=(.+?)[;\{,]/;
		$gene = $1;

	} elsif ($_ =~ /^DR\s+(.+)\n/) {
		$info=$1;
		$info =~ s/GO;\s//;
		if ($dr eq "-"){
			$dr = $info;
		}else{
			$dr .= $info;
		}

	} elsif ($_ =~ /^KW\s+(.+)\n/) {
		if ($kw eq "-"){
			$kw = $1;
		}else{
			$kw .= $1;
		}

	} elsif ($_ =~ /^\/\//) {
		foreach my $ac(@acs) {
			$ac =~ s/\s//;
			if ( exists $all_subj{$ac}) {
				$subject_length{$ac}=$length;
				$subject_gene{$ac}=$gene;
				$subject_desc{$ac}=$desc;
				$subject_dr{$ac}=$dr;
				$subject_kw{$ac}=$kw;
				$subject_ec{$ac}=$ec;
			}
		}
	}
}
close (DATABASE);

my $to_print;
open (OUT, ">$output_file");
print OUT "Query\tBest PSIBLAST Hit: Uniprot Accession [+stats]\tBest PSIBLAST Hit: Gene\tBest PSIBLAST Hit: Description\tBest PSIBLAST Hit: GO terms\tBest PSIBLAST Hit: Keywords\tBest PSIBLAST Hit: EC number\n";

foreach my $query (sort {$query_order{$a} <=> $query_order{$b}} keys %query_order) {

	print OUT $query,"\t";
	$to_print="-\t-\t-\t-\t-\t-";

	foreach my $subject(sort {$subject_order{$query}{$a} <=> $subject_order{$query}{$b}} keys %{$subject_order{$query}}) {

		last if (exists $hit{$query});

		if (exists $subject_length{$subject}){
			$coverage_subject = sprintf ("%.3f", ($subject_coor{$query}{$subject}/$subject_length{$subject}));
		} else {
			$coverage_subject=0;
			}

		if ($coverage_subject >= $coverage_cutoff) {
			$to_print = $subject." [Cov=".$coverages{$query}{$subject}."\% Evalue=".$evalues{$query}{$subject}."]\t".$subject_gene{$subject}."\t".$subject_desc{$subject}."\t".$subject_dr{$subject}."\t".$subject_kw{$subject};
			$to_print.= "\t".$subject_ec{$subject};
			$hit{$query}=$subject;
			$annot_prots_count++;
			if (exists $hyp{$query}) {$unknown_and_annotated++;}
			last;
		}
		undef $coverage_subject;
	}
	print OUT $to_print."\n";
}


exit 1;
