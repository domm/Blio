use Module::Build;
use Test::More;
my $build=Module::Build->current;
my $base=$build->notes('base');
plan skip_all=>'test environment not set up' unless $base;

plan tests=>2;
use Test::NoWarnings;
use Test::Deep;

use Blio;
my $blio=Blio->new({basedir=>$base,cats=>{blog=>'Blog',root=>'Root'}});

$blio->collect;
$blio->read;

my $node=$blio->allnodes->{'blog/another_simple_page'};
use Data::Dumper;
my $html=$node->text;

is($html,'This is another simple page<br><br>with some markup<ul><li>a list<li>with items</ul>some text with <a href="http://foobar">some</a> <a href="http://perl.org">links</a><br><br>','html');


