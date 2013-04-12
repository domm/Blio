#!/usr/bin/env perl
use strict;
use warnings;
use Blio;

# ABSTRACT: script to run Blio
# PODNAME: blio.pl

Blio->new_with_options->run;

__END__

=head1 SYNOPSIS

  ~/your_blog$ blio.pl --source_dir src --output_dir htdocs --template_dir templates

=head1 DESCRIPTION

C<Blio> is a very simple blogging "engine". I call it an '"engine"' because Blio is basically a slightly enhanced and streamlined (for my use cases, at least) ttree, or yet another pre-clone of jekyll.

In other words, it takes a bunch of plain text files containing some simple headers and some content, runs them through some templates, and writes out some html files for static serving. Blio also does some other things (most notably image handling, powered by Imager).

=head2 Directory Layout

C<Blio> needs three directories: F<src>, F<out> and F<templates>.

F<templates> contains the C<Template::Toolkit> templates used to render the HTML, F<src> contains all your raw content and C<out> containes the rendered HTML content ready for serving by your favourite web server.

But there a few formal restrictions you need to observer so C<Blio> can work:

=over

=item * Each node has to be a plain text file. It should have an all-lowercase filename. It must have an all-ascii filename. It must end in F<'.txt'>.

=item * If a node should contain sub-nodes, those have to be stored in a directory having exactly the same name as the node, but without the F<'.txt'>.

=item * If you want to link exactly one image to a node, the image has to have exactly the same name as the node, but with F<'.txt'> replaced with a proper extension.

=item * If you want to link one or more images to a node, you must put them in a directory at the same level as the node. This directory must have the same name as the node, but with F<'.txt'> replaced by F<'_images'>

=back

=head3 Example

  |-- out
  |-- templates
  `-- src
      |-- iceland
      |   |-- geysir.txt
      |   |-- geysir_images
      |   |   |-- geysir_1.jpg
      |   |   `-- geysir_2.jpg
      |   |-- gullfoss.txt
      |   |-- gullfoss.jpg
      |   `-- no_image.txt
      `-- iceland.txt

=head2 Node Format

Each Node is a simple plain-text UTF8 encoded file consisting of an HTTP-like header, a blank line and the content.

=head3 Header Fields

=head4 title

The title of this blog post. Required

=head4 date

The publication date of this post. Has to be parsable by C<DateTime::Format::ISO8601>. If this field is not set in the file, the mtime of the file will be used.

=head4 language

The language of this post.

=head4 converter

The converter to use. See CONFIGURATION.

=head4 feed

If set to a true value, an RSS feed will be generated containing the children of this node.

=head4 author

The name of the author of this post

=head4 tags

A comma seperated list of tags. See also the Global Config C<tags>

=head4 paged_list

Set to a value > 0 to have the children of this node paged.

=head4 inline_images

Enable inline images

=head4 thumbnail

Thumbnail size

=head3 Content

The content can be generated the common formatting languages supported by C<Markup::Unified>, or HTML

=head3 Example

    # file: iceland/geysir.txt
    title: Geysir
    converter: textile
    thumbnail: 400

    Lots of water

    h4. Food
    
    There's a small tourist info where you can get soup.

=head1 CONFIGURATION

C<Blio> can be configured via a combination of command line options and a config file.

See MooseX::Getopt and MooseX::SimpleConfig for the implementation details.

=head2 Global Config

Global Config can be specified via command line option or the global config file.

=head3 configfile

Path to the configfile. Default 'blio.ini'. The configfile has to be parsable by MooseX::SimpleConfig.

=head3 source_dir

The directory containing the plain text source files. Here is where you generate and edit content. Default 'src'.

=head3 output_dir

The directory where the rendered HTML files are stored. This directory should be the document root of your webserver. Default 'out'.

=head3 template_dir

The directory containing the templates used to render your content. Default 'template'.

Please note that some very simple (and very ugly) default templates are provided by Blio. These are installed via File::ShareDir.

=head3 name

The name of your blog.

=head3 site_url

The URL of your blog (needed to generate a proper RSS feed)

=head3 site_author

Your name  (needed to generate a proper RSS feed)

=head3 tags

Set to a true value if you want to use tags in your Blog. If you do, all tags will be collected and added to a vitual top node called 'tags.html'.

=head3 schedule

Set to a true value if you want to use the scheduling feature. If active, all node with a date in the future will not be rendered.

=head3 force

Force a complete regeneration of the site. Currently, this mostly means that all images will be again converted to thumbnails.

=head3 quiet

Do not producde regular output

=head2 Per-Node config

Per-Node config can be specified per node, or falls back to a global value speciefied via command line option or in the config file.

=head3 language

The default language of your content. You can set other languages per node.

=head3 converter

The default text2html converter. You can choose other converters per node. Currently valid converters are: C<html>, C<textile>, C<markdown>, C<bbcode>. If you choose C<html>, the content is not converted at all (because we assume it's already HTML). All other converters are handled via C<Markup::Unified>.

=head3 thumbnail

The width (in pixel) of thumbnails that are generated by Blio / Imager.

=head1 USAGE

