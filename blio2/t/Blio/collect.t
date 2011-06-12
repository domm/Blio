#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Path::Class;
use Blio;

my $blio = Blio->new(source_dir=>Path::Class::dir(qw(. t testdata site1)));
$blio->collect;

is(keys %{$blio->nodes_by_url},5,'5 nodes');
is(@{$blio->tree},3,'3 root nodes');

my $books = $blio->nodes_by_url->{'books/index.html'};
is($books->has_children,2,'books has 2 children');


done_testing();
