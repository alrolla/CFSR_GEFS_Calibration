import sys
import time
import datetime as dt
import numpy as np
import os
from netCDF4 import Dataset,  date2num
from datetime import datetime

# Directorio donde estan los TRMM en netcdf a transformar
path_input = '/Users/alrolla/Documents/datos/DATOS_Precipitacion/TRMM/netcdf/'
path_output = '/Users/alrolla/Documents/datos/DATOS_Precipitacion/TRMM_DAILY/'

# Fecha de referencia netCDF salida
AAAA_R = '1978'
MM_R = '12'
DD_R = '31'

# Loop sobre todos los datasets =========================================================
for file in os.listdir(path_input):
    # Recupero la fecha del nombre del archivo
    AAAA = file[11:15]
    MM = file[15:17]
    DD = file[17:19]
    print('%s%s' % (path_input, file), "Fecha:", dt.datetime(int(AAAA), int(MM), int(DD)))

    nc_df = Dataset('%s%s' % (path_input, file), 'r')  # ABRIR NETCDF ==================

    # ==== Extraigo los datos del NetCDF
    lats = nc_df.variables['lat'][:]  # Recupero las Latitudes
    lons = nc_df.variables['lon'][:]  # Recupero las Longitudes
    pre = nc_df.variables['precipitation'][:]  # Recupero la precipitacion

    nc_df.close()               # CERRAR NETCDF ==================

    # === CREAR  NETCDF DIARIO ( Con la metadata correcta )
    # Datos globales del NetCDF
    nc_out = Dataset('%sTRMM_%4s-%2s-%2s.nc' % (path_output, AAAA, MM, DD), 'w', format='NETCDF4')
    nc_out.description = "TRMM %4s-%2s-%2s Netcdf 4"
    nc_out.source = 'netCDF4 from TRMM 3B42RT diario'
    nc_out.history = 'Created ISO:' + time.strftime("%Y-%m-%d")

    # Crear dimensiones del netCDF
    lat_out = nc_out.createDimension('lat', len(lats))
    lon_out = nc_out.createDimension('lon', len(lons))
    time_out = nc_out.createDimension('time', 1)

    # Definicion de la dimension TIME
    times = nc_out.createVariable('time', np.float64, ('time',))
    times.long_name = 'Time'
    times.units = ('days since %4s-%2s-%2s 00:00:00' % (AAAA_R, MM_R, DD_R))  # Fecha de referencia
    times.calendar = 'gregorian'
    times.axis = 'T'
    # Calculo de dias desde la fecha de referencia para poner como tiempo
    print(date2num(datetime(int(AAAA), int(MM), int(DD)), units=times.units, calendar=times.calendar))
    times[:] = date2num(datetime(int(AAAA), int(MM), int(DD)), units=times.units, calendar=times.calendar)

    # Definicion de la dimension LATITUDES
    latitudes = nc_out.createVariable('lat', np.float32, ('lat',))
    latitudes.units = 'degree_north'
    latitudes.long_name = 'Latitude'
    latitudes.standard_name = "latitude"
    latitudes.axis = "Y"
    latitudes[:] = lats

    # Definicion de la dimension LONGITUDES
    longitudes = nc_out.createVariable('lon', np.float32, ('lon',))
    longitudes.units = 'degree_east'
    longitudes.long_name = "Longitude"
    longitudes.standard_name = "longitude"
    longitudes.axis = "X"
    longitudes[:] = lons

    # Definicion de la dimension PRECIPITACION
    # Create the actual 3-d variable
    precipitacion = nc_out.createVariable('pre', np.float32, ('time', 'lat', 'lon'))
    precipitacion.units = "mm"
    precipitacion.long_name = \
        "Daily accumulated precipitation (combined microwave-IR) estimate with gauge calibration over land"
    precipitacion.fill_value = -9999.9
    precipitacion[:, :] = np.transpose(pre)

    nc_out.close()


print("Fin.....")
