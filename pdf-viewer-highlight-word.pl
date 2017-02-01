#!/usr/bin/perl
use strict;
use warnings;
#use Data::Dumper qw(Dumper);
use constant WORDWIDTH => 1;

my $h_temp = <STDIN>; $h_temp =~ s/^\s+|\s+$//g;
my @h = split / /, $h_temp; chomp @h;
my $word = <STDIN>; chomp $word;
my @wh = ();
map { push @wh, $h[ord(lc($_))-ord('a')] } split //, $word;
@wh = sort @wh;
#print Dumper \@wh;

#print '-' x 10 . "\n";
#print '' . length($word) .' x '. WORDWIDTH . ' x ' . $wh[-1] . "\n";
print length($word) * WORDWIDTH * $wh[-1] . "\n";
