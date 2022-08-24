library(terra)
library(sf)
source("tools.R")

expname=commandArgs()[6]
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
sites=vect(readRDS("testsites.RDS"))
ts=1000

print(paste0("Starting simulation ",expname))

onesimu=run_simulation (
                           sites=sites,
                           viable=viable,
                           dem=height.ras,
                           ressources=rast("ressources.tiff"),
                           water=height.wat,
                           foldervid=expname,
                           visu=F,visumin=TRUE,
                           ts=ts,#length of simulation in year
                           Kbase=c("HG"=35,"F"=110),#difference in K for the two cultures
                           cul_ext=c("HG"=7,"F"=6),#spatial penality to extent: lower, bigger penality
                           penal_cul=c("HG"=4,"F"=5),#penality of occupational area: low, other sites can cam close
                           prob_birth=c("HG"=0.3,"F"=0.5),#proba to give birth every year
                           prob_survive=c("HG"=0.8,"F"=0.65),#proba to die when pop > K
                           prob_split=c("HG"=.5,"F"=.6),#proba to create new settlement when Ne > K
                           minimals=c("HG"=.14,"F"=.20),#how big the group of migrant should be to create a new city vs migrate to a existing one 
                           bufferatack=300,#distance max around which settlement can fight
                           prob_move=c("HG"=0.2,"F"=0.1) #proba to migrate to existing settlement when Ne > K
                           )

Nts=onesimu$Nts
warcasualties=onesimu$warcasualties
sites=onesimu$sites
i=min(ts,which(apply(Nts,1,sum)==0))

pdf(paste0(expname,"final,pdf"))
plotMap(height.ras,height.wat,paste0("year ",i))
plot(sites,cex=(as.integer(Nts[i,]>0)*0.3+Nts[i,]/200),pch=21,add=T,bg=rainbow(2,alpha=.6)[as.factor(sites$culture)])
text(sites)
dev.off()


pdf(paste0(expname,"growth_utils.pdf"))
plot(2:i,warcasualties[1:(i-1)],lwd=2,col="green",type="h",yaxt="n",ylab="",xlim=c(0,i))
axis(4)
par(new=T)
growF=apply(Nts[1:i,sites$culture=="F"],1,sum)
growHG=apply(Nts[1:i,sites$culture=="HG"],1,sum)
plot(growF,col="red",type="l",lwd=2,ylim=c(0,max(growF,growHG)),xlim=c(0,nrow(Nts)))
points(growHG,col="blue",lwd=2,type="l")
dev.off()

pdf(paste0(expname,"growth_tot.pdf"))
plot(warcasualties[1:(i-1)],lwd=2,col="green",type="h",yaxt="n",ylab="",xlim=c(0,i))
axis(4)
par(new=T)
growT=apply(Nts[1:(i-1),],1,sum)
plot(growT,col="black",type="l",lwd=2,ylim=c(0,max(growT)),xlim=c(0,i))
dev.off()

saveRDS(file=paste0(expname,".RDS"),onesimu)
