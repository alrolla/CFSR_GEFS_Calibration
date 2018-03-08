## Script bash para el proceso de "GEFS Reforecast v2 Ensemble Data"



*    Primero se bajan los datos GEFS:
    http://www.esrl.noaa.gov/psd/forecasts/reforecast2/download.html

*    Se selecciono el Area de Argentina y la variable precipitacion. Para la S1 y S2. El sistema pone en cola el trabajo y devuelve un mail con la informacion de donde quedo el archivo.


Se descargan los datos del ftp de ftp.cdc.noaa.gov/Public/reforecast2/



wget ftp://ftp.cdc.noaa.gov/Public/reforecast2/apcp_sfc_latlon_all_19900101_20101231_alfrFMVteL_t190.nc
