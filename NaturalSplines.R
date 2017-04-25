#### HAVE TO PERFORM ALL DATA PREP THAT IS AT TOP OF OTHER FILE  #### 

library(splines)

R2 <- matrix(data=0,nrow=8,ncol=6)
par(mfrow=c(4,2))
M.s <- C.na.2
#title = "No Arrest, Bin 1"
#maxM.s <- max(M.s)
#minM.s <- min(M.s)
#plot(M.s[,1]~v,ylim=c(minM.s,maxM.s),xlab="Time (Months)",ylab="Avg Severity",col=colors[1],main=title,pch=20)
#model <- lm(M.s[,1]~v)
                                        #abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[1],lwd=2)

#par(mfrow=c(2,4))
plot(M[1:192,1],ylim=c(min(M),max(M)),col=colors[i])

for(i in 1:columns){
    y <- M[1:192,i]
    points(y~v,col=colors[i],pch=20,main=i)
    model <- lm(y~v)
    #model.p <- lm(y~ns(v,knots=c(25,50,125,150,175)))
    #pred.p <- predict(model.p,interval="confidence")
    fit.ns <-lm(y~ns(v,knots=c(55,100,150)))
    pred.ns <- predict(fit.ns,interval="confidence")
    lines(pred.ns[,1]~v,lwd=2,col=colors[i])
    
    #lines(pred.p[,1]~v,lwd=2)
    #abline(a=model$coefficients[1],b=model$coefficients[2],col=colors[i],lwd=2)
    print(i)
    #par(mfrow=c(2,2))
                                        #plot(fit.ns)
    print(paste("POINT",i))
    print(summary(model))
    #R2[i,n] <- summary(fit.ns)$r.squared
    #R2[i,2] <- summary(model)$r.squared
    #R2[i,3] <- summary(model.p)$r.squared
    #dev.off()
}


COLOR <- rainbow(6)
dev.off()
plot(R2[,1],ylim=c(min(R2),max(R2)),col="white")
for(i in 1:6){
    points(R2[,i]~c(1:8),col=COLOR[i],pch=19)
}
par(mfrow=c(4,2))
for(i in 1:columns){
    y <- M.s[1:192,i]
    model <- lm(y~ns(v,knots=c(55,100,150)))
    resid <- cbind(v,model$residuals) 
    for(j in 0:11){
        index <- resid[,1]%%12==j
        if(j==0){
            resid[index,1] <- 12
        }else{
            resid[index,1] <- j
        }
    }
    points(resid,col=colors[i],ylab="Counts",xlab="Month",main="Residuals")
    ss.res <- smooth.spline(resid)
    lines(ss.res,col=colors[i],lwd=2)
    Sys.sleep(.2)
}
