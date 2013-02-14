package Blio;
use 5.010;

# ABSTRACT: domms blogging "engine"

our $VERSION = 2.001;

use Moose;
use MooseX::Types::Path::Class;
use Path::Class;
use Path::Class::Iterator;
use Template;
use File::ShareDir qw(dist_dir);
use DateTime;

use Blio::Node;

with 'MooseX::Getopt';
with 'MooseX::SimpleConfig';

has '+configfile' => ( default => 'blio.ini' );
has 'source_dir' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    required   => 1,
    coerce     => 1,
    lazy_build => 1
);
sub _build_source_dir {
    my $self = shift;
    return Path::Class::Dir->new->subdir('src');
}

has 'output_dir' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    required   => 1,
    coerce     => 1,
    lazy_build => 1
);
sub _build_output_dir {
    my $self = shift;
    return Path::Class::Dir->new->subdir('out');
}

has 'template_dir' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    required   => 1,
    coerce     => 1,
    lazy_build => 1
);
sub _build_template_dir {
    my $self = shift;
    return Path::Class::Dir->new->subdir('templates');
}

has 'name' => (is=>'ro',isa=>'Str',default=>'Blio',required=>1);
has 'site_url' => (is=>'ro',isa=>'Str',required=>0);
has 'site_author' => (is=>'ro',isa=>'Str',required=>0);
has 'language' => (is=>'ro',isa=>'Str',default=>'en',required=>1);
has 'converter' => (is=>'ro',isa=>'Maybe[Str]',default=>undef,required=>1);
has 'thumbnail' => (is=>'ro',isa=>'Int',default=>300,required=>1);
has 'tags' => (is=>'ro',isa=>'Bool',default=>0);
has 'schedule' => (is=>'ro',isa=>'Bool',default=>0);

has 'force' => (is=>'ro',isa=>'Bool',default=>0);
has 'quiet' => (is=>'ro',isa=>'Bool',default=>0);

has 'nodes_by_url' => ( is => 'ro', isa => 'HashRef', default => sub { {} } ,traits  => [ 'NoGetopt' ]);
has 'tree' => (
    is      => 'ro',
    isa     => 'ArrayRef[Blio::Node]',
    default => sub { [] },
    traits  => ['Array', 'NoGetopt'],
    handles => { add_top_node => 'push', },
);
has 'tt' => (
    is=>'ro',
    isa=>'Template',
    lazy_build => 1,
    traits  => [ 'NoGetopt' ],
);
sub _build_tt {
    my $self = shift;
    return Template->new({
        OUTPUT_PATH=>$self->output_dir->stringify,
        INCLUDE_PATH=>[$self->template_dir->stringify, dir(dist_dir('Blio'),'templates')->stringify],
        WRAPPER=>'wrapper.tt',
        ENCODING     => 'UTF8',
    });
}

has 'nodes_by_date' => (is=>'ro', isa=>'ArrayRef',lazy_build=>1,traits  => [ 'NoGetopt' ]);
sub _build_nodes_by_date {
    my $self = shift;

    my @sorted =
        map { $_->[0] }
        sort { $b->[1] <=> $a->[1] }
        map { [$_ => $_->date->epoch] }
        values %{$self->nodes_by_url};
    return \@sorted;
}
has 'stash' => (is=>'ro',isa=>'HashRef',default=>sub {{}},traits  => [ 'NoGetopt' ]);

has 'tagindex' => (
    is=>'rw',
    isa=>'Blio::Node',
    lazy_build=>1,
    traits  => [ 'NoGetopt' ],
);
sub _build_tagindex {
    my $self = shift;
    my $tagindex = Blio::Node->new(
        base_dir => $self->source_dir,
        source_file => $0,
        id=>'tags.html',
        url=>'tags.html',
        title=>'Tags',
        date=>DateTime->now,
        content=>'',
    );
    $self->nodes_by_url->{'tags.html'}=$tagindex;
    return $tagindex;
}

sub run {
    my $self = shift;

    $self->collect;
    $self->write;
}

