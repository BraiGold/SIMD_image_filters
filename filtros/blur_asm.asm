default rel
global _blur_asm
global blur_asm

extern getKernel

%define TAM_PIXEL   4
%define TAM_FLOAT   4

section .data

cast_to_float: db 0x00, 0x80, 0x80, 0x80, 0x01, 0x80, 0x80, 0x80, 0x02, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
cast_to_int8: db 0x00, 0x04, 0x08, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
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

            movd      xmm2, [r13]
            psrldq    xmm2, 3
			pslldq    xmm2, 3
            por       xmm1, xmm2

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
