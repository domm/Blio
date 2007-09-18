package Blio::Node::Txt;

use strict;
use warnings;

use base qw(Blio::Node);
use Carp;

#----------------------------------------------------------------
# parse
#----------------------------------------------------------------
sub parse {
    my $self=shift;
   
    my $in;
    #print $self->srcpath,"\n";
    open($in,$self->srcpath) || "cannot read ".$self->scrpath.": $!";
    my @lines=<$in>;
    my $title=shift(@lines);
    chomp($title);
    
    if ($title =~/ -- (\d+)$/) {
        my $rdate=$1;
        my $date=DateTime->new(
            year=>substr($rdate,0,4),
            month=>substr($rdate,4,2),
            day=>substr($rdate,6,2),
        );
        $self->date($date);
        $self->mtime($date->epoch);
        $title=~s/ --.*$//;
    }
   
    my $empty=shift(@lines);  # remove seperator
    unshift(@lines,$empty) if $empty=~/\w/;

    my $text=join('',@lines);

    # transform text
    my $html=$text;
    
    $html=~s/\n\n\* /<ul><li>/gs;
    $html=~s/\n\*/<li>/gs;
    $html=~s/<li> (.*?)\n\n/<li>$1<\/ul>/gs;
    
    $html=~s/\n\n/<br><br>/gs;
    $html=~s|\[(.*?)\s+(.*?)\]|<a href="$1">$2</a>|gs;
   
    $html=~s{\*(.*?)\*}{<b>$1</b>}gs;
    $html=~s{_(.*?)_}{<i>$1</i>}gs;

    my $teaser=$text;
    $teaser=~s|\[(.*?)\s+(.*?)\]|$2|gs;
    if (length($teaser)>=150) {
        $teaser=substr($teaser,0,150)."...";
    }
    $self->title($title);
    $self->teaser($teaser);
    $self->text($html);
}

sub template { 'node' }

sub filename { return shift->basename.".html" }

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
