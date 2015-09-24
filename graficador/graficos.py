import numpy as np
from pylab import *

#~ plt.xkcd()

input_h1_blur_c = 'h1-resultados-blur-c.txt'

# Hipotesis 1
def hipotesis1():
	dim    = []
	ticks1 = []
	ticks2 = []

	# Obtengo los valores
	for line in open(input_h1_blur_c):
		values = line.split(" ");
		dim.append(int(values[0]) * int(values[1]))
		ticks1.append(float(values[2]))
		ticks2.append(float(values[2])/float(int(values[0])*int(values[1])))

	# Grafico 1
	# ---------------------------------------------------------------------
	fig1 = figure(figsize=(7,6))
	ax   = fig1.add_subplot(1,1,1)

	ax.plot(dim,ticks1,'-',lw=5)

	# Escala
	ax.set_xscale('log')
	ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

	# Label
	ax.set_title('# Ticks por dimension de la imagen')
	ylabel('# Ticks')
	xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))

	fig1.savefig('fig1.png')

	# Grafico 2
	# ---------------------------------------------------------------------
	fig2 = figure(figsize=(7,6))
	ax   = fig2.add_subplot(1,1,1)

	ax.plot(dim,ticks2,'-',lw=5)

	# Escala
	#ax.set_xscale('log')
	ax.get_xaxis().set_major_formatter(FuncFormatter(my_formatter_5))

	# Label
	ax.set_title('# Ticks por pixel de la imagen')
	ylabel('# Ticks')
	xlabel('# Pixeles x '+'$10^{{{0:d}}}$'.format(-5))

	fig2.savefig('fig2.png')
	

def my_formatter_5(x, p):
    return "%.1f" % (x * (10 ** (-5)))

def hipotesis3():
	alto  = []
	ancho = []
	ticks = []

	# Obtengo los valores
	for line in open(input_h1_blur_c):
		values = line.split(" ");
		alto.append(int(values[0]))
		ancho.append(int(values[1]))
		ticks.append(float(values[2]))

	# Make plot with vertical (default) colorbar
	fig, ax = plt.subplots()

	cax = ax.imshow(ticks, origin='lower', interpolation='none', cmap='hot')
	ax.set_title('Titulo')

	# Put the major ticks at the middle of each cell
	ax.set_xticks(ancho, minor=False)
	ax.set_yticks(alto, minor=False)

	# Labels
	column_labels = ancho
	row_labels    = alto
	ax.set_xticklabels(column_labels, minor=False)
	ax.set_yticklabels(row_labels, minor=False)
	xlabel('# Pixeles ancho')
	ylabel('# Pixeles alto')

	# Add colorbar, make sure to specify tick locations to match desired ticklabels
	#cbar = fig.colorbar(cax, ticks=[ticks.min(),ticks.max()])
	#cbar.ax.set_yticklabels(['%'ticks.min(),ticks.max()])# vertically oriented colorbar

