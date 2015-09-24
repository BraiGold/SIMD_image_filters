#!/bin/bash

#*----------------------------------------------------------------------------*
#* Tomamos mediciones sobre el filtro blur de todas sus implementaciones para *
#* la hipótesis 1.                                                            *
#*----------------------------------------------------------------------------*

source parametros.sh

for imp in c ; do

    rm h1-resultados-blur-$imp.txt

	for tam in $TAM_H1; do
		./build/tp2 blur -i $imp img/img_$tam.bmp $sigma $radius 6 -t $k >> h1-resultados-blur-$imp.txt
	    rm img_$tam.bmp.blur.$imp.bmp
	done
done
