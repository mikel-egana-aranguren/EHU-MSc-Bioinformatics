#!/usr/bin/perl -w

use strict;
use warnings;
#############################################
# Programa para coordinar el resto de programas

#######################################################

# limpiar variables
my $a = '';
my $e = '';
my $i = 1;
# El programa podra hacer la carga 'de novo' o actualizar la base de datos
while ($i==1){
	print "Quieres actualizar la base de datos de genbank?\nA: Cargar la base de datos\nB: Actualizar la base de datos\nC: Salir\n";
	$a= <STDIN>;
	chomp $a;
	$a = uc $a;

	if ($a =~ /B/){		#ACTUALIZAR LA BASE DE DATOS
		print "Estas seguso de querer actualizar la base de datos?(S/n)\n";
		$e = <STDIN>;
		$e = uc $e;
		if ($e =~ /SI|S/){
			system ('rm gbenv*.seq');	# Elimina todas las entradas existentes de la serie gbenv (si existen)
			system ('wget ftp://ftp.ncbi.nih.gov/genbank/gbenv*');	# se descarga los datos del genbank
			system ('gzip -d gbenv*.seq.gz');	#descomprime todos los archivos descargados
			system ('perl acmicroparser.pl');	# parsea los archivos del genbank y crea en outfasta2
			system ('perl idmuestra.pl');	#inserta el id de muestra para cada caso
			system ('perl muestratabla.pl');	#inserta los datos referentes a las muestras en la tabla (muestra)
			system ('perl acmetadata_ambiente.pl');	#inserta los datos referentes al ambiente
			system ('cat outfasta* > fasta3');
			system ('cd-hit-est -i fasta3 -o outfasta3 -c 0.97 -M 4000 -T 2 -aL 0.8 -aS 0.4 -l 200 -r 1');	#comando del DC-HIT-EST
			system ('vm outfasta3 outfasta');	#renombra el fichero final
			system ('vm outfasta3.clstr outfasta.clstr');	#renombra el fichero final
			system ('perl actualizacion_clusteres.pl'); 	#insertar elarchivo del CD_HIT en la BD
			system ('perl acconteofasta.pl');	#fracciona los fasta para realizar el el blast
			system ('perl blastn.pl');	#hace el blast
			system ('cat *.fas.blastn > fichero.fas.blastn');	#concatena todos los archivos en uno solo
			system ('perl asigna16S.pl fichero.fas.blastn > besthit.txt');	 # crea el archivo de taxones
			system ('perl blastparser.pl');	#inserta los datos referentes a los taxones (taxones y especies)
			print "La base de datos esta actualizada\n";
			$i = '';
		}else{
			$i = 1;
		}
	}
	elsif ($a =~ /A/){	# CARGAR LA BASE DE DATOS
		print "Estas seguso de querer cargar la base de datos?(S/n)\n";
		$e = <STDIN>;
		$e = uc $e;
		if ($e =~ /SI|S/){
			system ('rm gbenv*.seq');	# Elimina todas las entradas existentes de la serie gbenv (si existen)
			system ('wget ftp://ftp.ncbi.nih.gov/genbank/gbenv*');	# se descarga los datos del genbank
			system ('gzip -d gbenv*.seq.gz');	#descomprime todos los archivos descargados
			system ('perl microparser.pl');	# parsea los archivos del genbank y los inserta en la BD (micro)
			system ('perl idmuestra.pl');	# el id de muestra para cada caso 
			system ('perl muestratabla.pl');	#inserta los datos referentes a las muestras en la tabla (muestra)
			system ('perl metada_ambiente.pl');	#inserta los datos referentes al ambiente en la tabla (ambientes)
			system ('cd-hit-est -i fasta.fa -o outfasta -c 0.97 -M 4000 -T 2 -aL 0.8 -aS 0.4 -l 200 -r 1');	#comando del DC-HIT-EST
			system ('perl cdhitparser.pl'); 	# inserta el archivo del CD_HIT en la BD (especies y secuencias)
			system ('wget greengenes.lbl.gov/Download/Sequence_Data/Fasta_data_files/current_prokMSA_unaligned.fasta.gz');	#descarga la BD del greengenes
			system ('formatdb -i current_prokMSA_unaligned.fasta -p F');	# da formato al archivo descargado de greengenes
			system ('perl conteofasta.pl');	#fracciona los fasta para realizar el el blast
			system ('perl blastn.pl');	#hace el blast
			system ('cat *.fas.blastn > fichero.fas.blastn');	#concatena todos los archivos en uno solo
			system ('perl asigna16S.pl fichero.fas.blastn > besthit.txt');	 # crea el archivo de taxones
			system ('perl blastparser.pl');	#inserta los datos referentes a los taxones (taxones y especies)
			print "La base de datos esta cargada\n";
			$i = '';
		}else{
			$i = 1;
		}
	}
	elsif ($a=~ /C/){	#SALIR DE LA BASE DE DATOS
		exit;
	}
	else {	#SALIR DE LA BASE DE DATOS
		exit;
	}
}
exit;
