use Module::Build;
my $build=Module::Build->current;
my $base=$build->notes('base');

use Test::More;
plan skip_all=>'no test environment set up' unless $base;

eval {
    use File::Copy::Recursive qw(dircopy);
};
Test::More->builder->BAILOUT('File::Copy::Recursive neede for testsuite but seems to be missing') if $@;

plan tests=>3;

use File::Spec::Functions;
if (-e $base) {
    use File::Path;
    my $rvrm=rmtree($base);
    cmp_ok($rvrm,'>=',1,'delete test environ');
} else {
    my $rvmd=mkdir($base);
    is($rvmd,1,'mkdir $base');
}


my $rv=dircopy("example",$base);
cmp_ok($rv,'>=',1,'copy test environ');

# change setting in $base/blio.yaml
eval {
    use File::Spec::Functions;
    use YAML qw(LoadFile DumpFile);
    my $cf=catfile($base,'blio.yaml');
    my $c=LoadFile($cf);
    $c->{basedir}=$base;
    DumpFile($cf,$c);
};
is($@,'','test yaml rewritten');

