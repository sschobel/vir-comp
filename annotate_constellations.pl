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