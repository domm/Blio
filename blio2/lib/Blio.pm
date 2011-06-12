package Blio;
use 5.010;
use Moose;
use MooseX::Types::Path::Class;
use Path::Class::Iterator;


with 'MooseX::Getopt';


has 'source_dir' => (is=>'ro',isa=>'Path::Class::Dir',required=>1,coerce=>1, lazy_build=>1);
has 'output_dir' => (is=>'ro',isa=>'Path::Class::Dir',required=>1,coerce=>1, lazy_build=>1);
has 'nodes_by_url' => (is=>'ro',isa=>'HashRef',default=>sub {{}});
has 'tree' => (is=>'ro',isa=>'ArrayRef[Blio::Node]',default=>sub {[]});

sub _build_source_dir {
    return Path::Class::Dir->new->subdir('src');
}
sub _build_outout_dir {
    return Path::Class::Dir->new->subdir('out');
}


sub run {
    my $self = shift;

    $self->collect;

}


sub collect {
    my $self = shift;
say $self->source_dir;
    my $iterator = Path::Class::Iterator->new(root => $self->source_dir);
    until ($iterator->done) {
        my $file = $iterator->next;
        say $file;
    }

}



__PACKAGE__->meta->make_immutable;
1;
