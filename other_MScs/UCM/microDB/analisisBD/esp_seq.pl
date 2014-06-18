#!/usr/bin/perl -w

use DBI;
use strict;
use warnings;

$|=1;

my $dbh = DBI->connect( "dbi:Pg:dbname=microdb;host=localhost","agirre", "", { RaiseError => 0, AutoCommit => 0 } );
unless ( defined($dbh) ) {die "Ha habido un problema al conectar con la base de datos:"  . $DBI::errstr  unless ( defined($dbh) );}

my $sthfech = $dbh->prepare("SELECT Fecha FROM micro" );
unless ( defined ($sthfech) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

open( FECHA, '+>FECHA.txt' );	#archivo para guardar el ultimo numero de muestra
	if ( !open( FECHA, 'FECHA.txt' ) ) {die "Error al abrir el fichero 'FECHA.txt'";}

my $e='';
my @pmid=();
my $seq ='';
my $i='';
my @clus=();
my @mues=();
my $clus='';
my $mues='';
my $u='';
my $o='';
my $fech='';
my @fecha=();
my $ano='';
my $ano1='';

unless ( $sthfech->execute) {die "Se ha producido un problema al conectar con la base de datos: " . $DBI::errstr unless ( defined($dbh) );}
if ($sthfech->rows == 0) {
	print "mal\n";
}
else {
	while (my ($fech) = $sthfech->fetchrow_array()) {
	push(@fecha, $fech);
	}
}
foreach $u(@fecha){
	if ($u=~/\d{2}\-\w{3}\-(\d{4})/){
		$ano=$1;
	}
	print FECHA "$ano\n";

}

#### Cortar la comunicacion con las tablas

$sthfech->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

## Desconectar base de datos
$dbh->disconnect || warn " Fallo al desconectar . Error : $DBI::errstr \n ";

close(FECHA);

system ('sort FECHA.txt > sortFECHA.txt');
system ('uniq sortFECHA > uniqFECHA.txt');

exit;
