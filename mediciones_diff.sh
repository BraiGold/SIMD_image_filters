#!/bin/bash

#*----------------------------------------------------------------------------*
#* Tomamos mediciones sobre el filtro diff de todas sus implementaciones.     *
#*----------------------------------------------------------------------------*

# PARÁMETROS:
# 
# $1: número experimento

source parametros.sh

if [ "$1" -eq "1" ]; then
    tamanos=$TAM_H1
else
    tamanos=$TAM_H2
fi

#-----------------------------------------------------------------------------*
# Implementación en C
#-----------------------------------------------------------------------------*
imp=c

# Se hace uppercase al contenido de "imp"
uppImp=$(echo $imp | tr [a-z] [A-Z])

for opt in O2; do

    # Se modifica el archivo Makefile de la carpeta filtros para compilar el
    # programa con las optimizaciones
    sed -i '18s/.*/CFLAGS64 ?=-Wall -Wextra -pedantic -'$opt' -ggdb/' filtros/Makefile
    make clean
    make

    # Si ya existe el archivo donde se guardan las mediciones lo elimino pues
    # son viejos valores que ya no considero
    rm h$1-diff-$imp-$opt.txt

    # Ejecuto el filtro y voy guardando las mediciones realizadas en un archivo
    for tam in $tamanos; do
	    ./build/tp2 diff -i $imp img/$name'_'$tam.bmp img/$name'_'$tam.bmp -t $k >> h$1-diff-$imp-$opt.txt
        rm $name'_'$tam.bmp.diff.$uppImp.bmp
    done
done

# Se modifica el archivo Makefile de la carpeta filtros como estaba anteriormente
sed -i '18s/.*/CFLAGS64 ?=-Wall -Wextra -pedantic -O0 -ggdb/' filtros/Makefile

#-----------------------------------------------------------------------------*
# Implementación en ASM
#-----------------------------------------------------------------------------*
imp=asm

# Si ya existe el archivo donde se guardan las mediciones lo elimino pues
# son viejos valores que ya no considero
rm h$1-diff-$imp.txt

# Se hace uppercase al contenido de "imp"
uppImp=$(echo $imp | tr [a-z] [A-Z])

# Ejecuto el filtro y voy guardando las mediciones realizadas en un archivo
for tam in $tamanos; do
    ./build/tp2 diff -i $imp img/$name'_'$tam.bmp img/$name'_'$tam.bmp -t $k >> h$1-diff-$imp.txt
    rm $name'_'$tam.bmp.diff.$uppImp.bmp
done
