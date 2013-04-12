#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Path::Class;

use lib qw(t);
use testlib;

my $blio = testlib::blio('site1');

$blio->collect;

is(keys %{$blio->nodes_by_url},6,'6 nodes');
is(@{$blio->tree},3,'3 root nodes');

my $books = $blio->nodes_by_url->{'books.html'};
is($books->has_children,2,'books has 2 children');

done_testing();
