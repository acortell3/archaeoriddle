library(terra)
library(sf)
source("tools.R")
height.ras=rast("data_original/east_narnia4x.tif")
height.wat=height.ras
height.wat[height.wat>mean(height.wat[])]=NA
Nts=readRDS("general_results_selected_simu/buffattack300_K110_PSU065_3_all.RDS")$Nts
ress=rast("data_original/resources.tiff")
allsites=vect(readRDS("general_results_selected_simu/buffattack300_K110_PSU065_3_sitesRast.RDS"))
plotMap(height.ras,height.wat)
plot(allsites,add=T)
plot(allsites[Nts[nrow(Nts),]>0,],add=T,col="red",cex=.6)

dates=readRDS("general_results_selected_simu/buffattack300_K110_PSU065_3_dates.RDS")

foundsites=allsites[lengths(dates)>0,]
foundsites$numdates=unlist(lengths(dates[lengths(dates)>0]))
founddates=dates[lengths(dates)>0]
founddates=lapply(founddates,sort)
founddates=lapply(founddates,gsub,pattern=" BP",replacement="")
founddates=lapply(founddates,rev)
founddates=lapply(founddates,function(i)paste0(i," ± ",sample(stdpool,length(i),replace=T,prob=c(3,3,3,3,2,2,1,1))," BP"))
foundsites$dates=sapply(founddates,paste0,collapse=" | ")

leftdates=dates[lengths(dates)>0]
plotMap(height.ras,height.wat)
plot(foundsites,cex=foundsites$numdates/20+1,pch=21,bg=as.factor(foundsites$culture),add=T)
squares=st_make_grid(height.ras,.5)
squares=st_bind_cols(squares,ID=1:length(squares))
plot(squares,add=T)
selection=c(14,30,45,65,66)
plot(squares[selection,],add=T,col=adjustcolor("blue",.3))
inter=st_intersection(st_as_sf(foundsites),squares[selection,])
plotMap(height.ras,height.wat)
plot(st_geometry(inter),add=T,bg=rainbow(2,alpha=.6)[as.factor(inter$culture)],pch=21,cex=1+inter$numdates/10)

site_dist=st_distance(inter)
min(site_dist[as.numeric(site_dist)>units(0)])

sitesnames=1:nrow(inter)

sitesnames[c(1:4, 20)]=c("Farwallow" ,"Bearcall" ,"Dustscar" ,"Clearreach" ,"Rabbithole")

fr=c("Épibéliard" ,"Cololuçon" ,"Pulogne" ,"Haguemasse" ,"Auriteaux" ,"Bourville" ,"Banau" ,"Montnesse" ,"Bannet" ,"Alenlon", "Roullac" ,"Genneville" ,"Vinlès" ,"Antonnet" ,"Courtou" ,"Beaulogne" ,"Coloville" ,"Sarsart" ,"Soilon" ,"Cololimar")
sitesnames[5:19]=fr[1:(19-4)]
spain=c("Zava" ,"Catadrid" ,"Tegon" ,"Alicia" ,"Mulid" ,"Zararbella" ,"Malid" ,"Cásca" ,"Granalejos" ,"Segorez" ,"Terteixo" ,"Astumanca" ,"Galle" ,"Talona" ,"Girovega" ,"Albanada" ,"Nadoba" ,"Senca" ,"Vallanca" ,"Taville")

sitesnames[21:length(sitesnames)]=spain[1:(length(sitesnames)-20)]

inter$sitesnames=sitesnames
for(g in selection){
curr=inter[inter$ID==g,]
coords=st_coordinates(curr)
    write.csv(file=paste0("square_",g,".csv"),cbind.data.frame(sitename=curr$sitesnames,lon=coords[,1],lat=coords[,2],dates=curr$dates,economy=curr$culture))
}
text(st_coordinates(inter),inter$sitesnames,cex=.8)
#names generated via:https://www.fantasynamegenerators.com/fantasy-town-names.php



allsites=st_intersection(st_as_sf(foundsites),squares[-selection,])

for(g in (1:nrow(squares))[-selection]){
curr=allsites[allsites$ID==g,]
coords=st_coordinates(curr)
    write.csv(file=paste0("square_",g,".csv"),cbind.data.frame(lon=coords[,1],lat=coords[,2],dates=curr$dates,economy=curr$culture))
}

ld=strsplit(inter$dates," \\| ")
ld=lapply(ld,function(i)gsub(" ± .*","",i))
inter$start=sapply(ld,max)
inter$end=sapply(ld,min)

## plotting oldschool map


plot(height.wat,col=adjustcolor("light blue",.4),reset=F,legend=F,axes=F)
contour(height.ras,levels=seq(5,300,15),axes=F,ann=F,lwd=.1,labels="",bg="light blue",add=T)
plot(st_geometry(inter),pch=4,add=T,lwd=.3)
plot(st_geometry(inter),pch=20,add=T,lwd=.2,cex=.8,col=as.factor(inter$culture),alpha=.8)
box()

