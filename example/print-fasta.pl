#!/usr/bin/perl

use strict;
use warnings;

BEGIN { # Use bundled library
  require File::Basename;
  require Cwd;

  unshift @INC, Cwd::abs_path((File::Basename::fileparse(__FILE__))[1] . '../lib');
}

use WWW::UniProt;

print WWW::UniProt::get_protein 'Q9NII1'; # Print FASTA
