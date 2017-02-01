#!/usr/bin/perl
use strict;
use warnings;

my $t = <STDIN>; chomp $t;
for my $a0 (0..$t-1){
    my $n_temp = <STDIN>;
    my @n_arr = split / /, $n_temp;
    my $n = $n_arr[0]; chomp $n;
    my $k = $n_arr[1]; chomp $k;
    my $a_temp = <STDIN>;
    my @a = split / /,$a_temp; chomp @a;
    my $c = 0; map { $c++ if $_ <= 0 } @a;
    print ''.(($c < $k)?'YES':'NO')."\n";
}
