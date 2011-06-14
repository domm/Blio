use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Blio',
    license             => 'perl',
    dist_author         => 'Thomas Klausner <domm@zsi.at>',
    dist_version_from   => 'lib/Blio.pm',
    requires => {
        'YAML'=>0.36,
        
        # for testing
        'Test::More' => 0,
        'File::Copy::Recursive'=> 0.04,
    },
    add_to_cleanup      => [ 'Blio-*' ],
    create_makefile     => 'passthrough',
    create_readme       => 1,
    share_dir=>'share',
);

$builder->create_build_script();

