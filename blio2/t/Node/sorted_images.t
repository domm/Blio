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

my $blio = testlib::blio('site_images');

{
    $blio->collect;
    my $geysir = $blio->nodes_by_url->{'iceland/geysir.html'};
    is($geysir->has_images,2,'2 images');
    my $sorted = $geysir->sorted_images;
    is($sorted->[0]->url,'iceland/geysir_images/geysir_1.jpg','geysir_1.jpg');
    is($sorted->[1]->url,'iceland/geysir_images/geysir_2.jpg','geysir_2.jpg');
}

done_testing();
