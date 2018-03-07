
setwd("~/Documents/Preciptacion")

nptos <- c(1,9,25,49)

for(ptos in 0:3){
  
  datos=get(load(paste("DatosIguazu/iguazu",ptos,sep="")))
  
  for(power in 1:4){
    
    frame()
    #pdf(paste("scatterplots_Iguazu/iguazu_pwr",power,".pdf",sep=""),width=8,height=9)
    png(paste("scatterplots_Iguazu/iguazu_ptos",nptos[ptos+1],"_pwr",power,".png",sep=""),width=800,height=800)
    
    
    par(mfrow=c(2,2),oma=c(0,0,3,0))
    for( s in 1:4){
      prono <- eval(parse(text=paste("datos$S",s,"P",sep="")))
      obs <-  eval(parse(text=paste("datos$S",s,"O",sep="")))
      x=round(as.vector(prono)^(1/power),2)
      y=round(as.vector(obs)^(1/power),2)
      ino <- which(is.na(y))
      y <- y[-ino]
      x <- x[-ino]
      xmax <- max(x)
      ymax <- max(y)
      lims <- max(c(xmax,ymax))
      lims <- 300^(1/power)
      plot(x,y,pch=19,cex=.32,col="red",bg="red",xlim=c(0,lims),ylim=c(0,lims),main=paste("Week ",s,"\n 01-01-1999 to 31-12-2010 "),
                                                   ylab=paste("Observation^(1/",power,") (mm/week)",sep=""),
                                                   xlab=paste("Forecast^(1/",power,") (mm/week)",sep=""))
      rug(x,side=1,col="blue")
      
      rug(y,side=2,col="blue")
      
      #legend("topright", inset=.05, title="NObs",
      #       "4355", horiz=TRUE)
      grid(col = "black")
      }
    title(paste("Precipitation Control Point(s) ",nptos[ptos+1]," at Lat: -25.75, Lon: -54.5 (Iguazú)\nN.Pts: ",length(datos[,2]),sep=""), outer=TRUE)
    
    dev.off()
  }
}