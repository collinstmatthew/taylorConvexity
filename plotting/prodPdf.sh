#!/bin/bash

#Compiled graph from gnuplot into a cropped pdf

# run gnuplot
gnuplot plotg.gnuplot

# compile both pdflatex
pdflatex pdfLin.tex
pdflatex pdfQuad.tex

# remove whitespace
pdfcrop pdfLin.pdf pdfLin.pdf
pdfcrop pdfQuad.pdf pdfQuad.pdf

pdftoppm -png pdfQuad.pdf QuadFinal
pdftoppm -png pdfLin.pdf LinFinal
