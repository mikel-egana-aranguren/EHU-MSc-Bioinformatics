#!/usr/bin/perl -w
use DBI;
use strict;
use warnings;
use Text::LevenshteinXS qw (distance);

#### Clasificar por titulos y autores las muestras, de esta forma cada podremos relacionar cada secuencia con cada muestra, y a su vez
### cada muestra con su medio posteriormente, viendo de esta forma las posibles especies

my $dbh = DBI->connect( "dbi:Pg:dbname=microdb;host=localhost","agirre", "", { RaiseError => 0, AutoCommit => 0 } );  #TABLA MICROPURGADO
unless ( defined($dbh) ) {die "Ha habido un problema al conectar con la base de datos:"  . $DBI::errstr  unless ( defined($dbh) );}

###################################################################################################

#entre todos los titulos
open( TITUNI, 'unititautfin.txt' );		#archivo todo corregido sin redundancias
	if ( !open( TITUNI, 'unititautfin.txt' ) ) {die "Error al abrir el fichero 'unititautfin.txt'";}
	my @titaut= <TITUNI>;
	chomp(@titaut);
open (TITULO, 'PACK.txt');
	if ( !open( TITULO, 'PACK.txt' ) ) {die "Error al abrir el fichero 'PACK.txt'";}
###################################################################################################
### Preparar la tabla de datos para la tabla de archivos purgados
my $sthtitulo = $dbh->prepare("INSERT INTO muestra (Pmid, Titulo, Autores, ID_muestra) VALUES (?, ?, ?, ?) " );
unless (defined($sthtitulo)){die "no se pueden preparar las datos para insertarlos en las tablas\n";}

my $sthpmid = $dbh->prepare("SELECT pmid FROM muestra WHERE ID_muestra=? " );
unless (defined($sthpmid)){die "no se pueden preparar las datos para insertarlos en las tablas\n";}

my $sthnum = '';

#########
my $errflag = 0;
my $tit ='';
my $i = '';
my $e ='';
my $izen ='';
my $a = '';
my $titu = '';
my $auto= '';
my $NUM_seq ='';
my $mu = '';
my $o = '';
my @pmmu= ();
my $sed = '';
my $pmid = '';
my $autores = '';
my $titulo = '';
my $d='';
my @datos =();
my $pack ='';
my $tmax='';
my $tmin='';
my $s='';
my $fh='';
my $pmid1='';
my @pmid1=();
my $t='';
#################################################3

foreach (<TITULO>){	#Archivo con el pmid y todos los titulos y autores
	$d=$_;
	chomp($d);
	if ($d=~ /\s?(.+)\|(.+)\|(.+)/){
		$pmid=$1;
		$titulo=$2;
		$autores=$3;
	}
	#print "$pmid1, $titulo1, $autores1\n";
	$e= "$titulo|$autores";
	my $tam = length$e;
	$tmax=$tam+5;
	$tmin=$tam-5;
	$i=0;
	foreach $a(@titaut){	#archivo con todos los titutlos y autores corregidos
		$i++;
		if (length$a <= $tmax || length$a >= $tmin ){
			$izen = distance ($e, $a);
			if ($izen < 13){
				if ($a =~ /(.+)\|(.+)/){
					$titu=$1;
					$auto=$2;
				
					#print "$pmid, $titu, $auto, $i\n";
						if ( !$sthtitulo->execute($pmid, $titu, $auto, $i)) {
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
				next;
			}
		}
	}
}

for($s=1;$s<=scalar@titaut;$s++){
	unless ( $sthpmid->execute($s) ) {die "Se ha producido un problema al conectar con la base de datos: " . $DBI::errstr unless ( defined($dbh) );}
	if ($sthnum->rows == 0) {
			print "NO MATCHES FOR $s.\n\n";
		}
	else {
		while ( $pmid1 = $sthnum->fetchrow_array() ){
			push(@pmid1, $pmid1);
		}
	}
	$t=scalar@pmid1;
	$fh= "UPDATE muestra set NUM_seq=? WHERE ID_muestra='$s' ";
	$sthnum = $dbh->prepare("$fh" );
unless (defined($sthnum)){die "no se pueden preparar las datos para insertarlos en las tablas\n";}
	unless ( $sthnum->execute($t) ) {die "Se ha producido un problema al conectar con la base de datos: " . $DBI::errstr unless ( defined($dbh) );}
	if ($sthnum->rows == 0) {
		print "NO MATCHES FOR $t.\n\n";
	}
}

#### Cortar la comunicacion con las tablas
$sthtitulo->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

$sthnum->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

$sthpmid->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);


## Desconectar base de datos
$dbh->disconnect || warn " Fallo al desconectar . Error : $DBI::errstr \n ";

close(TITULO);
close(TITUNI);

exit;
