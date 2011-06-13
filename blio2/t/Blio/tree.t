#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Test::File;

use lib qw(t);
use testlib;

use Path::Class;

my $blio = testlib::blio('site_tree');


$blio->run;

file_exists_ok( $blio->output_dir->file('root.html') );
file_exists_ok( $blio->output_dir->file(qw(root child greatchild greatgreatchild the_end.html)) );

{
    my $content = $blio->output_dir->file('root.html')->slurp;
    like($content,qr{<a href="root/child.html">});
    like($content,qr{<a href="root/child_2.html">});
}

{
    my $content = $blio->output_dir->file(qw(root child.html))->slurp;
    like($content,qr{<a href="../root/child/greatchild.html">});
}

done_testing();
