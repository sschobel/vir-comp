#!/usr/local/bin/perl

use strict;

my $seg_file = $ARGV[0];
my $con_file = $ARGV[1];

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

my %cons;

foreach my $seg (@segs) {
    my $group_file = $seg . ".r_distmat.groups";
    my $map_file = $seg . ".map";
    
    open (GF, $group_file) || die "Cannot open $group_file. $!\n";
    my %group_map;
    my $gc;
    my %seg_g;
    while (<GF>) {
        chomp $_;
        my @line = split /\t/, $_;
        unless ($seg_g{$line[0]}) {
            $gc ++;
            $seg_g{$line[0]} = $gc;
        }
        $group_map{$line[1]} = $seg_g{$line[0]};
    }
    close GF;
    open (MAP, $map_file) || die "Cannot open $map_file. $!\n";
    while (<MAP>) {
        chomp $_;
        my @line = split /\t/, $_;
        if ($group_map{$line[0]}) {
            my $strain = $line[1];
            $strain =~ s/mixed_.*/mixed/;
            push @{$cons{$strain}->{$seg}}, $group_map{$line[0]};
            @{$cons{$strain}->{$seg}} = sort(@{$cons{$strain}->{$seg}})
        }
    }
    close MAP;
}

my $errfile = "merge_constellations.err";
open (ERR, ">$errfile") || die "cannot open $errfile. $!\n";
open (CONOUT, ">$con_file") || die "cannot open $con_file. $!\n";
my $header = join "\t", @segs;
my %con_counts;
foreach my $strain (keys %cons) {
    my @formated_segs;
    foreach my $seg (@segs) {
        my $txt;
        if (!$cons{$strain}->{$seg}) {
            print ERR "ERR: $strain, $seg\n";
            $txt = "99";
        } else {
            $txt = join ",", @{$cons{$strain}->{$seg}};
        }
 		push @formated_segs, $txt;
    }
    my $string = join ";", @formated_segs;
    print CONOUT "$strain;$string\n";
}
close ERR;
close CONFILE;

my $sort_string = &write_sort_cmd_order_string(\%order);
my $sort_cmd = "sort -t ';' $sort_string $con_file | sed 's/;/\t/g' > tmp";
print "$sort_cmd\n";
system $sort_cmd;
system "mv tmp $con_file";

open (SORTED, $con_file) || die "cannot open $con_file. $!\n";
my @sort_order;
while (<SORTED>) {
	chomp $_;
	my @line = split "\t", $_;
	shift @line;
	my $text = join ("\t", @line);
	unless ($con_counts{$text}) {
		push @sort_order, $text;
	}
	$con_counts{$text} ++;
}
close SORTED;

my $uniq = "unique_constellations.list";
my $con_counts_file = "constellation_counts.csv";
open (CON, ">$con_counts_file") || die "cannot open $con_counts_file. $!\n";
open (UNIQ, ">$uniq") || die "cannot open $uniq. $!\n";
my $count;
foreach my $constellation (@sort_order) {
	$count++;
	print UNIQ "$constellation\n";
	print CON "constellation_$count:$con_counts{$constellation}\t$constellation\n";
}
close UNIQ;
close CON;

unless (-s $errfile) {
    unlink $errfile;
}

sub write_sort_cmd_order_string {
	my $order = shift;
	my $order_txt;
	foreach my $seg (sort {$a <=> $b} keys %$order) {
		my $num = $$order{$seg} + 1;
		$order_txt .= "-k$num,${num}n ";
	}
	return $order_txt;
}