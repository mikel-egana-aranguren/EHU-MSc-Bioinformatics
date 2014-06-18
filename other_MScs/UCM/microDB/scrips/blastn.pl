#!/usr/bin/perl -w

use strict;
use warnings;
my $a='';
my $i = 0;
my $e=1;
if ($e ==1){
	open (FAS, "fas$i.txt")||die ;
	$a = "blastall -p blastn -i fas$i.txt -d greengenes -o file$i.fas.blast -m 8 -e 1e-03 -D 200 -a 2";
	#print "$a\n";
	system("'blastall -p blastn -i fas$i.txt -d greengenes -o file$i.fas.blast -m 8 -e 1e-03 -D 200 -a 2'");
	$i++;

}
close(FAS);
exit;
