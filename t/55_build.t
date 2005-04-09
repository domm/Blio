use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>1;
use Test::NoWarnings;
use Test::Deep;

use Blio;
my $blio=Blio->new({basedir=>$base,cats=>{blog=>'Blog',root=>'Root'}});

$blio->collect;
$blio->build;


