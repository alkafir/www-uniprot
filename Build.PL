#!/usr/bin/perl

use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new (
  module_name => 'WWW::UniProt',
  license => 'perl',
  allow_pureperl => 1,
  create_readme => 1,
  requires => {
    'perl' => '5.20.2',
    'LWP' => '6.13'
  },
  configure_requires => {
    'Module::Build' => '0.42'
  },
  add_to_cleanup => [
    'MANIFEST',
    '*.json',
    '*.yml',
    'README',
    '*.bak',
    '*.tar.gz'
  ]
);

$build->create_build_script;
