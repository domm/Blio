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
    srcfile cat template pos images modified));


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
        modified=>$mtime,
        mtime=>$mtime,
        date=>DateTime->from_epoch(epoch=>$mtime),
    },$nodeclass;

    my $sth = $blio->db->prepare("select * from blio where url = ?");
    $sth->execute($node->url);
    my $found = $sth->fetchrow_array;
    unless ($found) {
        $blio->db->do("insert into blio (url,mtime) values (?,?)",undef,$node->url,$mtime);
    }

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
    my ($db_mtime) = $blio->db->selectrow_array("select mtime from blio where url = ?",undef,$self->url) || 0;

    # check if dir exists
    unless($self->is_top) {
        my $pdir=catdir($blio->outdir,$self->parent->id);
        unless (-d $pdir) {
            mkdir($pdir);
        }
        unless ($blio->force) {
            return if $self->modified <= $db_mtime;  
        }
    }
    print $self->url,"\n";
    $blio->db->do("update blio set mtime = ? where url =?",undef,$self->modified,$self->url);
    
    # handle images
    foreach my $i (@{$self->images}) {
        $i->write;
    }   
    
    # sort nodes
    my $pos=0;
    my @sorted;
    foreach my $sn (sort {$b->mtime <=> $a->mtime} @{$self->nodes}) {
        #print $sn->mtime," ",$sn->id,"\n";
        $sn->pos($pos);
        push(@sorted,$sn);
        $pos++;
    }
    $self->nodes(\@sorted);
    
    my $tt=$blio->tt;
    $tt->process(
        $self->template,
        {
            blio=>$blio,
            node=>$self,
        },
        $self->url
    ) || die $tt->error;
    utime($self->mtime,$self->mtime,$blio->outdir.$self->url);

    # also write index.html if node is top-node
    if ($self->is_top) {
        my $index_url=$self->url;
        my $base=$self->basename;
        $index_url=~s{$base.html}{$base/index.html};
        print "$index_url\n";
        $tt->process(
            $base eq 'microblog' ? 'microblog' : $self->template,
            {
                blio=>$blio,
                node=>$self,
            },
            $index_url
        ) || die $tt->error;
        utime($self->mtime,$self->mtime,$blio->outdir.$index_url);
    }
    
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

sub images_by_basename {
    my $n=shift;
    return [sort {$a->basename cmp $b->basename}  @{$n->images}];
}

#----------------------------------------------------------------
# url
#----------------------------------------------------------------
sub url {
    my $self=shift;
    my $url;
    if ($self->is_top) {
        $url =  '/'.$self->filename;
    } else {
        $url = join('/','',$self->dir,$self->filename);
    }
    $url=~s{^//}{/};
    return $url;
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
