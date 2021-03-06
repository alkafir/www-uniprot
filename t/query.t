#!/usr/bin/perl

# UniProt query test

use strict;
use warnings;

BEGIN {
  require Cwd;
  require File::Basename;

  unshift @INC, Cwd::abs_path((File::Basename::fileparse(__FILE__))[1] . '../lib');
}

use WWW::UniProt qw(search);
use Test::Simple tests => 1;

my @result = search 'myosine';
my $result = 0;

for (@result) {
  $result++ if(${$_}{'id'} eq 'Q8JJY4');
}

ok($result, "Query UniProt");
