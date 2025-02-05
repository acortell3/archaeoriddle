library(terra)
onesimu=readRDS(here::here("doc","bookdown","data_original","general_results_selected_simu","buffattack300_K110_PSU065_3_all.RDS"))
Nts=onesimu$Nts
warcasualties=onesimu$warcasualties
sites=vect(here::here("doc","bookdown","data_original","sitesinitialposition"))
#Figure3
pdf("Figure3.pdf",width=8,height=6)
i=1000
par(mar=c(5,5,1,5))
running_totals <- stats::filter(warcasualties, rep(1, 10), sides = 1)
w=19
plot(sapply(1:(length(warcasualties)-w),function(i)sum(warcasualties[i:(i+w)])),type="h",yaxt="n",yaxt="n",ylab="",xlim=c(0,i),xlab="time")
axis(4,col="#673147",col.axis="black")
mtext("total number of death due to conflict (10 year windows)",4,2.5,col="black",font=1)
par(new=T)
growF=apply(Nts[1:i,sites$culture=="F"],1,sum)
growHG=apply(Nts[1:i,sites$culture=="HG"],1,sum)
plot(growF,col=rainbow(2)[1],type="l",lwd=5,ylim=c(0,max(growF,growHG)),xlim=c(0,i),ylab="population size",xlab="")
points(growHG,col=rainbow(2)[2],lwd=5,type="l")
legend("topleft",col=c(rainbow(2),"black"),legend=c("farmers","hunter gathers","war deaths"),lwd=3,bty="n")
dev.off()

