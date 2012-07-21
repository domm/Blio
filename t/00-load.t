#!/opt/perl5.10.1/bin/perl
use Test::Most;
use Module::Pluggable search_path => [ 'Blio' ];

require_ok( $_ ) for sort 'Blio', __PACKAGE__->plugins;

done_testing();

