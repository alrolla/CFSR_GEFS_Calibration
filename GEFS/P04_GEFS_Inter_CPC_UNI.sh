#!/bin/bash

cd /Users/alrolla/Dropbox/Calibracion_CFSv2_Web/Proc_GEFS/Week1y2

for f in *.nc
do
   cdo remapcon,grid.CPC_UNI ${f} ../../GEFS/GFS_${f:0:22}CPC.nc
   exit
done
