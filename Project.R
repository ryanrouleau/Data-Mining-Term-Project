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

df.a <- df[df$Arrest==1,-6]  ##Remove arrest attribute
df.na <- df[df$Arrest==0,-6]

## Justification to split into arrest/no arrest
                                        #chisq.test(table(df$Bin,df$Arrest))

## Run same analysis on whole data, split no arrest/arrest
table <-  as.data.frame.matrix(table(df.na$MonthYear,df.na$Bins))
plot(table[1:192,1]~c(1:192),col="blue",ylim=c(0,max(table)))
points(table[1:192,2]~c(1:192),col="green")
points(table[1:192,3]~c(1:192),col="red")

par(mfrow=c(3,1))
colordf <- c("blue","green","red")
for(i in 1:3){
    datapred <- data.frame(y=table[1:192,i],x=c(1:192))
    model <- lm(y~x,data=datapred)
    #predict(model,newdata=data.frame(x=c(193:195)),interval="confidence")

    resid <- cbind(v,model$residuals) 
    for(j in 0:11){
        index <- resid[,1]%%12==j
        if(j==0){
            resid[index,1] <- 12
        }else{
            resid[index,1] <- j
        }
    }
    plot(resid,col=colordf[i],ylab="Counts",xlab="Month",main=paste("Bin",i))
    ss.res <- smooth.spline(resid)
    ss.res
    predict(ss.res)
    lines(ss.res,col=colordf[i],lwd=2)
}

##table of lm predictions, residual predictions, and actual values###

#choose centers
n=100 ##Smooth severity plots the loop takes a while to run with this one
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
    centers <- centers[c(47,43,38,33,24,19,14,5),]  
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
M <- matrix(nrow=194,ncol=columns,dat=0) 
M.s <- matrix(nrow=194,ncol=columns,dat=0)

data = TRUE  ##USES ARREST DATA IF SET TRUE
#### run loop once for data = TRUE then change data= FALSE to generate matrices for no arrest

