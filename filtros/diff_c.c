
#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

unsigned char norma_inf( bgra_t *pixel ){
    return ( pixel->r >= pixel->g ) ? ( ( pixel->r >= pixel->b ) ? pixel->r : pixel->b ) :
                                      ( ( pixel->g >= pixel->b ) ? pixel->g : pixel->b );
}

void diff_c (
	unsigned char *src_1,
	unsigned char *src_2,
	unsigned char *dst,
	int m, // ancho
	int n, // alto
	int src_1_row_size,
	int src_2_row_size,
	int dst_row_size
) {
    unsigned char (*src_1_matrix)[src_1_row_size] = (unsigned char (*)[src_1_row_size]) src_1;
    unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
    unsigned char r, g, b, max;
    int i, j;

    i = 0;
    while(i<n){
        j = 0;
		while(j < (m)){

            // Obtenemos los pixeles de interés
            bgra_t *dst_pixel = (bgra_t*)&dst_matrix[i][j*4];
            bgra_t *src_1_pixel = (bgra_t*)&src_1_matrix[i][j*4];
            bgra_t *src_2_pixel = (bgra_t*)&src_2_matrix[i][j*4];

            // Calculamos la diferencia
            r = abs(src_1_pixel->r - src_2_pixel->r);
            g = abs(src_1_pixel->g - src_2_pixel->g);
            b = abs(src_1_pixel->b - src_2_pixel->b);

            // Obtenemos el máximo valor entre las 3 diferencias
            max = ( r >= g ) ? ( ( r >= b ) ?  r : b ) : ( ( g >= b ) ? g : b );

            // Actualizamos la imagen destino
            dst_pixel->r = max;
            dst_pixel->g = max;
            dst_pixel->b = max;
            dst_pixel->a = 255;
            j++;
        }
        i++;
    }
}

