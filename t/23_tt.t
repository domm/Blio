use Module::Build;
use Test::More;
use Test::Deep;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>3;
use Test::NoWarnings;

use Blio;
my $blio=Blio->new({basedir=>$base});
$blio->read_config;

my $tt=$blio->tt;

is(ref($tt),'Template','$tt is a Template');

my $tt2=$blio->tt;
cmp_deeply($tt,$tt2,'tt2 is tt');

