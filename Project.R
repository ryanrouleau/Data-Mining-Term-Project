library(fields)
#library(ggmap)

###Ignoring severity mapping

df<- read.csv("ProcessedCrimes.csv",header=TRUE)
sev<- read.csv("mapping.csv",header=TRUE)
bin <- read.csv("binning.csv",header=TRUE)

### MAKE SURE TO CHANGE HEADER OF binning.csv FILE TO Bins INSTEAD OF Severity  ###

df<-merge(df,sev,by="IUCR")
df<-merge(df,bin,by="IUCR")

rm(list=c("bin","sev"))

df <- df[,-1] #No longer need IUCR code
ls(df)

df.a <- df[df$Arrest==1,-5]  ##Remove arrest attribute
df.na <- df[df$Arrest==0,-5]

## Justification to split into arrest/no arrest
#chisq.test(table(df$Bin,df$Arrest))

#choose centers
#n=100 ##Smooth severity plots the loop takes a while to run with this one
n=7 ##prediction fits

lat.s <- summary(df$Lat)
lat <- c(lat.s[1],lat.s[6])
diff <- (lat[2]-lat[1])/(2*n)
lat <- seq(lat[1]+diff,lat[2]-diff,length.out=n)

lon.s <- summary(df$Lon)
lon <- c(lon.s[1],lon.s[6])
diff<- (lon[2]-lon[1])/(2*n)
lon <- seq(lon[1]+diff,lon[2]-diff,length.out=n)

centers <- as.matrix(expand.grid(lon,lat))
rm(list=c("lat","lon","lon.s","lat.s","diff"))
#centers <- centers[-c(1:7,11:15,21:25,31:33,40:44,49:55,59:64,69:73,79:80,88:90,98:100),] ##10X10
#centers<-centers[-c(1,2,3,6,7,11,15,16,20,21,25),] ##5x5
plot(centers)
if(n==7){
    points(centers[c(1,9),],col="red")  ##determined radius based on these pts
    radius <- rdist(centers[c(1,9),])[2]
    centers <- centers[c(47,43,38,33,28,24,19,14,5),]    
}else{
    ##General smoothing radius (more overlapping than above)
    radius <- sort(rdist(centers)[1,])[2]*2  ##min distance neq 0
}

radius

##define temp variable to check location of points
points(centers,col="blue")
US(add=TRUE)



v <- 1:192
columns <- dim(centers)[1]

####MATRICES WILL TRACK COUNTS PER LOCATION########
M <- matrix(nrow=192,ncol=columns,dat=0) 
M.s <- matrix(nrow=192,ncol=columns,dat=0)

data = TRUE  ##USES ARREST DATA IF SET TRUE
#### run loop once for data = TRUE then change data= FALSE to generate matrices for no arrest

for(bin in 1:3){  ##SET bin for now, don't run through full loop
    if(data){
        df.bin <- df.a[df.a$Bin==bin,]
    }else{
        df.bin <- df.na[df.na$Bin==bin,]
    }
    for(year in 2001:2016){
        df.year <- df.bin[df.bin$Year == year,]
        for(month in 1:12){
            df.month <- df.year[df.year$Month==month,]
            grd <- as.matrix(data.frame(df.month$Lon,df.month$Lat))
            dist.mat <- rdist(grd,centers)
            row = (year-2001)*12+month  ##row in matrix
            for(i in 1:columns){
                M[row,i] <- sum(dist.mat[,i]<radius)   #Count 

                if(M[row,i]!=0){
                    M.s[row,i] = (1*(dist.mat[,i]<radius)%*%df.month$Severity)/M[row,i] ##Average severity
                }else{
                    M.s[row,i] = 0
                }
            }
            print(row)
        }
    }
    ##Store as COUNT (C) and severity (S) matrices
    if(data){
        assign(paste(c("C.a.",bin),collapse=""),M)
        assign(paste(c("S.a.",bin),collapse=""),M.s)
    }else{
        assign(paste(c("C.na.",bin),collapse=""),M)
        assign(paste(c("S.na.",bin),collapse=""),M.s)
    }
}


#plot counts, severities, and show points

dev.off()
colors <- c("red","hotpink","orange","springgreen1","turquoise","blue","navy","violet","darkviolet")



