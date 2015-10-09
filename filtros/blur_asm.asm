default rel
global _blur_asm
global blur_asm

extern getKernel

;*----------------------------------------------------------------------------*
;* CONSTANTES
;*----------------------------------------------------------------------------*
%define TAM_PIXEL   4
%define TAM_FLOAT   4


%define NULL 		0
%define TRUE 		1
%define FALSE 		0

%define RGBA_SIZE 	    	 4
%define OFFSET_R 		 	 0
%define OFFSET_G 		 	 1
%define OFFSET_B 		 	 2
%define OFFSET_A 		 	 3

;*----------------------------------------------------------------------------*
;* DATA
;*----------------------------------------------------------------------------*
section .data

cast_to_float: db 0x00, 0x80, 0x80, 0x80, 0x01, 0x80, 0x80, 0x80, 0x02, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
cast_to_int8: db 0x00, 0x04, 0x08, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80


;UNPACK_B_2_DW_MASK DB 0x80,0x80,0x80,0x04,0x80,0x80,0x80,0x03,0x80,0x80,0x80,0x02,0x80,0x80,0x80,0x01
;before = b | g | r | a | b | g | r | a | b | g | r | a | b | g | r | a |
UNPACK_B_2_DW_MASK: DB 0x00, 0x80, 0x80, 0x80, 0x01, 0x80, 0x80, 0x80, 0x02, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
;after = 0 | 0 | 0 | b | 0 | 0 | 0 | r | 0 | 0 | 0 | g | 0 | 0 | 0 | a |

;before = x | x | x | b | x | x | x | g | x | x | x | r | x | x | x | a |
PACK_DW_2_B_MASK: DB 0x00, 0x04, 0x08, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
;after = 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | b | g | r | a |

A_MASK: DB 0x00, 0x00, 0x00, 0xff, 0x00, 0x00 , 0x00 , 0xff , 0x00 , 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff

;*----------------------------------------------------------------------------*
;* CODE
;*----------------------------------------------------------------------------*
section .text

;void blur_asm (
;               unsigned char *src,
;               unsigned char *dst,
;               int filas,
;               int cols,
;               float sigma,
;               int radius)

_blur_asm:
blur_asm:
    push rbp
    mov  rbp, rsp

    ;call implementacion1
    call implementacion2

    pop rbp
    ret


