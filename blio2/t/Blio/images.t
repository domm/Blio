#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Test::File;

use lib qw(t);
use testlib;

use Path::Class;

my $blio = testlib::blio('site_images');

$blio->run;

file_exists_ok( $blio->output_dir->file(qw(iceland geysir.html)) );
file_exists_ok( $blio->output_dir->file(qw(iceland geysir_images geysir_1.jpg)) );
file_exists_ok( $blio->output_dir->file(qw(iceland geysir_images geysir_2.jpg)) );
file_exists_ok( $blio->output_dir->file(qw(iceland geysir_images th_geysir_1.jpg)) );
file_exists_ok( $blio->output_dir->file(qw(iceland geysir_images th_geysir_2.jpg)) );

done_testing();
