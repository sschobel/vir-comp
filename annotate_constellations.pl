#!/usr/bin/perl

use strict;

my $file = $ARGV[0];
my $con_file = $ARGV[1];

open (IN, $file) || die "Cannot open $file. $!\n";

my @grep_list;
while (<IN>) {
	chomp $_;
	push @grep_list, $_;
}
my $count = 1;
foreach my $con (@grep_list) {
	my $file_name = "constellation_$count.list";
	system "echo $file_name >> con_file.list";
	my $cmd = "grep \"$con\" $con_file | awk '{print \$1}' > $file_name";
	print "$cmd\n";
	system($cmd);
	$count ++;
}