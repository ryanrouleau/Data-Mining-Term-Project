#### HAVE TO PERFORM ALL DATA PREP WITH N=7 THAT IS AT TOP OF OTHER FILE  ####

#### This file uses spline fits

library(splines)

table <-  as.data.frame.matrix(table(df.na$MonthYear,df.na$Bins))
plot(table[1:192,1]~c(1:192),col="blue",ylim=c(0,max(table)))
points(table[1:192,2]~c(1:192),col="green")
points(table[1:192,3]~c(1:192),col="red")
colordf <- c("blue","green","red")

plot.predict=FALSE
par(mfrow=c(3,1))
for(i in 1:3){
    #plot(table[1:195,i]~c(1:195),col=colordf[i],pch=19,ylab="Crime Counts",xlab="Month",main=paste("Bin",i))
    model <- lm(table[1:192,i]~ns(v,knots=c(25,55,100,150))+cos(2*pi*v/12)+sin(2*pi*v/12))
    print(paste("BIN = ",i))
    print(summary(model))
    #pred.ns <- predict(model,interval="confidence",newdata=data.frame(v=c(1:195)))
    #lines(pred.ns[,1]~c(1:195),lwd=2,col=colordf[i])
    #abline(v=192)
    #lines(pred.ns[,2]~v,lwd=2,col="grey")
    #lines(pred.ns[,3]~v,lwd=2,col="grey")
    if(plot.predict){
        temp <- table[193:195,i]
        x.temp <- c(193:195)
        pred.yr <- predict(model,interval="confidence",newdata=data.frame(v=c(193:204)))
        max <- max(pred.yr[,3],temp)
        min <- min(pred.yr[,2],temp)
        plot(temp~x.temp,ylim=c(min,max),xlim=c(193,204),pch=19,col=colordf[i],main=paste("Bin",i),ylab="Count",xlab="Month")
        lines(pred.yr[,1]~c(193:204),col=colordf[i])
        lines(pred.yr[,2]~c(193:204))
        lines(pred.yr[,3]~c(193:204))
    }
}


#library(gplots)
colors <- c("red","#A30052","orange","#00A352","#189589","blue","navy","#901490","darkviolet")
colors.t <- c("#FF7A7A","hotpink","#FFCF75","springgreen1","turquoise","#8080FF","#7A7AFF","violet","darkviolet")

par(mfrow=c(4,2))
M.a <- S.a.3
M.na <- S.na.3
bool.pred=TRUE
plot.reg=FALSE
count.a <- count.na <- 0
for(i in 1:columns){
    y.a <- M.a[,i]
    y.na <- M.na[,i]
    max <- max(y.a,y.na)  ##Max value for plot bounds
    min <- min(y.a,y.na)
    fit.ns.a <-lm(y.a[1:192]~ns(v,knots=c(55,100,150))+cos(2*pi*v/12)+sin(2*pi*v/12))
    fit.ns.na <-lm(y.na[1:192]~ns(v,knots=c(55,100,150))+cos(2*pi*v/12)+sin(2*pi*v/12))
    
    if(plot.reg){
        plot(y.a~c(1:195),col=colors[i],pch=20,ylim=c(min,max),ylab="Avg Severity",xlab="Month",main=paste("Point",i))
        points(y.na[1:192],col=colors.t[i],pch=20)
        pred.ns <- predict(fit.ns.a,interval="confidence")
        lines(pred.ns[,1]~v,lwd=2,col=colors[i])
        pred.ns <- predict(fit.ns.na,interval="confidence")
        lines(pred.ns[,1]~v,lwd=2,col=colors.t[i])
    }
    if(bool.pred){ 
        pred.a <- predict(fit.ns.a,newdata=data.frame(v=c(193:204)),interval="confidence")
        pred.na <- predict(fit.ns.na,newdata=data.frame(v=c(193:204)),interval="confidence")
        max <- max(pred.a,pred.na,y.a,y.na)
        min <- min(pred.a,pred.na,y.a,y.na)
        plot(y.a[193:195]~c(193:195),ylim=c(min,max),xlim=c(193,204),col=colors[i],pch=20,main=paste("Point",i),xlab="Month",ylab="Predicted Severity")
        points(y.na[193:195]~c(193:195),col=colors.t[i],pch=20)
        lines(pred.a[,1]~c(193:204),col=colors[i])
        lines(pred.na[,1]~c(193:204),col=colors.t[i])
        lines(pred.a[,2]~c(193:204),col="grey")
        lines(pred.na[,2]~c(193:204),col="grey")
        lines(pred.na[,3]~c(193:204),col="grey")
        lines(pred.a[,3]~c(193:204),col="grey")
        count.a <- count.a+sum((y.a[c(193:195)]<pred.a[c(1:3),3])*(y.a[c(193:195)]>pred.a[c(1:3),2]))
        count.na <- count.na+sum((y.na[c(193:195)]<pred.na[c(1:3),3])*(y.na[c(193:195)]>pred.na[c(1:3),2]))
        
    }
    #print(summary(fit.ns.a)$r.squared)
    #print(summary(fit.ns.na)$r.squared)
}
count.a/(3*columns)
count.na/(3*columns)

par(mfrow=c(4,2))
for(i in 1:columns){
    y.a <- M.a[,i]
    y.na <- M.na[,i]
    fit.ns.a <-lm(y.a[1:192]~ns(v,knots=c(55,100,150))+cos(2*pi*v/12)+sin(2*pi*v/12))
    fit.ns.na <-lm(y.na[1:192]~ns(v,knots=c(55,100,150))+cos(2*pi*v/12)+sin(2*pi*v/12))
    
    #fit.ns.a <-lm(y.a[1:192]~ns(v,knots=c(55,100,150)))
    #fit.ns.na <-lm(y.na[1:192]~ns(v,knots=c(55,100,150)))
    resid.a <- cbind(v,fit.ns.a$residuals)
    resid.na <- cbind(v,fit.ns.na$residuals)
    for(j in 0:11){
        index.a <- resid.a[,1]%%12==j
        index.na <- resid.na[,1]%%12==j
        if(j==0){
            resid.a[index.a,1] <- 12
            resid.na[index.na,1] <- 12
        }else{
            resid.a[index.a,1] <- j
            resid.na[index.na,1] <- j
        }
    }
    max <- max(resid.a,resid.na)  ##Max value for plot bounds
    min <- min(resid.a,resid.na)
    plot(resid.a,col=colors[i],ylab="Counts",xlab="Month",main="Residuals",ylim=c(min,max))
    ss.res <- smooth.spline(resid.a)
    lines(ss.res,col=colors[i],lwd=2)
    points(resid.na,col=colors.t[i])
    ss.res <- smooth.spline(resid.na)
    lines(ss.res,col=colors.t[i],lwd=2)
    Sys.sleep(.2)
}
