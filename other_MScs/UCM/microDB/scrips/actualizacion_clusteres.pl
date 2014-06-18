#!/usr/bin/perl -w

use DBI;
use strict;
use warnings;

## Actualizar los clusteres mediante el cd-hit
#############################################
# Parseador de los archivos devulestos por el CD-HIT
# Y meterlo en la base de datos

#######################################################

my $dbh = DBI->connect( "dbi:Pg:dbname=microdb;host=localhost","agirre", "", { RaiseError => 0, AutoCommit => 0 } );
unless ( defined($dbh) ) {die "Ha habido un problema al conectar con la base de datos:"  . $DBI::errstr  unless ( defined($dbh) );}
#########################
open (CDHIT, 'outfasta.clstr')||die "ERROR: no se puede leer o crear el archivo fasta\n";
open( FASTA, '+>fastaact' );		#archivo todo corregido sin redundancias
	if ( !open( FASTA, 'fastaact' ) ) {die "Error al abrir el fichero 'fastaact'";}

 #conexion a la base de datos
 # Vamos a ejecutar la sentencia para preparar la introducion a la base de datos
	my $sthesp = $dbh->prepare("INSERT INTO especies(ID_cluster, NUM_seq, ID_seq_representante) VALUES (?, ?, ?)");
	unless ( defined ($sthesp) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

	my $sthseq = $dbh->prepare("INSERT INTO secuencias(ID_cluster, longitud_seq, Pmid, Secuencia) VALUES (?, ?, ?, ?)");
	unless ( defined ($sthseq) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}
	
	my $sthsecu = $dbh->prepare("SELECT Secuencia FROM micro WHERE Pmid=? " );
	unless ( defined ($sthsecu) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

	my $sthact = $dbh->prepare("SELECT ID_cluster FROM especies WHERE ID_seq_representante=? " );
	unless ( defined ($sthact) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

##############################
my $numseq = '';
my $cluster = '';
my $seqrepr = '';
my @refseq = ();
my @reflong = ();
my $reflong1 = '';
my $u = '';
my $secuencia = '';
my $i='';
my $errflag=0;
my $seq='';
my $long='';

########################################
foreach (<CDHIT>) {
	my $line = $_;
	chomp($line);

	#expresiones regulares
		## ID_CLUSTER
	if ($line =~ /^>Cluster\s+(\d+)/){
		$cluster = $1;
	}
	elsif ($line =~ /^[^>]/){
		if ($line =~ /\d+\s+\d+nt,\s+>(\w+)\.{3}\s+\*/){
			$seqrepr = $1; ### ID de la secuencia representante del cluster
		
		}
		if ($line =~ /\d+\s+(\d+)nt,\s+>(\w+)\.{3}\s+\*?.?/){
			### longitud de secuencia
			$long = $1;
			push( @reflong, $long );
			### ID de la secuencia
			$seq = $2;
			push( @refseq, $seq );
		}
	}
	
	if ($line =~ /^>/){
		$numseq = scalar@refseq;
		my $r=0;
		foreach $i(@refseq){
			unless ( $sthact->execute($i) ) {die "Se ha producido un problema al conectar con la base de datos: " . $DBI::errstr unless ( defined($dbh) );}
			if ($sthact->rows == 0) {
					unless ( $sthsecu->execute($i) ) {die "Se ha producido un problema al conectar con la base de datos: " . $DBI::errstr unless ( defined($dbh) );}
					#imprime los valores que se hayan pedido
					if ($sthsecu->rows == 0) {
						print "NO MATCHES FOR $i.\n\n";
					}
					else {
						 $secuencia = $sthsecu->fetchrow_array();
					}
					print FASTA "$i\n$secuencia\n\n";	# Ffasta de las nuevas secuencias no clusterizadas
				}
			else {
				$cluster = $sthact->fetchrow_array();
				splice (@refseq, $r, 1);
				splice (@reflong, $r, 1);
			}
			$r++;
		}
		$r=0;

		$u = 0;
		foreach $i(@refseq){
			$reflong1 = $reflong[$u];
			unless ( $sthsecu->execute($i) ) {die "Se ha producido un problema al conectar con la base de datos: " . $DBI::errstr unless ( defined($dbh) );}
			#imprime los valores que se hayan pedido
			if ($sthsecu->rows == 0) {
					    print "NO MATCHES FOR $i.\n\n";
				}
			else {
				 $secuencia = $sthsecu->fetchrow_array();
			}
			## ID_cluster	longitud_seq	refseq	secuencia
			if ( !$sthseq->execute($cluster, $reflong1, $i, $secuencia)) {
				warn "error al insertar: " . $DBI::errstr;
				$errflag = 1;
				exit;
			}
			
			$u++;
		}
			## ID_cluster,	NUM_seq,	seqrepr
		if ( !$sthesp->execute($cluster, $numseq, $seqrepr)) {
			warn "error al insertar: " . $DBI::errstr;
			$errflag = 1;
			exit;
		}

	# limpiar variables
	$numseq = '';
	$cluster = '';
	$seqrepr = '';
	$seq = '';
	@refseq = ();
	@reflong = ();
	$reflong1 = '';
	$u = '';
	$secuencia = '';
	}
}
if ( !$errflag ) {
	$dbh->commit();
}
else {
	$dbh->rollback();
}

##################### Fin del bucle de cada archivo
#Cerrar todas las transaciones con las tablas
$sthesp->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

$sthseq->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

$sthsecu->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

$sthact->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

#Cerrar la conecsion con la base de datos y el archivo
$dbh->disconnect()|| warn " Fallo al desconectar . Error : $DBI::errstr \n ";

close(CDHIT);
close(FASTA)
exit;
