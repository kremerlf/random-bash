#!/bin/bash
# to use greek, term need to be in enhanced mode 
# png size is in pixels
# eps size is in inchs
#
###################################################################### 
echo "####################################################"
echo "# Script to plot SIESTA Alat"
echo "#"
echo "# Luiz Felipe Kremer"
echo "# 12 Dec 2017:"
echo "####################################################"
echo ""
#
read -p "enter file label: " filelabel
read -p "ING or BR: " lang
read -p "output name: " labelout
ext=".dat"

#
# language
#
if [ $lang == BR ]; then
	label_x="Par{\342}metro de Rede"
	label_y="Energia"
else [ $lang == ING ]
	label_x="Lattice Constant"
	label_y="Energy"
fi
#
# minimun energy point
#
cat $filelabel$ext | tr -s ' ' | cut -d ' ' -f1-2 | sort -k2 -n | head -n 1 > aux
minx=`cat aux | tr -s ' ' | cut -d ' ' -f1`
miny=`cat aux | tr -s ' ' | cut -d ' ' -f2`
#
# xy range
#
cat $filelabel$ext | tr -s ' ' | cut -d ' ' -f2 | sort -k2 -n > aux2
cat $filelabel$ext | tr -s ' ' | cut -d ' ' -f1 | sort -k1 -n > aux3
range_xi=`cat aux3 | head -n 1 `
range_xf=`cat aux3 | tail -n 1 `
range_yi=`cat aux2 | head -n 1 `
range_yf=`cat aux2 | tail -n 1 `
#
# dumm calculation
#
diff=$(perl -e "print $range_yi-($range_yf)"); disp=$(perl -e "print $diff/6.666"); maxy=$(perl -e "print $miny+$disp")
disp2=$(perl -e "print $diff/100"); labelmaxy=$(perl -e "print $maxy+$disp2*2.5")
#
# displacement of xtics
#
lines=`cat aux2 | wc -l`
if [ $lines -le 8 ]; then
		xtics="0.005"
	else
		xtics="0.02"
fi
#
gnuplot -persist <<-EOF
	set autoscale
	set terminal postscript eps color "Times-Roman" 25 size 8,7 enhanced
	set encoding iso_8859_1 # needed for angstrom symbol which is {\305}
	set output "alat-$labelout.eps"
	set tics front
	unset grid 
	#set xrange [$(perl -e "print $range_xi-0.005"):$(perl -e "print $range_xf+0.005")]
	set xtics $xtics
	#set yrange [$(perl -e "print $range_yf-0.5"):$(perl -e "print $range_yi+0.05")]
	set xlabel font "Times-Roman,34"
	set xlabel "$label_x ({\305})"
	set ylabel font "Times-Roman,34"
	set ylabel "$label_y (eV)" 
	set arrow 1 from $minx,$maxy to $minx,$miny lc rgb "red" front
	set label 1 "$minx" at ($minx),($labelmaxy) center front
	plot	"$filelabel$ext" with lp pt 7  lw 1.5 lc rgb "black" notitle
	EOF
rm aux;rm aux2;rm aux3;echo "#";echo "done"
