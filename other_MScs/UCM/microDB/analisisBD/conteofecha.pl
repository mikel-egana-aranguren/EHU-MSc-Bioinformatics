#!/usr/bin/perl -w

use strict;
use warnings;
$|=1;
open( FECHA, 'FECHA.txt' );
	if ( !open( FECHA, 'FECHA.txt' ) ) {die "Error al abrir el fichero 'FECHA.txt'";}
	my @fecha = <FECHA>;
	chomp @fecha;

open( UNIQ, 'uniqFECHA.txt' );
	if ( !open( UNIQ, 'uniqFECHA.txt' ) ) {die "Error al abrir el fichero 'uniqFECHA.txt'";}
	my @uni = <UNIQ>;
	chomp @uni;

#crear el archivo de los titulos y autores sin repeticiones
open (CONT, '>SEQfecha.txt');
	if ( !open( CONT, 'SEQfecha.txt' ) ) {die "Error al abrir el fichero 'SEQfecha.txt'";}

my $a='';
my $e='';
my @ano=();
my $num='';
my $tot=0;
foreach $a(@uni){
	foreach $e (@fecha){
		if ($a eq $e){
			push (@ano, $e);
		}
	}
	$num = scalar@ano;
	$tot= $tot+$num;
	print CONT "$a	$num	$tot\n";
	@ano=();
}

#close(CONT);
close(FECHA);
close(UNIQ);
close(CONT)
exit;
