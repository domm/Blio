use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>6;
use Test::NoWarnings;
use Test::Deep;

use Blio;
my $blio=Blio->new({basedir=>$base,cats=>{blog=>'Blog',root=>'Root'}});

$blio->collect;
my $outdir=$blio->outdir;

use File::Spec::Functions qw(catdir catfile);

# OUTDIRS
#ok(-e catdir($outdir,'blog'),'outdir blog');
#ok(-e catdir($outdir,'blog','page_with_images'),'outdir blog/page_with_images');
#ok(-e catdir($outdir,'blog','page_with_subpages'),'outdir blog/page_with_subpages');

# CATEGORIES
my $cats=$blio->cats;
my @catkeys=keys %$cats;
is(scalar @catkeys,2,'num cats');
cmp_bag(\@catkeys,[qw(root blog)],'cats');

# TOPNODES
my @top=$blio->topnodes;
is(scalar @top,1,'num topnodes');
is(scalar @{$blio->allnodes->{blog}{nodes}},4,'4 nodes in blog');

# NODES 
#{
#    my $node=$cats->{blog}{nodes}[0];
#    is($node->outpath,catfile($base,'out','blog','standalone_image.html'),'outpath');
#    is($node->absurl,'/blog/standalone_image.html','url');
#}

# ALL NODES
use Data::Dumper;{
    my $all=$blio->allnodes;
    is(scalar keys %$all,8,'8 nodes in total');
}

