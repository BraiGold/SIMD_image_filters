#!/bin/bash

#*----------------------------------------------------------------------------*
#* Tomamos mediciones variando ancho y alto de imagen de manera               *
#* desproporcionada.                                                          *
#*----------------------------------------------------------------------------*

source parametros.sh

# Genero las imágenes a testear
echo -e "$ROJO >> $DEFAULT Generando imágenes..."

    ./convert.sh img/$name.bmp 2

echo -e "$ROJO >> $DEFAULT Las imágenes han sido generadas..."

# Mediciones
echo -e "\n$ROJO >> $DEFAULT Tomando mediciones al filtro diff...\n"

#    echo -e "\n\t$AZUL- sigma = 0.78, radio = 2$DEFAULT\n"
#    ./mediciones_blur.sh 2 0.78 2

#    echo -e "\n\t$AZUL- sigma = 1.00, radio = 3$DEFAULT\n"
#    ./mediciones_blur.sh 2 1.00 3

#    echo -e "\n\t$AZUL- sigma = 2.00, radio = 6$DEFAULT\n"
#    ./mediciones_blur.sh 2 2.00 6

#    echo -e "\n\t$AZUL- sigma = 3.00, radio = 9$DEFAULT\n"
#    ./mediciones_blur.sh 2 3.00 9

#    echo -e "\n\t$AZUL- sigma = 4.00, radio = 12$DEFAULT\n"
#    ./mediciones_blur.sh 2 4.00 12

    echo -e "\n\t$AZUL * sigma = 5.00, radio = 15$DEFAULT\n"
    ./mediciones_blur.sh 2 5.00 15

echo -e "\n$ROJO >> $DEFAULT Tomando mediciones al filtro diff..."

    ./mediciones_diff.sh 2

echo -e "\n$VERDE \nMediciones realizadas con éxito$DEFAULT"

# Elimino las imágenes generadas
echo -e "\n$ROJO >> $DEFAULT Eliminando las imágenes generadas..."

    for tam in $TAM_H2; do
        rm img/$name'_'$tam.bmp
    done

echo -e "$ROJO >> $DEFAULT Las imágenes generadas han sido eliminadas..."
