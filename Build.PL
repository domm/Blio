use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Blio',
    license             => 'perl',
    dist_author         => 'Thomas Klausner <domm@zsi.at>',
    dist_version_from   => 'lib/Blio.pm',
    requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Blio-*' ],
    create_makefile     => 'passthrough',
    create_readme       => 1,
);

#my $thisdir=$builder->base_dir."/";
my $base=$builder->prompt("
Please enter a writable directory where I can install a test enviroment.
I will copy some file into this directory, run various tests on them,
and remove them afterwards.
    
If you specifiy an empty values, a lot of tests won't be run.
",'/temp');
$builder->notes(base=>$base);

$builder->create_build_script();

