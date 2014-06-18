#!/usr/bin/perl -w
use DBI;
use strict;
use warnings;
#cuando se actualiza la base de datos
open( FAST, 'fastaact' );
	if ( !open( FAST, 'fastaact' ) ) {die "Error al abrir el fichero 'fastaact'";}

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
