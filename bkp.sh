#!/bin/bash
#
# #######################################################################
# Script para criar um backup dos aquivos
# Funcionamento:
#      Copia todos os aquivos (e sua estrutura de pastas) com extensao 
#      listada na variavel ARQVS partindo de uma pasta ORIGEM para 
#      pasta DESTINO. Se solicitado compacta em um tar.gz.
#      A variavel ARQVS ira receber tantos argumentos quanto necessario.
#		 OBS: pastas que nao contiverem ARQVS nao sao copiadas.
#
# Execucao: 
#      ./bkp.sh ORIGEM {ARQVS}
#
# Exemplo da execucao do script:
#      ./bkp.sh /home/lfkremer/contas xyz out
#
#      todos os arquivos .xyz e .out da pasta contas (e suas filhas) serao
#      copiados
#
# Luiz Felipe Kremer 08/2021
# Tester: Douglas Vargas
# #######################################################################
#
# Variaveis
ORIGEM=$1 # Pasta onde estao os arquivos a serem copiados
ARQVS=${@:2} # Extensoes dos arquivos a serem copiados 
BKP="bkpContas$(date +%Y%m%d)" # Nome do arquivo final
#
# Testa se o DESTINO existe, se falso cria a pasta
DESTINO="/tmp/$BKP" ; [[ -d $DESTINO ]] || mkdir $DESTINO
#
# Execucao do backup
cd $ORIGEM
#
for i in ${ARQVS}
do
 	find . -type f -name "*.$i" -exec cp -p --parents {} $DESTINO ";"
	echo "Arquivos .$i copiados"
done
#
# Compactacao
while true; do
 read -p "Deseja compactar o bkp?(S ou N) " tgz
 case $tgz in
	S | s )
		cd /tmp; tar -czf $BKP.tar.gz $BKP;cp $BKP.tar.gz $ORIGEM; rm -r $DESTINO*;
		echo "BKP PRONTO EM: $ORIGEM/$BKP.tar.gz"; cd
		break
		;;
	N | n )
		cd /tmp; cp -r $BKP $ORIGEM; rm -r $DESTINO;
		echo "BKP PRONTO EM: $ORIGEM/$BKP"; cd
		break
		;;
	*) 
		echo "Deseja compactar o bkp?(S ou N) "
		;;
esac
done
