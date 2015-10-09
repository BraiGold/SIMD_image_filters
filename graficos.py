import numpy as np
from pylab import *
import math

#~ plt.xkcd()

ini = 32
gra = 128

#*----------------------------------------------------------------------------*
#* Hipotesis 1
def hipotesis1():
    #hipotesis1_blur( '0.78', '2' )
    #hipotesis1_blur( '1.00', '3' )
    #hipotesis1_blur( '2.00', '6' )
    #hipotesis1_blur( '3.00', '9' )
    #hipotesis1_blur( '4.00', '12' )
    hipotesis1_blur( '5.00', '15' )
    hipotesis1_diff()

#*----------------------------------------------------------------------------*
#* Hipotesis 2
def hipotesis2():
    #hipotesis2_blur( 'c', '0.78', '2' )
    #hipotesis2_blur( 'c', '1.00', '3' )
    #hipotesis2_blur( 'c', '2.00', '6' )
    #hipotesis2_blur( 'c', '3.00', '9' )
    #hipotesis2_blur( 'c', '4.00', '12' )
    hipotesis2_blur( 'c-O2', '5.00', '15' )

    #hipotesis2_blur( 'asm', '0.78', '2' )
    #hipotesis2_blur( 'asm', '1.00', '3' )
    #hipotesis2_blur( 'asm', '2.00', '6' )
    #hipotesis2_blur( 'asm', '3.00', '9' )
    #hipotesis2_blur( 'asm', '4.00', '12' )
    hipotesis2_blur( 'asm-1', '5.00', '15' )

    hipotesis2_blur( 'asm-2', '5.00', '15' )

    hipotesis2_diff( 'c-O2' )
    hipotesis2_diff( 'asm' )

#*----------------------------------------------------------------------------*
#* Hipotesis 1 - BLUR
def hipotesis1_blur( sigma, radius ):
    # Inicializo las listas
    dim_c    = []
    ticks_c1 = []
    ticks_c2 = []
    ticks_c3 = []
    error_c  = []

    dim_aa    = []
    ticks_aa1 = []
    ticks_aa2 = []
    ticks_aa3 = []
    error_aa  = []

    dim_ab    = []
    ticks_ab1 = []
    ticks_ab2 = []
    ticks_ab3 = []
    error_ab  = []

    const = []

    # Obtengo los valores
    for line in open('h1-blur-c-O2-'+sigma+'-'+radius+'.txt'):
        values = line.split(" ");
        dim    = int(values[0]) * int(values[1])
        dim_c.append(dim)
        ticks_c1.append(float(values[2]))
        ticks_c2.append(float(values[2])/float(dim))
        ticks_c3.append(float(values[2])/(float(dim)*float(dim)))
        error_c.append(float(values[3]))

    for line in open('h1-blur-asm-1-'+sigma+'-'+radius+'.txt'):
        values = line.split(" ");
        dim    = int(values[0]) * int(values[1])
        dim_aa.append(dim)
        ticks_aa1.append(float(values[2]))
        ticks_aa2.append(float(values[2])/float(dim))
        ticks_aa3.append(float(values[2])/(float(dim)*float(dim)))
        error_aa.append(float(values[3]))

    for line in open('h1-blur-asm-2-'+sigma+'-'+radius+'.txt'):
        values = line.split(" ");
        dim    = int(values[0]) * int(values[1])
        dim_ab.append(dim)
        ticks_ab1.append(float(values[2]))
        ticks_ab2.append(float(values[2])/float(dim))
        ticks_ab3.append(float(values[2])/(float(dim)*float(dim)))
        error_ab.append(float(values[3]))

    n = len(ticks_c1)

    for i in range(n):
        const.append((ticks_c1[i]/ticks_ab1[i]))

    # Grafico 1: Ticks por cantidad de pixeles de la imagen
    # -------------------------------------------------------------------------
    fig1 = figure(figsize=(9,6))
    ax   = fig1.add_subplot(1,1,1)

    ax.errorbar(dim_c, ticks_c1, yerr=error_c, linestyle='-', linewidth=1, label='$T_C(n)$' )
    ax.errorbar(dim_aa, ticks_aa1, yerr=error_aa, linestyle='-', linewidth=1, label='$T_{ASM1}(n)$' )
    ax.errorbar(dim_ab, ticks_ab1, yerr=error_ab, linestyle='-', linewidth=1, label='$T_{ASM2}(n)$' )

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    ax.set_title('$\sigma = '+sigma+" \ \ r = "+radius+"$")
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    # Guardo el grafico generado
    fig1.savefig('h1-blur'+'-'+sigma+'-'+radius+'.png', bbox_extra_artists=(lgd,), bbox_inches='tight')

    # Grafico 2: Ticks/pixel por cantidad de pixeles de la imagen
    # -------------------------------------------------------------------------
    fig2 = figure(figsize=(9,6))
    ax   = fig2.add_subplot(1,1,1)

    ax.plot(dim_c, ticks_c2, '-', lw=2, label='$T_C(n)/n$')
    ax.plot(dim_aa, ticks_aa2, '-', lw=2, label='$T_{ASM1}(n)/n$')
    ax.plot(dim_ab, ticks_ab2, '-', lw=2, label='$T_{ASM2}(n)/n$')

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    ax.set_title('$\sigma = '+sigma+" \ \ r = "+radius+"$")
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    fig2.savefig('h1-blur'+'-'+sigma+'-'+radius+'_lineal.png', bbox_extra_artists=(lgd,), bbox_inches='tight')

    # Grafico 3: Ticks/pixel^2 por cantidad de pixeles de la imagen
    # -------------------------------------------------------------------------
    fig3 = figure(figsize=(9,6))
    ax   = fig3.add_subplot(1,1,1)

    ax.plot(dim_c, ticks_c3, '-', lw=2, label='$T_C(n)/n^2$')
    ax.plot(dim_aa, ticks_aa3, '-', lw=2, label='$T_{ASM1}(n)/n^2$')
    ax.plot(dim_ab, ticks_ab3, '-', lw=2, label='$T_{ASM2}(n)/n^2$')

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    ax.set_title('$\sigma = '+sigma+" \ \ r = "+radius+"$")
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    fig3.savefig('h1-blur-'+sigma+'-'+radius+'_cuadratica.png', bbox_extra_artists=(lgd,), bbox_inches='tight')

    # Grafico 4: Ticks C / Ticks ASM por cantidad de pixeles de la imagen
    # -------------------------------------------------------------------------
    fig4 = figure(figsize=(9,6))
    ax   = fig4.add_subplot(1,1,1)

    ax.plot(dim_c, const, '-', lw=2, label='$T_C(n)/T_{ASM}(n)$')

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    ax.set_title('$\sigma = '+sigma+" \ \ r = "+radius+"$")
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    fig4.savefig('h1-blur-'+sigma+'-'+radius+'_constante.png', bbox_extra_artists=(lgd,), bbox_inches='tight')

