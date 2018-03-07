library(ggmap)
library(rgdal)
library(ggplot2)
library(ncdf4)
library(RMySQL)
library(RANN)

setwd("~/Dropbox/Calibracion_CFSv2_Web")

plotrect <- function (a,lon,lat,delta,col,label){
  a <- a + geom_segment(x = (lon-delta), y = (lat-delta), xend = (lon-delta), yend =( lat+delta) ,colour=col,linetype="dotted")
  a <- a + geom_segment(x = (lon-delta), y = (lat+delta), xend = (lon+delta), yend =( lat+delta) ,colour=col,linetype="dotted")
  a <- a + geom_segment(x = (lon+delta), y = (lat+delta), xend = (lon+delta), yend =( lat-delta) ,colour=col,linetype="dotted")
  a <- a + geom_segment(x = (lon+delta), y = (lat-delta), xend = (lon-delta), yend =( lat-delta) ,colour=col,linetype="dotted")
  a <- a + geom_point(x = (lon-delta), y = (lat+delta+.1),colour="yellow",size=6)
  a <- a + geom_text(x = (lon-delta), y = (lat+delta+.1),label=label,size=4)  
  return(a)
}

plotlegend <- function (a,posx,posy){
  a <- a + geom_rect(xmax=(posx+1.6)   ,xmin=posx    ,ymax=(posy+1.3)    ,ymin=posy    ,fill="white",colour="black")
  a <- a + geom_text( x = (posx+.05), y = (posy+1.25),label="References:",hjust=0,vjust=1,size=4)  
  a <- a + geom_point(x = (posx+.1), y = (posy+1.),colour="red",size=2)
  a <- a + geom_text( x = (posx+.2), y = (posy+1.),label="CPC-UNI",hjust=0,size=4)  
  a <- a + geom_point(x = (posx+.1), y = (posy+.8),colour="red",size=2)
  a <- a + geom_text( x = (posx+.2), y = (posy+.8),label="CFSRv2 (Interp)",hjust=0,size=4)  
  a <- a + geom_point(x = (posx+.1), y = (posy+.6),colour="blue",size=2)
  a <- a + geom_text( x = (posx+.2), y = (posy+.6),label="CFSRv2",hjust=0,size=4)  
  a <- a + geom_point(x = (posx+.1), y = (posy+.4),colour="orange",size=2)
  a <- a + geom_text( x = (posx+.2), y = (posy+.4),label="Closest station pt.",hjust=0,size=4)  
  a <- a + geom_point(x = (posx+.1), y = (posy+.2),colour="yellow",size=5)
  a <- a + geom_text (x = (posx+ 0.05), y = (posy+.25),label="#",hjust=0,vjust=1,size=3)
  a <- a + geom_text( x = (posx+.2), y = (posy+.2),label="Stations in box",hjust=0,size=4)  
  return(a)
}

#Leo la grilla de CFSR
CFSR.nc <- nc_open("CFSR.ori/prate_f.01.19990101.weekly.nc")
CFSR.lat <- ncvar_get( CFSR.nc, varid="latitude" )
CFSR.lon <- ncvar_get( CFSR.nc, varid="longitude" ) - 360.
CFSR.grid <- expand.grid(CFSR.lon,CFSR.lat)
names(CFSR.grid) <- c("lon","lat")
CFSR.grid <- as.data.frame(CFSR.grid)

#Leo la grilla de CPC
CPC.nc <- nc_open("CPC_UNI/prate_o.01.19990101.weekly.nc")
CPC.lat <- ncvar_get( CPC.nc, varid="latitude" )
CPC.lon <- ncvar_get( CPC.nc, varid="longitude" ) - 360.
CPC.grid <- expand.grid(CPC.lon,CPC.lat)
names(CPC.grid) <- c("lon","lat")
CPC.grid <- as.data.frame(CPC.grid)

#Leo la tabla de estaciones de la DB
db = dbConnect(MySQL(), user='root', password='', dbname='SMN', host='localhost')
rs = dbSendQuery(db, "select idOMM,NomEstacion,Institucion,Longitud,Latitud,Elevacion from SMN_META_ARG where activo='*'")
data.stn = fetch(rs, n=-1)
dbDisconnect(db)

#Leo el Shapefile
dpto.shape <- readOGR(dsn="shapes",layer="departamentos")
#asigno la proyeccion al shapefile ( porque no la tiene ...)
proj4string(dpto.shape) <- CRS("+proj=longlat +datum=WGS84")
dpto.shape <- spTransform(dpto.shape, CRS("+proj=longlat +datum=WGS84"))
dpto.shape <- fortify(dpto.shape)

