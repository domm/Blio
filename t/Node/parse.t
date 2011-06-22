#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Test::Most;

use Blio::Node;

{
    my ($header,$content) = Blio::Node->parse('Title: First Test!', '','A first test');
    is($header->{title},'First Test!','title');
    is($content,'A first test','content');
}

{
    my ($header,$content) = Blio::Node->parse('title  : Second Test!', "  \n",'A second test','Two lines');
    is($header->{title},'Second Test!','title');
    is($content,"A second test\nTwo lines",'content');
}

done_testing();
