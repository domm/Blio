use Module::Build;
my $build=Module::Build->current;
my $base=$build->notes('base');

use Test::More;
plan skip_all=>'no test environment set up' unless $base;

plan tests=>1;
is(1,1);

copy("example",$base);



