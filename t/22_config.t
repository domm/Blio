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

is($blio->config->{basedir},$blio->basedir,'basedir');

