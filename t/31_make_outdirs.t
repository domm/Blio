use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>3;
use Test::NoWarnings;

use Blio;
my $blio=Blio->new({basedir=>$base});
$blio->read_config;
$blio->collect;
$blio->make_outdirs;

my $outdir=$blio->outdir;
use File::Spec;
ok(-e File::Spec->catdir($outdir,'blog'),'outdir blog');
ok(-e File::Spec->catdir($outdir,'blog','baz'),'outdir blog/baz');

