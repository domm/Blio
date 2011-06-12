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
use Blio::Node;

my $src  = Path::Class::dir(qw(. t testdata site1));
my $out  = Path::Class::dir( tempdir( CLEANUP => $ENV{NO_CLEANUP} ? 0 : 1 ) );
my $blio = Blio->new( output_dir => $out, );

{
    my $node =
        Blio::Node->new_from_file( $src,
        file(qw(. t testdata site1 books un_lun_dun.txt)) );
    $node->write($blio);
    file_exists_ok( $out->file('books/un_lun_dun.html') );
}

done_testing();
