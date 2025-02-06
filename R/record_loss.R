## Function 8. Short term taphonomic loss
#' @title Short-term taphonomic loss
#' @description
#' Simulates the short-term taphonomic loss applying binomials to values on a
#' single vector for 1 year. If used for many years, use with apply function,
#' where the rows of the data frame are the depths and the columns the years.
#' @param x: A vector with the amount of samples per depth, at a specific years.
#' @param theta_s: Probability of the record surviving after the
#' first year after deposition
#' @return `numeric` with reduced values due to the short-term taphonomic loss
#' @export
short_loss <- function(x, theta_s){
    rbinom(length(x), x, theta_s)
}

## Function 9. Long term taphonomic loss
#' @title Long-term taphonomic loss
#' @description
#' Simulates the long-term taphonomic loss applying binomials to values on a
#' single vector for 1 year. If used for many years, use with apply function,
#' where the rows of the data frame are the depths and the columns the years.
#' @param x: A vector with the amount of sample per depth. 
#' @param theta_l: Probability of the record surviving after the first year after deposition
#' @param it: Initial time. Initial year of occupation in BP.
#' @return `numeric` with reduced values due to long-term taphonomic loss
#' @export
long_loss <- function(x, theta_l, it){
  t <- it+1950
  for (i in 1:ncol(x)){
    prob <- theta_l^(t-i)
    x[, i] <- rbinom(length(x[,i]), x[,i], prob)
  }
  return(x)
}
