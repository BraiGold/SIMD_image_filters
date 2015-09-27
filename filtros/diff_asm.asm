default rel
global _diff_asm
global diff_asm

%define TAM_PIXEL_X4   16

section .data

clean_a: db 0x00, 0x01, 0x02, 0x80, 0x04, 0x05, 0x06, 0x80, 0x08, 0x09, 0x0a, 0x80, 0x0c, 0x0d, 0x0e, 0x80
rotacion1: db 0x02, 0x00, 0x01, 0x80, 0x06, 0x04, 0x05, 0x80, 0x0a, 0x08, 0x09, 0x80, 0x0e, 0x0c, 0x0d, 0x80
rotacion2: db 0x01, 0x02, 0x00, 0x80, 0x05, 0x06, 0x04, 0x80, 0x09, 0x0a, 0x08, 0x80, 0x0d, 0x0e, 0x0c, 0x80

section .text
;void diff_asm    (
	;unsigned char *src,
    ;unsigned char *src2,
	;unsigned char *dst,
	;int filas,
	;int cols)

_diff_asm:
diff_asm:
    ;*------------------------------------------------------------------------*
    ;* Parámetros de entrada
    ;* --> RDI: puntero a imagen fuente 1
    ;* --> RSI: puntero a imagen fuente 2
    ;* --> RDX: puntero a imagen destino
    ;* --> RCX: cantidad de filas de las imágenes
    ;* --> R8:  cantidad de columnas de las imágenes
    ;*------------------------------------------------------------------------*

    ; Armo la stack frame alineada
    push rbp
    mov  rbp, rsp

    ; Cargo mmáscaras a registros XMM
    movdqu xmm13, [clean_a]
    movdqu xmm14, [rotacion1]
    movdqu xmm15, [rotacion2]

    ; Determino la cantidad de iteraciones que voy a realizar: filas*columnas/4
    movd xmm1, ecx
    movd xmm2, r8d

    pmuludq xmm1, xmm2      ; XMM1 = filas*columnas

    xor  r9, r9
    movd r9d, xmm1
    shr  r9d, 2

    ; Recorro la imagen donde realizo la diferencia entre las imágenes fuente
    ; procesando de a 4 píxeles

    .recorrerPixeles:

        movdqu xmm1, [rdi]      ; XMM1 = | ... | a1 | r1 | g1 | b1 |
        movdqu xmm2, [rsi]      ; XMM2 = | ... | a2 | r2 | g2 | b2 |

        ; Calculamos la diferencia
        movdqu xmm0, xmm1       ; XMM0 = | ... | a1 | r1 | g1 | b1 |
        pshufb xmm1, xmm13      ; XMM1 = | ... |  0 | r1 | g1 | b1 |
        pshufb xmm2, xmm13      ; XMM2 = | ... |  0 | r2 | g2 | b2 |

                                ; Sea mx = max(x1,x2), con x = {r,g,b}
        pmaxub xmm0, xmm2       ; XMM0 = | ... | a1 | mr | mg | mb |

                                ; Sea dx = abs(x1-x2), con x = {r,g,b}. Entonces, por ejemplo:
        movdqu  xmm3, xmm0      ; XMM3 = | ... | a1 | mr | mg | mb |
        psubusb xmm0, xmm1      ; XMM0 = | ... | a1 | dr |  0 |  0 |
        psubusb xmm3, xmm2      ; XMM3 = | ... | a1 |  0 | dg | db |    

        por xmm0, xmm3          ; XMM0 = | ... | a1 | dr | dg | db |

        ; Obtengo la norma infinito
        movdqu xmm3, xmm0       ; XMM3 = | ... | a1 | dr | dg | db |
        movdqu xmm4, xmm0       ; XMM4 = | ... | a1 | dr | dg | db |

        pshufb xmm3, xmm14      ; XMM3 = | ... |  0 | dg | db | dr |
        pshufb xmm4, xmm15      ; XMM4 = | ... |  0 | db | dr | dg |

        pmaxub xmm0, xmm3       
        pmaxub xmm0, xmm4       ; XMM0 = | ... | a1 |  m |  m |  m |

        ; Calculo la diferencia

        ; Guardo la diferencia en la imagen destino
        movdqu [rdx], xmm0

        ; Avanzo a los siguientes 4 píxeles
        lea rdx, [rdx+TAM_PIXEL_X4]
        lea rdi, [rdi+TAM_PIXEL_X4]
        lea rsi, [rsi+TAM_PIXEL_X4]

        dec r9

    jnz .recorrerPixeles

    pop rbp

    ret
