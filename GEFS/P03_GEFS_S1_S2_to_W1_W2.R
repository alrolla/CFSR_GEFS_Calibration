library("ncdf4")

setwd("~/Dropbox/Calibracion_CFSv2_Web/Proc_GEFS")

dirOri <- "~/Dropbox/Calibracion_CFSv2_Web/Proc_GEFS/S1y2EnsMean/"
dirDest <- "~/Dropbox/Calibracion_CFSv2_Web/GEFS/Week1y2"

cfsr.files <- list.files(path = dirOri, pattern = "*.nc")

iday <- 1

time.serie <- seq(1,14,7)-1

for (ifile in cfsr.files){
  
  print(ifile)
  
  nc <- nc_open(paste(dirOri,ifile,sep=""))
  
  prate <- ncvar_get( nc, varid="pre" )
  
  dim(prate)
  
  lat <- ncvar_get( nc, varid="lat" )
  lon <- ncvar_get( nc, varid="lon" )
  time <- ncvar_get( nc, varid="time" )
  vtimes <- seq(as.Date("1999-01-01"),as.Date("2010-12-31"),1) # 
  
  
  Sx <- array(0, dim=c(23,36,2))
  
  iSx <- 1
  for ( s in seq(1,14,7)){
    #print(paste(s,(s+6)))
    for ( is in s:(s+6)){
      Sx[,,iSx] <- Sx[,,iSx] + prate[,,is]
    }
    iSx <- iSx +1
  }
  nc_close(nc)
  
  
  #======= NETCDF
  #definicion de las dimensiones
  dimLon <- ncdim_def('lon', units='degrees_east', longname='longitude', vals=lon)
  dimLat <- ncdim_def('lat', units='degrees_north', longname='latitude', vals=lat)
  dimTime <- ncdim_def('time', units=paste('days since ',vtimes[iday],sep=''), calendar='standard',longname='time', vals=time.serie)
  
  #definicion de las variables
  varPre <- ncvar_def('pre', units='mm/week', dim=list(dimLon,dimLat,dimTime),missval=9999., longname='precipitacion')
  
  #creo el nuevo archivo semanal
  #pre_2010-12-31D01a16.ensmean.nc
  nc <- nc_create(paste(dirDest,"/",substr(ifile,1,14),".weekly.nc",sep=""),varPre)
  
  for(iw in 1:2){
    ncvar_put(nc, varPre,Sx[,,iw],start=c(1,1,iw), count=c(-1,-1,1))
  }
  nc_close(nc)
  iday <- iday + 1
 
}
