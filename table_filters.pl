#########
# Filter a custom BLAST table to calculate coverage and average identity among phages
# how to run: perl table_filters TABLE OUTPUT
#########
# First remove all lines with aligments of less than 200bp


open (TABLA1, $ARGV[0]);
open (SALIDA, ">$ARGV[1]");
open (SALIDATEMP, ">$ARGV[0].temp.tab");
@tabla1 = <TABLA1>;
$contador_hit=0;

foreach $linea (@tabla1) { 
		if ($linea =~ /.*\t.*\t.*\t(.*)\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t.*\n/) { 
			$largo_hit = $1;
		if ( $largo_hit >= 200 ) { print SALIDATEMP $linea } }
		else { print SALIDATEMP $linea; }

}
close SALIDATEMP;
open (TABLA2, "$ARGV[0].temp.tab");
print SALIDA "Query\tSubject\tQueryCoveragePerSubject\tQueryCoveragePerUniqueSubject\tAverageIdentity\tHSPsNumber\n";
@tabla2 = <TABLA2>;

foreach $linea (@tabla2) {
		if (( $linea eq "# BLASTN 2.9.0+\n" ) && ( $contador_hit != 0 )) { print SALIDA "$query\t$fago_anterior\t$qcov_cobertura\t$qunique_cov\t"; printf SALIDA ("%.2f", $promedio_ident); print SALIDA "\t$contador_hit\n\n"; $fago_anterior = "primero"; $contador_hit = 1; $suma_ident = 0}
		elsif ($linea eq "# BLASTN 2.9.0+\n") {	#print "nuevo resultado \n"; 
			$fago_anterior = "primero"; $contador_hit = 0; $suma_ident = 0;}
			
		elsif ($linea =~ /(.*)\t(.*)\t(.*)\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t.*\t(.*)\t(.*)\n/) { #print "se encontró línea con hits\n";
			$query = $1; $hit = $2; $identidad = $3; $qcov_cobertura_nueva = $4; $qunique_cov_nueva = $5;
			
			if ($fago_anterior eq 'primero' ) { 
				$suma_ident = $suma_ident + $identidad ; $qcov_cobertura = $qcov_cobertura_nueva; $qunique_cov = $qunique_cov_nueva;
				$fago_anterior = $hit; $contador_hit = 1; 
			}
			elsif ($fago_anterior eq $hit) { 
				$suma_ident = $suma_ident + $identidad ; $contador_hit = $contador_hit + 1;
				$fago_anterior = $hit;
			}
				
			else { $promedio_ident = $suma_ident / $contador_hit;
				print SALIDA "$query\t$fago_anterior\t$qcov_cobertura\t$qunique_cov\t"; printf SALIDA ("%.2f", $promedio_ident); print SALIDA "\t$contador_hit\n";
				$suma_ident = $identidad ; $contador_hit = 1;
				$fago_anterior = $hit; $qcov_cobertura = $qcov_cobertura_nueva; $qunique_cov = $qunique_cov_nueva;
			}
		}
}

print SALIDA "$query\t$fago_anterior\t$qcov_cobertura\t$qunique_cov\t"; printf SALIDA ("%.2f", $promedio_ident); print SALIDA "\t$contador_hit\n";



