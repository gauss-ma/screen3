#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"

RED="\e[31m"
GREEN="\e[32m"
NC="\e[0m"


PROYECTO="PRUEBA"

emis_file=EMIS/EMIS.INP
exe_file=../../exe/SCREEN3.EXE


#Global Params:
Ta=293.15	#temp ambiente [ºK]
Hflag=1.50	#Altura del receptor [m]

URB=R		#urban/rural [U/R]
bool_BUILD=0	#building [Y/N]
	Hb=6.0
	Lmin=20.0
	Lmax=60.0
TERR_opt=3	#(1) complex terrain ; (2) simple terrain

MET_opt=1 	#meteorology option [1/2/3]

bool_REC_auto=1 #auto receptor grid []
	dmin=100	#distancia mínima
	dmax=10000	#distancia máxima

bool_REC_discrete=0
	discrtete_dist=(1000.0 2000.0)

bool_FUMMIGATION=0
bool_HARDCOPY=0
#Emis:
read nl name <<< $(wc -l ${emis_file})

#for (( i=2; i<${nl}; i++ ))
for (( i=2; i<$nl; i++ ))
do
	echo -e "${GREEN}Iteración: ${NC}$i"

	#emis_file columns: pollutid;id;type;wkt;Z;Q;H;Ts;U;D
	read pollutid id tipo Q Hs Ts Us Ds <<< $(awk -F";" -v i=$i 'NR==i{print $1" "$2" "$3" "$6" "$7" "$8" "$9" "$10" "$11}' ${emis_file} )
	echo -e "${GREEN}Preparando .inp ...${NC}"

	titulo=${PROYECTO}_${pollutid}_${id}

	tipo=$( if (( $tipo == "POINT" )); then echo "P"; fi)

	printf "%s\n" ${titulo}> SCREEN3.INP;
	printf "%s\n%f\n%.2f\n%.2f\n%.3f\n%.2f\n" ${tipo} ${Q} ${Hs} ${Ds} ${Us} ${Ts}>> SCREEN3.INP;
	printf "%.2f\n%.2f\n%s\n" ${Ta} ${Hflag} ${URB} >> SCREEN3.INP;

	if (( $bool_BUILD ))
       	then
		#printf "N\n">> SCREEN3.INP
		printf "Y\n$Hb\n$Lmin\n$Lmax">>SCREEN3.INP;
	else
		printf "N\n">> SCREEN3.INP

	fi;

	case $TERR_opt in
        	(1)	#complex terrain
        		printf "Y\n">>SCREEN3.INP
        	;;
        	(2)	#flat terrain
        		printf "N\nY\n">>SCREEN3.INP
        	;;
        	(3)	#
        		printf "N\nN\n">>SCREEN3.INP
        	;;
        esac

	case $MET_opt in
		(1)
	 		#"1 - FULL METEOROLOGY (ALL STABILITIES & WIND SPEEDS)"
			printf "1\n">>SCREEN3.INP
		;;
		(2)
 	 		#"2 - INPUT SINGLE STABILITY CLASS"
		;;
		(3)
 	 		#"3 - INPUT SINGLE STABILITY CLASS AND WIND SPEED"
		;;
	esac

	
	if (( $bool_REC_auto ))
	then
		printf "Y\n $dmin,$dmax\n">> SCREEN3.INP;
	else
		printf "N\n">> SCREEN3.INP;
	                                         
	fi;

	#discrete
	if (( $bool_REC_discrete ))
	then
		printf "Y\n" >> SCREEN3.INP

	else
		printf "N\n" >> SCREEN3.INP
	fi;
	#fumig
	if (( $bool_FUMIGATION ))
	then
		printf "Y\n" >> SCREEN3.INP
	else
		printf "N\n" >> SCREEN3.INP
	fi;
	#hardcopy
	if (( $bool_HARDCOPY ))
	then
		printf "Y\n" >> SCREEN3.INP
	else
		printf "N\n" >> SCREEN3.INP

	fi;

	echo -e "${GREEN}Ejecutando screen3 ... ${NC}"

	cat SCREEN3.INP

	ln -sf ${exe_file} SCREEN3.EXE
	./SCREEN3.EXE < SCREEN3.INP > ${titulo}.LOG


	echo -e "${GREEN}Escribiendo salida en ${titulo}.OUT ...${NC}"
	cp SCREEN.OUT ${titulo}.OUT

done;

#Esquema general
#$titulo
#$type
#$Q
#$Hs
#$Ds
#$Us
#$Ts
#$Ta
#$Hflag
#$URB
#$bool_BUILD
#$Hb
#$Lmin
#$Lmax
#$bool_TERR
#$MET_opt
#$bool_REC_auto

