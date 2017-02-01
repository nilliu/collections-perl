#!/usr/bin/perl
use strict;
use warnings;

sub spring {
  return $_[0]*=2;
}
sub summer {
  return $_[0]++;
}

my $t = <STDIN>;
chomp $t; 
for my $a0 (0..$t-1){
    my $n = <STDIN>; chomp $n;
    my $h = 1; # initialize height
    for my $cycle (1..$n){
      if ($cycle % 2) {
        spring $h;
      } else {
        summer $h;
      }
    }
    print $h."\n";
}
