package Blio;

use strict;
use warnings;

use base qw(Class::Accessor);

use YAML qw(LoadFile);
use File::Spec::Functions qw(abs2rel catfile catdir);
use Carp;
use File::Find;

$Blio::VERSION='0.01';

# generate accessors
Blio->mk_accessors(qw(basedir config files dirs));


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


sub collect {
    my $self=shift;
    my $srcdir=$self->srcdir;
    
    my @files;
    my @dirs;
    my $ignore=$self->config->{ignore};
    my $ignore_re=join('|',@$ignore);
    
    my $wanted=sub {
        return if $File::Find::name=~/$ignore_re/;
        return if /^\.+$/;
        if (-f) {
            #$self->register_node($File::Find::name);
            push(@files,$File::Find::name);
        } elsif (-d) {
            my $d=abs2rel($File::Find::name,$srcdir);
            push(@dirs,$d);
        }
    };
    find($wanted,$srcdir);

    $self->files(\@files);
    $self->dirs(\@dirs);
}


sub make_outdirs {
    my $self=shift;
    my $outdir=$self->outdir;
    my $dirs=$self->dirs;
    foreach (@$dirs) {
        my $d=catdir($outdir,$_);
        unless (-e $d) {
            mkdir($d) || croak ("Cannot create $d: $!");
        }
    }
    return $self;
}

sub register_node {
    my $self=shift;
    my $srcpath=shift;

    $srcpath=~/\.(\w+)$/;
    my $extension=$1;

    my $node;
    if ($extension eq 'txt') {
        $node=Blio::Node::Text->new($srcpath,$self);
    } elsif ($extension =~ /jpg|jpeg|gif|png/) {
        $node=Blio::Node::Image->new($srcpath,$self);

    }
        

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

=head4 collect

Traverse srcdir and collect the files and directories contained in it.

=head4 make_outdirs

Generate directory structure in outdir.

=head3 Accessor Methods (via Class::Accessor)

=head4 basedir

Absolute path to basedir.

=head4 config

The config data structur (blio.yaml).

=head4 files

List of all absolute file paths to be processed

=head4 dirs

List of all directories, relative to out/src

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
