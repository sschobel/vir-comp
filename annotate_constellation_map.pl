#!/usr/local/bin/perl

use strict;

my $file = $ARGV[0];
my $con_list = $ARGV[1];
my %con_map;

open (IN, $con_list) || die "Cannot open $con_list. $!\n";

while (<IN>) {
	chomp $_;
	my $con_file = $_;
	my $con_num = $con_file;
	$con_num =~ s/constellation_//;
	$con_num =~ s/.list//;
	
	open (FILE, $con_file) || die "Cannot open $con_file. $!\n";
	while (<FILE>) {
		chomp $_;
		$con_map{$_} = $con_num;
	}
	close FILE;
}
close IN;

open (LIST, $file) || die "Cannot open $file. $!\n";
while (<LIST>) {
	chomp $_;
	print "$_\t$con_map{$_}\n";
}