#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Path::Class;
use Blio::Node;

{
    my $node = Blio::Node->new_from_file(file(qw(. t testdata site1 blog.txt)));
    is($node->title,'A Blog','title');
    is($node->date,'2011-06-12T15:46:37','date from mtime');
    is($node->parent,undef,'no parent');
}

{
    my $node = Blio::Node->new_from_file(file(qw(. t testdata site1 books.txt)));
    is($node->title,'Books','title');
    is($node->date,'2010-01-01T00:00:00','date from header');
    is($node->date->time_zone->name,'floating','floating time zone');
}

{
    my $node = Blio::Node->new_from_file(file(qw(. t testdata site1 movies.txt)));
    is($node->title,'Movies','title');
    is($node->date,'2011-06-12T15:45:33','date from header');
    is($node->date->time_zone->name,'+0200','time zone offset');
}

done_testing();
