package Blio::Node;
use 5.010;
use Moose;
use namespace::autoclean;
use MooseX::Types::Path::Class;
use Moose::Util::TypeConstraints;
use DateTime::Format::ISO8601;
use Encode;
use Markup::Unified;
use Blio::Image;
use XML::Atom::SimpleFeed;
use DateTime::Format::RFC3339;

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

has 'template' => (is=>'rw',isa=>'Str',required=>1,default=>'node.tt');
has 'title' => ( is => 'ro', isa => 'Str', required => 1 );
has 'date' => (
    is         => 'rw',
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
has 'feed' => (is=>'ro',isa=>'Bool',default=>0);
has 'author' => (is=>'ro',isa=>'Str');
has 'paged_list' => (is=>'ro',isa=>'Int',default=>0);
has 'prev_next_nav' => (is=>'ro',isa=>'Int',default=>0);

has 'raw_content'      => ( is => 'rw', isa => 'Str' );
has 'content' => ( is => 'rw', isa => 'Str', lazy_build=>1 );
sub _build_content {
    my $self = shift;
    my $converter = $self->converter;
    my $raw_content = $self->raw_content;
    return $raw_content unless $converter;

    if ($self->inline_images) {
        $raw_content=~s/<bliothumb:(.*?)>/$self->image_by_name($1,'thumbnail')/ge;
        $raw_content=~s/<blioimg:(.*?)>/$self->image_by_name($1,'url')/ge;

        $raw_content=~s/<bliothumb#(\d+)>/$self->image_by_index($1,'thumbnail')/ge;
        $raw_content=~s/<blioimg#(\d+)>/$self->image_by_index($1,'url')/ge;
    }

    given ($converter) {
        when ('html') { return $raw_content }
        when ([qw(textile markdown bbcode)]) {
            my $o = Markup::Unified->new();
            return $o->format($raw_content, 'textile')->formatted;
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
    traits  => ['Array'],
    handles => {
        has_tags => 'count',
    },
    );
has 'images' => (
    is      => 'rw',
    isa     => 'ArrayRef[Blio::Image]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        has_images   => 'count',
        add_image    => 'push',
    },
    );
has 'inline_images' => (is=>'ro',isa=>'Bool',default=>0);
has 'thumbnail' => (is=>'ro',isa=>'Int');

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
has 'stash' => (is=>'ro',isa=>'HashRef',default=>sub {{}});
has 'feed_url' => (is=>'ro',isa=>'Str',lazy_build=>1);
sub _build_feed_url {
    my $self = shift;
    return $self->id.'.xml';
}

sub new_from_file {
    my ( $class, $blio, $file ) = @_;
    my @lines = $file->slurp(
        chomp  => 1,
        iomode => '<:encoding(UTF-8)',
    );
    my ( $header, $raw_content ) = $class->parse(@lines);
    my $tags = delete $header->{tags};
    my $node = $class->new(
        base_dir    => $blio->source_dir,
        language    => $blio->language,
        converter   => $blio->converter,
        source_file => $file,
        %$header,
        raw_content => $raw_content,
        stash=>$header,
    );

    $node->register_tags($blio, $tags) if $tags && $blio->tags;

    # check and add single image
    my $single_image = $file->basename;
    $single_image =~ s/\.txt$/.jpg/i;
    my $single_image_file = $file->parent->file($single_image);
    if (-e $single_image_file) {
        my $img = Blio::Image->new(
            base_dir    => $blio->source_dir,
            source_file => $single_image_file,
        );
        $node->add_image($img);
    }

    # check and add images dir
    my $img_dir = $file->basename;
    $img_dir=~s/\.txt$//;
    $img_dir = $file->parent->subdir($img_dir.'_images');
    if (-d $img_dir) {
        while (my $image_file = $img_dir->next) {
            next unless $image_file =~ /\.jpe?g$/i;
            my $img = Blio::Image->new(
                base_dir    => $blio->source_dir,
                source_file => $image_file,
            );
            $node->add_image($img);
        }
    }

    return $node;
}

sub parse {
    my ( $class, @lines ) = @_;
    my %header;
    while ( my $line = shift(@lines) ) {
        last if $line =~ /^\s+$/;
        last unless $line =~ /:/;
        chomp($line);
        $line=~s/\s+$//;
        my ( $key, $value ) = split( /\s*:\s*/, $line, 2 );
        $header{ lc($key) } = $value;
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
            base=>$self->relative_root,
        },
        ,$outfile->relative($blio->output_dir)->stringify,
        binmode => ':utf8',
    ) || die $tt->error;

    my $utime = $self->date->epoch;
    if ($self->has_children) {
        my $children = $self->sorted_children;
        my $child_utime = $children->[0]->date->epoch;
        $utime = $child_utime if $child_utime > $utime;
    }
    utime($utime,$utime,$outfile->stringify);

    if ($self->has_images) {
        foreach my $img (@{$self->images}) {
            if ($blio->force || !-e $blio->output_dir->file($img->thumbnail)) {
                say "\timage ".$img->url unless $blio->quiet;
                $img->publish($blio);
                $img->make_thumbnail($blio, $self->thumbnail);
            }
        }
    }

    $self->write_feed($blio) if $self->feed;
}

sub write_paged_list {
    my ($self, $blio) = @_;

    my $list = $self->sorted_children;
    my $items_per_page = $self->paged_list;
    my $current_page = 1;
    my $outfile = $blio->output_dir->file($self->url);
    my $utime=0;
    my @page;
    foreach my $i (0 .. $#{$list}) {
        if ($i>0 && $i % $items_per_page == 0) {
            # write this page
            $self->_write_page($blio, \@page, $current_page, $list, $outfile, $utime, $i);

            # start new page
            my $utime=0;
            @page=();
            $current_page++;
            $outfile = $blio->output_dir->file($self->id."_".$current_page.'.html');
        }
        push(@page, $list->[$i]);
        my $this_utime = $list->[$i]->date->epoch;
        $utime = $this_utime if $this_utime > $utime;
        # write last page
        $self->_write_page($blio, \@page, $current_page, $list, $outfile, $utime) if $i == $#{$list} ;
    }

    $self->write_feed($blio) if $self->feed;
}

sub _write_page {
    my ($self, $blio, $page, $current_page, $list, $outfile, $utime, $i ) = @_;
    my $tt = $blio->tt;
    my $data = {
        node=>$self,
        page=>$page,
        blio=>$blio,
        base=>$self->relative_root,
    };
    $data->{prev} = sprintf("%s_%i.html",$self->id, $current_page-1) if $current_page > 1;
    $data->{prev} = $self->url if $current_page==2;
    $data->{next} = sprintf("%s_%i.html",$self->id, $current_page+1) if $i && $list->[$i+1];
    $tt->process($self->template,
        $data,
        ,$outfile->relative($blio->output_dir)->stringify,
        binmode => ':utf8',
    ) || die $tt->error;
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

sub sorted_children {
    my ($self, $limit) = @_;
    my @sorted =
        map { $_->[0] }
        sort { $b->[1] <=> $a->[1] }
        map { [$_ => $_->date->epoch] } @{$self->children};
    if ($limit && $limit < @sorted) {
        @sorted = splice(@sorted,0,$limit);
    }
    return \@sorted;
}

sub sort_children_by {
    my ($self, $order_by, $limit) = @_;
    my @sorted =
        map { $_->[0] }
        sort { $a->[1] cmp $b->[1] }
        map { [$_ => lc($_->$order_by)] } @{$self->children};
    if ($limit && $limit < @sorted) {
        @sorted = splice(@sorted,0,$limit);
    }
    return \@sorted;
}

sub sorted_images {
    my $self = shift;
    my @sorted = 
        map { $_->[0] }
        sort { $a->[1] cmp $b->[1] }
        map { [$_ => $_->source_file->basename ] } @{$self->images};
    return \@sorted;
}

sub teaser {
    my ($self, $length) = @_;
    return unless $self->raw_content;
    $length ||= 200;

    my $teaser;
    if ($length =~ /^\d+$/) {
        $teaser = $self->content;
        $teaser =~ s/<a href(.*?)>//g;
        $teaser =~ s{</a>}{}g;
        $teaser =~ s{<img(.*?)>}//g;
        $teaser = substr($teaser,0,$length);
        $teaser =~s/\s\S+$/ .../;
    }
    else {
        my $rest;
        ($teaser, $rest) = split($length, $self->content, 2);
        unless ($rest) {
            $teaser = $self->teaser(200);
        }
    }
    return $teaser;
}

sub write_feed {
    my ($self, $blio) = @_;

    my $site_url = $blio->site_url;
    die "Cannot generate Atom Feed without site_url, use --site_url to set it" unless $site_url;
    $site_url .= '/' unless $site_url =~m{/$};

    my $children = $self->sorted_children(5);

    return unless @$children;
    my $rfc3339 = DateTime::Format::RFC3339->new();

    my $feed = XML::Atom::SimpleFeed->new(
        title=>decode_utf8($self->title || 'no title'),
        author=>$blio->site_author || $0,
        link=>{
            href=>$site_url.$self->feed_url,
            rel=>'self',
        },
        id=>$site_url.$self->feed_url,
        updated=>$rfc3339->format_datetime($children->[0]->date),
    );

    foreach my $child (@$children) {
        next unless $child->parent;
        my @entry = (
            title=>decode_utf8($child->title || 'no title'),
            link=>$site_url.$child->url,
            id=>$site_url.$child->url,
            updated=>$rfc3339->format_datetime($child->date),
            category=>$child->parent->id,
            summary=>decode_utf8($child->teaser || ' '),
            content=>decode_utf8($child->content),
        );
        push (@entry,author => $self->author) if $self->author;
        if ($child->has_tags) {
            foreach my $tag (@{$child->tags}) {
                push (@entry, category => $tag->title);
            }
        }
        $feed->add_entry( @entry );
    }
    my $feed_file = $blio->output_dir->file($self->feed_url);
    open(my $fh,'>:encoding(UTF-8)',$feed_file->stringify) || die "Cannot write to Atom feed file $feed_file: $!";
    $feed->print($fh);
    close $fh;

    my $utime = $children->[0]->date->epoch;
    utime($utime,$utime,$feed_file->stringify);
}

sub register_tags {
    my ($self, $blio, $tags ) = @_;
    my @tags = split(/\s*,\s*/,$tags);
    my $tagindex = $blio->tagindex;
    my @tagnodes;
    foreach my $tag (@tags) {
        my $tagid = $tag;
        $tagid=~s/\s/_/g;
        $tagid=~s/\W/_/g;
        my $tagnode = $blio->nodes_by_url->{"tags/$tagid.html"};
        unless ($tagnode) {
            $tagnode = Blio::Node->new(
                base_dir => $blio->source_dir,
                source_file => $0,
                id=>$tagid.'.html',
                url=>"tags/$tagid.html",
                title=>$tag,
                date=>DateTime->new(year=>1980),
                content=>'',
            );
            $blio->nodes_by_url->{$tagnode->url} = $tagnode;
            $tagnode->parent($tagindex);
            $tagindex->add_child($tagnode);
        }
        $tagnode->add_child($self);
        if ($self->date > $tagnode->date) {
            $tagnode->date($self->date);
        }
        push(@tagnodes,$tagnode);
    }
    $self->tags(\@tagnodes) if @tagnodes;
}

sub image_by_name {
    my ($self, $name, $method) = @_;
    $method ||= 'url';
    my @found = grep { $name eq $_->source_file->basename } @{$self->images};
    if (@found == 1) {
        return $self->relative_root.$found[0]->$method;
    }
    return "cannot_resolve_image_".$name."_found_".scalar @found;
}

sub image_by_index {
    my ($self, $index, $method) = @_;
    $method ||= 'url';

    my $img = $self->images->[$index - 1];
    return $self->relative_root.$img->$method if $img;
    return "cannot_resolve_image_index_".$index;
}

sub prev_next_post {
    my $self = shift;
    return unless my $p = $self->parent;
    return unless $p->prev_next_nav;
    my $siblings = $p->sorted_children;
    my $hit;
    my $i;
    for ($i=0;$i<@$siblings;$i++) {
        my $this = $siblings->[$i];
        if ($this->id eq $self->id) {
            $hit = $i;
            last;
        }
    }
    my %sib;
    $sib{prev} = $siblings->[$i+1] if $i < $#{$siblings} && $siblings->[$i+1];
    $sib{next} = $siblings->[$i-1] if ($i-1 >= 0 && $siblings->[$i-1]);
    return \%sib;
}

__PACKAGE__->meta->make_immutable;
1;
