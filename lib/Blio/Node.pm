package Blio::Node;

use strict;
use warnings;

use base qw(Class::Accessor);

use Carp;
use File::Spec::Functions qw(catdir catfile abs2rel splitpath splitdir);

# generate accessors
Blio::Node->mk_accessors(qw(srcpath basename ext dir dirs is_top 
    parent parent_id 
    nodes images title text teaser date mtime
    srcfile cat template pos images));


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

sub register {
    my $class=shift;
    my $srcpath=shift;
    my $blio=Blio->instance;

    my $local=abs2rel($srcpath,$blio->srcdir);
    my ($vol,$dir,$file)=splitpath($local);
    $dir=~s|/$||;
    my @dirs=splitdir($dir);
    $file=~/^(.*)\.(.*)/;
    my $basename=$1;
    my $ext=$2;
    
    my $mtime=(stat($srcpath))[9];
    
    my $nodeclass=$class."::Txt";
    $nodeclass=$class."::Image" unless $ext eq 'txt';
    my $node=bless {
        srcpath=>$srcpath,
        basename=>$basename,
        ext=>$ext eq 'txt' ? 'html' : $ext,
        dir=>$dir,
        dirs=>\@dirs,
        nodes=>[],
        images=>[],
        mtime=>$mtime,
        date=>DateTime->from_epoch(epoch=>$mtime),
    },$nodeclass;

    if ($dir) {
        # print STDERR "# is dir $dir - $srcpath $basename - $local \n";
        
        if (my $same=$blio->allnodes->{$node->id}) {
            my ($parent,$image);
            if ($node->is_image) {
                $parent=$same;
                $image=$node;
            } else {
                $parent=$node;
                $image=$same;
                $blio->allnodes->{$node->id}=$parent;
            }
            $image->parent($parent);
            push(@{$parent->images},$image);
        } else {
            # add to parent
            $node->parent_id($dir);
            my $parent=$blio->allnodes->{$node->parent_id};
            die "no parent" unless $parent;
            $node->parent($parent);
            if ($node->is_image) {
                push(@{$parent->images},$node);
            } else {
                push(@{$parent->nodes},$node);
                $blio->allnodes->{$node->id}=$node;
            }
        }
    } else {
        $node->is_top(1);
        push(@{$blio->topnodes},$node);
        $blio->allnodes->{$node->id}=$node;
    }
    
}

#----------------------------------------------------------------
# parse
#----------------------------------------------------------------
sub parse { croak "'parse' has to be implemented in Subclass!" }


sub write {
    my $self=shift;
    my $blio=Blio->instance;

    print $self->url,"\n";
    # check if dir exists
    unless($self->is_top) {
        my $pdir=catdir($blio->outdir,$self->parent->id);
        unless (-d $pdir) {
            mkdir($pdir);
        }
    }
    
    # handle images
    foreach my $i (@{$self->images}) {
        $i->write;
    }   
    
    my $tt=$blio->tt;
    $tt->process(
        $self->template,
        {
            blio=>$blio,
            node=>$self,
        },
        $self->url
    ) || die $tt->error;

    my $pos=0;
    my @sorted;
    foreach my $sn (sort {$b->mtime <=> $a->mtime} @{$self->nodes}) {
        #print $sn->mtime," ",$sn->id,"\n";
        $sn->pos($pos);
        push(@sorted,$sn);
        $pos++;
    }
    $self->nodes(\@sorted);
    foreach (@sorted) { $_->write }
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

sub outfile {
    my $self=shift;
    my $outdir=Blio->instance->outdir;
    return catfile($outdir,$self->dir,$self->basename.".html");
}

sub id {
    my $self=shift;
    return $self->basename if $self->is_top;
    return $self->dir.'/'.$self->basename;
}

sub is_image { 0 }

#----------------------------------------------------------------
# url
#----------------------------------------------------------------
sub url {
    my $self=shift;
    return '/'.$self->filename if $self->is_top;
    return join('/','',$self->dir,$self->filename);
}

8;


__END__


srcfile    /home/domm/bla/blio/src/foo/bar.txt
outfile    /home/domm/bla/blio/out/foo/bar.html
absurl     /foo/bar.html
filename   bar.html

srcfile    /home/domm/bla/blio/src/foo/bar.jpg
outfile    /home/domm/bla/blio/out/foo/bar.jpg
filename   bar.jpg
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
