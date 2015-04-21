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