################################################################################
####### ARCHAEORIDDLE FIGURE 2
################################################################################

### An example of record generation and taphonomic loss

### Because this is a general explanation, we simulate a population, and its 
### generated record from scratch

### We consider three phases:
# 1. Phase with average population
# 2. Phase with population decline
# 3. Phase with population increase

## For each phase, the different parameters of the model change. See code below
## and bookdown for more information

## Create a function to quickly simulate this population (this function does not
## currently belong to the package, but it can be used freely)

#' @title Popsim
#' Generates a number of inhabitants per year. It can simulate complex population
#' dynamics using the parameter legs.
#' @param init: Integer. initial population
#' @param K: Integer. Carrying capacity. Provided by the user
#' @param g: Double. Population growth parameter
#' @param t: Integer. Length of the process (in years)
#' @param legs: If this is provided, K, g and t become vectors with length = number
#' of legs provided. In this case, K and g are specific for each leg and t marks
#' the end of each leg. Unless legs = NULL, the length(K) & length(g) & length(t) 
#' == legs is necessary.
#' @param smoothing: Double. A vector with length length(legs) - 1 (one 
#' transition for each leg). It smooths the demographic transitions between
#' different lengths. Lower values for a smoother transition. The effect is more
#' noticeable within the range [0,1] but there is no limit to the upper range.
#' Default is NULL
#' @export

Popsim <- function(init,K,g,t,legs=NULL,smoothing=NULL){
  
  if (is.null(legs)){ ## If there no population dynamics
    
    pop <- rep(0,sum(t))
    pop[1] <- init
    
    for (i in 1:sum(t)){
      dPopdt <- g*pop[i]*(1-(pop[i]/K))
      pop[i+1] <- pop[i]+dPopdt
    }
  } else { ## For complex population dynamics
    
    ## Stop if the lengths of K, g or t ar not == legs
    if(length(K) != legs | length(g) != legs | length(t) != legs){
      stop('K, g and t must have length == legs, unless legs == NULL')
    }
    
    ## Build different vectors for the length of the occupation of the site
    Klegs <- c() ## Create empty vectors to append combined values
    glegs <- c() ## Create empty vectors to append combined values
    
    for (i in 1:length(t)){
      Klegs <- append(Klegs,rep(K[i],t[i]))
      glegs <- append(glegs,rep(g[i],t[i]))
    }
    
    ## Define the smooth sections
    if (is.null(smoothing) == FALSE){
      for (i in 2:length(K)){
        smt <- seq(K[i-1],K[i],ifelse(K[i-1]>K[i],-smoothing[i-1],smoothing[i-1]))
        Klegs[(sum(t[1:i-1])+1):(sum(t[1:i-1])+length(smt))] <- smt
      }
    }
    
    pop <- rep(0,sum(t))
    pop[1] <- init
    
    for (i in 1:sum(t)){
      dPopdt <- glegs[i]*pop[i]*(1-(pop[i]/Klegs[i]))
      pop[i+1] <- pop[i]+dPopdt
    }
  }
  
  pop <- pop[1:(length(pop)-1)] ## Drops last observation to substitute init
  return(pop)
}



set.seed(1)

## Build three occupation phases
time <- c(100,450,450) ## Length of each occupation phase
K <- c(70,20,120) ## Carrying capacity at each occupation phase 
g <- c(0.02,0.005,0.02) ## Population growth for each phase
sm <- c(1.5,0.3) ## Smoothness of each transition

## Population, according to the above
Pop <- Popsim(init=40,K=K,g=g,t=time, legs = length(time), smoothing = sm)

## Different consuming rates per phase
kcalpers <- c(rep(2,time[1]), rep(1.8,time[2]), rep(2,time[3]))
kcalmeat_eat <- c(rep(0.45,time[1]),rep(0.3,time[2]),rep(0.3,time[3]))
kcalmeat_prod <- c(rep(1.1,time[1]),rep(1.3, time[2]),rep(1.1,time[3]))
in_camp_eat <- c(rep(0.45,time[1]),rep(0.55,time[2]),rep(0.6,time[3]))
in_camp_stay <- c(rep(13,time[1]),rep(7,time[2]),rep(12,time[3]))
kg <- c(rep(0.07,sum(time)))

