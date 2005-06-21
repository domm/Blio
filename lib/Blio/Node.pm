package Blio::Node;

use strict;
use warnings;

use base qw(Class::Accessor);

use Carp;
use File::Spec::Functions qw(catdir catfile abs2rel);

# generate accessors
Blio::Node->mk_accessors(qw(srcpath srcfile basename title text date cat template pos images));


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
            cat=>$blio->cats->{$self->cat},
            cats=>$blio->cats,
        },
        $self->absurl
    ) || die $tt->error;
}   

#----------------------------------------------------------------
# parse
#----------------------------------------------------------------
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


#----------------------------------------------------------------
# find_stuff
#----------------------------------------------------------------
sub find_stuff {
    my $self=shift;

    my $blio=Blio->instance;
    my $lookfor=catfile($blio->srcdir,$self->cat,$self->basename);
    
    if (-d $lookfor) {
        print "SUBDIR $lookfor\n";
        my $subdir;
        opendir($subdir,$lookfor);
        while(readdir,
        
    } else {
        my $img;my $file;
        if (-e $lookfor.".jpg") {
            $file=$lookfor.".jpg";
            $img=$self->basename.".jpg";
        } elsif (-e $lookfor.".png") {
            $file=$lookfor.".png";
            $img=$self->basename.".png";
        }
        if ($img) {
            my $mtime=(stat($file))[9];
            $self->register_images({$img=>$mtime});
        }
    }
}

sub register_images {
    my $self=shift;
    my $imgs=shift;
    my $cat=$self->cat;
    
    my @images;
    foreach my $img (sort {$imgs->{$a} <=> $imgs->{$b}} keys %$imgs) {
        my $i=Blio::Node::Image->new({node=>$self,image=>$img,mtime=>$imgs->{$img}});
        $i->mangle;
        push(@images,$i);
    }
    $self->images(\@images);
}

#----------------------------------------------------------------
# outpath
#----------------------------------------------------------------
sub outpath {
    my $self=shift;
    if ($self->{outpath}) {
        return $self->outpath;
    }
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
# mtime
#----------------------------------------------------------------
sub mtime {
    my $self=shift;
    my $date=$self->date;
    return DateTime->now->epoch unless $date;
    return $date->epoch;
}


8;


__END__


srcfile    /home/domm/bla/blio/src/foo/bar.txt
outfile    /home/domm/bla/blio/out/foo/bar.html
absurl     /foo/bar.html
relurl     bar.html

srcfile    /home/domm/bla/blio/src/foo/bar.jpg
outfile    /home/domm/bla/blio/out/foo/bar.jpg
img        bar.jpg
outfile_th /home/domm/bla/blio/out/foo/th_bar.jpg
thumb      th_bar.jpg


=pod

=head1 NAME

Blio::Node - Node Base Class

=head1 SYNOPSIS

hmm...

=head1 DESCRIPTION

=head2 METHODS

=head4 new

Generates and returns a new Node.

=head4 print

Pass the Nodes data to the Nodes template. Print output file.

=head4 parse

Stub Method. Has to be overridden in subclass (eg C<Blio::Node::Txt>).

C<parse> should read the source file and generate the Nodes data.

=head4 outpath

Returns the absolute path to the html file.

=head4 absurl

Returns the url (absolute from docroot)

=head4 relurl

Retunrs the url (relative to the current dir, i.e. 'filename.html')

=head4 mtime

Returns the mtime of a node as seconds since the epoch.

=head1 AUTHOR

Thomas Klausner, domm@zsi.at

=head1 COPYRIGHT & LICENSE

Copyright 2005 Thomas Klausner, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it

=cut
