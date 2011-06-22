use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Blio',
    license             => 'perl',
    dist_author         => 'Thomas Klausner <domm@plix.at>',
    dist_version_from   => 'lib/Blio.pm',
    requires => {
        'Moose'       => '1.21',
        'MooseX::Types::Path::Class'=>'0.05',
        'Path::Class'  => '0.23',
        'Path::Class::Iterator'  => '0.05',
        'Template'=>0,
        'File::ShareDir'=>'1.03',
        'Digest::SHA1'=>'2.13',,
        'Imager'=>'0.83',
        'DateTime::Format::ISO8601'=>'0.07',
        'Markup::Unified'=>'0.03',
        'XML::Atom::SimpleFeed'=>'0.86',
    },
    build_requires=>{
        'Test::Most'=>'0.23',
        'Test::File'=>'1.29',
    },
    add_to_cleanup      => [ 'Blio-*' ],
    create_makefile     => 'passthrough',
    create_readme       => 1,
    share_dir=>'share',
    recursive_test_files=>1,
);

$builder->create_build_script();

