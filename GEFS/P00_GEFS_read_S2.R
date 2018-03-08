library(ncdf4)
library(fields)

setwd("~/Dropbox/Calibracion_CFSv2_Web/GEFS")

fh <- nc_open("ARGENTINA/EnsCompleto/apcp_sfc_latlon_all_19900101_20101231_alfrFMVteL_t190.nc")

lon <- ncvar_get(fh,"lon") - 360
nlon <- length(lon)

lat <- ncvar_get(fh,"lat")
nlat <- length(lat)

time <- ncvar_get(fh,"time")
ntime <- length(time)

ens <- ncvar_get(fh,"ens")
nens <- length(ens)

fhour <- ncvar_get(fh,"fhour")
nfhour <- length(fhour)

idate="1999-01-01"

#3288 es el primer año: me confundi en la bajada de datos

for (itime in 3288:ntime){
  print(paste("time: ",itime,sep=""))
  for (iens in 1:nens){
    
    #float Total_precipitation(time, ens, fhour, lat, lon)
    pre <- ncvar_get(fh,"Total_precipitation" , c(1,1,1,iens,itime), c(nlon,nlat,34,1,1))
    
    dias=c(6, 10, 14, 18, 22, 26, 30, 34)
    
    tdiario=array(0, dim=c(23,36,8))
    
    for (nmat in 1:8){
      diario=array(0, dim=c(23,36))
      if(nmat == 1) {
        sec = 2:dias[1]
        #print(sec)
        #print("=========")
      }
      if(nmat != 1) {
        sec = (dias[nmat-1]+1):(dias[nmat]) 
        #print(sec)
        #print("=========")
      }
      
      for(it in sec){
        diario = diario + pre[,,it]
        #print(pre[21,22,it])
      }
      tdiario[,,nmat] = diario
      #print(diario[21,22])
    }   
    
    # define dimensions
    londim <- ncdim_def("lon","degrees_east",as.double(lon)) 
    latdim <- ncdim_def("lat","degrees_north",as.double(lat)) 
    timedim <- ncdim_def("time","time", as.integer(8:15),unlim=TRUE)
    
    # define variables
    fillvalue <- 9999.0
    
    pre_def <- ncvar_def("pre","kg m-2",list(londim,latdim,timedim),fillvalue,"precipitacion",prec="single")
    
    # create netCDF file and put arrays
    
    ncfname <- paste("S2/pre_",idate,"D09a16_M",sprintf("%02d", iens),".nc",sep="")
    
    ncout <- nc_create(ncfname,list(pre_def),force_v4=T)
    
    # put variables
    ncvar_put(ncout,pre_def,tdiario)
    
    # put additional attributes into dimension and data variables
    ncatt_put(ncout,"lon","axis","X") #,verbose=FALSE) #,definemode=FALSE)
    ncatt_put(ncout,"lat","axis","Y")
    ncatt_put(ncout,"time","axis","T")
    ncatt_put(ncout,"time","units",paste("days since ",idate," 00:00:00",sep=""))
    
    nc_close(ncout)  
    print(paste0("Archivo: ",ncfname))
    #stop("END")
  }
  idate=as.Date(idate)+1
  print(paste0("Fecha: ",idate))
}


