#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Test::File;

use lib qw(t);
use testlib;

use Path::Class;
use Blio::Node;
use DateTime;

my $blio = testlib::blio('site1');

{
    $blio->collect;
    my $books = $blio->nodes_by_url->{'books.html'};
    is($books->has_children,2,'2 childs');
    my $sorted = $books->sorted_children;
    is($sorted->[0]->id,'books/un_lun_dun','UnLunDun');
    is($sorted->[1]->id,'books/artemis_fowl','Artemis');
}

done_testing();
