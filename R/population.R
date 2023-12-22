## Function 1. Generation of population dynamics
#' @title Generation of population dynamics
#' @description
#' Protocol to generate a stochastic demographic process
#' @param x Input data with initial population matrix. A data frame or matrix
#' with two columns and `nrow` equal to the initial population. One row per individual.
#' The first column is the age of the individual.
#' The second column is the sex of the individual, and must be `c("F","M")`.
#' The columns must be named Age and Sex respectively.
#' @param K Carrying capacity.
#' @param W_fert_age Vector with two values. The first value is the youngest age
#' at which is considered that women can have children for prehistoric societies.
#'  The second value is the oldest age at which is considered that women can 
#'  have children. Default is `c(10,30)`.
#' @param M_fert_age Vector with two values. The first value is the youngest age
#' at which is considered that men can have children for prehistoric societies.
#' The second value is the oldest age at which is considered that men can have 
#' children. Default is `c(15,40)`
#' @param p_offspring Probability of a woman having a son per year. Default is 0.3.
#' @param prob Probability that an individual will die per year if total population
#' exceeds K. Default is 0.8
#' @param ... Arguments passed to [death()]. The mortality probability by age matrix. 
#' Their arguments can be added.
#' @return data.frame with two columns, where the number of rows is the number of
#' people. The first column contains the ages and the second column contains the sex.
#' @export
#'
Gpd <- function(x, K, W_fert_age = c(10, 45), M_fert_age = c(15, 55),
                p_offspring = 0.3, prob = 0.8, ...){
  
  ## Process of having offspring
  # Female fertile population
  W <- x[x[,2]=="F", ]
  W_fert <- W[W$Age > W_fert_age[1] & W$Age < W_fert_age[2], ]
  # Male fertile population
  M <- x[x[,2]=="M", ]
  M_fert <- M[M$Age > M_fert_age[1] & M$Age < M_fert_age[2], ]
  
  ## Probability of having descendance per woman
  # Penalisation in case there are too few men
  pen <- round(nrow(M_fert)*2 / nrow(W_fert), 2) # Assumes one man can have two women
  pen[pen>1] <- 1 ## The men penalisation can never multiply the birth rate per woman
  # Probability of a woman having a son per year
  p_offspring <- p_offspring*pen
  
  ## Aging process. They get one year older
  x$Age <- x$Age+1
  
  ## Births are new population that's added
  n_offspring <- sum(rbinom(nrow(W_fert), 1, p_offspring))
  new_pop <- data.frame(
    "Age" = rep(0, n_offspring),
    "Sex" = sample(c("M","F"), n_offspring, prob=c(0.5, 0.5), replace=TRUE))
  x <- rbind(x, new_pop)
  
  ## Process of dying
  vec_d <- apply(x, 1, death, ...)
  x <- x[vec_d==0, ]
  
  ## Apply carrying capacty restrictions
  x <- K_lim(x, K = K, prob = prob)
  
  return(x)
}


## Function 2. Simulation of death process
#' @title Simulation of death process
#' @description
#' For a single individual, returns whether it lives (0) or dies (1)
#' Meant to be used with apply on the population data.frame x
#' @param x A vector or data.frame with a single row from the population matrix.
#' It must contain two values or columns, Age and Sex
#' @param pd The probability matrix for mortality by age
#' The age-structured data frame is based on Gurven, Kaplan and Supa, 2007.
#' It is extracted adapted after computation from their text (not graphs or tables)
#' @return A value 0 or 1 where 0 = person lives and 1 = person dies, based
#' on pd (the probability matrix)
#' @export
death <- function(x, pd=data.frame("Age" = c(0:99),
                                   "P_d" = c(rep(0.14,1),
                                             rep(0.16,4),
                                             rep(0.05,5),
                                             rep(0.01,24),
                                             rep(0.03,14),
                                             rep(0.1,10),
                                             rep(0.3,42)))){
  age <- as.numeric(x[1])
  return(rbinom(1, 1, prob=pd[pd$Age==age, 2]))
}

## Function 3. Simulation of carrying capacity limitation
#' @title Simulation of carrying capacity limitation
#' @description
#' If the population exceeds the carrying capacity, it eliminates oversize
#' with prob probability per person exceeding.
#' @param x Data frame or matrix. Population (number of people)
#' @param K Integer. Carrying capacity. Provided by the user
#' @param prob It is the probability of dying when surpassing carrying capacity
#' @return Returns a data.frame with the updated population
#' @export
K_lim <- function(x, K, prob=0.8){
  p <- nrow(x)
  if (p>K){
    o <- rbinom(p-K, 1, prob)
    o <- sum(o[o==1])
    o[o==0] <- 1 # Avoids problem eliminating all the df if remove == 0
    x <- x[-sample(1:nrow(x), o, replace=FALSE), ]
  }
  return(x)
}


## Function 4. Stochastic population generation
#' @title Stochastic population generation
#' @description
#' It reproduces the population stochastic process. The result is a vector with the 
#' number of individuals for each year.
#' @param pop_size Integer, the initial population
#' @param K Only if model_pop = TRUE. In this case, it is the carrying capacity
#' @param ts Time-span, the number of years considered for the process
#' @param prob Probability that an individual will die if total population
#' exceeds K. Default is 0.8
#' @param ... Additional arguments passed to [Gpd()], and in turn to [death()]
#' @return A vector with the population size for each year from 1 to ts
#' @export
Pop_stoch <- function(pop_size, K, ts, prob = 0.8, ...){
  
  ## Create initial population
  pop_matrix <- data.frame(
    "Age" = sample(10:30, pop_size, 10:30, replace = TRUE),
    "Sex" = sample(c("M","F"), pop_size, prob = c(0.5,0.5), replace = TRUE)
  )
  
  ## Initialize vector with population size for each year  
  pop <- vector(length=ts)
  pop[0] <- nrow(pop_matrix)
  ## Run stochastic process  
  for (i in 1:ts){
    pop_matrix <- Gpd(pop_matrix, K=K, prob=prob, ...)
    pop[i] <- nrow(pop_matrix)
  }
  
  return(pop)
}

