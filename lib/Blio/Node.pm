package Blio::Node;

use strict;
use warnings;

use base qw(Class::Accessor);

use Carp;
use File::Spec::Functions qw(catdir catfile abs2rel);

# generate accessors
Blio::Node->mk_accessors(qw(srcpath srcfile basename title text date cat template));


#----------------------------------------------------------------
# new
#----------------------------------------------------------------
sub new {
    my $class=shift;
    my $data=shift;

    my $self=bless $data,$class;
    my $mtime=(stat($self->srcpath))[9];
    $self->date(DateTime->from_epoch(epoch=>$mtime));

    return $self;
}

#----------------------------------------------------------------
# print
#----------------------------------------------------------------
sub print {
    my $self=shift;
    my $blio=Blio->instance;
    print $self->absurl."\n";
    my $tt=$blio->tt;
    $tt->process(
        $self->template,
        {
            node=>$self,
            blio=>$blio,
        },
        $self->absurl
    ) || die $tt->error;
    
}   

#----------------------------------------------------------------
# parse
#----------------------------------------------------------------
sub parse {
    my $self=shift;

    print "base parse ".$self->srcpath."\n";
    
    # open srcfile
    # read it
    # text2html
    # store data
    # handle_image (nur bei Txt)
    
    # oder besser in jeder Node extra?
    # vor allem Dir und Sub nodes muessen ja einiges extra machen
}

#----------------------------------------------------------------
# outpath
#----------------------------------------------------------------
sub outpath {
    my $self=shift;
    if ($self->{outpath}) {
        return $self->outpath;
    }
    my $srcpath=$self->srcpath;
    my $outdir=Blio->instance->outdir;
    return catfile($outdir,$self->cat,$self->basename.".html");
}

#----------------------------------------------------------------
# absurl
#----------------------------------------------------------------
sub absurl {
    my $self=shift;
    return join('/','',$self->cat,$self->basename.".html");
}

#----------------------------------------------------------------
# relurl
#----------------------------------------------------------------
sub relurl {
    my $self=shift;
    return $self->basename.".html";
}

#----------------------------------------------------------------
# filename
#----------------------------------------------------------------
sub filename {
    my $self=shift;
    my $src=$self;
}

#----------------------------------------------------------------
# mtime
#----------------------------------------------------------------
sub mtime {
    my $self=shift;
    my $date=$self->date;
    return DateTime->now unless $date;
    return $date->epoch;
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
