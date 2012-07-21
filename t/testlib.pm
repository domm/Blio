package testlib;
use 5.010;
use strict;
use warnings;

use File::Temp qw(tempdir);
use Test::File;

use Blio;

sub blio {
    my $site = shift;
    return Blio->new(
        output_dir=>testdir(),
        source_dir=>Path::Class::dir(qw(. t testdata ),$site),
        template_dir=>Path::Class::dir(qw(. share templates)),
        @_
    );
}

sub testdir {
    return Path::Class::dir( tempdir( CLEANUP => $ENV{NO_CLEANUP} ? 0 : 1 ));
}

1;
