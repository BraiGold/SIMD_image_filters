#!/bin/bash

#*----------------------------------------------------------------------------*
#* Tomamos mediciones sobre el filtro blur de todas sus implementaciones para *
#* la hipótesis 1.                                                            *
#*----------------------------------------------------------------------------*

source parametros.sh

# Genero las imágenes a testear
./convert.sh img/img.bmp


for imp in c ; do

    # Si ya existe el archivo donde se guardan las mediciones lo elimino pues
    # son viejos valores que ya no considero
    rm h1-resultados-blur-$imp.txt

    uppImp=$(echo $imp | tr [a-z] [A-Z])

    # Ejecuto el filtro y voy guardando las mediciones realizadas en un archivo
	for tam in $TAM_H1; do
		./build/tp2 blur -i $imp img/img_$tam.bmp 2 6 -t $k >> h1-resultados-blur-$imp.txt
	    rm img_$tam.bmp.blur.$uppImp.bmp
	done
done

# Elimino las imágenes generadas
for tam in $TAM_H1; do
    rm img/img_$tam.bmp
done
