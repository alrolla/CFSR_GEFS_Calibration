
from netCDF4 import Dataset

rootgrp = Dataset('/Users/alrolla/Documents/datos/DATOS_Precipitacion/TRMM/netcdf/3B42_Daily.20000101.7.nc4',
                  'r', format='NETCDF4')

print(rootgrp.data_model)

rootgrp.close()

