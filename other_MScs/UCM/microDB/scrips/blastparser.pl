#!/usr/bin/perl -w

use DBI;
use strict;
use warnings;

my $dbh = DBI->connect( "dbi:Pg:dbname=microdb;host=localhost","agirre", "", { RaiseError => 0, AutoCommit => 0 } );
unless ( defined($dbh) ) {die "Ha habido un problema al conectar con la base de datos:"  . $DBI::errstr  unless ( defined($dbh) );}
############### ABRIR ARCHIVO 
open (DATOS, 'besthit.txt')||die "ERROR: no se puede leer o crear el archivo datos de blast\n";

# Procesamiento fichero


#conexion a la base de datos
# Vamos a ejecutar la sentencia para preparar la introducion a la base de datos
my $sthtax = $dbh->prepare("INSERT INTO taxones( ID_seq_representante, superkingdom_besthit, superkingdom_bestAVG, superkingdom_ID, phylum_besthit, phylum_bestAVG, phylum_ID, class_besthit, class_bestAVG, class_ID, orderbesthit, orderbestAVG, orderID, family_besthit, family_bestAVG, family_ID, genus_besthit, genus_bestAVG, genus_ID, species_besthit, species_bestAVG, species_ID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

unless ( defined ($sthtax) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

my $errflag = 0;
	my $pmid = '';
	my $tipo = '';
	my $nomAVG = '';
	my $nomHIT = '';
	my $score = '';
	my $kingAVG = '';
	my $kingHIT = '';
	my $kingscor = '';
	my $phyAVG = '';
	my $phyHIT = '';
	my $physcor = '';
	my $clasAVG = '';
	my $clasHIT = '';
	my $classcor = '';
	my $ordAVG = '';
	my $ordHIT = '';
	my $ordscor = '';
	my $famAVG = '';
	my $famHIT = '';
	my $famscor = '';
	my $genAVG = '';
	my $genHIT = '';
	my $genscor = '';
	my $specAVG = '';
	my $specHIT = '';
	my $specscor = '';
	my $tax = '';
	my $sthtaxon = '';
	my $tex = '';


foreach (<DATOS>) {
	my $line = $_;
	chomp($line);

	if ($line =~ /^(.+)\t(.+)\t(.+)\t(.+)\t(.+)/){
		$pmid = $1;
		$tipo = $2;
		$nomAVG = $3;
		$nomHIT = $4;
		$score = $5;
		if ($tipo =~ /superkingdom/ ){
			$kingAVG=$nomAVG;
			$kingHIT=$nomHIT;
			$kingscor=$score;
		}
		elsif ($tipo =~ /phylum/ ){
			$phyAVG=$nomAVG;
			$phyHIT=$nomHIT;
			$physcor=$score;
		}
		elsif ($tipo =~ /class/ ){
			$clasAVG=$nomAVG;
			$clasHIT=$nomHIT;
			$classcor=$score;
		}
		elsif ($tipo =~ /order/ ){
			$ordAVG=$nomAVG;
			$ordHIT=$nomHIT;
			$ordscor=$score;
		}
		elsif ($tipo =~ /family/ ){
			$famAVG=$nomAVG;
			$famHIT=$nomHIT;
			$famscor=$score;
		}
		elsif ($tipo =~ /genus/ ){
			$genAVG=$nomAVG;
			$genHIT=$nomHIT;
			$genscor=$score;
		}
		elsif ($tipo =~ /species/ ){
			$specAVG=$nomAVG;
			$specHIT=$nomHIT;
			$specscor=$score;
		}
	}
	if ($line !~ /.+/){

#		print "$pmid, $kingHIT, $kingAVG, $kingscor, $phyHIT, $phyAVG, $physcor, $clasHIT, $clasAVG, $classcor, $ordHIT, $ordAVG, $ordscor, $famHIT, $famAVG, $famscor, $genHIT, $genAVG, $genscor, $specHIT, $specAVG, $specscor\n";
		if ( $kingAVG=~/Unresolved/){
			$tax = "$kingAVG(superkingdom)";
		}
		elsif ($specscor =~ /(97\.)*(98\.)*(99\.)*(100\.)*/ && $specAVG!~/Unresolved/){
			$tax = "$kingAVG(superkingdom);$phyAVG(phylum);$clasAVG(class);$ordAVG(order);$famAVG(family);$genAVG(genus);$specAVG(species)";
		}
		elsif ($genscor =~ /(94\.)*(95\.)*(96\.)*(97\.)*(98\.)*(99\.)*(100\.)*/ && $genAVG !~ /Unresolved/){
			$tax= "$kingAVG(superkingdom);$phyAVG(phylum);$clasAVG(class);$ordAVG(order);$famAVG(family);$genAVG(genus)";
		}
		else{
			$tax="$kingAVG(superkingdom);$phyAVG(phylum);$clasAVG(class);$ordAVG(order);$famAVG(family)";
		}
#		print "$tax\n";

		$tex= "UPDATE especies set taxon=? WHERE ID_seq_representante='$pmid'";
#		print "$tex\n";
		$sthtaxon = $dbh->prepare("$tex");
		unless ( defined ($sthtaxon) ) {die "no se pueden prepara las datos para insertarlos en las tablas\n";}

		if ( !$sthtaxon->execute($tax)){
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
#		print "$kingAVG(superkingdom);$phyAVG(phylum);$clasAVG(class);$ordAVG(order);$famAVG(family);$genAVG(genus);$specAVG(species)\n";
		if ( !$sthtax->execute($pmid, $kingHIT, $kingAVG, $kingscor, $phyHIT, $phyAVG, $physcor, $clasHIT, $clasAVG, $classcor, $ordHIT, $ordAVG, $ordscor, $famHIT, $famAVG, $famscor, $genHIT, $genAVG, $genscor, $specHIT, $specAVG, $specscor )) {
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
		$pmid = '';
		$nomAVG = '';
		$nomHIT = '';
		$score = '';
		$kingAVG = '';
		$kingHIT = '';
		$kingscor = '';
		$phyAVG = '';
		$phyHIT = '';
		$physcor = '';
		$clasAVG = '';
		$clasHIT = '';
		$classcor = '';
		$ordAVG = '';
		$ordHIT = '';
		$ordscor = '';
		$famAVG = '';
		$famHIT = '';
		$famscor = '';
		$genAVG = '';
		$genHIT = '';
		$genscor = '';
		$specAVG = '';
		$specHIT = '';
		$specscor = '';
		$tax = '';
		$tex = '';
		$sthtaxon->finish() unless ($DBI::err);
		warn "Error de consulta: " . $DBI::errstr if ($DBI::err);
	}
}

##################### Fin del bucle de cada archivo
#Cerrar todas las transaciones con las tablas
$sthtax->finish() unless ($DBI::err);
warn "Error de consulta: " . $DBI::errstr if ($DBI::err);

#Cerrar la conecsion con la base de datos y el archivo
$dbh->disconnect() || warn " Fallo al desconectar . Error : $DBI::errstr \n ";

close(DATOS);

exit;
