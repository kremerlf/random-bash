#!/bin/bash
##########################################
#### PATHS
SIE="/home/lfkremer/utils/siesta-master"
UtilSIE="$SIE/Util"
##########################################
preProc="bands"
posProc="banda"

# post processing band with gnubands
function callGnubands()
{
	$UtilSIE/Bands/gnubands < $1.$preProc > $1.$posProc
	echo "Gnubands done for $1.$preProc"
}

# Get some info from the .bands file
function infoBands()
{
 	eF=$(awk 'NR==1 {print $0}' $systemLabel.$preProc)
	x=($(awk 'NR==2 {print $0}' $systemLabel.$preProc))
	n=($(awk 'NR==4 {print $0}' $systemLabel.$preProc))
}

# Get the number of high-symm K points and the points
function kPoints()
{
	nK=$(awk 'NR>1 && NF==1 { print }' $1 | tr -s ' ')
	
	pK=$(awk '/[[:alpha:]]/ {print $2" "$1","}' $1 | 
		sed 's/\Gamma/\{\/Symbol G\}/g' | tr -d '\n')
}

# Vertical markings of the high-symm points
function kPlotLines()
{
	[[ -f verticalLines.aux ]] && rm verticalLines.aux
	local lines=$(wc -l $1 | cut -d ' ' -f 1)
	for i in $(seq $(($lines-$nK+1)) $lines)
		do
			awk 'NR=='"$i"' {printf("%f\t%d\n", $1, '"$yf"')}' $1 >> verticalLines.aux
			awk 'NR=='"$i"' {printf("%f\t%d\n", $1, '"$yi"')}' $1 >> verticalLines.aux
			echo >> verticalLines.aux
		done 
}

function formatBands()
{
	if [[ ${n[1]} -eq 2 ]]
	then
		bandToPlot $arqOut $(getLine $arqOut 1) $(getLine $arqOut 2)
	else
		bandToPlot $arqOut $(getLine $arqOut 1)
	fi
}

# Get the bands from the gnubands out and writes it as band spinUp spinDown
function bandToPlot()
{
	[[ -f bandToPlot.aux ]] && rm bandToPlot.aux
	
	if [[ ${n[1]} -eq 2 ]]
	then
		awk 'NR>='"$2"' && NR<='"$3"' {print $1"\t"$2}' $1 >> bandUp.aux
		awk 'NR>='"$4"' && NR<='"$5"' {print $2}'       $1 >> bandDn.aux
		paste bandUp.aux bandDn.aux >> bandToPlot.aux
		rm bandUp.aux bandDn.aux
	else
		awk 'NR>='"$2"' && NR<='"$3"' {print $1"\t"$2}' $1 >> bandUp.aux
		paste bandUp.aux >> bandToPlot.aux
		rm bandUp.aux 
	fi
}

# Get initial and final lines from the gnubands.out for a given spin component
function getLine()
{
	local ini=$(awk '/ '"$2"'$/ {print NR}' $1 | head -n 1)
	local fin=$(awk '/ '"$2"'$/ {print NR}' $1 | tail -n 1)
	echo $ini $fin
}

# Gnuplot call to plot the band
function plotter()
{
gnuplot -persist <<-EOF
	set autoscale
	set terminal postscript eps color "Times-Roman" 25 size 6,5 enhanced 
	set output "banda-$systemLabel.eps"
	set tics front
	set xrange [${x[0]}:${x[1]}]
	set xtics  ( $pK ) font "Times-Roman,30"
	set yrange [$yi:$yf]
	set ylabel "Energy (eV)" font "Times-Roman,35"
	set arrow 1 from ${x[0]},$eF to ${x[1]},$eF nohead dt "_ _ " lc rgb "black"
	if ( ${n[1]} == 2 ){
		set key right top maxcols 2 maxrows 1 opaque box height 1.0 width 1.0
		plot "bandToPlot.aux" using 1:3  with line lw 1.5 lc rgb "red" t "{/Symbol \257}",\
			"bandToPlot.aux" using 1:2  with line lw 1.5 lc rgb "black" t "{/Symbol \255}" ,\
			"verticalLines.aux" using 1:2  with line lw 1.5 lc rgb "black" notitle;
	} else {
		set key off
		plot "bandToPlot.aux" using 1:2  with line lw 1.5 lc rgb "black" notitle ,\
			"verticalLines.aux" using 1:2 with line lw 1.5 lc rgb "black" notitle;}	
EOF
rm *.aux;echo "#";echo "done"
}

