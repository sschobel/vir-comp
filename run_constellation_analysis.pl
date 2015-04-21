#!/usr/bin/perl

###############################################################################
#                                                                             # 
#       Copyright (c) 2015 J. Craig Venter Institute.                         #     
#       All rights reserved.                                                  #
#                                                                             #
###############################################################################
#                                                                             #
#    This program is free software: you can redistribute it and/or modify     #
#    it under the terms of the GNU General Public License as published by     #
#    the Free Software Foundation, either version 3 of the License, or        #
#    (at your option) any later version.                                      #
#                                                                             #
#    This program is distributed in the hope that it will be useful,          #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
#    GNU General Public License for more details.                             #
#                                                                             #
#    You should have received a copy of the GNU General Public License        #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.    #
#                                                                             #
###############################################################################

###############################################################################

use strict;
use FindBin;
use Getopt::Std;
use vars qw($opt_l $opt_P);

getopts("l:sr:P");
my $usage = "usage: 
$0 
	-l <.MAP file>
	[-P (Amino Acid/Protein Flag)]

	Takes a list of DNA,RNA or, protein features, computes pairwise distance 
	and between each feature of a particualr category.  Next categories are 
	parsed into a matrix for each sample based on a specified percent identity 
	cutoff.
";

if(!defined($opt_l)){
	die $usage;
}

my $seg_file = $opt_l;
my $protein = $opt_P;
my $ext;

if ($protein) {
	$ext = "pep";
} else {
	$ext = "fasta";
}

open (IN, $seg_file) || die "cannot open feature list file '$seg_file'. $!\n";
my @segs;
my %order;
my $count;
while (<IN>) {
	chomp $_;
	my @line = split "\t", $_;
	push @segs, $line[0];
	$count ++;
	if ($line[1]) {
		$order{$line[1]} = $count;
	}
}

my @cutoffs = (.00001,.01,.02,.025,.05,.1);

my %EXECS = (
    CA2RD => "$FindBin::Bin/ANDES/ClustalALN_to_RDistanceMatrix.pl",
    PRD => "$FindBin::Bin/ANDES/Partition_Members_byDistanceMatrix.r",
    MAFFT => "/usr/local/bin/mafft",
    MERGE => "$FindBin::Bin/merge_constellations.pl",
    ANNOTATE => "$FindBin::Bin/annotate_constellations.pl",
    ANN_MAP => "$FindBin::Bin/annotate_constellation_map.pl",
);

foreach my $seg (@segs) {
    my $alnfile = "$seg.aln";
    my $fsafile = "$seg.$ext";
	my $rdfile = "$seg.r_distmat";

    unless (-e $alnfile) {    
        my $cmd = $EXECS{MAFFT} . " --clustalout $fsafile > $alnfile";
        print "$cmd\n";
        system $cmd;
    }
    
    unless (-e $rdfile) {
	    my $cmd = $EXECS{CA2RD} . " -a $alnfile";
    	print "$cmd\n";
    	system $cmd;
    }
}

foreach my $cut (@cutoffs) {
    my $dir = (1-$cut) * 100;
    mkdir $dir;
    chdir $dir;

    foreach my $seg (@segs) {
        my $rdfile = "$seg.r_distmat";
        my $mapfile = "$seg.map";
        
        system("cp ../$mapfile .");
        system("cp ../$rdfile .");
        system("cp ../$seg_file .");
        my $cmd = $EXECS{PRD} . " -d $rdfile -h $cut";
        print "$cmd\n";
        system $cmd;

    }
    
    my $con_file = "constellations_$dir.csv";
    my $cmd = $EXECS{MERGE} . " $seg_file $con_file";
    print "$cmd\n";
    system $cmd;

	mkdir "annotation";
	chdir "annotation";

	my $cmd = $EXECS{ANNOTATE} . " ../unique_constellations.list ../$con_file";
	print "$cmd\n";
	system $cmd;
	
	my $sorted_list = "$dir.sorted.list";
	system "cat constellatio*.list | sort -u > $sorted_list";
	
	my $con_map = "$dir.constellation.map";
	my $cmd = $EXECS{ANN_MAP} . " $sorted_list con_file.list > $con_map";
	print "$cmd\n";
	system $cmd;
	
    chdir "../../";
}