#*----------------------------------------------------------------------------*
#* Hipotesis 1 - DIFF
def hipotesis1_diff():
    # Inicializo las listas
    dim_c    = []
    ticks_c1 = []
    ticks_c2 = []
    ticks_c3 = []
    error_c  = []

    dim_aa    = []
    ticks_aa1 = []
    ticks_aa2 = []
    ticks_aa3 = []
    error_aa  = []

    const = []

    # Obtengo los valores
    for line in open('h1-diff-c-O2.txt'):
        values = line.split(" ");
        dim    = int(values[0]) * int(values[1])
        dim_c.append(dim)
        ticks_c1.append(float(values[2]))
        ticks_c2.append(float(values[2])/float(dim))
        ticks_c3.append(float(values[2])/float(dim*dim))
        error_c.append(float(values[3]))

    for line in open('h1-diff-asm.txt'):
        values = line.split(" ");
        dim    = int(values[0]) * int(values[1])
        dim_aa.append(dim)
        ticks_aa1.append(float(values[2]))
        ticks_aa2.append(float(values[2])/float(dim))
        ticks_aa3.append(float(values[2])/float(dim*dim))
        error_aa.append(float(values[3]))

    n = len(ticks_c1)

    for i in range(n):
        const.append((ticks_c1[i]/ticks_aa1[i]))
    # Grafico 1: Ticks por dimension de la imagen
    # -------------------------------------------------------------------------
    fig1 = figure(figsize=(9,6))
    ax   = fig1.add_subplot(1,1,1)

    ax.errorbar(dim_c, ticks_c1, yerr=error_c, linestyle='-', linewidth=1, label='$T_C(n)$' )
    ax.errorbar(dim_aa, ticks_aa1, yerr=error_aa, linestyle='-', linewidth=1, label='$T_{ASM}(n)$' )

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    # Guardo el grafico generado
    fig1.savefig('h1-diff.png', bbox_extra_artists=(lgd,), bbox_inches='tight')

    # Grafico 2: Ticks por pixel de la imagen
    # -------------------------------------------------------------------------
    fig2 = figure(figsize=(9,6))
    ax   = fig2.add_subplot(1,1,1)

    ax.plot(dim_c, ticks_c2, '-', lw=2, label='$T_C(n)/n$')
    ax.plot(dim_aa, ticks_aa2, '-', lw=2, label='$T_{ASM}(n)/n$')

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    #ax.set_title()
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    fig2.savefig('h1-diff_lineal.png', bbox_extra_artists=(lgd,), bbox_inches='tight')

    # Grafico 3: Ticks/pixel^2 por cantidad de pixeles de la imagen
    # -------------------------------------------------------------------------
    fig3 = figure(figsize=(9,6))
    ax   = fig3.add_subplot(1,1,1)

    ax.plot(dim_c, ticks_c3, '-', lw=2, label='$T_C(n)/n^2$')
    ax.plot(dim_aa, ticks_aa3, '-', lw=2, label='$T_{ASM1}(n)/n^2$')

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    #ax.set_title()
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    fig3.savefig('h1-diff_cuadratica.png', bbox_extra_artists=(lgd,), bbox_inches='tight')

    # Grafico 4: Ticks C / Ticks ASM por cantidad de pixeles de la imagen
    # -------------------------------------------------------------------------
    fig4 = figure(figsize=(9,6))
    ax   = fig4.add_subplot(1,1,1)

    ax.plot(dim_c, const, '-', lw=2, label='$T_C(n)/T_{ASM}(n)$')

    # Escala
    #ax.set_xscale('log') # Escala logaritmica en X
    #ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

    # Label
    #ax.set_title()
    ylabel('$T$ = # Ticks')
    xlabel('$n$ = # Pixeles')
    #xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))
    lgd = ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0. )

    fig4.savefig('h1-diff_constante.png', bbox_extra_artists=(lgd,), bbox_inches='tight')
	

