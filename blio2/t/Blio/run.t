#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use File::Temp qw(tempdir);
use Test::File;
use Test::File::ShareDir -share => { -dist => { 'Blio' => 'share/' } };

use Path::Class;
use Blio;
my $out = Path::Class::dir( tempdir( CLEANUP => $ENV{NO_CLEANUP} ? 0 : 1 ) );
my $blio = Blio->new(
    source_dir => Path::Class::dir(qw(. t testdata site1)),
    output_dir => $out,
);
$blio->run;

file_exists_ok( $out->file('blog.html') );
file_exists_ok( $out->file('movies/index.html') );
file_exists_ok( $out->file('books/index.html') );
file_exists_ok( $out->file('books/un_lun_dun.html') );
file_exists_ok( $out->file('books/artemis_fowl.html') );

done_testing();
