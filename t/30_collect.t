use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>9;
use Test::NoWarnings;
use Test::Deep;

use Blio;
my $blio=Blio->new({basedir=>$base});
$blio->read_config;

$blio->collect;
my $outdir=$blio->outdir;

use File::Spec::Functions qw(catdir catfile);

# OUTDIRS
ok(-e catdir($outdir,'blog'),'outdir blog');
ok(-e catdir($outdir,'blog','page_with_images'),'outdir blog/page_with_images');
ok(-e catdir($outdir,'blog','page_with_subpages'),'outdir blog/page_with_subpages');

# CATEGORIES
my $cats=$blio->cats;
my @catkeys=keys %$cats;
is(scalar @catkeys,2,'num cats');
cmp_bag(\@catkeys,[qw(root blog)],'cats');

is(scalar @{$cats->{root}},0,'no nodes in root');
is(scalar @{$cats->{blog}},4,'4 nodes in blog');

#use Data::Dumper;
#diag(Dumper $cats);
# NODES 
{
    my $node=$cats->{blog}[0];
#    is($node->outpath,catfile($base,'out','blog','standalone_image.html'),'outpath');
#    is($node->absurl,'/blog/standalone_image.html','url');
}

# ALL NODES
{
    my $all=$blio->all_nodes;
    is(scalar @$all,4,'4 nodes in total');
}

