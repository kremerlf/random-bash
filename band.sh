#!/bin/bash
echo "#####################################################################"
echo "# Script to plot SIESTA bands using gnuplot"
echo "# need .bands "
echo "# it calls gnubands and make the out file"
echo "#"
echo "# Luiz Felipe Kremer"
echo "# 13 Dec 2017"
echo "######################################################################"
echo ""
read -p " enter file label (without ext): " filelabel
read -p " # of High Symmetry Points (HSP) : " var1
read -p " define yrange (from low to high) : " yi yf
read -p " do E-E_F (y or n): " e_ef
read -p " ING or BR : " lang
read -p " output name: " file_out
#
extin=".bands"
extout=".banda"
#
# make E-E_F
#
if [ $e_ef == y ]; then
	~/Dropbox/cod/cod-fortran/bands-ef.x < $filelabel$extin > $filelabel$extout
	efermi=0
else
	~/Dropbox/cod/cod-fortran/bands.x < $filelabel$extin > $filelabel$extout
	efermi=`head -n 1 $filelabel$extin` 
fi
#
# language
#
if [ $lang == BR ]; then
        label_x="Pontos de alta simetria"
	if [ $e_ef == y ]; then
		label_y="E-E_F (eV)"
	else
		label_y="Energia (eV)"
	fi
 else [ $lang == ING ]
	label_x="High Symmetry Points"
        if [ $e_ef == y ]; then
		label_y="Energy (eV)"
	else
		label_y="Energy (eV)"
	fi
fi
#
#
# get variables
#
HSPp=`tail -n $var1 $filelabel$extin | tr -s ' ' | cut -d ' ' -f2 `
HSPs=`tail -n $var1 $filelabel$extin | tr -s ' ' | cut -d ' ' -f3 `
xi=`head -n 5 $filelabel$extin | tr -s ' ' | tail -n 1 | cut -d ' ' -f2`
xf=`tail -n 1 $filelabel$extin | tr -s ' ' | cut -d ' ' -f2`
#
# change gamma symbol for gnuplot
#
tail -n $var1 $filelabel$extin | tr -s ' ' | awk -F ' ' '{print $2, $1","}' | tr -d '\n' > aux
	sed -i -e 's/\Gamma/\{\/Symbol G\}/g' aux
	HSPptics=`tail -n $var1 aux`
#
# make the lines for the high symm points
#
for i in `echo "$HSPp"`
do
	echo $i $yf >> aux2
	echo $i $yi >> aux2
	echo ""     >> aux2
done
#
# plot
#
gnuplot -persist <<-EOF
	set autoscale
	set terminal postscript eps color "Times-Roman" 25 size 6,5 enhanced 
	set output "banda-$file_out.eps"
	set tics front
	set xrange [$xi:$xf]
	set xtics ($HSPptics) font "Times-Roman,30"
	#set xlabel "$label_x" font "Times-Roman,35"
	set yrange [$yi:$yf]
	#set y2tics ('E_F' 0)
	set ylabel "$label_y" font "Times-Roman,35"
	set arrow 1 from $xi,$efermi to $xf,$efermi nohead dt "_ _ " lc rgb "red" 
	plot 	"$filelabel$extout" using 1:2  with line  lc rgb "black" notitle,\
	 	"aux2" using 1:2  with line lw 1.5 lc rgb "black" notitle   
	EOF
rm aux;rm aux2;echo "#";echo "done"
