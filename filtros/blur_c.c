#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"



void blur_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    float sigma,
    int radius)
{
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;

    float k [(2 * radius ) + 1][(2 * radius ) + 1] ;
    int i = 0;
    float total= 0;
    while( i<= (2 * radius ) ){
    	int j = 0;
    	while( j <= (2 * radius )  ){
    		float x = radius -i;
    		float y = radius - j;
    		float ePowBla = pow( 2.71828182846  , -1.0 * ( ( (x*x) + (y*y) ) / (2.0*(pow(sigma,2.0))) )  );
			float constante = (1.0/ (2.0*( 3.14159265359)* pow(sigma,2.0) ));
    		k[i][j]  =  constante *  ePowBla;

    		// printf("%f | ", k[i][j] );
    		
    		total += k[i][j];
    		// printf ("k[i][j] :%f \n" , k[i][j]);
    		j++;
    	}	
    	// printf("\n" );
    	i++;
    }
    // printf("total : %f \n" , total);


    i = radius;
	while(i< (filas - radius)){
		// printf ("i :%i \n" , i);
		int j = radius;
		while(j < (cols -radius)  ){
			// printf ("j :%i \n" , j);
			float promedio_r = 0;
			float promedio_g = 0;
			float  promedio_b = 0;
			int aux_i = i - radius;
			int x =  0;
			//while(aux_i <= (i + 2*radius) ){
			while(aux_i <= (i + radius) ){
				int aux_j = j - radius;
				int y = 0;
				//while(aux_j <= ( j + 2*radius ) ) {
				while(aux_j <= ( j + radius ) ) {
					bgra_t *src_pixel = (bgra_t*)&src_matrix[aux_i][aux_j *4];
					
					promedio_r += ((float)src_pixel->r * k[x][y]);
					promedio_g +=  ((float)src_pixel->g * k[x][y]);
					promedio_b +=  ((float)src_pixel->b * k[x][y]);
					//aux_j = aux_j + 4;
					aux_j ++;
					y ++ ;
				}
				aux_i++;
				x ++;
			}
			// promedio_r = promedio_r / ((2*radius)+1)*((2*radius)+1);
			// promedio_g = promedio_g / ((2*radius)+1)*((2*radius)+1);
			// promedio_b = promedio_b / ((2*radius)+1)*((2*radius)+1);

			bgra_t *dst_pixel = (bgra_t*)&dst_matrix[i][j*4];
			
			dst_pixel->r = (unsigned char) promedio_r;
			dst_pixel->g = (unsigned char) promedio_g;
			dst_pixel->b = (unsigned char) promedio_b;
			// dst_pixel->a = 255;
			// printf ("(%i , %i , %i ) | " ,promedio_r , promedio_g,promedio_b);
			// printf ("dst_pixel->r :%i ," ,promedio_r);
			// printf ("dst_pixel->g :%i ," , promedio_b);
			// printf ("dst_pixel->b :%i \n" , promedio_g);
			//j = j + 4;
			j ++;
		}
		// printf("\n" );
		i++;

	}

}



int relX( int x ){
	return x;
}

int relY( int y ){
	return y/4;
}

int absX( int x ){
	return x;
}

int absY( int y ){
	return y*4;
}
