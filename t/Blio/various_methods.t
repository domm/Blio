#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;
use Path::Class;
use Blio;

my $blio = Blio->new;
is($blio->source_dir,'src','source dir builder');
is($blio->output_dir,'out','output dir builder');
is($blio->template_dir,'templates','output dir builder');

done_testing();
