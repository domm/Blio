package Blio::Node;
use 5.010;
use Moose;
use namespace::autoclean;
use MooseX::Types::Path::Class;
use Moose::Util::TypeConstraints;
use DateTime::Format::ISO8601;
use Encode;
use Markup::Unified;

class_type 'DateTime';
coerce 'DateTime' => from 'Int' => via {
    my $d = DateTime->from_epoch( epoch => $_ );
    $d->set_time_zone('local');
    return $d;
} => from 'Str' => via { DateTime::Format::ISO8601->parse_datetime($_) };

has 'base_dir' => ( is => 'ro', isa => 'Path::Class::Dir', required => 1 );
has 'source_file' =>
    ( is => 'ro', isa => 'Path::Class::File', required => 1, coerce => 1 );
has 'id' => (is => 'ro', isa=>'Str', required=>1, lazy_build=>1);
sub _build_id {
    my $self = shift;
    my $path = $self->source_file->relative($self->base_dir)->stringify;
    $path=~s/\.txt$//;
    return $path;
}
has 'url' => ( is => 'ro', isa => 'Str', lazy_build => 1 );
sub _build_url {
    my $self = shift;
    return $self->id.'.html';
}

has 'template' => (is=>'ro',isa=>'Str',required=>1,default=>'node.tt');
has 'title' => ( is => 'ro', isa => 'Str', required => 1 );
has 'date' => (
    is         => 'ro',
    isa        => 'DateTime',
    required   => 1,
    lazy_build => 1,
    coerce     => 1
);
sub _build_date {
    my $self = shift;
    my $stat = $self->source_file->stat;
    return $stat->mtime;
}

has 'language' => (is=>'ro', isa=>'Maybe[Str]');
has 'converter' => (is=>'ro', isa=>'Maybe[Str]');

has 'raw_content'      => ( is => 'ro', isa => 'Str' );
has 'content' => ( is => 'rw', isa => 'Str', lazy_build=>1 );
sub _build_content {
    my $self = shift;
    my $converter = $self->converter;
    my $raw_content = $self->raw_content;
    return $raw_content unless $converter;
    
    given ($converter) {
        when ('html') { return $raw_content }
        when ([qw(textile markdown bbcode)]) {
            my $o = Markup::Unified->new();
            return $o->format($raw_content, 'textile')->formatted;
        }
        when ('domm_legacy') {
            return $self->convert_domm_legacy($raw_content);
        }
        default {
            my $method = 'convert_'.$converter;
            if ($self->can($method)) {
                return $self->$method($raw_content);
            }
            else {
                return "<pre>No such converter: $converter</pre>".$raw_content;
            }
        }
    }
}
has 'tags'             => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
    traits  => ['Array'] );
has 'images' => (
    is      => 'rw',
    isa     => 'ArrayRef[Blio::Image]',
    default => sub { [] },
    traits  => ['Array'] );
has 'children' => (
    is      => 'rw',
    isa     => 'ArrayRef[Blio::Node]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        has_children => 'count',
        add_child    => 'push',
    },

);
has 'parent' => ( is => 'rw', isa => 'Maybe[Blio::Node]', weak_ref => 1);

sub new_from_file {
    my ( $class, $blio, $file ) = @_;
    say $file;
    my @lines = $file->slurp(
        chomp  => 1,
        iomode => '<:encoding(UTF-8)',
    );
    my ( $header, $raw_content ) = $class->parse(@lines);
    my $node = $class->new(
        base_dir    => $blio->source_dir,
        language    => $blio->language,
        converter   => $blio->converter,
        source_file => $file,
        %$header,
        raw_content => encode_utf8($raw_content),
    );

    return $node;
}

sub parse {
    my ( $class, @lines ) = @_;
    my %header;
    while ( my $line = shift(@lines) ) {
        last if $line =~ /\^s+$/;
        last unless $line =~ /:/;
        my ( $key, $value ) = split( /\s*:\s*/, $line, 2 );
        $header{ lc($key) } = encode_utf8($value);
    }
    my $content = join( "\n", @lines );
    return \%header, $content;
}

sub write {
    my ($self, $blio) = @_;

    my $tt = $blio->tt;
    
    my $outfile = $blio->output_dir->file($self->url);
    $outfile->parent->mkpath unless (-d $outfile->parent);

    $tt->process($self->template,
        {
            node=>$self,
            blio=>$blio,
        },
        ,$outfile->relative($blio->output_dir)->stringify
    ) || die $tt->error;

    my $utime = $self->date->epoch;
    utime($utime,$utime,$outfile->stringify);
}

sub relative_root {
    my $self = shift;
    my $url = $self->url;
    my @level = $url=~m{/}g;
    
    return '' unless @level;
    
    return join('/',map { '..' } @level).'/';
}

sub possible_parent_url {
    my $self = shift;
    my $ppurl = $self->url;
    $ppurl =~ s{/\w+.html$}{.html};
    return $ppurl;
}

sub convert_domm_legacy {
    my ($self, $raw) = @_;
    return $raw;
}

__PACKAGE__->meta->make_immutable;
1;