#Leo el Shapefile
prov.shape <- readOGR(dsn="shapes",layer="argentina")
#asigno la proyeccion al shapefile ( porque no la tiene ...)
proj4string(prov.shape) <- CRS("+proj=longlat +datum=WGS84")
prov.shape <- spTransform(prov.shape, CRS("+proj=longlat +datum=WGS84"))
prov.shape <- fortify(prov.shape)

#for(i.est in 1:length(data.stn$idOMM)){
for(i.est in 93:98){
    
        #Punto de estacion  
        lat.stn <- data.stn$Latitud[i.est]
        lon.stn <- data.stn$Longitud[i.est]
        
        m <- get_map(location=c(lon=lon.stn,lat=lat.stn),zoom=7)
        
        lon.min <- round(lon.stn,digits = 0) - 3.
        lon.max <- round(lon.stn,digits = 0) + 3.
        lat.min <- round(lat.stn,digits = 0) - 3.
        lat.max <- round(lat.stn,digits = 0) + 3.
        
        ewbrks <- seq(lon.min,lon.max,1.)
        nsbrks <- seq(lat.min,lat.max,1.)
      
        a <- ggmap(m)
        a <- a + geom_blank()

        a <- a + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=.2,color='black', data=dpto.shape, alpha=0)
        a <- a + scale_x_continuous(breaks = ewbrks, limits = c(min(a$data$lon)-2, max(a$data$lon)+2)) 
        a <- a + scale_y_continuous(breaks = nsbrks, limits = c(min(a$data$lat)-2, max(a$data$lat)+2)) 
        
        a <- a + geom_polygon(aes(x=long, y=lat, group=group), fill='grey', size=1,color='black', data=prov.shape, alpha=0)
        a <- a + scale_x_continuous(breaks = ewbrks, limits = c(min(a$data$lon)-3, max(a$data$lon)+3)) 
        a <- a + scale_y_continuous(breaks = nsbrks, limits = c(min(a$data$lat)-3, max(a$data$lat)+3))         
        
        a <- a + coord_map(xlim = c(lon.min,lon.max),ylim = c(lat.min, lat.max))
        
        for ( xlon in lon.min:lon.max){
          a <- a + geom_segment(x =  as.numeric(xlon), y = min(a$data$lat), xend = as.numeric(xlon), yend = max(a$data$lat),colour="grey")
        }
        for ( ylat in lat.min:lat.max){
          a <- a + geom_segment(x =  min(a$data$lon), y = ylat, xend = max(a$data$lon), yend = ylat ,colour="grey")
        }
        

        #Plotea el rectangulo de 1,9,25,49
        #Buscar el punto mas cercano de CPC
        query=data.frame(lon=lon.stn,lat=lat.stn)
        closest <- nn2(data=CPC.grid,query=query, k=1)[[1]]
        
        lon.cpc <- CPC.grid$lon[closest]
        lat.cpc <- CPC.grid$lat[closest]
        col.box="black"
        a <- plotrect(a,lon.cpc,lat.cpc,.15,col.box,"1")
        a <- plotrect(a,lon.cpc,lat.cpc,0.55,col.box,"9")
        a <- plotrect(a,lon.cpc,lat.cpc,1.05,col.box,"25")
        a <- plotrect(a,lon.cpc,lat.cpc,1.55,col.box,"49")
        
        #Plotea el rectangulo general
        a <- a + geom_segment(x =  lon.min, y = lat.min, xend = lon.min, yend = lat.max ,colour="black")
        a <- a + geom_segment(x =  lon.min, y = lat.max, xend = lon.max, yend = lat.max ,colour="black")
        a <- a + geom_segment(x =  lon.max, y = lat.max, xend = lon.max, yend = lat.min ,colour="black")
        a <- a + geom_segment(x =  lon.max, y = lat.min, xend = lon.min, yend = lat.min ,colour="black")
        
        #Plotea la grilla CFSR
        a <- a +  geom_point(data=CFSR.grid, aes(lon,lat),colour="blue", size=2)
        
        #Plotea la grilla CPC
        a <- a + geom_point(data=CPC.grid, aes(lon,lat),colour="red", size=1)
        
        a <- a + geom_point(x =  lon.stn , y = lat.stn ,shape = 21, colour = "black", fill = "orange",size=4,stroke=2)
        
        a <- a + labs(title=paste0("idOMM: ",data.stn$idOMM[i.est]," - ",data.stn$NomEstacion[i.est],"  - (Alt: ",data.stn$Elevacion[i.est] , "m)"), x="Longitude", y = "Latitude")
        a <- a + theme(plot.title = element_text(size = 12))
        a <- plotlegend(a,lon.max-1.7,lat.max-1.4)
        
        ggsave(paste0("Graf.Estaciones/Est",data.stn$idOMM[i.est],".pdf"),a,dev="pdf")
        
        rm(a)
        
}