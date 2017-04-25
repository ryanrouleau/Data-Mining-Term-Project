###  FORMAT DATA AND GENERATE MATRICES TO RUN OTHER SCRIPTS  ####

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

##Defense to separate data in arrest and no arrest
chisq.test(table(df$Bin,df$Arrest))
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


####MATRICES WILL TRACK COUNTS AND SEVERITIES PER LOCATION########
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


