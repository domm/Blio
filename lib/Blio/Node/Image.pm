package Blio::Node::Image;

use strict;
use warnings;

use base qw(Blio::Node);
use Carp;
use File::Copy;
use File::Spec::Functions qw(catdir catfile abs2rel);

__PACKAGE__->mk_accessors(qw(image thumbnail width height th_width th_height));


#----------------------------------------------------------------
# parse
#----------------------------------------------------------------
sub parse {
    my $self=shift;
    
    print "parse img ".$self->srcpath."\n"; 

    my $title=$self->basename;
    $title=~s/_/ /g;
    
    $self->title($title);
    $self->image($self->srcfile);

    my $path=abs2rel($self->srcpath,Blio->instance->srcdir);
    my $target=catfile(Blio->instance->outdir,$path);   
    copy($self->srcpath,$target);
    
    # make thumbnail
    
    return;
}

sub template { 'image' }

8;
__END__

=pod

=head1 NAME

Blio::Node::Dir - Node from dir

=head1 SYNOPSIS

hmm...

=head1 DESCRIPTION

=head2 METHODS

=head1 AUTHOR

Thomas Klausner, domm@zsi.at

=head1 COPYRIGHT & LICENSE

Copyright 2005 Thomas Klausner, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it

=cut
