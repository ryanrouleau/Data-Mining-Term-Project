df<- read.csv("ProcessedCrimes.csv",header=TRUE)
sentiments<- read.csv("mapping.csv",header=TRUE)

df<-merge(df,sentiments,by="IUCR")

smp_size <- floor(0.75 * nrow(df))
set.seed(123)
train_ind <- sample(seq_len(nrow(df)), size = smp_size)
test <- df[-train_ind, ]
df<-df[train_ind,]

#### variable selection on location description #####
df.table <- as.data.frame.matrix(table(df$Description,df$Severity>1000))

###STREET RESIDENCE APARTMENT ALLEY ######



df.1 <- df[df$Year==2001,-3]
df.a <- df.1[df.1$Description=="APARTMENT",-5]
df.st <- df.1[df.1$Description=="STREET",-5]
df.r <- df.1[df.1$Description=="RESIDENCE",-5]
df.sw <- df.1[df.1$Description=="SIDEWALK",-5]

grd.a <- as.matrix(data.frame(df.a$Lon,df.a$Lat))
grd.r <- as.matrix(data.frame(df.r$Lon,df.r$Lat))
grd.sw <- as.matrix(data.frame(df.sw$Lon,df.sw$Lat))
grd.st <- as.matrix(data.frame(df.st$Lon,df.st$Lat))

library(fields)  #run install.packages("fields")
par(mfrow=c(2,2))
quilt.plot(grd.r,df.r$Severity,zlim=c(a,b),main="RESIDENCE")
quilt.plot(grd.st,df.st$Severity,zlim=c(a,b),main="STREET")
quilt.plot(grd.a,df.a$Severity,zlim=c(a,b),main="APARTMENT")
quilt.plot(grd.sw,df.sw$Severity,zlim=c(a,b),main="SIDEWALK")

quilt.plot(grd.r,df.r$IUCR,main="RESIDENCE")
quilt.plot(grd.st,df.st$IUCR,main="STREET")
quilt.plot(grd.a,1/df.a$IUCR,main="APARTMENT")
quilt.plot(grd.sw,1/df.sw$IUCR,main="SIDEWALK")

#for(i in 2001-2016){
#  temp<-df$Year==i
#  df.temp<-df[temp,-3]  ##takes year out 
#  assign(paste(c("df.",i)),df.temp)
#  assign(paste(c("grd.",i)),as.matrix(data.frame(df.temp$Lon,df.temp$Lat)))
#}
#df.2001.subset<-subset(df.2001,Description=="STREET"|Description=="RESIDENCE"|Description=="SIDEWALK"|Description=="APARTMENT")




