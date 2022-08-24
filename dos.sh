#!/bin/bash
echo "####################################################"
echo "# Script to plot SIESTA DOS"
echo "# needs .DOS and PDOS files,"
echo "# also .bands to pick the efermi"
echo "#"
echo "# Luiz Felipe Kremer "
echo "# 16 Apr 2019:"
echo "####################################################"
echo ""
read -p " enter file .DOS label : " filelabel
read -p " define xrange (from low to high) : " xi xf
read -p " define yrange (from low to high) : " yii yff
#read -p " ING or BR : " lang
#read -p " output: " file_out
#filelabel="layer-sic-si-i1-3127";xi=-8;xf=0;
lang="ING"
file_out=$filelabel
#
for i in "$dir"
	do
		ls *.dat | grep "$filelabel" > aux
	done
echo""
#
# language
#
if [ $lang == BR ]; then
        label_x="pDOS (estados/eV)"
        label_y="Energia (eV)"
else [ $lang == ING ]
        label_x="pDOS (states/eV)"
        label_y="Energy (eV)"
fi
#
extbands=".bands"
exttdos=".DOS"
extpdos=".dat"
efermi=`head -n 1 $filelabel$extbands`
numlines=`cat aux | wc -l`
# 
# 
for i in `seq 1 $numlines`
	do	
		elem=`sed "${i}q;d" aux | cut -d '.' -f1 | rev | cut -d '-' -f1 | rev`
		if [ $elem = "C" ]; then
			color="\"blue\""
		elif [ $elem = "Si" ]; then
			color="\"#9da700\""
		elif [ $elem = "H" ]; then
			color="\"red\""
		else
			color="\"brown\""
		fi
		kk=" using (column(1)-$efermi):2 with lines lw 2.5 lc rgb "$color" title \"$elem\""
	    	kk2=" using (column(1)-$efermi):(column(3)*-1) with lines lw 2.5 lc rgb "$color" notitle"
		file=`sed  "${i}q;d"  aux`
		fileb=\"$file\"$kk,\\ 
		filec=\"$file\"$kk2,\\  
		echo "$fileb" >> aux2 
		echo "$filec" >> aux2
		#
		
	done
#
extbands=".bands"
exttdos=".DOS"
extpdos=".dat"
#xi=0.0000
yf1=`cat $filelabel$exttdos | tr -s ' ' | cut -d ' ' -f3 | sort -n | tail -n1 ` # find the bigger # of states
yf=$(perl -e "print $yf1+($yf1*0.001)") # xrange for the dos with xxf1+15%
yi=$(perl -e "print $yf*-1")
bla=$(perl -e "print $efermi-0.1")
x_down=$(perl -e "print $yi+($yi*-.1)")
y_down=$(perl -e "print $efermi+.5")
x_up=$(perl -e "print $yf-($yf*.1)")
y_up=$(perl -e "print $efermi+.5")
#
dammit=`cat aux2`
echo $efermi
gnuplot -persist <<-EOF
	# NEW	
	set autoscale
	set terminal postscript eps color "Times-Roman" 25 size 6,5 enhanced
	set output "dos-$file_out.eps"
        set xrange [$xi:$xf]
        set xtics auto 
        set xlabel "Energy (eV)" font "Times-Roman,35"
        set yrange [$yii:$yff]
        #set arrow 2 from $x_down,$y_down to $x_down,$efermi lc rgb "blue" lw 3 
	#set arrow 3 from $x_up,$efermi to $x_up,$y_up lc rgb "red" lw 3 
        #set y2tics ('E_F' $efermi)
        set ylabel "pDOS (states/eV)" font "Times-Roman,35"
        set arrow 1 from 0,$yii to 0,$yff nohead dt "_ _ " lc rgb "red"
        #set key at 0.5,$yf1 #box opaque
 	plot $dammit
	EOF
rm aux;rm aux2;echo "#";echo "done"
