#!/bin/bash

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
