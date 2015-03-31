#!/usr/local/bin/perl

use strict;
use FindBin;

my $seg_file = $ARGV[0];
my $protein = $ARGV[1];
my $ext;

if ($protein) {
	$ext = "pep";
} else {
	$ext = "fasta";
}

open (IN, $seg_file) || die "cannot open $seg_file. $!\n";
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

