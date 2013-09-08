package Blio::Image;

# ABSTRACT: An image node

use 5.010;
use Moose;
use namespace::autoclean;
use Digest::SHA1;
use Path::Class;
use File::Copy;
use Imager;

has 'base_dir' => ( is => 'ro', isa => 'Path::Class::Dir', required => 1 );
has 'source_file' =>
    ( is => 'ro', isa => 'Path::Class::File', required => 1 );
has 'url' =>
    ( is => 'ro', isa => 'Path::Class::File', required => 1, lazy_build=>1 );
sub _build_url {
    my $self = shift;
    return $self->source_file->relative($self->base_dir);
}
has 'thumbnail' =>
    ( is => 'ro', isa => 'Path::Class::File', required => 1, lazy_build=>1);
sub _build_thumbnail {
    my $self = shift;
    my $th = $self->source_file->relative($self->base_dir)->stringify;
    $th=~s{/([^/]+)$}{/th_$1};
    return file($th);
}

sub publish {
    my ($self, $blio) = @_;

    $blio->output_dir->file($self->url)->parent->mkpath;
    my $from = $self->source_file->stringify;
    my $to = $blio->output_dir->file($self->url)->stringify;
    copy($from, $to) || die "Cannot copy $from to $to: $!";
}

sub make_thumbnail {
    my ($self, $blio, $width) = @_;

    $blio->output_dir->file($self->url)->parent->mkpath;
    my $file = $self->source_file->stringify;
    my $target = $blio->output_dir->file($self->thumbnail)->stringify;
    my $image = Imager->new;
    $image->read(file=>$file) || die "Cannot read image $file: ".$image->errstr;
    $width ||= $blio->thumbnail;
    my $thumbnail = $image->scale(xpixels => $width) || die "Cannot scale $file: ".$image->errstr;
    $thumbnail->write( file => $target ) || die "Cannot write thumbnail $target" . $thumbnail->errstr;
}

__PACKAGE__->meta->make_immutable;
1;

__END__

=pod

=head1 NAME

Blio::Image - An image node

=head1 VERSION

version 2.002

=head1 SYNOPSIS

 my $image_node = Blio::Image->new(
     base_dir    => $blio->source_dir,
     source_file => 'relative/path/to/image.jpg',
 );

 $image_node->make_thumbnail( $blio, 450 );
 $image_node->publish( $blio );

=head1 DESCRIPTION

You probably won't need to use C<Blio::Image> directly.

=head1 METHODS

=head2 publish

  $image_node->publish( $blio );

Write the image file into the L<output_dir>. Create all directories that are needed.

=head2 make_thumbnail

 $image_node->make_thumbnail( $blio, $width );

Generate a thumbnail image and store it in  L<output_dir>.

If C<$width> is not passed in, the default width from C<$blio> is used.

=attribute base_dir

<Path::Class::Dir> object pointing to the L<source_dir> of this C<Blio> instance.

=attribute source_file

<Path::Class::File> object pointing to the source image file. The file format has to be supported by C<Imager>. I would strongly suggest using jpeg or png.

=attribute url

Relative <Path::Class::File> object pointing to the non-scaled image. This can be used in templates to link to the img.

=attribute thumbnail

Relative <Path::Class::File> object pointing to the thumbnailed image. This can be used in templates to link to the thumbnail.

=head1 AUTHOR

Thomas Klausner <domm@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Thomas Klausner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
