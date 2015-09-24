#!/bin/bash

# MODO DE USO:
# - Si especificamos un archivo en particular, por ejemplo "img.bmp", entonces
#   en la terminal tipeamos:
#
#      $ ./convert.sh img.bmp
#
# - Si no especificamos nada entonces va a tomar TODOS los archivos del
#   directorio donde se encuentre este script. Y cuando digo TODOS es TODOS:
#   imágenes, archivos de texto, scritps (incluido este), ejecutables. A todos
#   ellos les va a querer aplicar este script. Por ello, es mejor usar la
#   primera opción. Resumiendo, con esta opción la cagan!

source parametros.sh

# pass directory as first argument to the script
# Use '.' (current directory) if no argument was passed
DIR=${1:-.}

SIZES=$TAM_H1

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
