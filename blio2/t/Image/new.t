#!/usr/bin/perl

use strict;
use warnings;
use 5.010;
use utf8;

use Test::Most;
use Path::Class;
use Blio::Image;

use lib qw(t);
use testlib;

my $blio = testlib::blio('site_images');
my $base = $blio->source_dir;

{
    my $image = Blio::Image->new(
        base_dir=>$blio->source_dir,
        source_file=>$blio->source_dir->file(qw(iceland geysir_images geysir_1.jpg)),
    );
    is($image->url->stringify,'iceland/geysir_images/geysir_1.jpg','target');
    is($image->thumbnail->stringify,'iceland/geysir_images/th_geysir_1.jpg','thumbnail');
}

done_testing();
