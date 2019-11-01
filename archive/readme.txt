Blio - domms blogging "engine"

See http://domm.plix.at/perl/2012_08_09_blio_my_blogging_engine.html
for some first thoughts on this fine pice of software.

See all my posts on Blio here:
http://domm.plix.at/tags/Blio.html

TODO:

- documentation!!
- autogenerate readme via distzilla, see
  http://babyl.dyndns.org/techblog/entry/dist-zilla-github
- delete a node:
  currently the rendered html files have to be deleted manually on the
  server. the idea is to first set a node to deleted (via a new header field
  'delete') & commit it. the next build than shall remove the rendered file
  (and all related images). Then git rm the node & commit again
- write some blog posts on domm.plix.at about:
  - tagging
  - config file handling via MooseX::Config
  - the post-receive gitolite build hook
- maybe set up a site dedicated to Blio, and copy / republish the blog
  posts there (add this blog to ironman?)


