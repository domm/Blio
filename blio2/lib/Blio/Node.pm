package Blio::Node;
use 5.010;
use Moose;
use namespace::autoclean;
use MooseX::Types::Path::Class;


has 'source_file'=>(is=>'ro',isa=>'Path::Class::File',required=>1,coerce=>1);
has 'output_file'=>(is=>'ro',isa=>'Path::Class::File',required=>1,coerce=>1)
has 'url'=>(is=>'ro',isa=>'Str',required=>1);
has 'title' => (is=>'ro',isa=>'Str',required=>1);
has 'date' => (is=>'ro',isa=>'DateTime',required=>1);
has 'raw_content' => (is=>'ro',isa=>'Str'); 
has 'rendered_content' => (is=>'rw',isa=>'Str');
has 'tags' => (is=>'rw',isa=>'ArrayRef',default=>sub {[]}, traits  => ['Array']);
has 'images' => (is=>'rw',isa=>'ArrayRef[Blio::Image]',default=>sub {[]}, traits  => ['Array']);
has 'children' => (is=>'rw',isa=>'ArrayRef[Blio::Node]',default=>sub {[]}, traits  => ['Array']);
has 'parent' => (is=>'ro',isa=>'Maybe[Blio::Node]');


__PACKAGE__->meta->make_immutable;
1;
