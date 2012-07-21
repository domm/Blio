#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use utf8;

use Test::Most;
use Path::Class;
use Blio::Node;
use Encode;

use lib qw(t);
use testlib;

my $blio = testlib::blio('site1',tags=>1);
my $base = $blio->source_dir;

{
    my $node = Blio::Node->new_from_file($blio, file(qw(. t testdata site1 books un_lun_dun.txt)));
    is(scalar @{$node->tags},2,'2 tags');

    my $tagindex = $blio->tagindex;
    is($tagindex->has_children,2,'2 tags beneath tagindex');

    my $tag_london = $blio->nodes_by_url->{'tags/london.html'};
    is($tag_london->has_children,1,'1 node linked with tag "london"');
    is($tag_london->children->[0]->url,$node->url,'correct node linked');
}

{
    my $node = Blio::Node->new_from_file($blio, file(qw(. t testdata site1 books artemis_fowl.txt)));
    is(scalar @{$node->tags},2,'2 tags');

    my $tagindex = $blio->tagindex;
    is($tagindex->has_children,3,'3 tags beneath tagindex');

    my $tag_fairy = $blio->nodes_by_url->{'tags/fairy.html'};
    is($tag_fairy->has_children,1,'1 node linked with tag "fairy"');
    is($tag_fairy->children->[0]->url,$node->url,'correct node linked');
}

my $tag_fantasy = $blio->nodes_by_url->{'tags/fantasy.html'};
is($tag_fantasy->has_children,2,'2 nodes linked with tag "fantasy"');

done_testing();