##Define which count matrix.  C.a.1 -->> Count.Arrest.Bin1
##After running loop, there should be 6 count matrices

M <- C.a.1
maxM<-max(M)
###### COUNTS ######
#points and linear fits
plot(M[,1]~v,ylim=c(0,maxM),xlab="Time (Months)",ylab="Count",col=colors[1],main="Counts",pch=20)
model <- lm(M[,1]~v)
abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[1],lwd=3)
for(i in 2:columns){
    points(M[,i]~v,col=colors[i],pch=20)
    model <- lm(M[,i]~v)
    abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[i],lwd=3)
    Sys.sleep(.2)
    print(i)
}

#residuals of counts
par(mfrow=c(3,3))
for(i in 1:columns){
    model <- lm(M[,i]~v)
    resid <- cbind(v,model$residuals) 
    for(j in 0:11){
        index <- resid[,1]%%12==j
        if(j==0){
            resid[index,1] <- 12
        }else{
            resid[index,1] <- j
        }
    }
    plot(resid,col=colors[i],ylab="Counts",xlab="Month",main="Residuals")
    ss.res <- smooth.spline(resid)
    lines(ss.res,col=colors[i],lwd=2)
    Sys.sleep(.2)
}

##### SEVERITIES ####

##Define severity matrix to use.  S.a.1 --> Severities.Arrest.Bin1

M.s <- S.a.2
maxM.s <- max(M.s)
dev.off()
plot(M.s[,1]~v,ylim=c(0,maxM.s),xlab="Time (Months)",ylab="Severities",col=colors[1],main="Severities",pch=20)
model <- lm(M.s[,1]~v)
abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[1],lwd=3)
for(i in 2:columns){
    points(M.s[,i]~v,col=colors[i],pch=20)
    model <- lm(M.s[,i]~v)
    abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[i],lwd=3)
    Sys.sleep(.2)
    print(i)
}


#plot(0,ylim=c(0,maxM),xlim=c(0,192),xlab="Month",ylab="Count",col="white",main="Linear Fits on Count")
par(mfrow=c(3,3))
for(i in 1:columns){
    model <- lm(M.s[,i]~v)
    resid <- cbind(v,model$residuals) 
    for(j in 0:11){
        index <- resid[,1]%%12==j
        if(j==0){
            resid[index,1] <- 12
        }else{
            resid[index,1] <- j
        }
    }
    plot(resid,col=colors[i],ylab="Counts",xlab="Month",main="Residuals")
    ss.res <- smooth.spline(resid)
    lines(ss.res,col=colors[i],lwd=2)
    Sys.sleep(.2)
}


dev.off()
##show where points are relative to chicago.  Maybe use google API to overlay them on Chicago?
##This is probably sufficient though

temp<- df.a[df.a$Bin==1,]
temp <- temp[temp$Year==2001,]
temp <- temp[temp$Month<7,]
plot(temp$Lon,temp$Lat,col="grey44")
points(centers,col=colors,main="Locations",pch=19,lwd=5)
US(add=TRUE)
rm(temp)


####### QUILT PLOTS AND PARAMETER ESTIMATION ##########
##Use max likelihood estimators to estimate spatial parameters when using n=100 (back at top)
##This will probably take one hell of a long time to run so probably don't do that
##Hopefully I'll be able to predict spatial parameters using regression similar to above

library(fields)
library(mapproj)
library(geoR)

M <- C.a.1
M.s <- S.a.1
par(mfrow=c(1,2))
for(i in 1:12){
    temp<-M[i,]!=0
    sum(temp)
    cent.t <- centers[temp,]
    temp <- mapproject(x=cent.t[,1],y=cent.t[,2],projection="sinusoidal")
    cent.t <- cbind(temp$x,temp$y)
    rm(temp)
    #count.t <- M[i,][temp]
    sev.t <- M.s[i,][temp]
    #quilt.plot(cent.t,count.t,main="COUNTS")
    quilt.plot(centers[temp,],sev.t,main="AVG SEVERITY")
        
    var <- vgram(loc=cent.t,y=sev.t,N=100,lon.lat=TRUE)
    max <- max(var$d)
    plot(var$stats["mean",]~var$centers,xlim=c(0,max/2))
    Sys.sleep(.2)
}

