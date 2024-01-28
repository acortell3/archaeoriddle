## Function 6. Depth protocol deposition
#' @title Depth protocol deposition
#' @description
#' It distributes the samples produced in one specific year along the depth of the
#' site, without any kind of post-depositional alteration, and according to 
#' pre-established post-deposition rates. Returns a vector with the samples exponentially
#' distributed. The vector is as long as L/r and the error (prop_buried, \eqn{\theta_{\epsilon}}) is considered.
#' @param W_t Integer (user provided), vector or data.frame. It is the number samples
#' produced at a specific 't'.
#' @param r Is the natural deposition rates. At this moment. Values greater than 0.5 are not accepted.
#' If values with two or more decimals are provided, the function will automatically round 
#' the value to one decimal.
#' @param max_bone_thickness Maximum thickness of bones within the assemblage. Four
#' values are possible: `'s'` (small) = 2.5 cm; `'m'` (medium) = 5 cm; `'l'` (large) = 10 cm
#' and `'vl'` (very large) = 20 cm. Default is `'m'`.
#' @param prop_buried Proportion of samples buried sample at tmax, considering error. Pb 
#' needs to be smaller than 1. Default is 0.9999, which stands for 99.99%.
#' This is \eqn{\theta_{\epsilon}} in equation 9
#' @return A vector of samples buried at times from tl to tm
#' @export
D_along <- function(W_t, r, max_bone_thickness = c("m", 's', 'l', 'vl'),
                    prop_buried = .9999){
  
  # Define parameter r
  if(r > 0.5) stop("values > 0.5 are not accepted for param 'r'")
  r <- round(r, 1)
  # Constraints for parameter Pb
  if (prop_buried >= 1) stop("Pb must be lower than 1")
  
  # Define parameter Max_bone_thickness (L)
  max_bone_thickness = match.arg(max_bone_thickness)
  if (max_bone_thickness == 's'){
    L <- 2.5
  } else if (max_bone_thickness == 'm'){
    L <- 5
  } else if (max_bone_thickness == 'l'){
    L <- 10
  } else if (max_bone_thickness == 'vl'){
    L <- 20
  }
  
  # Define tmax
  tm <- L/r
  # Estimate lambda
  l <- -log(1 - prop_buried) / tm
  
  ss <- rep(0, round(tm)) ## Vector to distribute samples over
  tl <- 0 # Year where the sample is deposited
  tu <- 1 # Year when it is covered
  
  for (i in 1:tm){
    Wb <- W_t * (1 - exp(-l*(tu-tl))) # Apply formula for tu
    Wbprev <- W_t * (1 - exp(-l*((tu-1)-tl))) # Calculate for previous to tu
    ss[i] <- round(Wb - Wbprev) # Number of samples for each year
    tu <- tu + 1
  }
  
  return(ss)
}

## 7. Archaeological deposition record
#' @title Archaeological deposition record
#' @description
#' Generate archaeological deposition record over time and depth
#' It iterates over D_along to spread the amount of samples produced at each time point over different profundities
#' @param x Vector with the number of samples per year. As produced as produced by iterating over A_rates.
#' @param area Only if `persqm = TRUE`. In this case, the total area of the site 
#' must be provided
#' @param ts Time-span, the number of years considered for the process
#' @param InitBP Initial year considered for the process. In BP.
#' @param persqm If TRUE, the total record is divided by the area of the site
#' (in square meters), so that the output is per square meter. Default is FALSE
#' @param ... This function uses the functions [D_along()]. The additional 
#' arguments can be added.
#' @return A square matrix of size ts. It contains the amount of samples deposited at each year (columns) and each depth (rows)
#' @export
Rec_c <- function(x, area, ts, InitBP, persqm = FALSE, ...){
  
  ## Whether sqm division must be included or not
  if (persqm == TRUE){
    x <- x / area
  }
  
  ## Spread dates along different depths
  matdim <- length(x)
  mat <- matrix(nrow=matdim, ncol=matdim)
  
  for (i in 1:matdim){
    new <- D_along(x[i], ...)
    st <- i - 1
    pos <- c(rep(0, st), new)
    pos <- pos[1:matdim]
    mat[, i] <- pos
  }
  mat[is.na(mat)] <- 0
  
  ## Names for columns (each year)
  years <- seq(InitBP, InitBP-ts)
  nyears <- c()
  for (i in 1:matdim){
    nyears[i] <- paste0(years[i], " BP")
  }
  colnames(mat) <- nyears
  
  ## Names for rows (each depth)
  # Extract arguments as a list
  extract_args <- function(x, ...){ 
    extras <- list(...)
    return(list(extras=extras)) 
  }
  
  dr <- extract_args(D_along, ...)
  dr <- dr$extras$r
  
  d <- rev(cumsum(rep(dr, nrow(mat)))) ## computes depths
  rownames(mat) <- paste0("d = ", d, " cm")
  
  return(mat)
}

