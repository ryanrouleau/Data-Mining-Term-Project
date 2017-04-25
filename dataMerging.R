###  FORMAT DATA TO RUN OTHER SCRIPTS  ####

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

