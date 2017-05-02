#### HAVE TO PERFORM ALL DATA PREP WITH N=20 THAT IS AT TOP OF OTHER FILE  ####
#### This file uses spline fits ####

library(splines)

##Regenerate centers to re-run
n=20
lat.s <- summary(df$Lat)
lat <- c(lat.s[1],lat.s[6])
diff <- (lat[2]-lat[1])/(2*n)
lat <- seq(lat[1]+diff,lat[2]-diff,length.out=n)

lon.s <- summary(df$Lon)
lon <- c(lon.s[1],lon.s[6])
diff<- (lon[2]-lon[1])/(2*n)
lon <- seq(lon[1]+diff,lon[2]-diff,length.out=n)
centers <- as.matrix(expand.grid(lon,lat))

#plot(centers)

M <- S.a.20.1
arrest=TRUE
M <- S.na.20.1
arrest=FALSE
#M.A <- S.a.100.1
##get rid of unnecessary centers (zero count) ##
dim(centers)
temp <- M[1,]
for(i in 2:dim(M)[1]){
    temp <- temp+M[i,]
}
temp <- temp!=0
centers <- centers[temp,]
points(centers,col="red")
M <- M[,temp]
length <- sum(temp)
length
rm(temp)

lower <- matrix(data=0,nrow=2,ncol=length)
predictions <- matrix(data=0,nrow=2,ncol=length)
upper <- matrix(data=0,nrow=2,ncol=length)

v=c(1:180)
COL = rainbow(length)
#plot(M[,1],ylim=c(min(M),max(M)))

for(i in 1:length){
    y <- M[,i]
    #points(y,col=COL[i])
    fit.ns <-lm(y[1:180]~ns(v,knots=c(55,100,150))+cos(2*pi*v/12)+sin(2*pi*v/12))
    pred.ns <- predict(fit.ns,newdata=data.frame(v=c(193,194)),interval="confidence")
    for(year in 1:2){
        predictions[year,i] <- pred.ns[year,1]
        lower[year,i] <- pred.ns[year,2]
        upper[year,i] <- pred.ns[year,3]
    }

}

grd <- as.matrix(centers)
par(mfrow=c(2,1))

yr <- 1  #Jan
#yr <- 2  #Feb

index <- 192+yr
max = max(M[index,],predictions[yr,])
min = min(M[index,],predictions[yr,])
library(fields)
#quilt.plot(grd,M[index,],zlim=c(min,max),main="Actual")
#quilt.plot(grd,predictions[yr,],zlim=c(min,max),main="Predicted")
temp <- (M[index,] < 1.05*upper[yr,])*(M[index,]>.995*lower[yr,])  
sum(temp)/length



#dev.off()
#diff <- M[index,]-predictions[yr,]
#hist(diff,breaks=30)
#sd(diff)
#mean(diff)

#### GENERATE PREDICTIVE HEAT MAPS USING KRIGING ####
### geoR needs projected coords to work ###
library(mapproj)
temp <- mapproject(x=grd[,1],y=grd[,2],projection="sinusoidal")
grd.proj <- cbind(temp$x,temp$y)
grd.p <- as.matrix(centers.p) #generate centers.p in dataMerge file
temp <- mapproject(x=grd.p[,1],y=grd.p[,2],projection="sinusoidal")
grd.p.proj <- cbind(temp$x,temp$y)

library(geoR)

#z <- M[index,]
z <- predictions[year,]
if(arrest){
    z.avg.a <- mean(z)
}else{
    z.avg.na <- mean(z)
}

z <- z-z.avg

dist.Max <- max(rdist(grd.proj))
breaks <- seq(0,dist.Max,length.out=50)
var <- variog(coords=grd.proj,data=z,estimator.type="classical",breaks=breaks,bin.cloud=TRUE)
#plot(var,xlim=c(0,dist.Max/2))  #only significant for half the max distance
vfit <- variofit(var,cov.model="exponential",weights="cressie")#,kappa=2)  ##Exponential covariance
#lines(vfit)

tau2 <- vfit$nugget    #nugget effect
tau2
sigma2 <- vfit$cov.pars[1]   ##sd
sigma2
a <- vfit$cov.pars[2]    ##range parameter
a

Sigma <- sigma2*exp(-rdist(grd.proj)/a)   #covariance matrix
#diag(Sigma) <- diag(Sigma)+tau2     #account for nugget effect

Sigma0 <- sigma2*exp(-rdist(grd.p.proj,grd.proj)/a)
#diag(Sigma0) <- diag(Sigma0)+tau2

                                        #ones <- matrix(nrow=length(z),ncol=1,data=1)
if(arrest){
    simple.a <- Sigma0%*%solve(Sigma)%*%z ## simple kriging residuals
}else{
    simple.na <- Sigma0%*%solve(Sigma)%*%z ## simple kriging residuals
}
    
par(mfrow=c(1,2))
quilt.plot(grd.p,simple.a+z.avg.a,main="Arrest",xlab="Longitude",ylab="Latitude")
quilt.plot(grd.p,simple.na+z.avg.na,main="No Arrest",xlab="Longitude",ylab="Latitude")
quilt.plot(grd,z+z.avg,add=TRUE)

sev.t <- M.A[192,][not.zero]
quilt.plot(grd.p,M.A[index,][not.zero],main="AVG SEVERITY")

diff <- simple+z.avg-M.A[index,][not.zero]
quilt.plot(grd.p,diff)
plot(diff)
hist(diff,n=30)
mean(diff)
sd(diff)
