package Blio::Node;

use strict;
use warnings;

use base qw(Class::Accessor);

use Carp;
use File::Spec::Functions qw(catdir catfile abs2rel);

# generate accessors
Blio::Node->mk_accessors(qw(srcpath basename title text date cat));


sub outpath {
    my $self=shift;
    if ($self->{outpath}) {
        return $self->outpath;
    }
    my $srcpath=$self->srcpath;
    my $outdir=Blio->instance->outdir;
    return catfile($outdir,$self->cat,$self->basename.".html");
}

sub url {
    my $self=shift;
    return join('/','',$self->cat,$self->basename.".html");

}

sub print {
    my $self=shift;
    my $blio=Blio->instance;
    print STDERR "# ".$self->url. " $self blio: $blio ".$blio->outdir."\n";
    my $tt=$blio->tt;
    $tt->process(
        'node',
        {
            node=>$self,
            blio=>$blio,
        },
        $self->url
    ) || die "#". $tt->error;
    
}   

sub parse {
    my $self=shift;

    # open srcfile
    # read it
    # text2html
    # store data
    # handle_image (nur bei Txt)
    
    # oder besser in jeder Node extra?
    # vor allem Dir und Sub nodes muessen ja einiges extra machen
}


8;


__END__

=pod

=head1 NAME

Blio::Node - Node Base Class

=head1 SYNOPSIS

hmm...

=head1 DESCRIPTION

=head2 METHODS

=head4 outpath

Returns the absolute path to the html file.

=head4 url

Returns the url (absolute from docroot)

=head1 AUTHOR

Thomas Klausner, domm@zsi.at

=head1 COPYRIGHT & LICENSE

Copyright 2005 Thomas Klausner, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it

=cut
