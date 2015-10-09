#!/bin/bash

#*----------------------------------------------------------------------------*
#* Tomamos mediciones sobre el filtro blur de todas sus implementaciones.     *
#*----------------------------------------------------------------------------*

# PARÁMETROS:
# 
# $1: número de experimento
# $2: sigma
# $3: radius

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
    rm h$1-blur-$imp-$opt-$2-$3.txt

    # Ejecuto el filtro y voy guardando las mediciones realizadas en un archivo
    for tam in $tamanos; do
	    ./build/tp2 blur -i $imp img/$name'_'$tam.bmp $2 $3 -t $k >> h$1-blur-$imp-$opt-$2-$3.txt
        rm $name'_'$tam.bmp.blur.$uppImp.bmp
    done
done

# Se modifica el archivo Makefile de la carpeta filtros como estaba anteriormente
sed -i '18s/.*/CFLAGS64 ?=-Wall -Wextra -pedantic -O0 -ggdb/' filtros/Makefile

#-----------------------------------------------------------------------------*
# Implementación en ASM
#-----------------------------------------------------------------------------*

imp=asm

# Se hace uppercase al contenido de "imp"
uppImp=$(echo $imp | tr [a-z] [A-Z])

# Habilito la implementación 1 y la compilo
sed -i '62s/.*/    call implementacion1/' filtros/blur_asm.asm
sed -i '63s/.*/    ;call implementacion2/' filtros/blur_asm.asm
make clean
make

# Si ya existe el archivo donde se guardan las mediciones lo elimino pues
# son viejos valores que ya no considero
rm h$1-blur-$imp-1-$2-$3.txt

# Ejecuto el filtro y voy guardando las mediciones realizadas en un archivo
for tam in $tamanos; do
    ./build/tp2 blur -i $imp img/$name'_'$tam.bmp $2 $3 -t $k >> h$1-blur-$imp-1-$2-$3.txt
    rm $name'_'$tam.bmp.blur.$uppImp.bmp
done

# Habilito la implementación 2 y la compilo
sed -i '62s/.*/    ;call implementacion1/' filtros/blur_asm.asm
sed -i '63s/.*/    call implementacion2/' filtros/blur_asm.asm
make clean
make

# Si ya existe el archivo donde se guardan las mediciones lo elimino pues
# son viejos valores que ya no considero
rm h$1-blur-$imp-2-$2-$3.txt

# Ejecuto el filtro y voy guardando las mediciones realizadas en un archivo
for tam in $tamanos; do
    ./build/tp2 blur -i $imp img/$name'_'$tam.bmp $2 $3 -t $k >> h$1-blur-$imp-2-$2-$3.txt
    rm $name'_'$tam.bmp.blur.$uppImp.bmp
done

