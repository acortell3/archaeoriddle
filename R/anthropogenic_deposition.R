## Function 5. Simulate anthropogenic deposition
#' @title Simulate anthropogenic deposition
#' @description
#' Simulation of samples generated per year (anthropogenic deposition rates)
#' Returns the Kilograms of bone produced per year in a site.
#' @param x Integer (user provided), vector or data.frame. If integer, it is the number of 
#' people inhabiting the site. If data.frame, the number of people is the number 
#' of rows. If vector, it is the length of the vector. It is Pop(t) in equation 3
#' @param kcalpers Quantity of kilocalories consumed per day per adult person.
#' It corresponds to B(t) in the equation 3. But in the formula it is per year.
#' Tt has a range of [1.5,2.5]. Default is 2.
#' @param kcalmeat_eat Proportion of kilocalories extracted from meat. Range [0,1].
#' Default is 0.45, based on Cordain et al (2000). It is M(t) in equation 3.
#' @param kcalmeat_prod Quantity of kiocalories per meat kilogram. Range [1,2.5]
#' Default is 1.5, considering goat meat. It is R(t) in euqation 3.
#' @param in_camp_eat Proportion of food consumed within the camp. Range [0,1]. 
#' Default is 0.55 based on Collette-Barbesque et al. (2016). S(t) in equation 3.
#' @param in_camp_stay Proportion of time spent in a specific camp. Valid for 
#' groups with high mobility. The proportion is computed within the function, but
#' the user introduces the weeks of occupation of the camp, where the maximum is
#' 52 (full year). Default is 13 (weeks, or 0.25 of the year, or three months a year).
#' It corresponds to O(t) in equation 3.
#' @param kg Bone proportion for each animal consumed. Default is 0.07
#' based on Johnston et al. (2021). It corresponds to F(t) in equation 3.
#' @return The number of samples
#' @export
A_rates <- function(x,
                    kcalpers = 2,
                    kcalmeat_eat = 0.45,
                    kcalmeat_prod = 1.5,
                    in_camp_eat = 0.55,
                    in_camp_stay = 13,
                    kg = 0.07){
  
  
  if (is.data.frame(x) == TRUE){
    P <- nrow(x)
  } else if (length(x) == 1){
    P <- x
  } else {
    P <- length(x)
  }
  
  # Check variable values are within the defined ranges
  if (1.5 <= kcalpers & kcalpers <= 2.5){
    B <- kcalpers*365
  } else {
    stop('kcalpers must be within [1.5, 2.5]')
  }
  
  if (0 <= kcalmeat_eat & kcalmeat_eat <= 1) {
    M <- kcalmeat_eat
  } else {
    stop('kcalmeat_eat must be within [0, 1]')
  }
  
  if (1 <= kcalmeat_prod & kcalmeat_prod < 2.5) {
    R <- kcalmeat_prod
  } else {
    stop('kcalmeat_prod must be within [1, 25]')
  }
  
  if (0 <= in_camp_eat & in_camp_eat <= 1){
    S <- in_camp_eat
  } else {
    stop('in_camp_eat must be within [0, 1]')
  }
  
  if (in_camp_stay <= 52){
    O <- round(in_camp_stay/52,2)
  } else {
    stop('A year cannot have more than 52 weeks')
  }
  
  C <- B*M
  G <- (C * S) / R ## Quantity (in kg) of animal consumed per person in camp during year t
  A <- P * O * kg * G ## kilograms of meat consumed within a camp by the group
  W <- round((1000 * A) / 4) ## samples extracted from that meat
  
  return(W)
}