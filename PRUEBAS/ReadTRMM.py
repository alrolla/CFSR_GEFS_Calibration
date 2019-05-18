from netCDF4 import Dataset, num2date, date2num
import datetime as dt
import numpy as np
import matplotlib.pyplot as plt
import os
os.environ["PROJ_LIB"] = '/Users/alrolla/anaconda/envs/CFSR_GEFS_Calibration/share/proj'
from mpl_toolkits.basemap import Basemap, addcyclic, shiftgrid

from datetime import datetime, timedelta

nc_df = Dataset('/Users/alrolla/Documents/datos/DATOS_Precipitacion/TRMM/netcdf/3B42_Daily.20000101.7.nc4', 'r')




print(filename[1:4])


# ==== Tratamiento de DIMENSIONES
nc_dims = [dim for dim in nc_df.dimensions]  # lista de las dimensiones

print("\nInformacion de las DIMENSIONES: ")
print("\nDimensiones : (", len(nc_dims), ")")
for dim in nc_dims:
    print("\tNombre:", '%-15s' % dim, "// size:", '%6d' % len(nc_df.dimensions[dim]))

# ==== Tratamiento de las VARIABLES
nc_vars = [var for var in nc_df.variables]  # lista de las variables

print("\nInformacion de las VARIABLES: ")
print("\nVariables : (", len(nc_vars), ")")
for var in nc_vars:
    if var not in nc_dims:
        print("\n\t== ", '%-20s' % var, " :: ", nc_df[var].dimensions, " :: ", nc_df[var].size, " :: ",
              repr(nc_df.variables[var].dtype))
        for ncattr in nc_df.variables[var].ncattrs():
            print('\t\t%15s:' % ncattr, repr(nc_df.variables[var].getncattr(ncattr)))

# ==== Tratamiento ATRIBUTOS GLOBALES
print("\nInformacion de las Variables GLOBALES : \n")
for attr in nc_df.ncattrs():
    print('%25s %s' % (attr,  repr(nc_df.getncattr(attr))))

# ==== Extraigo los datos del NetCDF

lats = nc_df.variables['lat'][:]  # Recupero las Latitudes
lons = nc_df.variables['lon'][:]  # Recupero las Longitudes
pre = nc_df.variables['precipitation'][:]  # Recupero la precipitacion

print(len(lats),lats.shape)
print(len(lons),lons.shape)
print(pre.shape)
print(pre)

# ==== Ploteo del mapa

print("ploteo mapa")
fig = plt.figure()
fig.subplots_adjust(left=0., right=1., bottom=0.01,top=0.90)
# ver http://matplotlib.org/basemap/users/mapsetup.html
mapa = Basemap(projection='merc', llcrnrlat=-60, urcrnrlat=-20,
            llcrnrlon=-120, urcrnrlon=0, resolution='i')

# mapa = Basemap(projection='moll', llcrnrlat=-90, urcrnrlat=90,\
#            llcrnrlon=0, urcrnrlon=360, resolution='c', lon_0=0)

mapa.drawcoastlines(color='k')
mapa.drawmapboundary()

#mapa.fillcontinents(color='#9ea061FF', lake_color='aqua')
mapa.drawcountries(linewidth=0.4, color="b")
mapa.drawstates(linewidth=0.2, color="r",)
mapa.drawmeridians(np.arange(0, 360, 15))
mapa.drawparallels(np.arange(-90, 90, 15))

lon2d, lat2d = np.meshgrid(lons, lats)
x, y = mapa(lon2d, lat2d)

paleta=np.arange(10, 250, 20)

cs = mapa.contourf(x, y, np.transpose(pre), levels=paleta, cmap=plt.cm.Spectral_r)

cbar = plt.colorbar(cs, orientation='horizontal', shrink=0.3)

print(nc_df.variables['precipitation'].units)

cbar.set_label("Precipitacion ColorBar")

plt.title("%s" % (nc_df.variables['precipitation'].long_name))

#  plt.show()

print("fin ploteo  mapa")

nc_df.close() # CERRAR NETCDF

darwin = {'name': 'Darwin, Australia', 'lat': -12.45, 'lon': 130.83}

print(darwin['name'])
print(darwin['lat'])
print(darwin['lon'])

lat_idx = np.abs(lats-darwin['lat']).argmin()
lon_idx = np.abs(lons-darwin['lon']).argmin()

print(lat_idx, "  ", lon_idx)

# === CREACION DE UN NETCDF

nc_out = Dataset('/Users/alrolla/Documents/datos/DATOS_Precipitacion/TRMM/salida.nc', 'w', format='NETCDF4')
nc_out.description = "TRMM Prueba"
nc_out.source = 'netCDF4 from TRMM 3B42RT diario'
# nc_out.history = 'Created ' + time.ctime(time.time())

lat_out = nc_out.createDimension('lat', len(lats))
lon_out = nc_out.createDimension('lon', len(lons))
time_out = nc_out.createDimension('time', 1)

times = nc_out.createVariable('time', np.float64, ('time',))
times.long_name = 'Time'
times.units = 'days since 1978-12-31 00:00:00'
times.calendar = 'gregorian'
times.axis = 'T'
times[:] = 1

print(type(times))

latitudes = nc_out.createVariable('lat', np.float32, ('lat',))
latitudes.units = 'degree_north'
latitudes.long_name = 'Latitude'
latitudes.standard_name = "latitude"
latitudes.axis = "Y"
latitudes[:] = lats

longitudes = nc_out.createVariable('lon', np.float32, ('lon',))
longitudes.units = 'degree_east'
longitudes.long_name = "Longitude"
longitudes.standard_name = "longitude"
longitudes.axis = "X"
longitudes[:] = lons

# Create the actual 3-d variable
precipitacion = nc_out.createVariable('pre', np.float32, ('time', 'lat', 'lon'))
precipitacion.units = "mm"
precipitacion.long_name = "Daily accumulated precipitation (combined microwave-IR) estimate with gauge calibration over land"
precipitacion.fill_value = -9999.9
precipitacion[:, :] = np.transpose(pre)
print(len(lat_out))


print(datetime(2001, 3, 1))

print(date2num(datetime(1979, 1, 31), units=times.units, calendar=times.calendar))
nc_out.close()

