#!/usr/bin/perl -w

use strict;
use warnings;

use lib ('../lib/');
use Blio;
my $blio=Blio->new({basedir=>'/home/domm/perl/Blio/example/'});
$blio->read_config;

$blio->collect;
$blio->build;


