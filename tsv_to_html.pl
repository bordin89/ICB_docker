#usr/bin/perl

# Creates a HTML table from a TSV file

use warnings;
use strict;

my $tsv_input 	= $ARGV[0]."_table.tsv";
my $html_output = $ARGV[0]."_table.html";
my $fasta 	= $ARGV[0]."_proteins.fa";
my $table_name 	= $ARGV[0]; $table_name =~ s/\_/ /g;

#print "$tsv_input\n";##
#print "$html_output\n";
#print "$fasta\n"; ##
#print "$table_name\n"; ##


my @column_names;
my $i=0;

open (TSV, $tsv_input) or die $!;
while(<TSV>){}; seek TSV,0,0;
my $proteins = $. - 1;


open (STDOUT, ">$html_output") or die $!;


print <<END;
<html>

<head>
	<script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.16/css/jquery.dataTables.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.3/css/fixedHeader.dataTables.min.css"/>

<script type="text/javascript" src="https://cdn.datatables.net/1.10.16/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/fixedheader/3.1.3/js/dataTables.fixedHeader.min.js"></script>

	<script>
	var myVar;

	function myFunction() {
	    myVar = setTimeout(showPage, 1500);
	}

	function showPage() {
	  document.getElementById("loader").style.display = "none";
	  document.getElementById("myDiv").style.display = "block";
	  \$('#table1').DataTable().fixedHeader.adjust();
	}

	</script>


	<script>
        function getQueryParams(qs) {
                qs = qs.split('+').join(' ');
                var params =    {},
                                tokens,
                                re = /[?&]?([^=]+)=([^&]*)/g;

                while (tokens = re.exec(qs)) {
                        params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
                }

                return params;
        }


        \$(document).ready(function (){
        var query = getQueryParams(document.location.search);
        var table = \$('#table1').DataTable({
	"fixedHeader": {
		header: true,
		footer: true
			},
search: {
                                                         search: query.filterfiltre,
							 "caseInsensitive": false
       }
    });

	\$('#table1').show();
	table.fixedHeader.adjust();
});
table.fixedHeader.adjust()
</script>
<style>
/* Center the loader */
\#loader {
  position: absolute;
  left: 50%;
  top: 50%;
  z-index: 1;
  width: 150px;
  height: 150px;
  margin: -75px 0 0 -75px;
  border: 16px solid #f3f3f2;
  border-radius: 50%;
  border-top: 16px solid #3298db;
  width: 120px;
  height: 120px;
  -webkit-animation: spin 2s linear infinite;
  animation: spin 2s linear infinite;
}

\@-webkit-keyframes spin {
  0% { -webkit-transform: rotate(0deg); }
  100% { -webkit-transform: rotate(360deg); }
}

\@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Add animation to "page content" */
.animate-bottom {
  position: relative;
  -webkit-animation-name: animatebottom;
  -webkit-animation-duration: 1s;
  animation-name: animatebottom;
  animation-duration: 1s
}

\@-webkit-keyframes animatebottom {
  from { bottom:-100px; opacity:0 }
  to { bottom:0px; opacity:1 }
}

\@keyframes animatebottom {
  from{ bottom:-100px; opacity:0 }
  to{ bottom:0; opacity:1 }
}

\#myDiv {
  display: none;
  text-align: center;
}

\#mydiv2 {
	background-image: url("logo.jpg");
	text-align:left
}
\#column-content {
  display: inline-block;
}
img {
  vertical-align: middle;
}
span {
  display: inline-block;
  vertical-align: middle;
  line-height: 85px;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
	font-size: 24px;
	font-style: normal;
	font-variant: normal;
	font-weight: 500;
  padding-left: 40px;
}

body {
	font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
        font-style: normal;
        font-variant: normal;
}

/* for visual purposes */
\#column-content {
  border: 1px solid red;
  position: relative;
}
</style>
</head>
<h1><span> $table_name proteome annotation</span></h1>
<body onload="myFunction()" style="margin:0;">

<div id="loader"></div>
<div style="display:none;" id="myDiv" class="animate-bottom">
<table id="table1" width="100%" class="table table-condensed stripe display compact cell-border" ;>
<thead>
END
#chomp ($_ = <STDIN>);
#s?\t?</th><th>?g;


# Read input TSV file and print content in rows
while (my $line = <TSV>) {
	$i++;

	# Print column names  ~ parses them from the file 1st row.
	if ($i == 1) {
		@column_names = split ('\t', $line);
		print "<tr>\n";
		foreach my $name (@column_names) {

			# Setting specific witdths
#			if ($name =~ /Protein Length/) { print "<th id=\"length\">";}

#			else {

			print "<th>";
			print "$name</th>\n";
		}
		print "</tr>\n</thead>\n<tbody>\n";

	} else {
		print "<tr>\n";
		my @fields = split('\t', $line);

		for my $cell(@fields) {

	
	#		if($cell =~ /^(\d|\s)+$/) {
	#			print "<td align=\"right\">$cell</td>";
	#		} else {
				print "<td>$cell</td>";
	#		}
		}
		print "</tr>\n";
	}
}

print <<END
</tr>

</table>
</tbody>
<script>
\$(document).ready( function () {
    \$(\'#table1\').DataTable();
} );
</script>
</html>
END