;* Implementación 1
;*----------------------------------------------------------------------------*
implementacion1:
    ;*------------------------------------------------------------------------*
    ;* Parámetros de entrada
    ;* --> RDI: puntero a imagen fuente
    ;* --> RSI: puntero a imagen destino
    ;* --> RDX: cantidad de filas de la imagen fuente
    ;* --> RCX: cantidad de columnas de la imagen fuente
    ;* --> R8: radio
    ;* --> XMM0: sigma
    ;*------------------------------------------------------------------------*

    ; Armo la stack frame alineada
    push rbp
    mov  rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub  rsp, 8

    ; Se guardan los parametros de entrada
    mov r12, rdi
    mov r13, rsi

    xor r14, r14
    xor r15, r15
    xor rbx, rbx

    mov r14d, edx
    mov r15d, ecx
    mov ebx , r8d

    ; R12: puntero a imagen fuente
    ; R13: puntero a imagen destino
    ; R14: cantidad de filas de la imagen fuente
    ; R15: cantidad de columnas de la imagen fuente
    ; RBX: radio

    ; Se obtiene la matriz de convolución
    mov  rdi, rbx
    call getKernel
    mov  rdi, rax

    ; RDI: matriz de convolución

    ; Determino la dimensión de la matriz de convolusión: (2*radio)+1
    mov rax, rbx
    add rax, rbx
    inc rax

    ; RAX: dimensión de la matriz de convolusión

    ; Recorro los píxeles de la imagen fuente de a uno sin considerar los que
    ; estan en los bordes no aplicables (lo cual depende del radio) y para ello
    ; defino:
    ;
    ; RCX: cantidad de filas a iterar
    ; RDX: cantidad de columnas a iterar

    ; Determino la primera fila de la imagen fuente donde aplico blur
    movd xmm1, ebx          ; XMM1 = radio
    movd xmm2, r15d         ; XMM2 = cantColumnas

    pmuludq xmm1, xmm2      ; XMM1 = radio*cantColumnas

    xor  rcx, rcx
    movd ecx, xmm1          ; RCX = radio*cantColumnas

    lea r13, [r13+rcx*TAM_PIXEL]

    ; Recorro las filas de la imagen fuente
    mov rcx, r14
    sub rcx, rbx
    sub rcx, rbx

    movdqu xmm13, [A_MASK]
    movdqu xmm14, [cast_to_float]
    movdqu xmm15, [cast_to_int8]

    .recorrerFilas:

        ; Recorro los píxeles de la fila de la imagen fuente donde aplico blur
        mov rdx, r15
        sub rdx, rbx
        sub rdx, rbx

        lea r13, [r13+rbx*TAM_PIXEL]

        .recorrerColumnas:

            ; Guardo en la pila los punteros a la imagen fuente y la matriz de
            ; convolución
            push r12
            push rdi

            lea  r11, [rdi]
            pxor xmm1, xmm1

            ; R11: puntero auxiliar a la matriz de convolución
            ; XMM1: Acumulador

            ; Recorro la matriz de convolución y la imagen fuente en la región
            ; determinada por el radio
            mov r8, 0

            .recorrerFilasKernel:

                lea r10, [r12]

                ; R10: puntero auxiliar a imagen fuente

                mov r9, 0

                .recorrerColumnasKernel:
                    ; Voy acumulando el producto PIXEL[i][j]*K[i][j] en XMM1

                    movd     xmm2, [r10]
                    pshufb   xmm2, xmm14
                    cvtdq2ps xmm2, xmm2     ; XMM2 = (float) PIXEL[i][j] = | A | R | G | B |

                    movd     xmm3, [r11]    ; XMM3 = |    0    |    0    |    0    | K[i][j] |
                    pshufd   xmm3, xmm3, 0  ; XMM3 = | K[i][j] | K[i][j] | K[i][j] | K[i][j] |

                    mulps    xmm2, xmm3     ; XMM2 = PIXEL[i][j]*K[i][j]
                    addps    xmm1, xmm2     ; XMM1 = XMM1 + PIXEL[i][j]*K[i][j]

                    ; Avanzo al siguiente valor K[i][j] de la fila en la matriz
                    ; de convolución y al siguiente valor PIXEL[i][j] de la fila
                    ; en la imagen fuente de la región determinada por el radio
                    lea r10, [r10+TAM_PIXEL]
                    lea r11, [r11+TAM_FLOAT]

                    inc r9
                    cmp r9, rax

                jne .recorrerColumnasKernel

                ; Avanzo a la siguiente fila en la imagen fuente en la región
                ; determinada por el radio
                lea r12, [r12+r15*TAM_PIXEL]

                inc r8
                cmp r8, rax
                
            jne .recorrerFilasKernel

            cvtps2dq  xmm1, xmm1
            pshufb    xmm1, xmm15
            por       xmm1, xmm13   ; Agrego tranparencia con valor 255

            movd     [r13], xmm1

            pop rdi
            pop r12

            ; Avanzo al siguiente pixel de la fila al que aplico blur
            lea r12, [r12+TAM_PIXEL]
            lea r13, [r13+TAM_PIXEL]

            dec rdx

        ; Salto si hay columnas que recorrer
        jnz .recorrerColumnas

        ; Avanzo a la siguiente fila de la imagen donde voy a aplicar blur
        lea r12, [r12+rbx*TAM_PIXEL]
        lea r12, [r12+rbx*TAM_PIXEL]
        lea r13, [r13+rbx*TAM_PIXEL]

        dec rcx

    ; Salto si hay filas que recorrer
    jnz .recorrerFilas

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret


;* Implementación 2
;*----------------------------------------------------------------------------*
implementacion2:
;stack frame
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15
sub rsp, 8

; RDI = src
; RSI = dst
; RDX = filas
; RCX = cols
; XMM0 = sigma
; R8 = radius
; Muevo las variables a registros seguros
mov	r12, rdi
mov	r13, rsi
mov	r14, rcx	
mov	r15, rdx
mov rbx, r8
;Calculo el k 
mov edi, r8d
call getKernel
mov r10, rax


