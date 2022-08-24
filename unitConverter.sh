#!/bin/bash

# reference values from SIESTA Manual 

ang2au()
{
	awk 'BEGIN {printf "%.8f\n", '"$1"'/.529177}'
}

au2ang()
{
	awk 'BEGIN {printf "%.8f\n", '"$1"'*.529177}' 
}

ev2ry()
{
	awk 'BEGIN {printf "%.8f\n", '"$1"'*.07349798}'
}

ry2ev()
{
	awk 'BEGIN {printf "%.8f\n", '"$1"'*.07349798}'
}

# c/a
cDa()
{
	awk 'BEGIN {printf "%.8f\n", '"$(ang2au $2)"'/'"$(ang2au $1)"'}'
}

atomMass()
{  
   grep -w "$1" ~/utils/periodicTable.dat | cut -d ',' -f 3
}

#a implementar
ecut()
{
	echo | awk '{printf ecut}'
}

#a implementar
pseudo()
{
	case $Exc in
		pbe) grep 
		;;
	esac
}


