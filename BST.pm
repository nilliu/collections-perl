#!/usr/bin/perl
package BST;

use strict;
use warnings;

sub new {
  my $class = shift;
  my $self = {
    _value => shift,
    _left => undef,
    _right => undef,
  };
  bless $self, $class;
  return $self;
}

sub insert {
  my ($self, $value) = @_;
  if ($value <= $self->{_value}){
    if (!defined($self->{_left})){
      $self->{_left} = new BST($value);
    } else {
      $self->{_left}->insert($value);
    }
  } else {
    if (!defined($self->{_right})){
      $self->{_right} = new BST($value);
    } else {
      $self->{_right}->insert($value);
    }
  }
}

sub contains {
  my ($self, $value) = @_;
  print "=> $self->{_value} ";
  if ($value == $self->{_value}) {
    print " FOUND.\n";
    return 1;
  } elsif ($value < $self->{_value}) {
    if (!defined($self->{_left})) {
      print "=> $value NOT FOUND.\n";
      return 0;
    } else {
      return $self->{_left}->contains($value);
    }
  } elsif ($value > $self->{_value}) {
    if (!defined($self->{_right})) {
      print "=> $value NOT FOUND.\n";
      return 0;
    } else {
      return $self->{_right}->contains($value);
    }
  }
}

sub depthFirstTraversal { # default goes with 'in-order'
  my ($self, $order) = @_;
  $order = 'in-order' if (!defined($order));
  print "=> $self->{_value} " if ($order eq 'pre-order');
  $self->{_left}->depthFirstTraversal($order) if (defined($self->{_left}));
  print "=> $self->{_value} " if ($order eq 'in-order');
  $self->{_right}->depthFirstTraversal($order) if (defined($self->{_right}));
  print "=> $self->{_value} " if ($order eq 'post-order');
}

sub breadthFirstTraversal {
  my ($self) = my @queue = @_;
  while($#queue + 1) {
    my $node = shift @queue;
    print "=> $node->{_value} ";
    push @queue, $node->{_left} if (defined($node->{_left}));
    push @queue, $node->{_right} if (defined($node->{_right}));
  }
}

sub getMin {
  my ($self) = @_;
  if (defined($self->{_left})) {
    $self->{_left}->getMin();
  } else {
    return $self->{_value};
  }
}

sub getMax {
  my ($self) = @_;
  if (defined($self->{_right})) {
    $self->{_right}->getMax();
  } else {
    return $self->{_value};
  }
}

1;
