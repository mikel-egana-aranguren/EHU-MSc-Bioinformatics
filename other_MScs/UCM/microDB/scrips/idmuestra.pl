#!/usr/bin/perl -w

use strict;
use warnings;
use Text::LevenshteinXS qw (distance);
$|=1;
#### Clasificar por titulos y autores las muestras, de esta forma cada podremos relacionar cada secuencia con cada muestra, y a su vez
### cada muestra con su medio posteriormente, viendo de esta forma las posibles especies

system ('sort titaut.txt > sortitaut.txt');
system ('uniq sortitaut.txt > unititaut.txt');


#################### lista de valores a usar
################################################################################################### PROBLEMA A LA HORA DE LLAMARLOS
#entre todos los titulo y autores
open( TITAUT, 'unititaut.txt' );
	if ( !open( TITAUT, 'unititaut.txt' ) ) {die "Error al abrir el fichero 'unititaut.txt'";}
	my @autuni = <TITAUT>;
	chomp @autuni;

#crear el archivo de los titulos y autores sin repeticiones
open (AUTFIN, '>titautfin.txt');
	if ( !open( TITAUT, 'titautfin.txt' ) ) {die "Error al abrir el fichero 'titautfin.txt'";}

my $a = '';
my $i = '';
my $disaut = '';
my $e = '';
my @idazle = ();
my $distit = '';
my $autores = '';
my $aa = '';
my @posicion = '';
my $tmax= '';
my $tmin = '';
my $o='';
my $u=0;

############# MIRAR BIEN EL CODIGO ES POSIBLE QUE HAYA QUE HACERLO DE OTRA MANERA
foreach $a(@autuni){
	$o=length$a;
	$tmax=$o+5;
	$tmin=$o-5;

	foreach $i(@autuni){
		
		#print "$a\n";
		if (length$i <= $tmax || length$i >= $tmin ){
			$disaut = distance ($a, $i);
			if ($disaut < 13){
				#print "$i\n";
				push (@idazle, $i);
				push (@posicion, $autuni[$u]);
			}
		}
		$u++;
	}
	$u=0;
	## eliminar del @tituni los que han entrado en @izenburu ## TARDA MUCHO TIEMPO AL RPINCIPIO
	for ($aa=scalar@autuni; $aa == 0 ;$aa--){
		foreach $e(@posicion){
			if ($aa = $e){
				splice (@autuni, $aa, 1); # elimina del array el elemento de la posicion $a
			}
		}
	}
$autores = $idazle[0];
#print "$autores\n";
print AUTFIN "$autores\n"; #################### NO FUNCIONA !!
# limpiar variables
@idazle = ();
@posicion = ();
}

close(TITAUT);
close(AUTFIN);
## reorganiza los archivos devueltos

system ('sort titautfin.txt > sortitautfin.txt');
system ('uniq sortitautfin.txt > unititautfin.txt');

exit;
