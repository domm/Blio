#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Path::Class;
use Blio::Node;

my $base = Path::Class::dir(qw(. t testdata site1));

{
    my $node = Blio::Node->new_from_file($base, file(qw(. t testdata site1 blog.txt)));
    
    is($node->source_file,'blog.txt','source_file');
    is($node->url,'blog.html','url');

    is($node->title,'A Blog','title');
    is($node->date,'2011-06-12T15:46:37','date from mtime');
    is($node->parent,undef,'no parent');
}

{
    my $node = Blio::Node->new_from_file($base, file(qw(. t testdata site1 books.txt)));
    
    TODO: { 
        local $TODO='children not implemented yet';
        is($node->url,'books/index.html','url');
    };
    
    is($node->title,'Books','title');
    is($node->date,'2010-01-01T00:00:00','date from header');
    is($node->date->time_zone->name,'floating','floating time zone');
}

{
    my $node = Blio::Node->new_from_file($base, file(qw(. t testdata site1 movies.txt)));
    is($node->title,'Movies','title');
    is($node->date,'2011-06-12T15:45:33','date from header');
    is($node->date->time_zone->name,'+0200','time zone offset');
}

done_testing();
