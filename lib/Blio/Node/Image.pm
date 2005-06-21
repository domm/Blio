package Blio::Node::Image;

use strict;
use warnings;

use base qw(Class::Accessor);
use Carp;
use File::Copy;
use Imager;
use File::Spec::Functions qw(catdir catfile abs2rel);

Blio::Node::Image->mk_accessors(qw(node loc image mtime outfile thumb width height alt thumb_width thumb_height));

sub mangle {
    my $self=shift;

    if (-e $self->outfile) {
        # image exists check mtime
        print "skip image (should check mtime...)\n";

        # should also get height and width
        my $img=Imager->new;
        $img->open(file=>$self->outfile) || die $img->errstr();
        my $th=Imager->new;
        $th->open(file=>$self->outfile_th) || die $img->errstr();
            
        $self->width($img->getwidth);
        $self->height($img->getheight);
        $self->thumb_width($img->getwidth);
        $self->thumb_height($img->getheight);
    } else {
        # copy image
        copy($self->srcfile,$self->outfile) || croak "Cannot copy image ".$self->image;
        
        # make thumbnail
        my $img=Imager->new;
        $img->open(file=>$self->srcfile) || die $img->errstr();
        my $resize=$img->scale(xpixels=>300);
        $resize->write(file=>$self->outfile_th) || die $resize->errstr;
    
        $self->width($img->getwidth);
        $self->height($img->getheight);
        $self->thumb_width($img->getwidth);
        $self->thumb_height($img->getheight);
    }
}



sub srcfile {
    my $self=shift;
    my $blio=Blio->instance;
    return catfile($blio->srcdir,$self->node->cat,$self->image);
}

sub outfile {
    my $self=shift;
    my $blio=Blio->instance;
    return catfile($blio->outdir,$self->node->cat,$self->image);
}

sub outfile_th {
    my $self=shift;
    my $blio=Blio->instance;
    return catfile($blio->outdir,$self->node->cat,"th_".$self->image);
}

sub thumb { return 'th_'.shift->image }

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
