library(RMySQL)
library(RANN)

setwd("~/Dropbox/Calibracion_CFSv2_Web")

#Leo la tabla de estaciones de la DB
db = dbConnect(MySQL(), user='root', password='', dbname='SMN', host='localhost')
rs = dbSendQuery(db, "select idOMM,NomEstacion,Institucion,Longitud,Latitud,Elevacion from SMN_META_ARG where activo='*'")
data.stn = fetch(rs, n=-1)
dbDisconnect(db)

nptos <- c(1,9)

db = dbConnect(MySQL(), user='root', password='', dbname='SMN', host='localhost')

#for(i.est in 1:length(data.stn$idOMM)){ 
for(i.est in 1:8){  
  
    for(ptos in 1:length(nptos)){
      
      rs = dbSendQuery(db, paste0("select * from SMN_PreSemanal where idOMM=",data.stn$idOMM[i.est]," and Ptos=",nptos[ptos]))
      datos = fetch(rs, n=-1)

      nom.est=gsub(" ", "",data.stn$NomEstacion[i.est] , fixed = TRUE)
      
      for(power in 4:4){
        frame()
        png(paste0("histogramas/H_",as.character(data.stn$idOMM[i.est]),"_",nom.est,"_ptos",nptos[ptos],"_pwr",power,".png",sep=""),width=900,height=900)
        par(mfrow=c(2,2),oma=c(0,0,3,0))
    
        for( s in 1:4){
          prono <- eval(parse(text=paste("datos$S",s,"P",sep="")))
          obs <-  eval(parse(text=paste("datos$S",s,"O",sep="")))
          x1.prono=round(as.vector(prono)^(1/power),2)
          x2.obs=round(as.vector(obs)^(1/power),2)
          ino <- which(is.na(x2.obs))
          if(length(ino) > 0){
            x1.prono <- x1.prono[-ino]
            x2.obs <- x2.obs[-ino]
          }
          max <- 400^(1/power)
          br <- seq(0,400^(1/power),400^(1/power)/40)
          #br <- seq(0,400,10)
          x1.prono.hist <- hist(x1.prono,breaks=br,plot=FALSE)
          x2.obs.hist <- hist(x2.obs,breaks=br,plot=FALSE)
          maxbp = max(x1.prono.hist$counts,x2.obs.hist$counts)*1.10
          barp <- t(cbind(x1.prono.hist$counts,x2.obs.hist$counts))
          rownames(barp) <- c("Forecast","Observations")
          a=barplot(barp,ylim=c(0,maxbp)
                  ,beside=TRUE
                  ,xlab=paste("Forecast^(1/",power,") (mm/week)",sep="")
                  ,ylab="Frecuency"
                  ,col=c("darkblue","red")
                  ,legend = rownames(barp)
                  ,names.arg=seq(10,400,10)
                  ,las=2
                  ,cex.axis=.8
                  ,cex.names=.7
                  ,main=paste("Week ",s,"\n 01-01-1999 to 31-12-2010 ")
                  
          )
          grid(col = "black")
        }
        title(paste0("Precipitation Histograms CPoints(s) ",nptos[ptos]," at Lat: ",datos$Pto.G.Lat[1],", Lon: ",datos$Pto.G.Lon[1]-360," (",data.stn$NomEstacion[i.est],")\nN.Pts: ",length(datos[,2])), outer=TRUE)
        
        dev.off()
        
      }
      
    }
}  
dbDisconnect(db)
