#!/usr/bin/perl

# UniProt query test

use warnings;

BEGIN {
  require Cwd;
  require File::Basename;

  push @INC, Cwd::abs_path((File::Basename::fileparse(__FILE__))[1] . '../lib');
}

use WWW::UniProt;
use Test::Simple tests => 1;

@result = search 'myosine';
$result = 0;

for (@result) {
  $result++ if(${$_}{'id'} eq 'Q8JJY4');
}

ok($result, "Query UniProt");
