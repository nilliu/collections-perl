#!/usr/bin/perl

use strict;
use warnings;
# use Data::Dumper qw(Dumper);

my %hotels, my %scores;

sub byScoreDescending {
  $scores{$b} <=> $scores {$a};
}

my $keywords = <STDIN>; chomp $keywords;
$keywords =~ s/\s+/|/g;

my $m = <STDIN>; chomp $m;
for my $a0 (0..$m-1){
  my $id = <STDIN>; chomp $id;
  my $line = <STDIN>; chomp $line;
  push @{$hotels{$id}{'reviews'}}, $line;
};
# print Dumper \%hotels;

for my $h (keys %hotels){
  my $score = 0;
  for my $review (@{$hotels{$h}{'reviews'}}) {
    my $count = () = ($review =~ /$keywords/g);
    # print "hotel-$h: [$review] found $count of [$keywords] \n";
    $score += $count;
  }
  $scores{$h} = $score;
}
# print Dumper \%scores;
foreach my $k (sort byScoreDescending (keys %scores)){
  print "$k\n";
}
