use Test::More tests=>5;
use Test::NoWarnings;

use Blio;

my $blio=Blio->new;
$blio->basedir('/temp');

is($blio->basedir,'/temp','basedir');
is($blio->outdir,'/temp/out','outdir');
is($blio->srcdir,'/temp/src','srcdir');
is($blio->configfile,'/temp/blio.yaml');


