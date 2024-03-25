# NAME

Blio - domms blogging "engine"

# VERSION

version 2.008

# SYNOPSIS

Backend for the `blio.pl` command. See [blio.pl](https://metacpan.org/pod/blio.pl) and/or `perldoc blio.pl` for details.

more docs pending...

docs provided by gabor, need to be integrated:

# CONFIGURATION

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

If no source\_dir provided or there is no src/ directory, you get this exception:

    Can't call method "done" on an undefined value at .../Blio.pm line 137.

- name

    The name of the site in the title of the pages. Default to Blio

- source\_dir

    The directory where the source files are. Each page of the site has a corresponding source file with .txt extension.
    Defaults to the `src/` directory relative to the current working directory where your run the `build.pl` script.

- output\_dir

    Directory where the generated html files should go. Defaults to `out/` relative to the current working directory.

- template\_dir

    The location of the template files. Defaults to `templates/` relative to the current working directory.
    As a fallback, there is a set of templates provided by Blio. They come in the share/templates directory of
    the distribution and are installed along the module.

- site\_url
- site\_author
- converter
- thumbnail

TODO - there are more fields that need explanation.

## Source directory hierarchy

The source directory defined using the `source_dir` paramater can havs subdirectories, but each subdirectory needs
a 'parent' page. The name of the parent page is the same as the name of the subdirectory with the additional .txt
extentsion. So if you'd like to have a `src/project/`  subdriectory, you also need to have a page called
`src/project.txt`.

If there is no index.txt in the src/ directory, Blio will generate a default index.html file.
This is not the case with subdirectories.

## Source files

Each source file has a txt extension. It has several lines of header and a body.
The module that represents each file is [Blio::Node](https://metacpan.org/pod/Blio%3A%3ANode).

    title: The Project
    date: 2013-02-10T00:27:53
    language: en
    converter: textile
    tags: Perl

    This is the project page.

The only required entry in the header is the `title`.

TODO - there are more fields that need explanation.

# AUTHOR

Thomas Klausner <domm@plix.at>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 - 2022 by Thomas Klausner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