## Generate the archaeological waste
W <- rep(NA,sum(time))
for (i in 1:sum(time)){
  W[i] <- A_rates(x=Pop[i], kcalpers = kcalpers[i], kcalmeat_eat = kcalmeat_eat[i],  kcalmeat_prod = kcalmeat_prod[i], ## 1.1 is for deear and 1.3 is for rabbit, according to the database BEDCA (https://www.bedca.net/bdpub/) 
                  in_camp_eat = in_camp_eat[i], in_camp_stay = in_camp_stay[i], kg = kg[i])
}
## Assume equal deposition rates and bone thickness for simplicity
l <- Rec_c(W, ts = 1000, InitBP = 7500,  r = 0.2, max_bone_thickness = "m") 

## Apply archaeological loss
Sl <- apply(l, 2, short_loss, 0.5)
Ll <- long_loss(Sl,.9996,7500)  
rownames(Ll) <- rownames(l)
tLl <- t(Ll)

## Prepare graphic parameters
laymap <- matrix(c(1,2,3,3,3,3), ncol = 2, byrow = TRUE)
pals <- c(colorRampPalette(9,colors = c("#DEEBF7", "#C6DBEF"))(90), rep("tomato4",20), ## Blues 
          colorRampPalette(9,colors = c("#9ECAE1", "#4292C6"))(440),  ## Purples
          colorRampPalette(9,colors = c("#2171B5", "#08306B"))(450)) ## Greens

## Population
plotPop <- data.frame("Population" = Pop,
                      "Time" = seq(7500,6501,-1))

layout(laymap)
plot(x = plotPop$Time, y = plotPop$Population, type = "l", ylim = c(0,max(K)), xlim = c(7500,6501),
     ylab = "Population", xlab = "Time", main = "Population dynamics", bty = "n", yaxt = "n", xaxt = "n", lwd = 0)
axis(1,at = seq(7400,6600,-200), lwd = 0.3, col = "gray")
axis(2,at = seq(0,120,20), lwd=0.3, col = "gray")
grid(col = "azure", lty = 3, lwd = 0.6)
lines(x=c(7500-time[1],7500-time[1]),y=c(-10,Pop[time[1]]), lty = 2, lwd = 0.4, col = "lightcyan3")
lines(x=c(7500-(time[1]+time[2]),7500-(time[1]+time[2])),y=c(-10,Pop[time[1]+time[2]]), lty = 2, lwd = 0.4, col = "lightcyan3")
lines(x = plotPop$Time, y = plotPop$Population, col = "lightcyan4", lwd = 0.6)

## All sample
barplot(tLl, col = pals, xlab = "Depth", ylab = "nsamples", main = "Remaining sample", 
        font.lab = 2, border = NA, space = 0, bty = "n", yaxt = "n", xaxt = "n")

## Build vector for x axis
max_dep <- as.numeric(substring(colnames(tLl)[1],1,nchar(colnames(tLl)[1])-2))
max_dep <- 200
dep <- seq(max_dep,0,-20)
for (i in 1:length(dep)){
  dep[i] <- paste(dep[i], "cm") 
}

axis(1,at = seq(1000,0,-100), labels = rev(dep), lwd=0.3, col = "gray")
axis(2,at = seq(0,1000,200), lwd=0.3, col = "gray")
lines(x=c(time[1],time[1]),y=c(0,sum(tLl[,time[1]])), lty = 3, lwd = 0.7, col = "gray28")
lines(x=c(time[1]+time[2],time[1]+time[2]),y=c(0,sum(tLl[,time[1]+time[2]])), lty = 3, lwd = 0.7, col = "gray28")

## After loss
barplot(tLl[c(90:110),c(90:110)], col = c(cividis(1),"tomato3",cividis(19)), xlab = "Depth", ylab = "nsamples", main = "Single date", 
        font.lab = 2, space = 0, border = NA, yaxt = "n", xaxt = "n")

## Build vector for x axis
dep <- seq(182.2,178.2,-0.4)
for (i in 1:length(dep)){
  dep[i] <- paste(dep[i], "cm") 
}

axis(1,at = seq(21,0,-2), labels = rev(dep), lwd=0.3, col = "gray")
axis(2,at = seq(0,1000,200), lwd=0.3, col = "gray")

