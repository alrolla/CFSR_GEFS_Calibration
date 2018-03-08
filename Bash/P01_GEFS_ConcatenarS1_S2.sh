#!/bin/bash

#Concatena dias semana 1 y semana 2

for fileS1 in $( ls S1 ) 
do
	echo $fileS1
	fileS2=${fileS1/D01a08/D09a16}
	fileS1y2=${fileS1/D01a08/D01a16}
	ncrcat -O S1/$fileS1  S2/$fileS2   S1y2/$fileS1y2
done


exit