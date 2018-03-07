#
# Este programa genera las tablas para generar los modelos de regresion logistica
# Tabla:
# ------------------------------------------------------------
# Fecha - ptos - S1P - S2P - S3P - S4P - S1O - S2O - S3O - S4O
# ------------------------------------------------------------
# El resultado se llama iguazu0(1 pto) - iguazu1 (9 ptos) - iguazu2 (25 ptos) - iguazu3(49 ptos)
#

library(ncdf4)
library(RMySQL)
library(RANN)

setwd("~/Dropbox/Calibracion_CFSv2_Web")

#Directorio donde estan las observaciones grilladas 
dir.obs   <- "CPC_UNI/"

#Directorio donde esta el CFSR grillado a la grilla de CPC_UNI
dir.prono <- "CFSR/"

prono.files <- list.files(path = dir.prono, pattern = "*.nc")
prono.n.files <- length(prono.files)

obs.files <- list.files(path = dir.obs, pattern = "*.nc")
obs.n.files <- length(obs.files)

#Latitud y longitud del punto de referencia para generar las tablas
#Leo la grilla de CPC para buscar las estaciones mas cercanas
CPC.nc <- nc_open("CPC_UNI/prate_o.01.19990101.weekly.nc")
CPC.lat <- ncvar_get( CPC.nc, varid="latitude" )
CPC.lon <- ncvar_get( CPC.nc, varid="longitude" ) 
CPC.grid <- expand.grid(CPC.lon,CPC.lat)
names(CPC.grid) <- c("lon","lat")
CPC.grid <- as.data.frame(CPC.grid)
#Leo la tabla de estaciones de la DB
db = dbConnect(MySQL(), user='root', password='', dbname='SMN', host='localhost')
rs = dbSendQuery(db, "select idOMM,NomEstacion,Institucion,Longitud,Latitud,Elevacion from SMN_META_ARG where activo='*'")
data.stn = fetch(rs, n=-1)
dbDisconnect(db)

#Numero de puntos alrededor del indicado ( 1, 9,25,49,...)

puntos.alrededor <- 1

#total de puntos 9,25,49, ...
ntotal <-c(1,3,5,7)^2


if(puntos.alrededor== 1){
  n <- prono.n.files
}else{
  n <- prono.n.files * ntotal[puntos.alrededor] 
}


i <- 1
ir <- 1

#Loop sobre los archivos de pronosticos ( porque son menos que los archivos de las observaciones)


db = dbConnect(MySQL(), user='root', password='', dbname='SMN', host='localhost')

for (ifile in prono.files){
    #Armo la fecha
    aa <- substr(ifile,12,15)
    mm <- substr(ifile,16,17)
    dd <- substr(ifile,18,19)
    fecha <- paste(aa,"-",mm,"-",dd,sep="")
    
    #Leo el pronostico
    nc.prono <- nc_open(paste(dir.prono,ifile,sep=""))  
    pre.prono <- ncvar_get( nc.prono, varid="pre" )
    pre.lat <- ncvar_get( nc.prono, varid="latitude" )
    pre.lon <- ncvar_get( nc.prono, varid="longitude" )
    
    #dim(pre.prono) <- c(111,160,6)
    obs.file <- paste(dir.obs,"prate_o.01.",substr(ifile,12,19),".weekly.nc",sep="")
    nc.obs <- nc_open(obs.file)
    pre.obs <- ncvar_get( nc.obs, varid="pre" )
        
    #for(i.est in 8:8){ 
    for(i.est in 1:length(data.stn$idOMM)){ 
      #total de puntos 9,25,49, ...
      ntotal <-c(1,3,5,7)^2
      for(puntos.alrededor in 1:2){
     
        if(puntos.alrededor== 1){
          n <- prono.n.files
        }else{
          n <- prono.n.files * ntotal[puntos.alrededor] 
        }

        # lat.punto <- -25.75
        # lon.punto <- 305.5
        lat.stn <- data.stn$Latitud[i.est]
        lon.stn <- data.stn$Longitud[i.est] + 360   
        query=data.frame(lon=lon.stn,lat=lat.stn)
        closest <- nn2(data=CPC.grid,query=query, k=1)[[1]]
        
        lon.punto <- CPC.grid$lon[closest]
        lat.punto <- CPC.grid$lat[closest]        
        
        lat.i <- which(pre.lat == lat.punto)
        lon.i <- which(pre.lon == lon.punto)
        
        if (puntos.alrededor == 1){
          x <- lon.i
          y <- lat.i
          insert=paste0("insert into SMN_PreSemanal values(",data.stn$idOMM[i.est],",",
                        1,",'",
                        fecha,"',",
                        1,",",
                        lat.punto,",",
                        lon.punto,",",                        
                        round(pre.prono[x,y,1],2),",",
                        round(pre.prono[x,y,2],2),",",
                        round(pre.prono[x,y,3],2),",",
                        round(pre.prono[x,y,4],2),",",
                        round(pre.obs[x,y,1],2),",",
                        round(pre.obs[x,y,2],2),",",
                        round(pre.obs[x,y,3],2) ,",",
                        round(pre.obs[x,y,4],2),")")
          insert=gsub("NA","Null",insert)
          dbSendQuery(db, insert)
          ir <- ir + 1
        }
        else
        {
          
          xmin <- lon.i - (puntos.alrededor-1)
          xmax <- lon.i + (puntos.alrededor-1)
          
          ymin <- lat.i - (puntos.alrededor-1)
          ymax <- lat.i + (puntos.alrededor-1)
          ipto <- 1
          for(x in xmin:xmax){
            for( y in ymin:ymax){
              insert=paste0("insert into SMN_PreSemanal values(",data.stn$idOMM[i.est],",",
                            ntotal[puntos.alrededor],",'",
                            fecha,"',",
                            ipto,",",
                            lat.punto,",",
                            lon.punto,",",                                  
                            round(pre.prono[x,y,1],2),",",
                            round(pre.prono[x,y,2],2),",",
                            round(pre.prono[x,y,3],2),",",
                            round(pre.prono[x,y,4],2),",",
                            round(pre.obs[x,y,1],2),",",
                            round(pre.obs[x,y,2],2),",",
                            round(pre.obs[x,y,3],2) ,",",
                            round(pre.obs[x,y,4],2),")")
              insert=gsub("NA","Null",insert)
              dbSendQuery(db,insert )
              ipto <-ipto +1
              ir <- ir + 1
            }
          }
        }
        i <- i+1
      } # fin loop puntos alrededor
 
    } # fin loop estaciones
        nc_close(nc.prono)
        nc_close(nc.obs)
        print(ifile)
} #fin loop archivos
dbDisconnect(db)


#obj2=get(load("iguazu0"))
#load("iguazu0")
