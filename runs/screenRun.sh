#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"

PROYECTO="PRUEBA"

emis_file=EMIS.INP

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
for (( i=2; i<3; i++ ))
do
	echo "Iteración: $i"

	#emis_file columns: pollutid;id;type;wkt;Z;Q;H;Ts;U;D
	read pollutid id tipo Q Hs Ts Us Ds <<< $(awk -F";" -v i=$i 'NR==i{print $1" "$2" "$3" "$6" "$7" "$8" "$9" "$10" "$11}' ${emis_file} )
	echo "Preparando .inp ..."

	titulo=${PROYECTO}_${pollutid}_${id}

	tipo=$( if (( $tipo == "POINT" )); then echo "P"; fi)

	printf "%s\n" ${titulo}> screen3.inp;
	printf "%s\n%f\n%.2f\n%.2f\n%.3f\n%.2f\n" ${tipo} ${Q} ${Hs} ${Ds} ${Us} ${Ts}>> screen3.inp;
	printf "%.2f\n%.2f\n%s\n" ${Ta} ${Hflag} ${URB} >> screen3.inp;

	if (( $bool_BUILD ))
       	then
		#printf "N\n">> screen3.inp
		printf "Y\n$Hb\n$Lmin\n$Lmax">>screen3.inp;
	else
		printf "N\n">> screen3.inp

	fi;

	case $TERR_opt in
        	(1)	#complex terrain
        		printf "Y\n">>screen3.inp
        	;;
        	(2)	#flat terrain
        		printf "N\nY\n">>screen3.inp
        	;;
        	(3)	#
        		printf "N\nN\n">>screen3.inp
        	;;
        esac

	case $MET_opt in
		(1)
	 		#"1 - FULL METEOROLOGY (ALL STABILITIES & WIND SPEEDS)"
			printf "1\n">>screen3.inp
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
		printf "Y\n $dmin,$dmax\n">> screen3.inp;
	else
		printf "N\n">> screen3.inp;
	                                         
	fi;

	#discrete
	if (( $bool_REC_discrete ))
	then
		printf "Y\n" >> screen3.inp

	else
		printf "N\n" >> screen3.inp
	fi;
	#fumig
	if (( $bool_FUMIGATION ))
	then
		printf "Y\n" >> screen3.inp
	else
		printf "N\n" >> screen3.inp
	fi;
	#hardcopy
	if (( $bool_HARDCOPY ))
	then
		printf "Y\n" >> screen3.inp
	else
		printf "N\n" >> screen3.inp

	fi;

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

	echo "Ejecutando screen3 ..."

	cat screen3.inp
	./SCREEN3.EXE < screen3.inp


	echo "Escribiendo salida en ${titulo}.OUT ..."
	cp SCREEN.OUT ${titulo}.OUT

done;
