## Scripts bash y R para el proceso de "GEFS Reforecast v2 Ensemble Data"



*  Primero se bajan los datos GEFS:
    http://www.esrl.noaa.gov/psd/forecasts/reforecast2/download.html

*  Se selecciono el Area de Argentina y la variable precipitacion. Para la S1 y S2. El sistema pone en cola el trabajo y devuelve un mail con la informacion de donde quedo el archivo.


* Se descargan los datos del ftp de ftp.cdc.noaa.gov/Public/reforecast2/ un archivo para la S1 y otro para la S2.

    wget ftp://ftp.cdc.noaa.gov/Public/reforecast2/apcp_sfc_latlon_all_19990101_20101231_alfrDuyHEJ.nc
    
    wget ftp://ftp.cdc.noaa.gov/Public/reforecast2/apcp_sfc_latlon_all_19900101_20101231_alfrFMVteL_t190.nc

* Se ejecuta el programa R "P00_GEFS_read_S1.R" : Lee los datos de  11 miembros del ensamble horarios de la semana 1 y los convierte en diarios.

* Se ejecuta el programa R "P00_GEFS_read_S2.R" : Lee los datos de  11 miembros del ensamble horarios de la semana 2 y los convierte en diarios.

* Se ejecuta el script bash "P01_GEFS_ConcatenarS1_S2.sh" para juntas la semana 1 y la 2 en un solo archivo.

* Se ejecuta el script bash "P02_GEFS_EnsMedio.sh" para pra calcular el ensamble medio de los 11 miembros de S1 y S2.

* Se ejecuta el script bash "P03_GEFS_Inter_CPC_UNI.sh" para interpolar el modelo a la grilla CPC_UNI.



