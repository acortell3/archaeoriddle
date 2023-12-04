library(terra)
source("tools.R")
height.ras=rast("east_narnia4x.tif")
height.wat=height.ras
height.wat[height.wat>mean(height.wat[])]=NA
height.groups=height.ras
maxh=max(height.ras[],na.rm=T)
height.groups[height.groups<mean(height.groups[])]=NA
height.groups[height.groups<(maxh*.7)]=1
height.groups[height.groups>(maxh*.7)]=200
height.groups[is.na(height.groups)]=-1
height.poly=as.polygons(height.groups)
viable=makeValid(height.poly[2,])
#buffattack300_K110_PSU065_3_sitesRast.RDS
expname=commandArgs()[6]
onesimu=readRDS(paste0(expname,"_all.RDS"))
sites=vect(readRDS(paste0(expname,"_sitesRast.RDS")))
Nts=onesimu$Nts
#alldeposit=lapply(1:ncol(Nts),function(s)Rec_c(sapply(Nts[1:i,s],A_rates), InitBP = 7500,ts=ts,r = 0.2, Max_bone_thickness = "m"))
#allShortLoss=lapply(1:10,function(ind){Rec=alldeposit[[ind]];print(paste0("settlement #",ind));apply(Rec,2,short_loss,.6)})
#allShortLoss=lapply(allShortLoss,function(Rec)long_loss(Rec,.9997,7500))

#All in one:
alldeposit=lapply(1:ncol(Nts),function(s)Rec_c(sapply(Nts[,s],A_rates), InitBP = 7500,ts=ncol(Nts),r = 0.2, Max_bone_thickness = "m"))
allLosses=lapply(1:length(alldeposit),function(ind){
                 st=Sys.time()
                    print(paste0("settlement #",ind));
                    Rec=alldeposit[[ind]];                    
                    Rec=apply(Rec,2,short_loss,.6)  #apply short loss
                    Rec=long_loss(Rec,.9997,7500) #apply long loss
                    print(Sys.time()-st)
                    return(Rec)
})
rm(alldeposit)


maxSites=max(sapply(allLosses,sum))
nsample=round(sapply(allLosses,sum)*30/maxSites)
allRemainingDates=lapply(seq_along(allLosses),function(r)extractDates(allLosses[[r]],n=nsample[r]))
rm(allLosses)


#pdf(paste0(expname,"_mapFound.pdf"))
#plotMap(height.ras,height.wat,paste0("final after losses"))
#plot(sites[1:10,],cex=3*(lengths(allRemainingDates)-1)/(29),pch=21,add=T,bg=rainbow(2,alpha=.6)[as.factor(sites$culture[1:10])])
#dev.off()

dates=unique(unlist(allRemainingDates))
dates=rev(sort(dates[!is.na(dates)]))
plot(table(unlist(allRemainingDates)))
totallDatesRemains=sapply(allRemainingDates,function(i)table(factor(i,levels=dates)))
saveRDS(allRemainingDates,file=paste0(expname,"_dates.RDS"))


