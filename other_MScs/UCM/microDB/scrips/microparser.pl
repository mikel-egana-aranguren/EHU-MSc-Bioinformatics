#!/usr/bin/perl -w

use DBI;
use strict;
use warnings;

my $dbh = DBI->connect( "dbi:Pg:dbname=microdb;host=localhost","agirre", "", { RaiseError => 0, AutoCommit => 0 } );
unless ( defined($dbh) ) {die "Ha habido un problema al conectar con la base de datos:"  . $DBI::errstr  unless ( defined($dbh) );}
#conexion a la base de datos
#Vamos a ejecutar la sentencia para preparar la introducion a la base de datos
my $sthmicro = $dbh->prepare("INSERT INTO micro(Titulo, Autores, Pmid, Fecha, Isolation_source, Gen, Secuencia, Metadatos) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
unless ( defined ($sthmicro) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

####################### CREAR EL FASTA PARA HACE EL BLAST
open (FASTA, '+>fasta.fa')||die "ERROR: no se puede leer o crear el archivo fasta\n";
open (TITULO, '+>titaut.txt')||die "ERROR: no se puede leer o crear el archivo titulo\n";
open (PACK, '+>PACK.txt')||die "ERROR: no se puede leer o crear el archivo titulo\n";
open (FECH, '+>fechpmid.txt')||die "ERROR: no se puede leer o crear el archivo titulo\n";
open (ISOLA, '+>isolation.txt')||die "ERROR: no se puede leer o crear el archivo datos\n";
#########################

my $errflag = 0;
my $file = '';
my $arch = '';

############################### LEER LOS ARCHIVOS DE UNO EN UNO
my $i = 1;
while ($i){
	$file = "gbenv$i.seq";
	
############################# Bucle para cada archivo a parsear

	open( MICRO, $file )||die "ERROR: no se puede leer o crear el archivo $file \n" && exit;
	print "Analizando archivo $file\n";
	# Procesamiento fichero

		#limpiar variables
		my $line      = '';
		my $letters   = '';
		my $nombre    = '';
		my $titulo    = '';
		my $journal1  = '';
		my $autores   = '';
		my $pmid      = '';
		my $fecha     = '';
		my $isolation = '';
		my $gen       = '';
		my $seq       = '';
		my $se1       = '';
		my $tit       = '';
		my $title     = '';
		my $hitz      = '';
		my $autore    = '';
		my $_         = '';
		my $num       = '';
		my $sekuen    = '';
		my $DNA       = '';
		my $sequ      = '';
		my $journal   = '';
		my $fine = '';
		my $t1 = '';
		my $country = '';
		my $host = '';
		my $coor = '';
		my $metadata = '';
		my $au = '';
		my $titu = '';
		my $zen = 0;
		my $titaut = '';

		foreach (<MICRO>) {
			my $line = $_;
			chomp($line);

			#expresiones regulares

			## TITULO DEL ARTICULO ######################################################
			if ($line =~ /TITLE/){
				$title = 1;
			}
			if ($line =~ /JOURNAL\s+\(in\).+/){
				if (!$titulo&&!$title){
					$title = 1;
					$fine = 1;
				}
			}
			if ($line =~ /JOURNAL\s+\w+/){
				$journal1 = 1;
			}
			if (!$journal1){
				if ($title){
					$letters = $_;
					chomp ($letters);
				}
				if ($_ =~ /JOURNAL\s+[a-zA-Z0-9]+/){
					$title = 0;
				}
				$titulo .= $letters;
				$titulo =~ s/TITLE//g;
				if ($titulo =~ /JOURNAL\s+\(in\)(.+)\..+/){
					$titulo = $1;
				}
				if ($titulo =~ /(.+)\s+\d{4}.+/){
					$titulo = $1;
				}
				$titulo =~ s/JOURNAL\s+\(in\)\s//g;
				if ($titulo =~ /.+(\(EDs.+\s\d+\-?\s(.+);.+\)).+/){
					$titulo = $1;
				}
				if ($titulo =~ /(.+)\s+AUTHORS.+/){
					$titulo = $1;
				}
				$titulo =~ s/JOURNAL.+//g;
				$titulo =~ s/\s{7}//g;
				$titulo =~ s/\s{4}//g;
				if ($fine){
					if ($titulo =~ /(.+)[^sp|spp]\.[^\d+]\s+(.+)/g){
						$t1 =$1;
						$titulo = $t1;
					}
					if ($titulo =~ /(.+)\s+Direct\s+Submission/){
						$titulo = $1;
					}
				}

			}

			## AUTORES DEL ARTICULO ######################################################
			if ( $line =~ /AUTHORS/ ) {
				$autore = 1;
			}
			if ($line =~ /TITLE|JOURNAL/){
				$journal = 1;
			}
			if (!$journal){
				if ($autore){
					$nombre = $_;
					chomp ($nombre);
				}
				if ($_ =~ /TITLE/){
					$autore = 0;
				}
				$autores .= $nombre;
				$autores =~ s/AUTHORS//g;
				$autores =~ s/JOURNAL.+//g;
				$autores =~ s/\s{7}//g;
				$autores =~ s/\s{4}//g;

			}
			
			## EL NUMERO DE IDENTIFICADOR ################################################
			if ( $line =~ /LOCUS\s+(\w{2,12})\s+.+/ ) {
				$pmid = $1;
			}

			# LA FECHA DE PUBLICACION ###################################################
			if ( $line =~ /JOURNAL\s+Submitted\s+\((\d+-\w+-\d+)\).+/ ) {
				$fecha = $1;
			}

			# EL MEDIO DONDE SE RECOGIO LA MUESTRA ######################################
			elsif ( $line =~ /\s+\/isolation_source="(.+)"$/ ) {
				$isolation = $1;
			}

			# EL NOMBRE DEL GEN #########################################################
			if ( $line =~ /\s+\/product="(.+)"/ ) {
				$gen = $1;
			}

			## METADATOS ######################################################
			if ($line =~ /\s+\/country="(.+)"$/){
				$country = $1;
			}
			elsif ($line =~ /\s+\/host="(.+)"$/){
				$host = $1;
			}
			elsif ($line =~ /\s+\/lat_lon="(.+)"$/){
				$coor = $1;
			}
		
				## Pais;hospedador;coordenadas ## si las hay 
			$metadata= "Lugar:$country;Hospedador:$host;Coordenadas:$coor";

			# LA SECUENCIA ##############################################################
			if ( $line =~ /^ORIGIN/ ) {    # REVISARLO
				$se1 = 1;
			}
			if ($se1){
				
					$sekuen = $_;
					chomp ($sekuen);
					$seq .= $sekuen;
				if ($_ =~ /\/\//) { 
					$se1 = 0;
					$seq =~ s/ORIGIN//g;
					$seq =~ s/\d//g;
					$seq =~ s/\s//g;
					$seq =~ s/\/\///g;
				}
				}

			if ( $line =~ /^\/\// ){    #cuando acabe cada entrada (con //) guarda los datos en la BD

				#Solo las entradas con 16S rRNA
				if ($titulo !~ /.+/){
					$titulo = ".";
				}
				$titaut = "$titulo|$autores";
				#print $titaut;
				if ($gen =~ /(16S\s*.*)|([Ss]mall\s+subunit\s+ribosomal\s+RNA)/){
					if (length $seq > 200 && length $seq < 1800){
						print FASTA ">$pmid\n$seq\n\n";
						print TITULO "$titaut\n";
						print PACK "$pmid|$titulo|$autores\n";
						if ($fecha=~/\d{2}\-\w{3}\-(\d{4})/){
							$ano=$1;
						}
						print FECH "$ano|$pmid\n";
						print ISOLA "$isolation\n";
						#Titulo, Autores, Pmid, Fecha, Isolation_source, Gen, Secuencia, Metadatos
						
						if ( !$sthmicro->execute($titulo, $autores, $pmid, $fecha, $isolation, $gen, $seq, $metadata)) {
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
				}else {$gen = '';
				}
				#limpiar variables
				$titulo    = '';
				$autores   = '';
				$pmid      = '';
				$fecha     = '';
				$isolation = '';
				$gen       = '';
				$seq       = '';
				$tit       = '';
				$se1       = '';
				$letters   = '';
				$title     = '';
				$hitz      = '';
				$autore    = '';
				$nombre    = '';
				$journal   = '';
				$journal1  = '';
				$fine = '';
				$t1 = '';
				$host = '';
				$coor = '';
				$country = '';
				$metadata = '';
				$titu = '';
				$au = '';
				$zen = 0;
				$titaut = '';
			}
		}    #cierra las expresiones regulares del parseador

	close(MICRO);
	
$i++;
}
##################### Fin del bucle de cada archivo
	#Cerrar todas las transaciones con las tablas
	$sthmicro->finish() unless ($DBI::err);
	warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

	#Cerrar la conecsion con la base de datos y el archivo
	$dbh->disconnect() || warn " Fallo al desconectar . Error : $DBI::errstr \n ";
close(ISOLA);
close(FASTA);
close(TITULO);
close(PACK);
close(FECH);
exit;
