#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"

float *getKernel( int radius, float sigma){
	int i, j;
    float x, y, ePowBla, constante;

	int n    = 2*radius+1;
	float *k = (float *) malloc( n * n * sizeof(float ) ) ;
	int tam  = (2*radius+1) * (2*radius+1) * sizeof(float ) ;
    
    i = 0;
    while( i<= (2*radius ) ){

    	j = 0;
    	while( j <= (2*radius )  ){
    		x         = radius -i;
    		y         = radius - j;
    		ePowBla   = pow( 2.71828182846, -1.0 * ( ( x*x + y*y ) / (2.0*pow(sigma,2.0)) ) );
			constante = (1.0/ (2.0*( 3.14159265359)* pow(sigma,2.0) ));

    		k[(i*n) +j]  =  (constante *  ePowBla);

    		j++;
    	}
    	i++;
    }

    return k;
}

void blur_c (
              unsigned char *src,
              unsigned char *dst,
              int cols,
              int filas,
              float sigma,
              int radius)
{
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    int i, j, aux_i, aux_j, x, y, n;
    float promedio_r, promedio_g, promedio_b;

    float * k = getKernel(radius,sigma);

    n = (2*radius)+1;

    i = radius;
	while(i< (filas - radius)){

		j = radius;
		while(j < (cols -radius)  ){

			promedio_r = 0;
			promedio_g = 0;
			promedio_b = 0;

			aux_i = i - radius;
			x     = 0;

			while(aux_i <= (i + radius) ){
				aux_j = j - radius;
				y     = 0;
				while(aux_j <= ( j + radius ) ) {
					bgra_t *src_pixel = (bgra_t*)&src_matrix[aux_i][aux_j*4];
					
					promedio_r += ((float)src_pixel->r * k[(x*n) + y]);
					promedio_g += ((float)src_pixel->g * k[(x*n) + y]);
					promedio_b += ((float)src_pixel->b * k[(x*n) + y]);
					aux_j ++;
					y ++ ;
				}
				aux_i++;
				x ++;
			}

			bgra_t *dst_pixel = (bgra_t*)&dst_matrix[i][j*4];
			
			dst_pixel->r = (unsigned char) promedio_r;
			dst_pixel->g = (unsigned char) promedio_g;
			dst_pixel->b = (unsigned char) promedio_b;
			j ++;
		}

		i++;
	}
}
