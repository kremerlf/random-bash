#!/bin/bash
#
# to use greek, term need to be in enhanced mode 
# png size is in pixels
# eps size is in inchs
#
echo "####################################################"
echo "# Script to plot SIESTA Absorbance coef"
echo "#"
# echo "# uses div.x"
echo "# Luiz Felipe Kremer "
echo "#	12 Dec 2017:"
echo "####################################################"
echo ""
#
filelabel=$1
#read -p "enter file label: " filelabel
#read -p "ja usou estas estradas (y or n): " first_use
#read -p "ING or BR: " lang
read -p "output: " file_out
lang="ING"; file_out=$filelabel
par="-optipar"
per="-optiper"
ext=".dat"
#
# lowing the scale
#
#if [ $first_use == n ]; then
#
#	~/tmp/absorb/div.x < "$filelabel$par$ext" &&
#	cp auxf.dat "$filelabel$par$ext"
#	rm auxf.dat
#
#	~/tmp/absorb/div.x < "$filelabel$per$ext" &&
#	cp auxf.dat "$filelabel$per$ext"
#	rm auxf.dat
#fi
#
# language
#
if [ $lang == BR ]; then
	label_x="Energia (eV)"
	label_y="Coeficiente de Absor{\347}{\343}o (10^5 cm^{-1})"
else [ $lang == ING ]
	label_x="Energy (eV)"
	label_y="Optical Absoption (arb. units)"
fi
#
gnuplot -persist <<-EOF
	set autoscale
	set terminal postscript eps color "Times-Roman" 25 size 5,4 enhanced
	set encoding iso_8859_1 # needed for angstrom symbol which is {\305}
	set output "opti-$file_out.eps"
	set tics front
	#set grid 
	set style rectangle fillstyle noborder
#	set object rect from 0.50,0 to 4.10,10 fc rgb "#d0d0d0" back
	set key box left opaque spacing 1.5
	set xrange [0:10]
	set xtics 1
	set xlabel font "Times-Roman,34"
	set xlabel "$label_x"
	set ylabel font "Times-Roman,34"
	set ylabel "$label_y"
	plot	"$filelabel$par$ext" with lines lt 1 lw 2.5 lc rgb "black" title '{/Symbol a_{/Symbol \174\174}',\
		"$filelabel$per$ext" with lines lt 1 lw 2.5 lc rgb "red"  title '{/Symbol a_{/Symbol \136}'
	EOF
echo "#";echo "done"