; indice de la imagen dest (r8) = 4 * ((radius * columna) + radius)
; r8 = (radius * filas) 
mov eax , ebx
mov edx , r15d
mul edx
shl rdx , 32
or rax , rdx
mov r8 , rax
; r8 += radius
add r8 , rbx
shl r8 , 2
; diagonal (rsi) = 4 * ((radius * columna) + radius)
mov rsi , r8
; #k (r11) = ((2 * radius) + 1) * ((2 * radius) + 1)
mov eax , ebx
shl rax , 1
add eax , 1
mov edx , eax
mul edx
shl rdx , 32
or rax , rdx
mov r11 , rax


; cant de filas por recorrer
;r9 = filas - 2* radius
mov r9 , r14
sub r9 , rbx
sub r9 , rbx

; me guardo las mascaras 
; xmm15 = UNPACK_B_2_DW_MASK
; xmm15 = PACK_DW_2_B_MASK
movdqu xmm15 , [UNPACK_B_2_DW_MASK]
movdqu xmm14 , [PACK_DW_2_B_MASK]
movdqu xmm13 , [A_MASK]

.ciclo_filas:
	;cant de columnas por recorrer
	;rcx = columnas - 2 * radius
	mov rcx , r15
	sub rcx , rbx
	sub rcx , rbx
	; voy a necesitar r9
	push r9
	
	
	

	.ciclo_columnas:

		
		; indice de k (rdx) = 0
		xor rdx , rdx

		;indice de la sub imagen de los vecinos  (rdi) = indice -  diagonal (rsi)
		;rdi = indice 
		mov rdi , r8
		;rdi = rdi -  4 * ((radius * columna) + radius)
		sub rdi , rsi
		; voy a necesitar rcx
		push rcx

		; indice de los vecinos por fila (r9) = (2 * radius) + 1
		
		mov r9 , rbx
		add r9 , rbx
		add r9 , 1

		;(dest_p_0) xmm8 = 0 | 0 | 0 | 0 
		pxor xmm8 , xmm8
		;(dest_p_1) xmm9 = 0 | 0 | 0 | 0
		pxor xmm9 , xmm9
		;(dest_p_2) xmm10 = 0 | 0 | 0 | 0
		pxor xmm10 , xmm10
		;(dest_p_3) xmm11 = 0 | 0 | 0 | 0
		pxor xmm11 , xmm11

		; blur !!!
		.ciclo_vecinos_filas:

			; indice de los vecinos por columnas (rcx) = (2 * radius) + 1
			
			mov rcx , rbx
			add rcx , rbx
			add rcx , 1
			xor rax , rax

			

			.ciclo_vecinos_columnas:

				movd     xmm6, [r10 + rdx]    ; XMM6 = |    0    |    0    |    0    | K[i][j] |
                   
				; cmp rax , 0
				; jle .esta_vacio


				; sub rax , 1
				; psrldq xmm6 , 4
				; jmp .sumatoria

				; .esta_vacio:
				; ; quiero levantar 4 floats de k
				; mov rax , 4
				
				; ; me fijo si los 4 q hagaro pertecen a k
				; push rdx
				; ; (rdx / 4) + 4 < #k
				; shr rdx , 2
				; add rdx , 4
				; cmp rdx , r11
				; pop rdx
				; jg .levanto_1

				; ;levanto_4:
				; ; xmm6 =  k_0 | k_1 | k_2 | k_3 |
				; movdqu xmm6 , [r10 + rdx]
				; ; salto 4 lugares en la matris k
				; add rdx , 16
				; jmp .sumatoria

				; .levanto_1:
				; sub rdx , 12
				; movdqu xmm6 , [r10 + rdx]
				; ;xmm6 = 0 | 0 | 0| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | x | x | x | x |
				; psrldq xmm6 , 12
				

				.sumatoria:
			
				; k_0 :
				; xmm7 = k_0 | k_0 | k_0 | k_0 |
				pshufd xmm7 , xmm6 , 0 

				; (source) xmm0 = r | g | b | a | r | g | b | a | r | g | b | a | r | g | b | a |
				; xmm0 = p_0 | p_1 | p_2 | p_3 |
				movdqu xmm0 , [r12 + rdi]

				
				


				; p_0:
				movdqu xmm1 , xmm0
				pshufb xmm1 , xmm15
				; xmm2 = float_r | float_b | float_g | float_a
				cvtdq2ps xmm2 , xmm1
				; xmm0 = 0 | 0 | 0| 0 | x | x | x | x | x | x | x | x | x | x | x | x |
				psrldq xmm0 , 4

				; p_1:
				movdqu xmm1 , xmm0
				pshufb xmm1 , xmm15
				; xmm3 = float_r | float_b | float_g | float_a
				cvtdq2ps xmm3 , xmm1
				; xmm0 = 0 | 0 | 0| 0 | 0 | 0 | 0 | 0 | x | x | x | x | x | x | x | x |
				psrldq xmm0 , 4

				; p_2:
				movdqu xmm1 , xmm0
				pshufb xmm1 , xmm15
				; xmm4 = float_r | float_b | float_g | float_a
				cvtdq2ps xmm4 , xmm1
				; xmm0 = 0 | 0 | 0| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | x | x | x | x |
				psrldq xmm0 , 4

				; p_3:
				movdqu xmm1 , xmm0
				pshufb xmm1 , xmm15
				; xmm5 = float_r | float_b | float_g | float_a
				cvtdq2ps xmm5 , xmm1
				
				; xmm2 =  k_0 * float_r | k_0 * float_g | k_0 * float_b | k_0 * float_a |
				mulps xmm2 , xmm7
				; xmm8 =  x + (k_0 * float_r ) | x + (k_0 * float_g ) | x + (k_0 * float_b ) | x + (k_0 * float_a ) |
				addps xmm8 , xmm2

				; xmm3 =  k_0 * float_r | k_0 * float_g | k_0 * float_b | k_0 * float_a |
				mulps xmm3 , xmm7
				; xmm9 =  x + (k_0 * float_r ) | x + (k_0 * float_g ) | x + (k_0 * float_b ) | x + (k_0 * float_a ) |
				addps xmm9 , xmm3

				; xmm4 =  k_0 * float_r | k_0 * float_g | k_0 * float_b | k_0 * float_a |
				mulps xmm4 , xmm7
				; xmm10 =  x + (k_0 * float_r ) | x + (k_0 * float_g ) | x + (k_0 * float_b ) | x + (k_0 * float_a ) |
				addps xmm10 , xmm4

				; xmm5 =  k_0 * float_r | k_0 * float_g | k_0 * float_b | k_0 * float_a |
				mulps xmm5 , xmm7
				; xmm11 =  x + (k_0 * float_r ) | x + (k_0 * float_g ) | x + (k_0 * float_b ) | x + (k_0 * float_a ) |
				addps xmm11 , xmm5

				; salto al siguiente pixel
				add rdi , 4
				add rdx , 4

				;mientras (rcx - 1 > 0) tenga pixeles a la levantar
				sub rcx , 1
				cmp rcx , 0
				jg .ciclo_vecinos_columnas

			; salto a la siguiente fila
			;rax = (columnas * 4)
			mov rax , r15
			shl rax , 2
			; rdi += (columnas * 4)
			add rdi ,rax 
			
			; salto a inicio de la  columna de vencidad
			;rax =  4*((2 * radius) + 1)
			mov rax , rbx
			add rax , rbx
			add rax , 1
			shl rax , 2
			sub rdi , rax

			;mientras (r9 - 1 >  0 ) tenga filas
			sub r9 , 1
			cmp r9 , 0
			jg .ciclo_vecinos_filas

		
				
				

		; empaqueto el resultado 
		; el resultado final (xmm12) = 0 | 0 | 0 | 0
		pxor xmm12 , xmm12

		; empaqueto p_3 
		; xmm8 = dest_r | dest_g |dest_b | dest_a 
		cvtps2dq xmm11 , xmm11
		; como se q dest_r es menor a 255 , por gauus  brg
		; Entonces en realidad tengo 
		; xmm8 = 0 | 0 | 0 | dest_r | 0 | 0 | 0 | dest_g | 0 | 0 | 0 | dest_b | 0 | 0 | 0 | dest_a |
		; xmm8 =  0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | dest_b | dest_r | dest_g | dest_a |
		pshufb xmm11 , xmm14
		;le agregeo el resultado a el xmm q voy a guardar en memoria 
		;xmm12 =  x | x | x | x | x | x | x | x | x | x | x | dest_b | dest_r | dest_g | dest_a
		por xmm12 , xmm11
		;xmm12 = 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | dest_b | dest_r | dest_g | dest_a | 0 | 0 | 0 | 0 |
		pslldq xmm12 , 4

		; empaqueto p_2 
		; xmm8 = dest_r | dest_g |dest_b | dest_a 
		cvtps2dq xmm10 , xmm10
		; como se q dest_r es menor a 255 , por gauus  brg
		; Entonces en realidad tengo 
		; xmm8 = 0 | 0 | 0 | dest_r | 0 | 0 | 0 | dest_g | 0 | 0 | 0 | dest_b | 0 | 0 | 0 | dest_a |
		; xmm8 =  0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | dest_b | dest_r | dest_g | dest_a |
		pshufb xmm10 , xmm14
		;le agregeo el resultado a el xmm q voy a guardar en memoria y shifteo
		;xmm12 = 0 | 0 | 0 | 0 | x | x | x | x | x | x | x | x | 0 | 0 | 0 | 0 |
		por xmm12 , xmm10
		;xmm12 =  x | x | x | x | x | x | x | x | dest_b | dest_r | dest_g | dest_a | 0 | 0 | 0 | 0 |
		pslldq xmm12 , 4

		; empaqueto p_1
		; xmm8 = dest_r | dest_g |dest_b | dest_a 
		cvtps2dq xmm9 , xmm9
		; como se q dest_r es menor a 255 , por gauus  brg
		; Entonces en realidad tengo 
		; xmm8 = 0 | 0 | 0 | dest_r | 0 | 0 | 0 | dest_g | 0 | 0 | 0 | dest_b | 0 | 0 | 0 | dest_a |
		; xmm8 =  0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | dest_b | dest_r | dest_g | dest_a |
		pshufb xmm9 , xmm14
		;le agregeo el resultado a el xmm q voy a guardar en memoria y shifteo
		;xmm12 = 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | x | x | x | x | dest_b | dest_r | dest_g | dest_a |
		por xmm12 , xmm9
		;xmm12 = 0 | 0 | 0 | 0 | x | x | x | x | dest_b | dest_r | dest_g | dest_a | 0 | 0 | 0 | 0 |
		pslldq xmm12 , 4


		; empaqueto p_0 
		; xmm8 = dest_r | dest_g |dest_b | dest_a 
		cvtps2dq xmm8 , xmm8
		; como se q dest_r es menor a 255 , por gauus  brg
		; Entonces en realidad tengo 
		; xmm8 = 0 | 0 | 0 | dest_r | 0 | 0 | 0 | dest_g | 0 | 0 | 0 | dest_b | 0 | 0 | 0 | dest_a |
		; xmm8 =  0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | dest_b | dest_r | dest_g | dest_a |
		pshufb xmm8 , xmm14
		;le agregeo el resultado a el xmm q voy a guardar en memoria y shifteo
		;xmm12 = 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | dest_b | dest_r | dest_g | dest_a |
		por xmm12 , xmm8
		

		; le enchufo 255 a la a de brga
		por xmm12 , xmm13
		

		;lo guardo en memoria
		movdqu [r13 + r8] , xmm12
		;si en relidad tengo q procesar 2 pixeles en vez de 4 
		pop rcx
		cmp rcx , 6
		je .levanto_2

		; levanto 4
		; indice += (4 pixeles) 
		add r8 , 16
		jmp .sig_columna

		.levanto_2:
		; indice -= (2 pixeles)
		add r8 , 8
		


		.sig_columna:

		;mientras (rcx - 4 >  0 ) tenga 4 pixeles para levatar
		
		sub rcx , 4
		cmp rcx , 0
		jg .ciclo_columnas

		
	
	;rcx =  8 * radius
	mov rcx , rbx
	shl rcx , 3
	; indice +=  8 * radius
	add r8 , rcx

	;mientras (r9 - 1 >  0 ) tenga filas
	pop r9
	sub r9 , 1
	cmp r9 , 0
	jg .ciclo_filas


.fin:



add rsp, 8
pop  r15
pop  r14
pop  r13
pop  r12
pop  rbx
pop  rbp

ret
