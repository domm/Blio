#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;

use Blio::Node;

package Blio::TestNode;
use Moose;
has 'url' => (is=>'ro');

package main;

my %tests = (
    'phoon.html' => 'phoon.html',
    'phoon/index.html' => '../phoon/index.html',
    'SPITZ/SPOPPLE/SPATZ.html' => '../../SPITZ/SPOPPLE/SPATZ.html',
    'ZZT/CHOMP/index.html' => '../../ZZT/CHOMP/index.html',
    'ZZT/CHOMP.html' => '../ZZT/CHOMP.html',
    'ZZT/CHOMP/fowf.html' => '../../ZZT/CHOMP/fowf.html',

);
while (my ($url,$expect) = each %tests) {
    my $node = Blio::TestNode->new(url=>$url);
    bless $node, 'Blio::Node';
    is($node->relative_url,$expect,"$url => $expect");

}

done_testing();
