package Blio::Node;

use strict;
use warnings;

use base qw(Class::Accessor);

use Carp;


# generate accessors
Blio->mk_accessors(qw(srcpath outpath url title text date parent childs));



8;


__END__

=pod

=head1 NAME

Blio::Node - Node Base Class

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
