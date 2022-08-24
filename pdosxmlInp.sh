#!/bin/bash
#
# Separa as especies atomicas pelo label do arquivo
atomSpec()
{
	# 1st sed: cria espaço encontrando uppercase
	# 2nd sed: remove estequeometria 
	echo $1 | sed 's/[A-Z]/ &/g' | sed 's/[0-9]//g'
}
#
# Altera o m_orbital_chooser para separar a pdos
# ver manual Utils/pdosxml para as variaveis
orbitalChooser()
{
	l=$3
	m=$4
echo "module m_orbital_chooser
type, public :: orbital_id_t
   integer  :: n
   integer  :: l
   integer  :: m
   integer  :: z
   integer  :: index
   integer  :: atom_index
   character(len=40)  :: species
end type orbital_id_t
public :: want_orbital
CONTAINS
function want_orbital(orbid) result(wantit)
type(orbital_id_t), intent(in)   :: orbid
logical                          :: wantit
wantit =( ( orbid%species == \"$2\" ) .and. (orbid%l == $l) .and. (orbid%m == $m) )
end function want_orbital
end module m_orbital_chooser" > /home/lfkremer/utils/siesta-rel-4.1/Util/pdosxml/m_orbital_chooser.f90
	make -C /home/lfkremer/utils/siesta-rel-4.1/Util/pdosxml/
	if [ $l == 0 ]; then	orb="s"
	elif [ $l == 1 ] && [ $m == 1  ]; then orb="px"
	elif [ $l == 1 ] && [ $m == -1 ]; then	orb="py"
	elif [ $l == 1 ] && [ $m == 0  ]; then	orb="pz"
	fi
	/home/lfkremer/utils/siesta-rel-4.1/Util/pdosxml/pdosxml $1.PDOS > $1-pdos-$2-$orb.dat
	make -C /home/lfkremer/utils/siesta-rel-4.1/Util/pdosxml/ clean
}
#
# Chama orbitalChooser para gerar PDOS por especie e orbitais
criaPDOS()
{
	for spec in $(atomSpec $1)
		do
			for l in {0,1}
			do
				if [[ l -eq 1 ]];then
					for m in {-1,0,1}
					do
						orbitalChooser $1 $spec $l $m 
					done
				elif [[ l -eq 0 ]];then
					orbitalChooser $1 $spec $l 0
				fi
			done
	done
}
#
criaPDOS $1


