#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

void diff_c (
	unsigned char *src,
	unsigned char *src_2,
	unsigned char *dst,
	int m, // ancho
	int n, // alto
	int src_row_size,
	int src_2_row_size,
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	int i = 0;
	while(i<n){
		int j = 0;
		while(j < (m)){
			bgra_t *dst_pixel = (bgra_t*)&dst_matrix[i][j*4];
			bgra_t *src_pixel = (bgra_t*)&src_matrix[i][j*4];
			bgra_t *src_2_pixel = (bgra_t*)&src_2_matrix[i][j*4];

			dst_pixel->r = abs(src_pixel->r - src_2_pixel->r);
			dst_pixel->g = abs(src_pixel->g - src_2_pixel->g);
			dst_pixel->b = abs(src_pixel->b - src_2_pixel->b);
			dst_pixel->a = 255;
			j++;
		}
		i++;
	}
}