sub collect {
    my $self     = shift;
    my $iterator = Path::Class::Iterator->new(
        root          => $self->source_dir,
        breadth_first => 1,
    );

    my $schedule = $self->schedule;
    my $now = DateTime->now;

    until ( $iterator->done ) {
        my $file = $iterator->next;
        next if -d $file;
        next unless $file =~ /\.txt$/;

        my $node = Blio::Node->new_from_file( $self, $file );
        if ($schedule && $node->date > $now) {
            say "skipping ".$node->id." (scheduled for ".$node->date." but now is ".$now.")";
            next;
        }
        $self->nodes_by_url->{ $node->url } = $node;

        if ( $node->source_file->parent->stringify eq
            $self->source_dir->stringify ) {
            $self->add_top_node($node);
        }
        else {
            my $possible_parent_url = $node->possible_parent_url;
            if ( my $parent = $self->nodes_by_url->{$possible_parent_url} ) {
                $node->parent($parent);
                $parent->add_child($node);
                #say $node->url .' is child of '.$parent->url;
            }
            else {
                say "Cannot find parent, but not a root node: " . $node->url;
                say "For each subdirectoy, you need a file in the parent directory";
                say "with the name of the subdirectory and .txt extension";
                say "Need a file called " . $node->source_file->parent->stringify . '.txt';
                exit 0;
            }
        }
    }

    unless ($self->nodes_by_url->{'index.html'}) {
        my $index = Blio::Node->new(
            base_dir => $self->source_dir,
            source_file => $0,
            id=>'index.html',
            url=>'index.html',
            title=>'Index',
            date=>DateTime->now,
            content=>'',
        );
        $self->nodes_by_url->{'index.html'}=$index;
        $index->children($self->tree);
    }
}

sub write {
    my $self = shift;

    while (my ($url, $node) = each %{$self->nodes_by_url}) {
        say "writing $url" unless $self->quiet;
        if ($node->paged_list) {
            $node->write_paged_list($self);
        }
        else {
            $node->write($self);
        }
    }

}

__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 SYNOPSIS

Backend for the C<blio.pl> command. See L<blio.pl> and/or C<perldoc blio.pl> for details.

more docs pending...

docs provided by gabor, need to be integrated:

=head1 NAME

Blio - The static blog engine of domm

=head1 ARTICLES

=over 4

=item 2013.01.20

L<Blio updates|http://domm.plix.at/perl/2013_01_blio_updates.html>

=item 2012.09.11

L<Some new Blio features|http://domm.plix.at/perl/2012_09_11_some_new_blio_features.html>

=item 2012.08.09

L<Blio - my blogging "engine"|http://domm.plix.at/perl/2012_08_09_blio_my_blogging_engine.html>

=back

=head1 CONFIGURATION

The configuration parameters can be provided either in the configuration file that defauts to blio.ini
or on the command line.

The configuration file can look like this:

  name=Test site
  source_dir=src/
  output_dir=.
  template_dir=templates/

The configureation file must exists.
Otherwise you will get a warning like this:

  Specified configfile 'blio.ini' does not exist, is empty, or is not readable

If no source_dir provided or there is no src/ directory, you get this exception:

  Can't call method "done" on an undefined value at .../Blio.pm line 137.

=over 4

=item name

The name of the site in the title of the pages. Default to Blio

=item source_dir

The directory where the source files are. Each page of the site has a corresponding source file with .txt extension.
Defaults to the C<src/> directory relative to the current working directory where your run the C<build.pl> script.

=item output_dir

Directory where the generated html files should go. Defaults to C<out/> relative to the current working directory.

=item template_dir

The location of the template files. Defaults to C<templates/> relative to the current working directory.
As a fallback, there is a set of templates provided by Blio. They come in the share/templates directory of
the distribution and are installed along the module.

=item site_url

=item site_author

=item language

Defaults to C<en>

=item converter

=item thumbnail

Defaults to 300.

=back

TODO - there are more fields that need explanation.

=head2 Source directory hierarchy

The source directory defined using the C<source_dir> paramater can havs subdirectories, but each subdirectory needs
a 'parent' page. The name of the parent page is the same as the name of the subdirectory with the additional .txt
extentsion. So if you'd like to have a C<src/project/>  subdriectory, you also need to have a page called
C<src/project.txt>.

If there is no index.txt in the src/ directory, Blio will generate a default index.html file.
This is not the case with subdirectories.


=head2 Source files

Each source file has a txt extension. It has several lines of header and a body.
The module that represents each file is L<Blio::Node>.

  title: The Project
  date: 2013-02-10T00:27:53
  language: en
  converter: textile
  tags: Perl

  This is the project page.

The only required entry in the header is the C<title>.

TODO - there are more fields that need explanation.

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>

=head1 COPYRIGHT & LICENSE

Copyright 2013 Thomas Klausner

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

