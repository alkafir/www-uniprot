#!/usr/bin/perl

# Copyright 2015 Alfredo Mungo <alqafir@cpan.org>
#
# This library is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

package WWW::UniProt;

use Exporter 'import';

use strict;
use LWP::UserAgent;
use URI::Escape;
use HTTP::Message;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

our $UAString = "WWW::UniProt/$WWW::UniProt::VERSION"; # User Agent string

BEGIN {
  our $VERSION = 0.004;

  our @EXPORT_OK = qw(prot_data search);
}

# Retrieves the required protein entry from the UniProt database.
#
# Arguments:
#  $protname: A string representing the protein name
#  \%opt: A dictionary reference for optional parameters. Supported keys are:
#   - dataset: A string representing the database to search (i.e. 'uniprot',
#    'uniref', 'uniparc'; defaults to 'uniprot')
#   - format: A string representing the format of the data to retrieve (i.e.
#    'fasta', 'xml', 'rdf', etc...; defaults to 'fasta')
#   - include: A boolean value representing whether referenced datasets should
#    be included inside the RDF/XML files (defaults to 0)
#
# Returns:
#  A string representing the FASTA file retrieve or undef if none is found
sub prot_data {
  my $protname = uri_escape(uc(shift));
  my $opt = shift // {};

  my $dataset = uri_escape(lc(${$opt}{dataset} // 'uniprot'));
  my $format = uri_escape(lc(${$opt}{format} // 'fasta'));
  my $include = uri_escape(${$opt}{include} // 0);

  # Retrieve entry
  my $agent = LWP::UserAgent->new(agent => $UAString);
  my $query_url = "http://www.uniprot.org/$dataset/$protname.$format"
    . (($include && ($format eq 'xml' || $format eq 'rdf'))? '?include=yes': '');
  my $response = $agent->get($query_url);
  
  return unless($response->is_success);
  return $response->content;
}

# Searches the UniProt database.
#
# Arguments:
#  $query: The search query as would be entered on the UniProt website.
#  \%opt: A dictionary reference for optional parameters. Supported keys are:
#   - limit: An integer representing the max number of entries to retrieve
#   - offset: An integer representing the number of entries to skip
#   - columns: An array reference representing the columns to retrieve
#   Any other value will be inserted as is in the url in the form KEY=VALUE
#
# Returns:
#  An array of hash references. Each reference will have the column names
#  as keys and the received values as values
sub search {
  my $query = uri_escape(shift);
  my $opt = shift // {};

  my $columns = ${$opt}{'columns'} // [qw(id)];

  # Remove already parsed entries
  delete ${$opt}{qw(columns)};

  # Produce query URL
  my $url = "http://www.uniprot.org/uniprot/?query=$query"
    . "&columns=" . uri_escape(join ',', @$columns);

  # Append other options
  while(my ($par, $val) = each(%$opt)) {
    next if($par eq 'format'); # Skip format, `tab' is enforced

    $url .= '&' . uri_escape($par) . '=' . uri_escape($val);
  }

  $url .= '&format=tab'; # Enforce `tab' format

  # Retrieve data
  my $agent = LWP::UserAgent->new(agent => $UAString);
  my $response = $agent->get($url, 'Accept-Encoding' => 'gzip');

  return unless($response->is_success);

  my $result = $response->content;
  my @result = ();

  # This is required since passing compress=yes as a parameter to the request
  # makes UniProt return a gzipped file
  if($response->header('Content-Type') eq 'application/x-gzip' || $response->header('Content-Encoding') eq 'gzip') {
    my $result_raw = $result;

    gunzip \$result_raw => \$result or die "Unable to decompress data: $GunzipError";
  }

  $result =~ s/^.*?\n//s; # Drop header

  for (split /\n/, $result) { # Parse data
    my @fields = split /\t/;
    my %record = ();

    for my $col (@$columns) {
      $record{$col} = shift(@fields);
    }

    push @result, \%record;
  }

  return @result;
}

1;

__END__

=head1 NAME

WWW::UniProt - UniProt search and data retrieval module

=head1 SYNOPSIS

  use WWW::UniProt;
  $fasta = WWW::UniProt::prot_data 'Q8JJY4'; # Grab FASTA

=head1 DESCRIPTION

This module allows programmatic access the UniProt database.
Currently two subroutines are available:

=head2 prot_data($protname)

=head2 prot_data($protname, \%opts)

This subroutine retrieves information about a protein from the UniProt
database. It accepts one mandatory argument C<$query> and one optional
C<\%opts>. The C<$protname> argument is a string representing the code of the
protein about which you want to retrieve information from UniProt (i.e.
'Q8JJY4'). The C<\%opts> argument is an optional reference to a hash of
optional arguments.

=head3 Optional arguments

=over

=item dataset

A string representing the database to search (i.e. 'uniprot', 'uniref',
'uniparc'; defaults to 'uniprot')

=item format

A string representing the format of the data to retrieve (i.e. 'fasta', 'xml',
'rdf', etc...; defaults to 'fasta')

=item include

A boolean value representing whether referenced datasets should be included
inside the RDF/XML files (defaults to 0)

=back

=head3 Return value

This subroutine returns a string representing the data as returned by UniProt
or C<undef> if the data could not be retrieved.

=head2 search($query)

=head2 search($query, \%otps)

This subroutine performs a search on UniProt. It accepts one mandatory argument
C<$query> and one optional C<\%opts>. The C<$query> argument is a query string
that will be used to search UniProt (i.e. 'myosin', 'amoeba', etc...). The
C<\%opts> argument is an optional reference to a hash of optional arguments.

=head3 Optional arguments

=over

=item limit

An integer representing the max number of entries to retrieve

=item offset

An integer representing the number of entries to skip

=item columns

An array reference representing the columns to retrieve

=item E<42>

Any other value will be inserted as is in the url in the form KEY=VALUE

=back

For a list of all the UniProt query options, refer to
L<http://www.uniprot.org/help/programmatic_access>.

=head3 Return value

This subroutine returns an array of records returned by the performed search or
C<undef> if the request could not be satisfied. Each element is a hash
reference in which each key is the name of one of the requested columns and
each value is the value of that column for that record.

=head1 CONNECTION SETTINGS

As this module uses B<LWP> to connect to UniProt, please refer to its
documentation for information about connection settings.

=head1 EXAMPLES

  # This example prints the 'ID' and 'protein names' field of the proteins
  # retrieved from UniProt, searching 'russula'.

  use WWW::UniProt;

  @result = WWW::UniProt::search 'russula', {columns => ['id', 'protein names']};

  print "ID: ${$_}{'id'}, Protein names: ${$_}{'protein names'}\n" for (@result);

=head1 AUTHOR

Alfredo Mungo <alqafir@cpan.org>

=head1 LICENSE

This library is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

L<LWP>

=cut
