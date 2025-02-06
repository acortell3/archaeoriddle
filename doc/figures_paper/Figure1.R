##check if you have the pacages/functions needed
check  <-  require(archaeoridlle,quietly=T)
if(!check && !exists('K_lim')) cat("You haven't installed the archaeoridlle package, you'll need to install it \n \t - \033[1;34m`devtools::install_github(\"acortell3/archaeoriddle\")`\033[0m\n or load it  \n \t - \033[1;34m`devtools::load_all('.')`\033[0m \n")

### Figure 1 ==== Below all the layers used in the figure One
library(terra)
library(sf)
onesimu=readRDS(here::here("doc","bookdown","data_original","general_results_selected_simu","buffattack300_K110_PSU065_3_all.RDS"))
Nts=onesimu$Nts
warcasualties=onesimu$warcasualties

sites=vect(here::here("doc","bookdown","data_original","sitesinitialposition"))
sitesF=readRDS(here::here("doc","bookdown","data_original","general_results_selected_simu","buffattack300_K110_PSU065_3_sitesRast.RDS"))
height.ras=rast(here::here("doc","bookdown","data_original","east_narnia4x.tif"))
height.wat=height.ras
height.wat[height.wat>mean(height.wat[])]=NA

png("dem.png",bg="transparent")
plot(height.ras,col=topo.colors(50),alpha=.5,axes=F,xlim=c(-4,1),ylim=c(-1,4),legend=F,mar=rep(0,4),oma=rep(0,4))
box(which="figure")
dev.off()

png("map.png",bg="transparent")
plotMap(height.ras,height.wat,axes=F,xlim=c(-4,1),ylim=c(-1,4),alpha=.8,mar=rep(0,4),oma=rep(0,4))
box(which="figure")
dev.off()

png("siteI.png",bg="transparent")
plot(sites,cex=(as.integer(Nts[1,]>0)*0.5+Nts[1,]/100),pch=21,axes=F,bg=rainbow(2,alpha=.6)[as.factor(sites$culture)],xlim=c(-4,1),ylim=c(-1,4),mar=rep(0,4),oma=rep(0,4))
text(sites[Nts[1,]>0],pos=3)
legend("topright",legend=c("hunter gather", "farmer"),pch=21,pt.bg=rainbow(2,alpha=.6))
box(which="figure")
dev.off()

png("siteF.png",bg="transparent")
par(mar=c(0,0,0,0),oma=c(0,0,0,0))
plot(sitesF,cex=(as.integer(Nts[nrow(Nts),]>0)*0.5+Nts[nrow(Nts),]/100),pch=21,axes=F,bg=rainbow(2,alpha=.6)[as.factor(sitesF$culture)],xlim=c(-4,1),ylim=c(-1,4),mar=rep(0,4),oma=rep(0,4))
box(which="figure")
dev.off()

ressources=rast(here::here("doc","bookdown","data_original","resources.tiff"))
png("ress.png",bg="transparent")
plot(ressources,axes=F,xlim=c(-4,1),ylim=c(-1,4),legend=F,alpha=.6,mar=rep(0,4),oma=rep(0,4))
box(which="figure")
dev.off()

png("square.png",bg="transparent")
squares=st_make_grid(height.ras,.5)
par(mar=rep(0,4),oma=rep(0,4))
plot(squares,add=F,col=adjustcolor(rainbow(length(squares)),.35),xlim=c(-4,1),ylim=c(-1,4),mar=rep(0,4),oma=rep(0,4),setParUsrBB=T)
text(st_coordinates(st_centroid(squares)),label=1:length(squares),col="white")
text(st_coordinates(st_centroid(squares)),label=1:length(squares),col="white")
dev.off()

dates=readRDS(here::here("doc","bookdown","data_original","general_results_selected_simu","buffattack300_K110_PSU065_3_dates.RDS"))
foundsites=sitesF[lengths(dates)>0,]
foundsites$numdates=unlist(lengths(dates[lengths(dates)>0]))
founddates=dates[lengths(dates)>0]
stdpool=c(20,30,40,50,60,80,100,120)
founddates=lapply(founddates,sort)
founddates=lapply(founddates,gsub,pattern=" BP",replacement="")
founddates=lapply(founddates,rev)
founddates=lapply(founddates,function(i)paste0(i," ± ",sample(stdpool,length(i),replace=T,prob=c(3,3,3,3,2,2,1,1))," BP"))
foundsites$dates=sapply(founddates,paste0,collapse=" | ")
leftdates=dates[lengths(dates)>0]

png("foundSites.png",bg="transparent")
plot(foundsites,cex=foundsites$numdates/20+1,pch=21,bg=rainbow(2,alpha=.6)[as.factor(foundsites$culture)],add=F,xlim=c(-4,1),ylim=c(-1,4),mar=rep(0,4),oma=rep(0,4))
dev.off()

png("squareavai.png",bg="transparent")
selection=c(14,30,45,65,66)
par(mar=rep(0,4),oma=rep(0,4))
plot(squares,xlim=c(-4,1),ylim=c(-1,4),mar=rep(0,4),oma=rep(0,4),setParUsrBB=T)
plot(squares[selection],add=T,col=adjustcolor("blue",.3))
inter=st_intersection(st_as_sf(foundsites),squares[selection])
plot(st_geometry(inter),add=T,col="red",pch=20,cex=1+inter$numdates/10,lwd=3,xlim=c(-4,1),ylim=c(-1,4),mar=rep(0,4),oma=rep(0,4))
dev.off()


