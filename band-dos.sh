#!/bin/bash
echo "#####################################################################"
echo "# Script to plot SIESTA bands+dos using gnuplot"
echo "# need .bands .DOS and pdos aux files "
echo "# it calls gnubands and make the out file"
echo "#"
echo "# Luiz Felipe Kremer"
echo "# 12 Dec 2017"
echo "######################################################################"
echo ""
read -p " enter file label (without ext): " filelabel
read -p " # of High Symmetry Points (HSP) : " var1
read -p " define yrange (from low to high) : " yi yf
read -p " do E-E_F (y or n): " e_ef
read -p " ING or BR : " lang
read -p " output name: " file_out
#
#filelabel="layer-c-249"
#var1=4; yi=-8; yf=0; e_ef=n; lang=BR
#file_out="c"
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
	#label_x="Pontos de alta simetria"
	label_x="Symm P"
	if [ $e_ef == y ]; then
		label_y="E-E_F (eV)"
	else
		label_y="Energia (eV)"
	fi
 else [ $lang == ING ]
	label_x="High Symmetry Points"
        if [ $e_ef == y ]; then
		label_y="E-E_F (eV)"
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
	sed -i -e 's/\\Gamma/\{\/Symbol G\}/g' aux
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

for i in "$dir"
	do
		ls *.dat | grep "$filelabel"  > aux3
	done
#
numlines=`cat aux3 | wc -l`
#
# change the color lines for the DOS 
# 
for i in `seq 1 $numlines`
	do
		if [ $i = 1 ]; then
			color="\"black\""
		elif [ $i = 2 ]; then
			color="\"blue\""
		else
			color="\"brown\""
		fi
		elem=`sed "${i}q;d" aux3 | cut -d '.' -f1 | rev | cut -d '-' -f1 | rev `
		kk=" using 2:1 with lines lw 2.5 lc rgb "$color" title \"$elem\""
		file=`sed  "${i}q;d"  aux3`
		fileb=\"$file\"$kk,\\  
		echo "$fileb" >> aux4 
		#
	done

echo $elem
#
# more variables...
#
exttdos=".DOS"
extpdos=".dat"
efermi=`head -n 1 $filelabel$extin` # find fermi energy
xxi=0.0000 #define the xrange start
xxf1=`cat $filelabel$exttdos | tr -s ' ' | cut -d ' ' -f3 | sort | tail -n1 ` # find the bigger # of states
xxf=$(perl -e "print $xxf1+($xxf1*0.1)") # xrange for the dos with xxf1+15%
orig=$(perl -e "print $xxf1*0.45") # E_F label x postition in DOS
bla=$(perl -e "print $efermi-0.1")  # 
bla2=$(perl -e "print $efermi+0.2") # E_F label y position in DOS
efermi2=`head -n 1 $filelabel$extin | cut -c3-7`  #
DDOSTICS=`echo "'DOS' $(perl -e "print $xxf/2")" > haha `;dostics=`cat haha` # write DOS in xtics from DOS
#
dammit=`cat aux4` # 
#
# plot
#
gnuplot5 -persist <<-EOF
	set autoscale
	set terminal postscript eps color "Times-Roman" 25 size 9,7 enhanced 
	set output "banddos-$file_out.eps"
	set multiplot layout 1,2
	#
	#PLOT BAND
	#
	set size 0.50,1
	set tics front
	set xrange [$xi:$xf]
	set xtics ($HSPptics) font "Times-Roman,30"
#	set xlabel "$label_x" font "Times-Roman,35"
	set yrange [$yi:$yf]
#	set y2tics ('E_F' 0)
	set ylabel "$label_y" font "Times-Roman,35"
	set arrow 1 from $xi,$efermi to $xf,$efermi nohead lt 7  lc rgb "red" 
	plot 	"$filelabel$extout" using 1:2  with line  lc rgb "black" notitle,\
	 	"aux2" using 1:2  with line lw 1.5 lc rgb "blue" notitle   
	#
	# PLOT DOS
	#
	set label 10 "E_F = $efermi2 (eV)" at $orig,$bla2 font "Times-Roman, 20"
	unset ylabel
	set size 0.50,1 
	set origin 0.45,0.0
	set ytics format ""
#	set xtics format ""
	set xrange [$xxi:$xxf]
	set xtics ($dostics) font "Times-Roman, 35"
#	set xlabel "DOS" font "Times-Roman, 35"
	set yrange [$yi:$yf]
#	set y2tics ('E_F' $efermi)
#	set ylabel "$label_y" font "Times-Roman,35"
	set arrow 1 from $xxi,$efermi to $xxf,$efermi nohead lc rgb "red" 
	set key at $xxf,$bla 
	plot	"$filelabel$exttdos" using 2:1 with filledcurve x1=0 fill solid  lc rgb "#dbdbdb" title "Total",\
		$dammit
	EOF
rm aux;rm aux2;rm aux3;rm aux4;echo "#";echo "done";rm haha
