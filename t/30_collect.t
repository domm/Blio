use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>2;
use Test::NoWarnings;

use Blio;
my $blio=Blio->new({basedir=>$base});
$blio->read_config;

$blio->collect;

#my $files=$blio->files;
my $dirs=$blio->dirs;
#is(scalar @$files,4,'num files');
is(scalar @$dirs,3,'num dirs');

