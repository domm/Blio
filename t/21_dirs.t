use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>5;
use Test::NoWarnings;

use Blio;
my $blio=Blio->new({basedir=>$base});

is($blio->basedir,$base,'basedir');
like($blio->outdir,qr/\/out$/,'outdir');
like($blio->srcdir,qr/\/src$/,'srcdir');
like($blio->configfile,qr/\/blio.yaml$/,'configfile');


