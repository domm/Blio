package Blio;

use strict;
use warnings;

use base qw(Class::Accessor Class::Singleton);

use YAML qw(LoadFile);
use File::Spec::Functions qw(abs2rel catfile catdir splitpath splitdir);
use Carp;
use File::Find;
use Template;
use DateTime;

use Blio::Node;
use Blio::Node::Dir;
use Blio::Node::Txt;
use Blio::Node::Image;

$Blio::VERSION='0.01';

# generate accessors
Blio->mk_accessors(qw(basedir config cats _tt));


#----------------------------------------------------------------
# new
#----------------------------------------------------------------
sub new {
    # return the singleton
    return shift->instance(@_);
}

#----------------------------------------------------------------
# _new_instance
#----------------------------------------------------------------
sub _new_instance {
    my $class=shift;
    my $data=shift;
    croak("please pass a hashref to new") unless ref($data) eq 'HASH';
    $data->{cats}={root=>[],};
    
    return bless $data,$class;
}


#----------------------------------------------------------------
# read_conf
#----------------------------------------------------------------
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


#----------------------------------------------------------------
# collect
#----------------------------------------------------------------
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


#----------------------------------------------------------------
# register_node
#----------------------------------------------------------------
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

    # currently, Blio doesn't support nested categories
    return if @dir>2; 

    my $cat=$dir[0] || 'root';
    $self->register_category($cat);
    
    my $srcfile=$f;
   
    $f=~/^(.*)\.(.*?)$/;
    my $basename=$1;
    my $ext=$2;
    
    my $nodeclass;
    if (@dir == 2) {
        if ($f eq 'node.txt') {
            $nodeclass='Dir';
            $basename=$dir[1];
        } elsif ($ext eq 'txt') {
            #$nodeclass='Sub';
        }   
    } else {
        if ($ext eq 'txt') {
            $nodeclass='Txt';
        } elsif ($ext=~/^(jpg|jpeg|gif|png)$/) {
            $nodeclass='Image';
        }
    }
    return unless $nodeclass;
    $nodeclass='Blio::Node::'.$nodeclass;
    
    my $node=$nodeclass->new({
        srcpath=>$srcpath,
        cat=>$cat,
        basename=>$basename,
        srcfile=>$srcfile,
    });
    $node->parse;
    push(@{$self->cats->{$cat}},$node);
    return;
}


#----------------------------------------------------------------
# register_category
#----------------------------------------------------------------
sub register_category {
    my $self=shift;
    my $cat=shift;
    my $cats=$self->cats;
    return if $cats->{$cat};
    $cats->{$cat}=[];
}

#----------------------------------------------------------------
# all_nodes
#----------------------------------------------------------------
sub all_nodes {
    my $self=shift;
    my $cats=$self->cats;
    my @all=map { @$_ } values %$cats;
    return wantarray ? @all : \@all;
}

#----------------------------------------------------------------
# build
#----------------------------------------------------------------
sub build {
    my $self=shift;


    while (my ($cat,$nodes)=each %{$self->cats}) {
        print "cat $cat\n";
        foreach my $node (@$nodes) {
            $node->print;
        }

        my $tt=$self->tt;
        $tt->process(
            'category',
            {
                cat=>$cat,
                nodes=>$nodes,
            },
            catfile($cat,'/index.html')
        ) || die $tt->error;
    }
}

#----------------------------------------------------------------
# tt
#----------------------------------------------------------------
sub tt {
    my $self=shift;
    return $self->_tt if $self->_tt;

    my $tt=Template->new({
        INCLUDE_PATH=>$self->tpldir,
        OUTPUT_PATH=>$self->outdir,
        WRAPPER=>'wrapper',
    });
    $self->_tt($tt);
    return $tt;
}

#----------------------------------------------------------------
# Accessor Methods
#----------------------------------------------------------------
sub outdir { return catdir(shift->basedir,'out') }
sub srcdir { return catdir(shift->basedir,'src') }
sub tpldir { return catdir(shift->basedir,'templates') }
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

=head2 Overview

Blio converts src files which are stored in the srcdir into html documents.

=head2 Configuration

The configuration is stored in the file F<blio.yaml> in the root dir of your Blio installation.

=head3 basedir

Absolute path to your Blio installation.

=head3 image_resizer

The name of the class to handle image resizing / thumbnailing.

=head3 image_width

The width (in pixel) of a thumbnail.

=head3 ignore

A list of regexes. Files matching this regexes are ignored by Blio.

=head2 Structure of srcdir

The srcdir can contain any number of directories. Each of this directories makes up a L<category>. A catgeory is a container of nodes.

Each category can contain any number of nodes.

A Node is any of:

=over

=item * a textfile

F<some_file.txt>

A textfile will be parsed and converted to an html page.

=item * an image

F<some_image.jpg>

For a standalone image an html page will be generated which displays the image as-is (i.e. without thumbnailing). The filename of the image will be used as the title of the page.

=item * a directory containing a file called F<node.txt> and a number of images

=item * a directory containing a file called F<node.txt> and a number of text files and a number of images

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

=head4 build

Fetch all nodes and generate an HTML page in outdir for each node.

=head3 Accessor Methods

=head4 outdir

Returns absolute path to outdir.

=head4 srcdir

Returns absolute path to srcdir.

=head4 configfile

Returns absolute path to configfile (blio.yaml).

=head4 all_nodes

Retruns an arrayref of all nodes

=head3 Accessor Methods (via Class::Accessor)

=head4 basedir

Absolute path to basedir.

=head4 config

The config data structur (blio.yaml).

=head4 files

List of all absolute file paths to be processed

=head4 dirs

List of all directories, relative to out/src

=head1 BUGS

Please use RT to report

=head1 AUTHOR

Thomas Klausner, domm@zsi.at

=head1 COPYRIGHT & LICENSE

Copyright 2005 Thomas Klausner, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it

=cut