#*----------------------------------------------------------------------------*
#* Formato de la escala de valores de x
def my_formatter_5(x, p):
    return "%.1f" % (x * (10 ** (-5)))

#*----------------------------------------------------------------------------*
#* Hipotesis 2 - BLUR
def hipotesis2_blur( imp, sigma, radius ):

    # Inicializo las listas
    #alto  = []
    #ancho = []
    ticks = []

    # Obtengo los valores
    for line in open('h2-blur-'+imp+'-'+sigma+'-'+radius+'.txt'):
        values = line.split(" ");
        #alto.append(int(values[0]))
        #ancho.append(int(values[1]))
        ticks.append(float(values[2]))

    # Necesito una matrix con los valores obtenidos y vectores con los valores
    # de los ejes
    n      = int(math.sqrt(len(ticks)))
    matrix = np.zeros((n,n))
    index  = 0

    for i in range(n):
        for j in range(n):
            matrix[i][j] = ticks[index]
            index = index + 1

    columnas = np.arange(ini, n*gra+1, gra)
    filas    = np.arange(ini, n*gra+1, gra)

    # Grafico: Ticks por dimension de la imagen
    # -------------------------------------------------------------------------
    #fig = plt.figure()
    fig, ax = plt.subplots()
    plt.set_cmap('hot')

    # Labels
    ax.set_title('Sigma = '+sigma+" - Radio = "+radius)
    xlabel('# Pixeles ancho')
    ylabel('# Pixeles alto')

    plt.pcolor(columnas, filas, matrix, vmin=min(ticks), vmax=max(ticks))
    plt.colorbar(orientation='vertical')
    plt.axis([columnas.min(), columnas.max(), filas.min(), filas.max()])

    fig.savefig('h2-blur-'+imp+'-'+sigma+'-'+radius+'.png')

#*----------------------------------------------------------------------------*
#* Hipotesis 2 - DIFF
def hipotesis2_diff( imp ):

    # Inicializo las listas
    #alto  = []
    #ancho = []
    ticks = []

    # Obtengo los valores
    for line in open('h2-diff-'+imp+'.txt'):
        values = line.split(" ");
        #alto.append(int(values[0]))
        #ancho.append(int(values[1]))
        ticks.append(float(values[2]))

    # Necesito una matrix con los valores obtenidos y vectores con los valores
    # de los ejes
    n      = int(math.sqrt(len(ticks)))
    matrix = np.zeros((n,n))
    index  = 0

    for i in range(n):
        for j in range(n):
            matrix[i][j] = ticks[index]
            index = index + 1

    columnas = np.arange(ini, n*gra+1, gra)
    filas    = np.arange(ini, n*gra+1, gra)

    # Grafico: Ticks por dimension de la imagen
    # -------------------------------------------------------------------------
    #fig = plt.figure()
    fig, ax = plt.subplots()
    plt.set_cmap('hot')

    # Labels
    xlabel('# Pixeles ancho')
    ylabel('# Pixeles alto')

    plt.pcolor(columnas, filas, matrix, vmin=min(ticks), vmax=max(ticks))
    plt.colorbar(orientation='vertical')
    plt.axis([columnas.min(), columnas.max(), filas.min(), filas.max()])

    fig.savefig('h2-diff-'+imp+'.png')

