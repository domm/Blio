package Blio;
use 5.010;
use Moose;
use MooseX::Types::Path::Class;
use Path::Class;
use Path::Class::Iterator;
use Template;
use File::ShareDir qw(dist_dir);

use Blio::Node;

with 'MooseX::Getopt';

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
has 'language' => (is=>'ro',isa=>'Str',default=>'en',required=>1);
has 'converter' => (is=>'ro',isa=>'Maybe[Str]',default=>undef,required=>1);

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
        ENCODING     => 'utf-8',
    });
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

    until ( $iterator->done ) {
        my $file = $iterator->next;
        next if -d $file;
        next unless $file =~ /\.txt$/;

        my $node = Blio::Node->new_from_file( $self, $file );
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
                say "Cannote find parent, but not a root node: " . $node->url;
                exit 0;
            }
        }
    }
}

sub write {
    my $self = shift;
    
    while (my ($url, $node) = each %{$self->nodes_by_url}) {
        say "writing $url" unless $self->quiet;
        $node->write($self);
    }
}


__PACKAGE__->meta->make_immutable;
1;
