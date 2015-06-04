# NAME

WWW::UniProt - UniProt search and data retrieval module

# SYNOPSIS

    use WWW::UniProt;
    $fasta = get_protein 'Q8JJY4'; # Grab FASTA

# DESCRIPTION

This module allows programmatic access the UniProt database.
Currently two subroutines are available:

## get\_protein($protname)

## get\_protein($protname, \\%opts)

This subroutine retrieves information about a protein from the UniProt
database. It accepts one mandatory argument `$query` and one optional
`\%opts`. The `$protname` argument is a string representing the code of the
protein about which you want to retrieve information from UniProt (i.e.
'Q8JJY4'). The `\%opts` argument is an optional reference to a hash of
optional arguments.

### Optional arguments

- dbname

    A string representing the database to search (i.e. 'uniprot', 'uniref',
    'uniparc'; defaults to 'uniprot')

- format

    A string representing the format of the data to retrieve (i.e. 'fasta', 'xml',
    'rdf', etc...; defaults to 'fasta')

- include

    A boolean value representing whether referenced datasets should be included
    inside the RDF/XML files (defaults to 0)

### Return value

This subroutine returns a string representing the data as returned by UniProt
or `undef` if the data could not be retrieved.

## search($query)

## search($query, \\%otps)

This subroutine performs a search on UniProt. It accepts one mandatory argument
`$query` and one optional `\%opts`. The `$query` argument is a query string
that will be used to search UniProt (i.e. 'myosine', 'amoeba', etc...). The
`\%opts` argument is an optional reference to a hash of optional arguments.

### Optional arguments

- limit

    An integer representing the max number of entries to retrieve

- offset

    An integer representing the number of entries to skip

- columns

    An array reference representing the columns to retrieve

- \*

    Any other value will be inserted as is in the url in the form KEY=VALUE

For a list of all the UniProt query options, refer to
[http://www.uniprot.org/help/programmatic\_access](http://www.uniprot.org/help/programmatic_access).

### Return value

This subroutine returns an array of records returned by the performed search or
`undef` if the request could not be satisfied. Each element is a hash
reference in which each key is the name of one of the requested columns and
each value is the value of that column for that record.

# EXAMPLES

    # This example prints the 'ID' and 'protein names' field of the proteins
    # retrieved from UniProt, searching 'russula'.
    
    use WWW::UniProt;
    
    @result = search 'russula', {columns => ['id', 'protein names']};
    
    print "ID: ${$_}{'id'}, Protein names: ${$_}{'protein names'}\n" for (@result);

# AUTHOR

Alfredo Mungo <alqafir@cpan.org>

# LICENSE

This library is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.
