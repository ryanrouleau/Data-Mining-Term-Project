library(fields)

## ANALYSIS ON WHOLE DATA FRAME USING LINEAR MODELS AND LOOKING AT RESIDUALS
table <-  as.data.frame.matrix(table(df.na$MonthYear,df.na$Bins))
plot(table[1:192,1]~c(1:192),col="blue",ylim=c(0,max(table)))
points(table[1:192,2]~c(1:192),col="green")
points(table[1:192,3]~c(1:192),col="red")
x=c(1:192)
colordf <- c("blue","green","red")
#Add regression lines to plots
for(i in 1:3){
    model <- lm(table[1:192,i]~x)
    abline(a=model$coeff[1],b=model$coeff[2],col=colordf[i])
}

##Residual plots for linear regression
par(mfrow=c(3,1))
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

#plot counts, severities, and show points

dev.off()
colors <- c("red","hotpink","orange","springgreen1","turquoise","blue","navy","violet","darkviolet")



##Define which count matrix.  C.a.1 -->> Count.Arrest.Bin1
##After running loop, there should be 6 count matrices

par(mfrow=c(1,2))
M <- C.a.1
maxM<-max(M)
###### COUNTS ######
plot(M[1:192,1]~v,ylim=c(0,maxM),xlab="Time (Months)",ylab="Count",col=colors[1],main="Arrest",pch=20)

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


