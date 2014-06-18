#!/usr/bin/perl -w
use DBI;
use strict;
use warnings;
# Cuando se caraga la base de datos por primera vez
open( FAST, 'outfasta' );
	if ( !open( FAST, 'outfasta' ) ) {die "Error al abrir el fichero 'outfasta'";}

my $numfa = 0;
my $i = 0;
foreach (<FAST>) {
	open (PART, "+>fas$i.txt")||die "ERROR: no se puede leer o crear el archivo titulo\n";
	my $line = $_;
	chomp($line);
	if ($line =~ /^>/){
		$numfa++;
	}
	print PART $line;
	if ($numfa == 50000){
		if ($line !~ /.+/){
			close(PART);
			$i++;
		}
	}
}
close(FAST);
close(PART);

exit;
