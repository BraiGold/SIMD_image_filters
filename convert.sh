#!/bin/bash

# PARAMETROS DE ENTRADA:
#     $1: Nombre del archivo imagen
#     $2: Número de hipótesis
#
# MODO DE USO:
#
#     $ ./convert.sh $1 $2
#
#     Ejemplo...
#
#     $ ./convert.sh img.bmp 1

source parametros.sh

# pass directory as first argument to the script
# Use '.' (current directory) if no argument was passed
DIR=${1:-.}

# Dada la hipótesis especificada determino el conjunto de tamaños
case $2 in
    "1")
        SIZES=$TAM_H1
        ;;
    "2")
        SIZES=$TAM_H2
        ;;
## Esto es el default
#   *)
#       ;; 
esac

# 
find $DIR -type f | while read file; do
   for size in $SIZES; do
      # Resize and rename DSC01258.JPG into DSC01258_640x480.JPG, etc.
      # Remove the ! after $size if you do not wish to force the format
      #convert -resize "${size}!" "$file" "${file%.*}_${size}.${file##*.}"

      # Cut and rename DSC01258.JPG into DSC01258_640x480.JPG, etc.
      # Remove the ! after $size if you do not wish to force the format
      convert -crop "${size}!"+0+0 "$file" "${file%.*}_${size}.${file##*.}"
   done
done

# Nota: Es mejor usar -crop que -resize ya que este último proceso tarda más.
