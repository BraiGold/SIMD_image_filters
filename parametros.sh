#!/bin/bash

#*----------------------------------------------------------------------------*
#* Parámetros para la ejecución de las hipótesis                              *
#*----------------------------------------------------------------------------*

# Tamaños de imagen considerados para hipótesis 1
TAM_H1="16x16 32x32 48x48 64x64 80x80 96x96 112x112 128x128"

# Tamaños de imagen considerados para hipótesis 2
TAM_H2="16x16 16x32 16x48 16x64 16x80 16x96 16x112 16x128 32x16 32x32 32x48 32x64 32x80 32x96 32x112 32x128 48x16 48x32 48x48 48x64 48x80 48x96 48x112 48x128 64x16 64x32 64x48 64x64 64x80 64x96 64x112 64x128 80x16 80x32 80x48 80x64 80x80 80x96 80x112 80x128 96x16 96x32 96x48 96x64 96x80 96x96 96x112 96x128 112x16 112x32 112x48 112x64 112x80 112x96 112x112 112x128 128x16 128x32 128x48 128x64 128x80 128x96 128x112 128x128"

# Protocolo de mediciones
k=50       # Cantidad de mediciones
sigma=2    # Sigma
radius=6   # Radio
