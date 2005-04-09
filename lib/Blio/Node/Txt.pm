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
    
    print "parse ".$self->srcpath."\n"; 
    open(IN,$self->srcpath) || "cannot read ".$self->scrpath.": $!";
    my @lines=<IN>;
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
        $title=~s/ --.*$//;
    }
   
    my $empty=shift(@lines);  # remove seperator
    unshift(@lines,$empty) if $empty=~/\w/;
    my $text=join('',@lines);

    $self->title($title);
    $self->text($text);
}

sub template { 'node' }

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
