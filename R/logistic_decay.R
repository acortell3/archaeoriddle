
## Fucntion 13. Logistic decay for resource generation
#' @title Logistic decay
#' @description
#' Given a raster and a vector of points, set resources hotspots with a
#' logistic decay around them
#' @param pt a vector points around witch decay is computed
#' @param rast a raster to compute distances
#' @param L starting point of decay
#' @param k a vector of decay rates
#' @param x0 areas around `pt` in which resources decay from
#' 
#' @return Logistic decay vector
#' @export
logisticdecay <- function(pt, rast, L=1, k=0.0001, x0=60000){
  ds <- distance(rast, pt)
  logdec = L-L/(1+exp(-k*(ds-x0)))
  return(logdec)
}