for(bin in 1:3){  ##SET bin for now, don't run through full loop
    if(data){
        df.bin <- df.a[df.a$Bin==bin,]
    }else{
        df.bin <- df.na[df.na$Bin==bin,]
    }
    for(year in 2001:2017){
        df.year <- df.bin[df.bin$Year == year,]
        if(year!=2017){
            maxMonth <- 12
        }else{
            maxMonth <- 2
        }
        for(month in 1:maxMonth){
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

par(mfrow=c(1,2))
M <- C.a.1
maxM<-max(M)
###### COUNTS ######
plot(M[1:192,1]~v,ylim=c(0,maxM),xlab="Time (Months)",ylab="Count",col=colors[1],main="No Arrest",pch=20)

model <- lm(M[1:192,1]~v)
abline(a=model$coeff[1],b=model$coeff[2],col=colors[2])
#lines(model$coeff[1]+model$coeff[2]*cos(2*pi*v/12)+model$coeff[3]*sin(2*pi*v/12)+model$coeff[4]*v~v)
#abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[1],lwd=3)
for(i in 2:columns){
    points(M[1:192,i]~v,col=colors[i],pch=20)
    model <- lm(M[1:192,i]~v)
    abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[i],lwd=3)
    Sys.sleep(.2)
    print(i)
}


#Plotting residuals of counts side by side for each data point
#Be sure to change bounds on loop and run for 1:4 and 5:8 to generate both plots

M1 <- C.a.3
M2 <- C.na.3
pred=TRUE
par(mfrow=c(4,2))
for(i in 5:8){
    model1 <- lm(M1[1:192,i]~v)

    resid1 <- cbind(v,model1$residuals)
    model2 <- lm(M2[1:192,i]~v)

    resid2 <- cbind(v,model2$residuals) 
    for(j in 0:11){
        index1 <- resid1[,1]%%12==j
        index2 <- resid2[,1]%%12==j
        if(j==0){
            resid1[index1,1] <- 12
            resid2[index2,1] <- 12
        }else{
            resid1[index1,1] <- j
            resid2[index2,1] <- j
        }
    }
    plot(resid1,col=colors[i],ylab="Counts",xlab="Month",main="Arrest")
    ss.res.1 <- smooth.spline(resid1)
    lines(ss.res.1,col=colors[i],lwd=2)
    plot(resid2,col=colors[i],ylab="Counts",xlab="Month",main="No Arrest")
    ss.res.2 <- smooth.spline(resid2)
    lines(ss.res.2,col=colors[i],lwd=2)
    #Sys.sleep(.2)
    if(pred){
        print("Arrest")
        predict(model1,newdata=data.frame(v=c(193:195)),interval="confidence")
        print("NO ARREST")
        predict(model1,newdata=data.frame(v=c(193:195)),interval="confidence")
    }
}

##periodic sinusoidal fits
plot(M[1:192,1]~v,ylim=c(0,maxM),xlab="Time (Months)",ylab="Count",col=colors[1],main="Counts",pch=20)
model <- lm(M[1:192,1]~cos(2*pi*v/12)+sin(2*pi*v/12)+v)
lines(model$coeff[1]+model$coeff[2]*cos(2*pi*v/12)+model$coeff[3]*sin(2*pi*v/12)+model$coeff[4]*v~v)
#abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[1],lwd=3)
for(i in 2:columns){
    points(M[1:192,i]~v,col=colors[i],pch=20)
    model <- lm(M[1:192,i]~cos(2*pi*v/12)+sin(2*pi*v/12)+v)
    lines(model$coeff[1]+model$coeff[2]*cos(2*pi*v/12)+model$coeff[3]*sin(2*pi*v/12)+model$coeff[4]*v~v) 
    Sys.sleep(.2)
    print(i)
}


##### SEVERITIES ####

##Define severity matrix to use as M.s ---  S.a.1 --> Severities.Arrest.Bin1
##Linear fits.  See NaturalSplines.R file for natural spline fitting

par(mfrow=c(3,2))
M.s <- S.a.1
title = "No Arrest, Bin 1"
maxM.s <- max(M.s)
minM.s <- min(M.s)
plot(M.s[1:192,1]~v,ylim=c(minM.s,maxM.s),xlab="Time (Months)",ylab="Avg Severity",col=colors[1],main=title,pch=20)
model <- lm(M.s[1:192,1]~v)
abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[1],lwd=2)
for(i in 1:columns){
    y <- M.s[1:192,i]
    points(y~v,col=colors[i],pch=20,main=i)
    model <- lm(y~v)
    #fit.ns <- lm(y~ns(v,knots=c(50,100,150)))
    #pred.ns <- predict(fit.ns,interval="confidence")
    #lines(pred.ns[,1]~v,col=colors[i])
    abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[i],lwd=2)
    print(i)
    #par(mfrow=c(2,2))
    #plot(fit.ns)
    #plot(model)
    #dev.off()
}


#plot(0,ylim=c(0,maxM),xlim=c(0,192),xlab="Month",ylab="Count",col="white",main="Linear Fits on Count")
par(mfrow=c(4,2))
for(i in 1:columns){
    model <- lm(M.s[1:192,i]~v)
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

###DEFINE FUNCTION TO OPTIMIZE FOR MLEs######

M <- C.a.1001
M.s <- S.a.1001
par(mfrow=c(1,2))
for(i in 1:12){
    temp<-M.s[i,]!=0
    sum(temp)
    cent.t <- centers[temp,]
    #count.t <- M[i,][temp]
    sev.t <- M.s[i,][temp]
    #quilt.plot(cent.t,count.t,main="COUNTS")
    quilt.plot(centers[temp,],sev.t,main="AVG SEVERITY")
        
    var <- vgram(loc=cent.t,y=sev.t,N=100,lon.lat=TRUE)
    max <- max(var$d)
    plot(var$stats["mean",]~var$centers,xlim=c(0,max/2))
    Sys.sleep(.2)
}

