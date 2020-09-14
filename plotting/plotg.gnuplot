set datafile separator ','
#labels
set xlabel 'Interest Rate ($r$)'
set ylabel 'Price'

#set arrow 1 from 0.08,28.8 to 0.08,64.8

#set terminal qt 0
set terminal epslatex color
set output "quadratic.tex"

plot 'funVals.csv' using 1:3 with lines title '$v_q(r) = 10000 \cdot r^2 + 10\cdot r$' linecolor 1, 'approxVals.csv' using 1:2 with lines title 'First order approximation' linecolor 2,"convexAdj.csv" using 1:2:3:4 with vectors filled head lw 3 title 'Convexity adjustment'
#
#set terminal qt 1
set terminal epslatex color
set output "linear.tex"
plot 'funVals.csv' using 1:2 with lines title '$v_l(r) = 1000\cdot r$',
