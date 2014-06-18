#!/usr/bin/perl -w

use DBI;
use strict;
use warnings;
use Text::LevenshteinXS qw (distance);

# ASIGNA UN NUMERO IDENTIFICADRO DE AMBIENTE A CADA GRUPO DE MUESTRAS QUE TENGAN EL MISMO ISOLATION SOURCE Y METADATOS

# CORREGIR

my $dbh = DBI->connect( "dbi:Pg:dbname=microdb;host=localhost","agirre", "", { RaiseError => 0, AutoCommit => 0 } );
unless ( defined($dbh) ) {die "Ha habido un problema al conectar con la base de datos:"  . $DBI::errstr  unless ( defined($dbh) );}

#entre todos los titulos
open( UNIQ, 'uniqiso.txt' );		#archivo todo corregido sin redundancias
	if ( !open( UNIQ, 'uniqiso.txt' ) ) {die "Error al abrir el fichero 'uniqiso.tx'";}
	my @uniq= <UNIQ>;
	chomp(@uniq);
open( UNIQ, 'id_ambiente.txt' );		#archivo todo corregido sin redundancias
	if ( !open( UNIQ, 'id_ambiente.txt' ) ) {die "Error al abrir el fichero 'id_ambiente.txt'";}
	my @amb= <UNIQ>;
	chomp(@amb);
### Preparar la tabla de datos para la tabla de archivos purgados

my $sthpmid = $dbh->prepare("SELECT Pmid, Metadatos FROM micro WHERE Isolation_source=? " );
unless (defined($sthpmid)){die "no se pueden preparar las datos para insertarlos en las tablas\n";}

my $sthambiente = $dbh->prepare("INSERT INTO ambiente(Pmid, ID_ambiente, Nombre_tipo, metadata) VALUES (?, ?, ?, ?)");
unless ( defined ($sthambiente) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

my $errflag = 0;
my $pm='';
my $line = '';
my $me = '';
my @ea = ();
my $pmid='';
my $a='';
my $e='';
my $i='';
my $u='';
my $meta='';
foreach $i(@amb){
	foreach $a(@uniq){
		$i++;
		unless ( $sthpmid->execute($a) ) {die "Se ha producido un problema al conectar con la base de datos: " . $DBI::errstr unless ( defined($dbh) );}
		if ($sthpmid->rows == 0) {
			print "NO MATCHES FOR $a.\n\n";
		}
		else {
			while ($pmid, $meta = $sthpmid->fetchrow_array()){
				$e= "$pmid|$meta";
				push(@ea, $e);
			}
			foreach $u(@ea){
				if ($u =~ /(.+)\|(.+)/){
					$pm=$1;
					$me=$2;
				}
			
			}
			#print "$pm, $i, $a, $me\n";
		
			if ( !$sthambiente->execute($pm, $i, $a, $me)) {
				warn "error al insertar: " . $DBI::errstr;
				$errflag = 1;
				exit;
			}
			if ( !$errflag ) {
				$dbh->commit();
			}
			else {
				$dbh->rollback();
			}
		}
	}
}

##################### Fin del bucle de cada archivo
#Cerrar todas las transaciones con las tablas
open( MUES, '+>id_ambiente.txt' );	#archivo para guardar el ultimo numero de muestra
	if ( !open( MUES, 'id_ambiente.txt' ) ) {die "Error al abrir el fichero 'id_ambiente.txt'";}
print MUES "$i\n";
close(MUES);

$sthambiente->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

$sthpmid->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

#Cerrar la conecsion con la base de datos y el archivo
$dbh->disconnect() || warn " Fallo al desconectar . Error : $DBI::errstr \n ";
close(UNIQ);
exit;
