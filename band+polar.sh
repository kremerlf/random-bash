#!/bin/bash
echo "#####################################################################"
echo "# Script to plot SIESTA bands using gnuplot"
echo "# need .bands and gnubands "
echo "# it calls gnubands and make the out file"
echo "# check in the make E-E_F block, change to yours gnubands folder"
echo "#"
echo "# Luiz Felipe Kremer"
echo "# 16 April 2019"
echo "######################################################################"
echo ""
read -p " enter file label (without ext): " filelabel
read -p " # of High Symmetry Points (HSP) : " var1
read -p " define yrange (from low to high) : " yi yf
#read -p " do E-E_F (y or n): " e_ef
#read -p " ING or BR : " lang
e_ef="n";lang="ING"
#
file_out=$filelabel
extin=".bands"
extout=".banda"
#
##
### make E-E_F
##
#
if [ $e_ef == y ]; then
	~/utils/siesta-master/Util/Bands/gnubands < $filelabel$extin > $filelabel$extout
	#~/Dropbox/cod/cod-fortran/bands-ef.x < $filelabel$extin > $filelabel$extout
	efermi=0
else
	#~/Dropbox/cod/cod-fortran/bands.x < $filelabel$extin > $filelabel$extout
	~/utils/siesta-master/Util/Bands/gnubands < $filelabel$extin > $filelabel$extout
	efermi=`head -n 1 $filelabel$extin` 
fi
#
##
### language
##
#
if [ $lang == BR ]; then
        label_x="Pontos de alta simetria"
	label_y="Energia (eV)"
 else [ $lang == ING ]
	label_x="High Symmetry Points"
	label_y="Energy (eV)"
fi
#
##
### Separating up and down channels
##
#
# auxiliar files exists?
[[ -e paux* ]] && rm paux*
# count total lines
lines_end=$(cat $filelabel$extout | wc -l )
# spin up channel
cat $filelabel$extout | tr -s ' ' | head -n $(($lines_end/2)) >> paux
# spin down channel
cat $filelabel$extout | tr -s ' ' | tail -n +$((($lines_end/2)+1)) >> paux2
# merge spin up + down
cat paux2 | tr -s ' ' | cut -d ' ' -f 3 >> paux3
paste paux paux3 >> paux4
cp paux4 $filelabel$extout
# kill auxiliar files
rm paux paux2 paux3 paux4
#
##
### get variables
##
#
HSPp=`tail -n $var1 $filelabel$extin | tr -s ' ' | cut -d ' ' -f2 `
HSPs=`tail -n $var1 $filelabel$extin | tr -s ' ' | cut -d ' ' -f3 `
xi=`head -n 5 $filelabel$extin | tr -s ' ' | tail -n 1 | cut -d ' ' -f2`
xf=`tail -n 1 $filelabel$extin | tr -s ' ' | cut -d ' ' -f2`
xff=$(perl -e "print $xf-($xf*0.5)")
#
##
### change gamma symbol for gnuplot
##
#
tail -n $var1 $filelabel$extin | tr -s ' ' | awk -F ' ' '{print $2, $1","}' | tr -d '\n' > aux
	sed -i -e 's/\Gamma/\{\/Symbol G\}/g' aux
	HSPptics=`tail -n $var1 aux`
#
##
### make the lines for the high symm points
##
#
for i in `echo "$HSPp"`
do
	echo $i $yf >> aux2
	echo $i $yi >> aux2
	echo ""     >> aux2
done
#
##
### Plot
##
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
	set key right top maxcols 2 maxrows 1 opaque box height 1.0 width 1.0
	set arrow 1 from $xi,$efermi to $xf,$efermi nohead dt "_ _ " lc rgb "black" 
	plot 	"$filelabel$extout" using 1:3  with line lw 1.5 lc rgb "red" t "{/Symbol \257}",\
		"$filelabel$extout" using 1:2  with line lw 1.5 lc rgb "black" t "{/Symbol \255}",\
	 	"aux2" using 1:2  with line lw 1.5 lc rgb "black" notitle   
	EOF
#rm aux aux2 ;echo "#";echo "done"
