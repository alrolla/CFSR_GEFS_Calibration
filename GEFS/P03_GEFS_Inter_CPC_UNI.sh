#!/bin/bash

cd /Users/alrolla/Documents/GEFS/Week1y2

for f in *.nc
do
cdo remapcon,grid.CPC_UNI ${f} ../GFS_interpolado_a_CPC_UNI/GFS_${f:0:22}CPC.nc

done
