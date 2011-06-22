#!/opt/perl5.10.1/bin/perl
# generated with /opt/perl5.10/bin/generate_00-load_t.pl
use Test::More tests => 2;


BEGIN {
	use_ok( 'Blio' );
}

diag( "Testing Blio Blio->VERSION, Perl $], $^X" );

use_ok( 'Blio::Node' );
