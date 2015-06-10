#!/usr/bin/perl

use strict;
use warnings;

BEGIN {
  require File::Basename;
  require Cwd;

  unshift @INC, Cwd::abs_path((File::Basename::fileparse(__FILE__))[1] . '../lib');
}

use WWW::UniProt qw(search prot_data);

my @result = search 'russula', {columns => ['id', 'protein names']};

print "ID: ${$_}{'id'}, Protein names: ${$_}{'protein names'}\n" for (@result);
