use Module::Build;
my $build=Module::Build->current;
my $base=$build->notes('base');

use Test::More;
plan skip_all=>'no test environment set up' unless $base;

plan tests=>1;

use File::Spec::Functions;
my $rv;
if (-e $base) {
    use File::Path;
    $rv=rmtree($base);
}

cmp_ok($rv,'>=',1,'deleted test environ');


