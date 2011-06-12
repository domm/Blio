package Blio::Node;
use 5.010;
use Moose;
use namespace::autoclean;
use MooseX::Types::Path::Class;
use Moose::Util::TypeConstraints;
use DateTime::Format::ISO8601;
class_type 'DateTime';
coerce 'DateTime'
    => from 'Int'
    => via { my $d = DateTime->from_epoch(epoch=>$_);$d->set_time_zone('local');return $d;}
    => from 'Str'
    => via { DateTime::Format::ISO8601->parse_datetime($_) };

has 'base_dir' => (is=>'ro',isa=>'Path::Class::Dir',required=>1);
has 'source_file'=>(is=>'ro',isa=>'Path::Class::File',required=>1,coerce=>1);
has 'url'=>(is=>'ro',isa=>'Str',lazy_build=>1);
sub _build_url {
    my $self = shift;
    my $path = $self->source_file->stringify;
    if ($self->has_children) {
        $path=~s{\.txt$}{/index.html};
    }
    else {
        $path=~s/\.txt$/.html/;
    }
    return $path;
}

has 'title' => (is=>'ro',isa=>'Str',required=>1);
has 'date' => (is=>'ro',isa=>'DateTime',required=>1, lazy_build=>1, coerce=>1);
sub _build_date {
    my $self = shift;
    my $stat = $self->base_dir->file($self->source_file)->stat;
    return $stat->mtime;
}
has 'raw_content' => (is=>'ro',isa=>'Str'); 
has 'rendered_content' => (is=>'rw',isa=>'Str');
has 'tags' => (is=>'rw',isa=>'ArrayRef',default=>sub {[]}, traits  => ['Array']);
has 'images' => (is=>'rw',isa=>'ArrayRef[Blio::Image]',default=>sub {[]}, traits  => ['Array']);
has 'children' => (is=>'rw',isa=>'ArrayRef[Blio::Node]',default=>sub {[]}, traits  => ['Array'],
handles=>{
    has_children=>'count',    
},

);
has 'parent' => (is=>'ro',isa=>'Maybe[Blio::Node]');

sub new_from_file {
    my ($class, $base, $file) = @_;

    my @lines = $file->slurp(
        chomp => 1,
        iomode => '<:encoding(UTF-8)',
    );
    my ($header, $raw_content) = $class->parse(@lines);
    my $node = $class->new(
        base_dir=>$base,
        source_file=>$file->relative($base),
        %$header,
        raw_content=>$raw_content,
    );

    return $node;

}

sub parse {
    my ($class, @lines) = @_;
    my %header;
    while (my $line = shift(@lines)) {
        last if $line =~ /\^s+$/;
        last unless $line =~ /:/;
        my ($key, $value) = split(/\s*:\s*/,$line,2);
        $header{lc($key)} = $value;  
    }
    my $content = join("\n",@lines);
    return \%header, $content;
}


__PACKAGE__->meta->make_immutable;
1;
