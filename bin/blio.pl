#!/usr/bin/env perl
use strict;
use warnings;
use Blio;

# ABSTRACT: Blio - domm's blogging "engine"
# PODNAME: blio.pl
# VERSION

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

The language of this post. See CONFIGURATION.

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

The content can be generated using the common formatting languages supported by C<Markup::Unified>, or HTML

=head3 Example

    # file: iceland/geysir.txt
    title: Geysir
    converter: textile
    thumbnail: 400

    Lots of water

    h4. Food
    
    There's a small tourist info where you can get soup.


=head1 INSTALLATION

C<Blio> runs on L<Perl|http://perl.org> application, and thus requires a rencent Perl (>= 5.10). It also reuses a lot of code from L<CPAN|http://cpan.org>.

=head2 From CPAN

The easiest way to install the current stable version of C<Blio> is via L<CPAN|http://cpan.org> and C<cpanminus>

  ~$ cpanm Blio
  Fetching http://www.cpan.org/authors/id/D/DO/DOMM/Blio-2.002.tar.gz ... OK
  Configuring Blio-2.002 ... OK
  ... # installing dependencies
  Building and testing Blio-2.002 ... OK
  Successfully installed Blio-2.002

If you don't have C<cpanminus> installed yet, L<install it right now|http://search.cpan.org/dist/App-cpanminus/lib/App/cpanminus.pm#INSTALLATION>:

  ~$ curl -L http://cpanmin.us | perl - --sudo App::cpanminus

=head2 From a tarball or git checkout

To install C<Blio> from a tarball or a git checkout, you will need L<Dist::Zilla|https://metacpan.org/module/Dist::Zilla> and some C<Dist::Zilla>-plugins

  ~/perl/Blio$ cpanm Dist::Zilla
  ~/perl/Blio$ dzil authordeps | cpanm

Now you can build a C<Blio> distributrion

  ~/perl/Blio$ dzil build

And finally you can install C<Blio> via C<dzil>:

  ~/perl/Blio$ dzil install

Or change into the build directory (F<Blio-$VERSION>) and do the old install dance:

  ~/perl/Blio/Blio-2.002$ perl Build.PL
  ~/perl/Blio/Blio-2.002$ ./Build
  ~/perl/Blio/Blio-2.002$ ./Build test
  ~/perl/Blio/Blio-2.002$ ./Build install  # might require sudo


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

Please note that some very simple (and very ugly) default templates
are provided by Blio. They come in the share/templates directory of
the distribution and are installed along the module via
File::ShareDir.

=head3 name

The name of your blog.

=head3 site_url

The URL of your blog (needed to generate a proper RSS feed)

=head3 site_author

Your name (needed to generate a proper RSS feed)

=head3 tags

Set to a true value if you want to use tags in your Blog. If you do, all tags will be collected and added to a vitual top node called 'tags.html'.

=head3 schedule

Set to a true value if you want to use the scheduling feature. If active, all node with a date in the future will not be rendered.

=head3 force

Force a complete regeneration of the site. Currently, this mostly means that all images will be again converted to thumbnails.

=head3 quiet

Do not producde regular output

=head2 Per-Node config

Per-Node config can be specified per node, or falls back to a global value specified via command line option or in the config file.

=head3 language

The default language of your content. You can set other languages per node. Default "en".

=head3 converter

The default text2html converter. You can choose other converters per node. Currently valid converters are: C<html>, C<textile>, C<markdown>, C<bbcode>. If you choose C<html>, the content is not converted at all (because we assume it's already HTML). All other converters are handled via C<Markup::Unified>.

=head3 thumbnail

The width (in pixel) of thumbnails that are generated by Blio / Imager. Default "300".

=head1 USAGE

=head2 DIRECTORY LAYOUT

=head2 NODE SYNTAX

=head1 TEMPLATES

=head2 Methods available in templates

=head3 $blio->..

=head3 $node->..

=head1 ARTICLES & PRESENTATIONS

=over 4

=item 2013.05.03

L<Talk at Linuxwochen 2013 Wien|http://domm.plix.at/talks/blio.html> (in german)

=item 2013.03.28

L<Building a static blog using Blio and Github|http://perl5maven.com/building-a-static-blog-using-blio-and-github>

=item 2013.01.20

L<Blio updates|http://domm.plix.at/perl/2013_01_blio_updates.html>

=item 2012.09.11

L<Some new Blio features|http://domm.plix.at/perl/2012_09_11_some_new_blio_features.html>

=item 2012.08.09

L<Blio - my blogging "engine"|http://domm.plix.at/perl/2012_08_09_blio_my_blogging_engine.html>

=back


