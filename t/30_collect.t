use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>8;
use Test::NoWarnings;
use Test::Deep;

use Blio;
my $blio=Blio->new({basedir=>$base});
$blio->read_config;

$blio->collect;

my $outdir=$blio->outdir;

use File::Spec;

# OUTDIRS
ok(-e File::Spec->catdir($outdir,'blog'),'outdir blog');
ok(-e File::Spec->catdir($outdir,'blog','page_with_images'),'outdir blog/page_with_images');
ok(-e File::Spec->catdir($outdir,'blog','page_with_subpages'),'outdir blog/page_with_subpages');

# CATEGORIES
my $cats=$blio->cats;
my @catkeys=keys %$cats;
is(scalar @catkeys,2,'num cats');
cmp_bag(\@catkeys,[qw(root blog)],'cats');

is(scalar @{$cats->{root}},0,'no nodes in root');
is(scalar @{$cats->{blog}},5,'5 nodes in root');
# 


