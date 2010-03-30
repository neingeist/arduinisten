#!/usr/bin/perl
use strict;

my @lines = <>;


# P1
# # CREATOR: GIMP PNM Filter Version 1.1
# 5 8
# 1000101010101011111101110100011000101010

$lines[0] eq "P1\n" or die "First line should read 'P1' for Plain PBM";

for (my $line=0; $line <= $#lines; 
