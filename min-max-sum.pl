#!/usr/bin/perl
################################################################################
use strict;
use warnings;
use Data::Dumper qw(Dumper);

sub main
{
  ### HackerRank don't need us to output any prompt for user input!
  # print "please input values...\n";
  my $line = <STDIN>; $line =~ s/^\s+|\s+$//g;
  die "no input detect!" if (!defined $line or !length $line);
  my @numbers = split / /, $line;
  my @sortNumbers = sort @numbers;
  # print Dumper \@sortNumbers;
  # print Dumper [@sortNumbers[0..$#sortNumbers-1]];
  # print Dumper [@sortNumbers[1..$#sortNumbers]];
  my $minSum = 0; map { $minSum += $_ } (@sortNumbers[0..$#sortNumbers-1]);
  my $maxSum = 0; map { $maxSum += $_ } (@sortNumbers[1..$#sortNumbers]);
  print "$minSum $maxSum\n";
}

main();
