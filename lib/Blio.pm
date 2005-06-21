package Blio;

use strict;
use warnings;

use base qw(Class::Accessor Class::Singleton);

use File::Spec::Functions qw(abs2rel catfile catdir splitpath splitdir);
use Carp;
use Template;
use DateTime;
use File::Find;

use Blio::Node;
use Blio::Node::Txt;
use Blio::Node::Image;

$Blio::VERSION='0.02';

# generate accessors
Blio->mk_accessors(qw(basedir cats _tt topnodes allnodes));

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
    croak("basedir missing") unless $data->{basedir};
    
    $data->{topnodes}=[]; 
    $data->{allnodes}={}; 
    return bless $data,$class;
}


#----------------------------------------------------------------
# collect
#----------------------------------------------------------------
sub collect {
    my $self=shift;
    my $srcdir=$self->srcdir;
    my $outdir=$self->outdir;

    find(\&ff_wanted,$srcdir);

}

#----------------------------------------------------------------
# ff_wanted
#----------------------------------------------------------------
sub ff_wanted {
    return if $File::Find::name=~/\.svn/;
    return unless $_=~/\.(txt|jpg|png)$/;
    Blio::Node->register($File::Find::name);
}



#----------------------------------------------------------------
# read
#----------------------------------------------------------------
sub read {
    my $self=shift;
    foreach my $n (values %{$self->allnodes}) {
        $n->parse;
    }
}


#----------------------------------------------------------------
# all_nodes
#----------------------------------------------------------------
sub all_nodes {
    my $self=shift;
    my $cats=$self->cats;
    my @all=map { @{$_->{nodes}} } values %{$cats};
    return wantarray ? @all : \@all;
}

#----------------------------------------------------------------
# build
#----------------------------------------------------------------
sub build {
    my $self=shift;

    my $cats=$self->cats;

    foreach my $id (keys %$cats) {
        my $cat=$cats->{$id};
        my $nodes=$cats->{$id}{nodes};
        my $pos=0;
        foreach my $node (@$nodes) {
            $node->pos($pos);
            $node->print;
            $pos++;
        }

        my $tt=$self->tt;
        $tt->process(
            'category',
            {
                id=>$id,
                cat=>$cat,
                nodes=>$nodes,
                cats=>$cats, 
            },
            catfile($id,'/index.html')
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
sub outdir { catdir(shift->basedir,'out') }
sub srcdir { catdir(shift->basedir,'src') }
sub tpldir { catdir(shift->basedir,'templates') }
sub catdirs { keys %{shift->cats} }
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

Pass config params to Blio in the build.pl script (wehn calling C<new>)

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

=item * a textfile with a dir with the same name containing images

=item * a textfile with a dir with the same name containing more text files

=item * an image

F<some_image.jpg>

For a standalone image an html page will be generated which displays the image as-is (i.e. without thumbnailing). The filename of the image will be used as the title of the page.

=back

=head2 METHODS

=head4 new

Creates a new Blio object.

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

=head4 tpldir

Returns absolute path to dir containing templates.

=head4 catdirs

Returns the list of category (directory) names.

=head4 all_nodes

Returns an arrayref of all nodes

=head3 Accessor Methods (via Class::Accessor)

=head4 basedir

Absolute path to basedir.

=head4 tt

Returns a Template::Toolkit object.

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
