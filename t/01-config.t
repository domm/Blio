use warnings;
use strict;

use Test::More;
use Blio;

use Path::Class;

use lib qw(t);
use testlib;

my $blio = Blio->new_with_config(
    ouptut_dir => testlib::testdir(),
    source_dir => Path::Class::dir(qw( . t testdata config )),
    configfile => Path::Class::dir(qw( . t testdata config blio.ini )));
ok($blio, 'instantiates');
is($blio->template_dir, 'tt', 'reads the value from config');

is($blio->template_configuration->{WRAPPER}, 'w2.tt', 'reads configuration from config');

{
    require Template;
    my $original_new = Template->can('new');
    my $wrapper;
    local *Template::new = sub {
        my ($class, $arg) = @_;
        $wrapper = $arg->{WRAPPER};
        $original_new->($class, $arg)
    };
    *Template::new = *Template::new; # Not used only once.
    $blio->tt;
    is($wrapper, 'w2.tt', 'configuration overrides defaults');
}

done_testing();
