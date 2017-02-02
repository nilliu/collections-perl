#!/usr/bin/perl
use BST;

use strict;
use warnings;


my $bst = new BST(50);
$bst->insert(30);
$bst->insert(20);
$bst->insert(10);
$bst->insert(45);
$bst->insert(35);
$bst->insert(70);
$bst->insert(60);
$bst->insert(59);
$bst->insert(100);
$bst->insert(85);
$bst->insert(105);

print "test contains() ...\n";
$bst->contains(35);
$bst->contains(60);
$bst->contains(99);

print "test depthFirstTraversal() ...\n";
$bst->depthFirstTraversal('post-order');
print "\n";

print "test breadthFirstTraversal() ...\n";
$bst->breadthFirstTraversal();
print "\n";

print "test getMin() & getMax() ...\n";
print "MIN: " . $bst->getMin() . ", MAX: " . $bst->getMax() . " \n";
