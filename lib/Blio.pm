package Blio;

use strict;
use warnings;

use base qw(Class::Accessor);

use YAML qw(LoadFile);
use File::Spec::Functions;
use Carp;

$Blio::VERSION='0.01';

# generate accessors
Blio->mk_accessors(qw(basedir config));


sub read_config {
    my $self=shift;
    my $configfile=$self->configfile;
    unless (-e $configfile) {
        croak("Configfile $configfile missing!"); 
    }
    my $config;
    eval {
        $config=LoadFile($configfile);
    };
    croak("Parse error in config $configfile: $@") if $@;

    $self->config($config);
    return $self;
}


sub outdir { return catdir(shift->basedir,'out') }
sub srcdir { return catdir(shift->basedir,'src') }
sub configfile { return catfile(shift->basedir,'blio.yaml') }

8;


__END__

=pod

=head1 NAME

Blio - Blog/Wiki/Website Generator 

=head1 SYNOPSIS

hmm...

=head1 DESCRIPTION

ttree on steroids.

bloxsom/bryar ripoff I can actually understand/use.

=head2 METHODS

=head3 Setup Methods

=head4 read_config

Reads the config file (blio.yaml) and stores the configuration in
$blio->config.

=head3 Accessor Methods (via Class::Accessor)

=head4 basedir

Returns absolute path to basedir.

=head4 config

Returns the config data structur (blio.yaml).

Returns

=head3 Special Accessor Methods

=head4 outdir

Returns absolute path to outdir.

=head4 srcdir

Returns absolute path to srcdir.

=head4 configfile

Returns absolute path to configfile (blio.yaml).

=head1 BUGS

Please use RT to report

=head1 AUTHOR

Thomas Klausner, domm@zsi.at

=head1 COPYRIGHT & LICENSE

Copyright 2005 Thomas Klausner, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it

=cut
