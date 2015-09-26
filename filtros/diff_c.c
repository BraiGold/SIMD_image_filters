
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
    unsigned char max_1, max_2;
    int i, j;

    i = 0;
    while(i<n){
        j = 0;
		while(j < (m)){

            // Obtenemos los pixeles de interés
            bgra_t *dst_pixel = (bgra_t*)&dst_matrix[i][j*4];
            bgra_t *src_1_pixel = (bgra_t*)&src_1_matrix[i][j*4];
            bgra_t *src_2_pixel = (bgra_t*)&src_2_matrix[i][j*4];

            // Obtenemos el máximo valor entre los canales de cada pixel
            max_1 = norma_inf( src_1_pixel );
            max_2 = norma_inf( src_2_pixel );

            // Calculamos la diferencia
            dst_pixel->r = abs(max_1 - max_2);
            dst_pixel->g = abs(max_1 - max_2);
            dst_pixel->b = abs(max_1 - max_2);
            dst_pixel->a = 255;
            j++;
        }
        i++;
    }
}

