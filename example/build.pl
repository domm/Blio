#!/usr/bin/perl -w

use strict;
use warnings;

use lib ('../lib/');
use Blio;
my $blio=Blio->new({
        basedir=>'/home/domm/perl/Blio/example/',
        cats=>{
            blog=>'blog',
            root=>'Root',
        }
    });

$blio->collect;
$blio->build;


