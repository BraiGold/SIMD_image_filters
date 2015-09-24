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

# List all the formats you wish to have
SIZES="16x16 16x32 16x48 16x64 16x80 16x96 16x112 16x128 32x16 32x32 32x48 32x64 32x80 32x96 32x112 32x128 48x16 48x32 48x48 48x64 48x80 48x96 48x112 48x128 64x16 64x32 64x48 64x64 64x80 64x96 64x112 64x128 80x16 80x32 80x48 80x64 80x80 80x96 80x112 80x128 96x16 96x32 96x48 96x64 96x80 96x96 96x112 96x128 112x16 112x32 112x48 112x64 112x80 112x96 112x112 112x128 128x16 128x32 128x48 128x64 128x80 128x96 128x112 128x128"

# pass directory as first argument to the script
# Use '.' (current directory) if no argument was passed
DIR=${1:-.}

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
