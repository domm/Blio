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

my $blio = testlib::blio('site1');

{
    my $node =
        Blio::Node->new_from_file( $blio,
        file(qw(. t testdata site1 books un_lun_dun.txt)) );
    $node->write($blio);
    file_exists_ok( $blio->output_dir->file('books/un_lun_dun.html') );
}

done_testing();
