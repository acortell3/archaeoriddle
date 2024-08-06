etopo <- read.csv(textConnection(
"altitudes,colours
10000,#FBFBFB
3900,#7E4B11
1900,#BD8D15
0,#307424
-1,#AFDCF4
-12000,#090B6A
"
), stringsAsFactors=FALSE)

col_ramp <- colorRampPalette(c("light blue",terrain.colors(10)[6], "#54843f","grey","white"))


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
plotMap <- function(height, water, maintitle="",...){
  terra::plot(height, col=col_ramp(50), legend=F, reset=F, main=maintitle,...)
  terra::plot(water, col="lightblue", add=T, legend=F,reset=F,...)
  above_level <- height > mean(height[])
  coastline <- sf::st_as_sf(as.polygons(above_level))[2,]
  plot(coastline, col=NA, bgc=adjustcolor("cyan", 0.1), add=T)
}





#png(file.path("fight.png"),width=800,height=800,pointsize=20)
#plotMap(height.ras,height.wat,paste0("year ",i))
#points(-1.5,2,bg="red",pch="🔥",cex=6,col=adjustcolor("yellow",.1))
#points(-1.5,2,bg="red",pch="⚔️",cex=6,col=adjustcolor("yellow",.1))
#points(-1.5,1,bg="red",pch="🕊️",cex=6,col=adjustcolor("yellow",.1))
#points(-.8,1.5,bg="red",pch="?",cex=6)
#points(-2.2,1.5,bg="red",pch="?",cex=6)
#dev.off()

#' Mimic 'viridis' Color Palette
#'
#' A function designed to mimic the 'viridis' color palette without requiring the
#' viridis package. It utilizes the base R function 'hcl.colors' to achieve a similar
#' outcome, providing a perceptually uniform color scale.
#'
#' @param n Integer; the number of colors to be generated. If n is 1, this function
#'        returns a character string describing the color. If n is greater than 1,
#'        it returns a character vector of color descriptions.
#' @return A character vector containing color hex codes that approximate the 'viridis'
#'         color palette.
#' @examples
#' viridis(10)  # Generate 10 colors approximating the 'viridis' palette
#' plot(1:10, col=viridis(10), pch=19, cex=2)  # Example plot using generated colors
#' @note This function is intended as a convenient workaround for scenarios where
#'       the 'viridis' package cannot be installed or loaded. It leverages the 'viridis'
#'       option in 'hcl.colors', available in base R, to provide a similar color palette.
#'       For precise color requirements or more complex color schemes, consider using
#'       the actual 'viridis' package or another suitable color package.
#' @seealso \code{\link[hcl.colors]{hcl.colors}} for more details on the color scheming
#'          function used.
viridis <- function(n) {
  hcl.colors(n, "viridis")
}
