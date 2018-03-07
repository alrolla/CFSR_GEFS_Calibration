#!/bin/bash

# #Concatena dias semana 1 y semana 2

# for fileS1 in $( ls S1 ) 
# do
# 	echo $fileS1
# 	fileS2=${fileS1/D01a08/D09a16}
# 	fileS1y2=${fileS1/D01a08/D01a16}
# 	ncrcat -O S1/$fileS1  S2/$fileS2   S1y2/$fileS1y2
# done
# 
# 
# exit

#Calcula el ensamble medio
fecha="1999-01-01"

while [ "$fecha" != 2011-01-01 ]; do 
	echo $fecha
	
    files=""
	for ((m=1; m<=11; m++))
	{
	  mm=$(printf "%02d" $m )
	  files=$files" "S1y2/pre_${fecha}D01a16_M${mm}.nc
	}

	cdo ensmean $files S1y2EnsMean/pre_${fecha}D01a16.ensmean.nc
	ncks -O -L 9 S1y2EnsMean/pre_${fecha}D01a16.ensmean.nc S1y2EnsMean/pre_${fecha}D01a16.ensmean.nc
	fecha=$(date -j -v +1d -f "%Y-%m-%d" ${fecha} +%Y-%m-%d)
	
done





