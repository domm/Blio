package Blio;

use strict;
use warnings;

use base qw(Class::Accessor);

use YAML qw(LoadFile);
use File::Spec::Functions qw(abs2rel catfile catdir splitpath splitdir);
use Carp;
use File::Find;

use Blio::Node;
use Blio::Node::Dir;
use Blio::Node::Txt;
use Blio::Node::Image;

$Blio::VERSION='0.01';

# generate accessors
Blio->mk_accessors(qw(basedir config cats));

sub new {
    my $class=shift;
    my $data=shift;
    croak("please pass a hashref to new") unless ref($data) eq 'HASH';
    $data->{cats}={root=>{},};
    
    return bless $data,$class;
    
}


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
    my $outdir=$self->outdir;
    
    my $ignore=$self->config->{ignore};
    my $ignore_re=join('|',@$ignore);
    
    my $wanted=sub {
        return if $File::Find::name=~/$ignore_re/;
        return if /^\.+$/;
        if (-f) {
            $self->register_node($File::Find::name);
        } elsif (-d) {
            my $d=abs2rel($File::Find::name,$srcdir);
            my $od=catdir($outdir,$d);
            unless (-e $od) {
                mkdir($od) || croak ("Cannot create $od: $!");
            }
        }
    };
    find($wanted,$srcdir);

}


sub register_node {
    my $self=shift;
    my $srcpath=shift;
    my $srcdir=$self->srcdir;

    my $abs=$srcpath;
    my $rel=abs2rel($srcpath,$srcdir);
    my ($v,$d,$f)=splitpath($rel);
    my @dir=splitdir($d);
    if ($dir[-1] eq '') {  # File::Spec::splitdir might return an empty
        pop(@dir);         # dir name; remove it
    }
    return if @dir>2;
    print "$v - $d: ".join(',',@dir)." - $f \n";
    #push(@files,$srcpath);

    my $cat=$dir[0] || 'root';
    $self->register_category($cat);
    
    my $nodeclass;
    if (@dir == 2) {
        if ($f eq 'node.txt') {
            $nodeclass='Dir'
        } elsif ($f=~/\.txt$/) {
            #$nodeclass='Sub'
        }   
    } else {
        if ($f=~/\.txt$/) {
            $nodeclass='Txt'
        } elsif ($f=~/\.(jpg|jpeg|gif|png)$/) {
            $nodeclass='Image'
        }
    }
    return unless $nodeclass;
    $nodeclass='Blio::Node::'.$nodeclass;
    print "$nodeclass\n";
    
    my $node=$nodeclass->new({srcpath=>$srcpath});

    
    return;

    

}


sub register_category {
    my $self=shift;
    my $cat=shift;
    my $cats=$self->cats;
    return if $cats->{$cat};
    $cats->{$cat}={};
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

=head4 new

Creates a new Blio object.

=head4 read_config

Reads the config file (blio.yaml) and stores the configuration in
$blio->config.

=head4 collect

Traverse srcdir and collect the files and directories contained in it.

=head4 register_category($cat)

Registers a new category. If the category already exists, does nothing;

=head4 register_node($srcpath)

Figures out what kind of node the $srcpath points to. Generates a fitting
Blio::Node::* object and registers the node in the node registry.

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
