package Blio::Node::Image;

use strict;
use warnings;

use base qw(Blio::Node);
use Carp;
use File::Copy;
use Imager;
use File::Spec::Functions qw(catdir catfile abs2rel);

Blio::Node::Image->mk_accessors(qw(node loc image mtime outfile thumb width height alt thumb_width thumb_height));


sub parse {}
sub write { 
    my $self=shift;
    my $blio=Blio->instance;

    my $pdir=catdir($blio->outdir,$self->parent->id);
    unless (-d $pdir) {
        mkdir($pdir);
    }
   
    # hmm: zur beschleunigung:
    # bei neuen images wird die x/y und th-x/y in ein globales file
    # geschrieben (hash indiziert ueber url)
    # beim naechsten durchlauf werden fuer existierende bilder die werte aus
    # diesem file genommen
    
    if (-e $self->outfile) {
        # image exists check mtime
        #print "get existing image info\n";
        
        # get height and width
        my $img=Imager->new;
        $img->open(file=>$self->outfile) || die $img->errstr();
        my $th=Imager->new;
        $th->open(file=>$self->outfile_th) || die $img->errstr();
            
        $self->width($img->getwidth);
        $self->height($img->getheight);
        $self->thumb_width($th->getwidth);
        $self->thumb_height($th->getheight);
    
    } else {
        #print "make thumbnail\n";

        # copy image
        copy($self->srcpath,$self->outfile) || croak "Cannot copy image ".$self->filename," to ",$self->outfile;
        
        # make thumbnail
        my $img=Imager->new;
        $img->open(file=>$self->srcpath) || die $img->errstr();
        my $resize=$img->scale(xpixels=>300);
        $resize->write(file=>$self->outfile_th) || die $resize->errstr;
    
        # get height and width
        $self->width($img->getwidth);
        $self->height($img->getheight);
        $self->thumb_width($resize->getwidth);
        $self->thumb_height($resize->getheight);
    }
}

sub is_image { 1 }


sub srcfile {
    my $self=shift;
    my $blio=Blio->instance;
    return'foo';
    return catfile($blio->srcdir,$self->dir,$self->image);
}

sub outfile {
    my $self=shift;
    my $blio=Blio->instance;

    return catfile($blio->outdir,$self->dir,$self->filename);
}

sub outfile_th {
    my $self=shift;
    my $blio=Blio->instance;
    return catfile($blio->outdir,$self->dir,"th_".$self->filename);
}

sub thumb { 
    my $self=shift;
    return join('/','',$self->dir,'th_'.$self->filename);
}

sub filename {
    my $self=shift;
    return $self->basename.'.'.$self->ext;
}

8;


__END__

=pod

=head1 NAME

Blio::Node::Dir - Node from dir

=head1 SYNOPSIS

hmm...

=head1 DESCRIPTION

=head2 METHODS

=head4 parse

Parse a text file

=head4 template

return tempalte name, 'node'

=head1 AUTHOR

Thomas Klausner, domm@zsi.at

=head1 COPYRIGHT & LICENSE

Copyright 2005 Thomas Klausner, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it

=cut
