#!/bin/bash

#*----------------------------------------------------------------------------*
#* Tomamos mediciones variando ancho y alto de imagen de manera               *
#* proporcionada.                                                          *
#*----------------------------------------------------------------------------*

source parametros.sh

# Genero las imágenes a testear
echo -e "$ROJO >> $DEFAULT Generando imágenes..."

    ./convert.sh img/$name.bmp 1

echo -e "$ROJO >> $DEFAULT Las imágenes han sido generadas..."

# Mediciones
echo -e "\n$ROJO >> $DEFAULT Tomando mediciones al filtro blur...\n"

#    echo -e "\n\t$AZUL- sigma = 0.78, radio = 2$DEFAULT"
#    ./mediciones_blur.sh 1 0.78 2

#    echo -e "\n\t$AZUL- sigma = 1.00, radio = 3$DEFAULT"
#    ./mediciones_blur.sh 1 1.00 3

#    echo -e "\n\t$AZUL- sigma = 2.00, radio = 6$DEFAULT"
#    ./mediciones_blur.sh 1 2.00 6

#    echo -e "\n\t$AZUL- sigma = 3.00, radio = 9$DEFAULT"
#    ./mediciones_blur.sh 1 3.00 9

#    echo -e "\n\t$AZUL- sigma = 4.00, radio = 12$DEFAULT"
#    ./mediciones_blur.sh 1 4.00 12

    echo -e "\n\t$AZUL * sigma = 5.00, radio = 15$DEFAULT\n"
    ./mediciones_blur.sh 1 5.00 15

echo -e "\n$ROJO >> $DEFAULT Tomando mediciones al filtro diff...\n"

    ./mediciones_diff.sh 1

echo -e "\n$VERDE Mediciones realizadas con éxito$DEFAULT"

# Elimino las imágenes generadas
echo -e "\n$ROJO >> $DEFAULT Eliminando las imágenes generadas..."

    for tam in $TAM_H1; do
        rm img/$name'_'$tam.bmp
    done

echo -e "$ROJO >> $DEFAULT Las imágenes generadas han sido eliminadas..."
