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

my $blio = testlib::blio('site1');
my $base = $blio->source_dir;

{
    my $node = Blio::Node->new_from_file($blio, file(qw(. t testdata site1 blog.txt)));
    
    is($node->source_file->relative($base),'blog.txt','source_file');
    is($node->url,'blog.html','url');

    is($node->title,'A Blög','title');
    is($node->date,'2011-06-13T11:54:40','date from mtime');
    is($node->parent,undef,'no parent');
}

{
    my $node = Blio::Node->new_from_file($blio, file(qw(. t testdata site1 books.txt)));
   
    $node->add_child($node); # urks..
    is($node->url,'books.html','url');
    
    is($node->title,'Books','title');
    is($node->date,'2001-01-01T00:00:00','date from header');
    is($node->date->time_zone->name,'floating','floating time zone');
    is($node->language,'en','language: en');
    is($node->converter,undef,'converter: undef');
}

{
    my $node = Blio::Node->new_from_file($blio, file(qw(. t testdata site1 movies.txt)));
    is($node->title,'Movies','title');
    is($node->date,'2011-06-12T15:45:33','date from header');
    is($node->date->time_zone->name,'+0200','time zone offset');
    is($node->language,'de','language: de');
    is($node->converter,'test','converter: test');
}

{
    my $node = Blio::Node->new_from_file($blio, file(qw(. t testdata site_images iceland geysir.txt)));
    is($node->has_images,2,'has 2 images');

}
done_testing();
