#'
col_ramp <- colorRampPalette(c("#54843f", "grey", "white"))



#' @title Extract dates
#' @description
#' Extract the dates from an archaeological record
#' 
#' @param record a full archaeological record (each line some depth, column represent year)
#' @param years better not to use, but if used should  be equal to \code{ncol(record)}
#' @param n final amount of sample needed
#' @export
extractDates <- function(record, years=NULL, n){
  if(n==0) {
    return(NULL)
  }
  if(is.null(years)){
    if(is.null(colnames(record))){
      years <- seq_along(record)
    }
    else {
      years <- colnames(record)
    }
  }
  peryear <- apply(record,2,sum) #get the total amount of datable fragement per year
  probs <- peryear/sum(peryear) #distributions years
  probs[is.na(probs)] <- 0
  return(sample(x=years, size=n, prob=probs, replace=T))
}


#' @title Plot the elevation and water map of the simulation
#' @param height Elevation raster
#' @param water Water 
#' @param maintitle Title of the plot
#' @importFrom terra plot
#' @export
plotMap <- function(height, water, maintitle=""){
  terra::plot(height^1.9, col=col_ramp(255), legend=F, reset=F, main=maintitle)
  terra::plot(water, col="lightblue", add=T, legend=F)
}





#png(file.path("fight.png"),width=800,height=800,pointsize=20)
#plotMap(height.ras,height.wat,paste0("year ",i))
#points(-1.5,2,bg="red",pch="🔥",cex=6,col=adjustcolor("yellow",.1))
#points(-1.5,2,bg="red",pch="⚔️",cex=6,col=adjustcolor("yellow",.1))
#points(-1.5,1,bg="red",pch="🕊️",cex=6,col=adjustcolor("yellow",.1))
#points(-.8,1.5,bg="red",pch="?",cex=6)
#points(-2.2,1.5,bg="red",pch="?",cex=6)
#dev.off()