old=inter[inter$start>7180,]
ne=inter[inter$start>6800 & inter$end<6900,]

pdf("../fake_papers/oldages.pdf")
plot(height.wat,col=adjustcolor("light blue",.4),reset=F,legend=F,axes=F)
contour(height.ras,levels=seq(5,300,15),axes=F,ann=F,lwd=.1,labels="",bg="light blue",add=T)
plot(st_geometry(old),pch=4,add=T,lwd=.5,cex=3)
plot(st_geometry(old),pch=20,add=T,lwd=.2,cex=1.8,col=as.factor(old$culture),alpha=.8)
box()
dev.off()


pdf("../fake_papers/all.pdf")
plot(height.wat,col=adjustcolor("light blue",.4),reset=F,legend=F,axes=F)
contour(height.ras,levels=seq(5,300,15),axes=F,ann=F,lwd=.1,labels="",bg="light blue",add=T)
plot(st_geometry(inter),pch=4,add=T,lwd=.5,cex=3)
plot(st_geometry(inter),pch=20,add=T,lwd=.2,cex=1.8,col=as.factor(inter$culture),alpha=.8)
box()
dev.off()


png("../fake_papers/all.png")
plot(height.wat,col=adjustcolor("light blue",.4),reset=F,legend=F,axes=F)
contour(height.ras,levels=seq(5,300,15),axes=F,ann=F,lwd=.1,labels="",bg="light blue",add=T)
plot(st_geometry(inter),pch=4,add=T,lwd=.5,cex=3)
plot(st_geometry(inter),pch=20,add=T,lwd=.2,cex=1.8,col=as.factor(inter$culture),alpha=.8)
box()
dev.off()

pdf("../fake_papers/newages.pdf")
plot(height.wat,col=adjustcolor("light blue",.4),reset=F,legend=F,axes=F)
contour(height.ras,levels=seq(5,300,15),axes=F,ann=F,lwd=.1,labels="",bg="light blue",add=T)
plot(st_geometry(ne),pch=4,add=T,lwd=.5,cex=3)
plot(st_geometry(ne),pch=20,add=T,lwd=.2,cex=1.8,col=as.factor(ne$culture),alpha=.8)
box()
dev.off()


cairo_pdf("illtwitter.pdf")
plot(height.wat,col=adjustcolor("light blue",.4),reset=F,legend=F,axes=F)
contour(height.ras,levels=seq(5,300,15),axes=F,ann=F,lwd=.2,labels="",bg="light blue",add=T)
plot(st_geometry(inter),pch=4,add=T,lwd=.5,cex=3)
plot(st_geometry(inter),pch=20,add=T,lwd=.2,cex=1.8,col=as.factor(inter$culture),alpha=.8)
box()
sel=inter[c(20,2,15,36),]
text(st_coordinates(sel),sel$sitesnames,cex=.8,pos=c(1,2,2,4))
text(x = -1, y = .7, labels = "❤️", adj = c(0, 0), cex = 3, col = "black", font = 1)
text(x = -1, y = 1.2, labels = "🔥 ", adj = c(0, 0), cex = 3, col = "black", font = 1)
text(x = -1, y = 1.2, labels = "⚔️ ", adj = c(0, 0), cex = 3, col = "black", font = 1)
text(x = -1.2, y = 1.8/2, labels = "???? ", adj=c(0,0), cex = 3, col = "black", font = 1)
dev.off()

 col_ramp <- colorRampPalette(c("light blue",terrain.colors(10)[6], "#54843f","grey","white"))
plotMap(height.ras,height.wat)
contour(height.ras,levels=seq(5,300,15),axes=F,ann=F,lwd=.2,labels="",bg="light blue",add=T)
plot(st_geometry(inter),pch=4,add=T,lwd=.5,cex=3)
plot(st_geometry(inter),pch=20,add=T,lwd=.2,cex=1.8,col=as.factor(inter$culture),alpha=.8)
plot(coastline,add=T,lwd=1.1,col="black")
box()
sel=inter[c(20,2,15,36),]
text(st_coordinates(sel),sel$sitesnames,cex=.8,pos=c(1,2,2,4))
#text(x = -1, y = .7, labels = "🍻", adj = c(0, 0), cex = 3, col = "black", font = 1)
text(x = -3.4, y = .7, labels = "🍻 ", adj = c(0, 0), cex = 10, col = "black", font = 1)
text(x = -1.8, y = .7, labels = "👍 ", adj = c(0, 0), cex = 8, col = "black", font = 1)
text(x = -.5, y = .7, labels = "🍔 ", adj = c(0, 0), cex = 6, col = "black", font = 1)
#text(x = -1, y = 1.2, labels = "⚔️ ", adj = c(0, 0), cex = 3, col = "black", font = 1)
#text(x = -1.2, y = 1.8/2, labels = "???? ", adj=c(0,0), cex = 3, col = "black", font = 1)
coastline=st_cast(st_as_sf(as.polygons(height.ras>mean(height.ras[])))[2,],"MULTILINESTRING")
