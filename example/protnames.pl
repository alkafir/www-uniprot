#!/usr/bin/perl

use warnings;

BEGIN {
  require File::Basename;
  require Cwd;

  push @INC, Cwd::abs_path((File::Basename::fileparse(__FILE__))[1] . '../lib');
}

use WWW::UniProt qw(search get_protein);

@result = search 'russula', {columns => ['id', 'protein names']};

print "ID: ${$_}{'id'}, Protein names: ${$_}{'protein names'}\n" for (@result);
