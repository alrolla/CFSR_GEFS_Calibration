import os
import sys
import datetime as dt
import time

print(time.strftime("%Y/%m/%d"))

path = '/Users/alrolla/Documents/datos/DATOS_Precipitacion/TRMM/netcdf'

for fn in os.listdir(path):
    AAAA = fn[11:15]
    MM = fn[15:17]
    DD = fn[17:19]
    print(fn, "Fecha:", dt.datetime(int(AAAA), int(MM), int(DD)))
    sys.exit()

