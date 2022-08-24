#!/bin/bash
#
## CAMINHOS E EXECUTAVEIS ##############################
source /home/lfkremer/utils/exes
PPs="/home/lfkremer/utils/pp"
#
export OMP_NUM_THREADS=1
#
runner="mpirun.openmpi -np 8 -x OMP_NUM_THREADS $SIEx"
minimo=$(echo "/home/lfkremer/calc/seminario/src/minimo.py")
########################################################
#
# Imprime os parametros encontrados
#
function printParam()
{
	printf "#######################################################
Parametros econtrados para um criterio de $eConv meV
para as contas $sysName:
#
Energia de Corte: $eCorte
#
Pontos K: $pontosK
#
a0: $lattConst
#######################################################\n" > resultadoParametros.dat
}
#
# remove arquivos que nao serao utilizados
#
function removeTralha()
{
	lixosSiesta=(*.bib fdf-*.log INPUT_TMP* MESSAGES TIMES 0_NORMAL_EXIT BASIS_* 
		fort.12 OUTVARS.yml PARALLEL_DIST FORCE_STRESS NON_TRIMMED_KP_LIST CLOCK *.times)
	for lixo in ${lixosSiesta[@]}
	do
		# testa se lixo existe, se positivo remove
		[[ -f $lixo ]] && rm $lixo
	done; echo "job feito e tralha removida"
}
#
# Roda a conta e testa convergencia
#
function rodaTesta()
{
   # roda a conta
	$(echo $runner) < $label.fdf > $label.out &&
	# adiciona o valor no array energia
   energia+=($(awk '/Total =/ {x=NF; print $x}' $label.out)) # energia= energia + aa
	# se o array tiver tamanho maior que 1 ele entra no if
	if [ ${#energia[@]} -gt 1 ]
	then
		# calcula a diferenca entre as energias
		local k=$(awk 'BEGIN {print ('"${energia[$count-1]}"')-('"${energia[$count]}"') }')
		# retorna 0 ou 1 se a convergencia foi atingida
		fC=$(bc <<< "${k#-} < $eConv")
	fi
}
#
# cria o input, roda e encontra os parametros de convergencia
# entrada: parametro vInicial vFinal incrimento
#
function getParam()
{
 local count=0
 local energia=()
  	 case $1 in 
	 	corte )
			for i in $(seq $2 $4 $3)
			do
				local label="$sysName-${i}-eC"
				criaInp $sysName $alat $zCaixa $kpt $i
				rodaTesta
				# se fC == 1 chama o passo atual de eCorte e
				# elimina a variavel fC e encerra o do
			   [[ $fC -eq 1 ]] && eCorte=$i && unset fC && break
				# quando a condicao nao eh satisfeita o count eh incrementado
				((count++))
			done
		;;
		######
		pontos )
			for i in $(seq $2 $4 $3)
			do
				local label="$sysName-${i}-Kp"
				criaInp $sysName $alat $zCaixa $i $eCorte
				rodaTesta
				[[ $fC -eq 1 ]] && pontosK=$i && unset fC && break
				((count++))
			done
		 ;;
	 esac
}
#
# calcula parametro de rede
#
function getAlat()
{
   # testa se o arquivo existe, se positivo remove
 	[[ -f $sysName-alatEnergia.dat ]] && rm $sysName-alatEnergia.dat
	# variaveis locais para definir o range do alat
	local pas=$(echo "$alat*0.01" | bc)
	local ini=$(echo "$alat*0.95" | bc)
	local fin=$(echo "$alat*1.05" | bc)
	for i in $(seq $ini $pas $fin)
	do
	 	local label="$sysName-$(echo $i | tr -d '.')"
  		criaInp $sysName $i $zCaixa $pontosK $eCorte
 		$(echo $runner) < $label.fdf > $label.out &&
		# escreve o alat e a energia no arquivo de saida
		echo $i $(awk '/Total =/ {x=NF; print $x}' $label.out) >> $sysName-alatEnergia.dat
	done
	# via cript python
	lattConst=$($minimo $sysName-alatEnergia.dat)
	# via gnuplot
	#lattConst=$(fitAlat $sysName-alatEnergia.dat) && rm fit.log
}
#
# Siesta input template
# entrada: sysName alat zCaixa pontosK eCorte
# label eh criado de acordo com a funcoes getParametro e getAlat
# obs: bloco do siesta comeca com %block mas a funcao printf entende
# 	  : % como argumento, assim os blocos estao comecando como %%block
#
function criaInp(){
 local c=$(echo "scale=8; $3/$2" | bc)
printf "############################################
SystemName             $label
SystemLabel	           $label
NumberOfAtoms          2	
NumberOfSpecies        2
LatticeConstant        $2 Ang
#
%%block ChemicalSpecieslabel
1 6 C
2 14 Si 
%%endblock ChemicalSpecieslabel
#
%%block LatticeVectors 
	1.000000	 0.000000	   0.000000
  -0.500000	 0.8660254038	0.000000
	0.000000	 0.000000	   $c
%%endblock LatticeVectors
#
%%block kgrid_Monkhorst_Pack
 $4  0    0    0.5
 0   $4   0    0.5
 0   0    1    0.5
%%endblock kgrid_Monkhorst_Pack
#
XC.functional        		GGA    
XC.authors           		PBE   
#
PAO.BasisType        		split    
PAO.EnergyShift      		0.010 eV  
PAO.SplitNorm        		0.15     
PAO.BasisSize        		DZP      
Spin								polarized
MeshCutoff           		$5.0 Ry
#
WriteMullikenPop     		0    
WriteHirshfeldPop				F
WriteCoorXmol        		T
WriteCoorStep        		F
WriteMDXmol						F
SaveBaderCharge				F
SaveRho							F
SaveElectrostaticPotential F
#
MaxSCFIterations      50  
DM.MixingWeight       0.10 
DM.Tolerance          1.d-4 
DM.UseSaveDM          yes
DM.NumberPulay        3
SolutionMethod        Diagon  
ElectronicTemperature 150 K 
#
MD.TypeOfRun          CG      
MD.NumCGsteps         100      
MD.MaxCGDispl         0.1 Bohr  
MD.MaxForceTol        0.01 eV/Ang
MD.UseSaveXV          T    
#
AtomicCoordinatesFormat  		Fractional
AtomicCoordinatesFormatOut  	Fractional
#
%%block AtomicCoordinatesAndAtomicSpecies
 0.333333333       0.666666666       0.500000000 1
 0.666666666       0.333333333       0.500000000 2
%%endblock AtomicCoordinatesAndAtomicSpecies
####################################################" > $label.fdf
#
 # identifica especies atomicas e copia os PPs necessarios
 #
 local sB=$(awk '/%block/ && /Chemical/ { printf NR }' $label.fdf)
 local eB=$(awk '/%endblock/ && /Chemical/ { printf NR }' $label.fdf)
 local specList=( $(awk 'NR>'"$sB"' && NR<'"$eB"' { printf $NF"\t" }' $label.fdf) )
 for atmSpec in ${specList[@]}
 do
	# testa se o arquivo de pp nao existe, se true copia da pasta referencia para 
	# o local da conta a rodar
   [[ ! -f $atmSpec.psf ]] && cp $PPs/$atmSpec.psf .
 done
}
#
# calcula parametro de rede via gnuplot
#
function fitAlat()
{
	# se fit existe, remova
	[[ -f fit.log ]] && rm fit.log
	# passa argumentos para o gnuplot
	gnuplot -persist <<-EOF
		set fit quiet
		f(x)=a+b*x+c*x**2
		fit f(x) "$1" via a,b,c 
		EOF

	local b=$(awk '/^b/ && /=/ {print $3}' fit.log)
	local c=$(awk '/^c/ && /=/ {print $3}' fit.log)
	# calcula o alat via o fit do gnuplot
	echo "scale=3; (-1*$b)/(2*$c)" | bc
}
