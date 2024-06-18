
## Function 17. Change population sizes
#' @title Change population sizes
#' @description It changes population sizes due to killing or swap between
#' a loosing and winning population
#' 
#' 
#' @param loosingPop data.frame of the population that's decreasing 
#' @param size Number of deaths or size of the population swap
#' @param winingPop data.frame of the population that's increasing
#' @param new Deprecated
#' @param method Currently only supports "random"
#' @param probs Density distribution function to calculate probabilities of individuals
#' to be sampled based on age
#' @param prob.option Options for probs functions (e.g. `mean` and `sd` for `dnorm`)
#'
#' @return Either the updated loosing population data.frame or a list with both
#' the winning and loosing populations
#' @export
#'
changePopSize <- function(loosingPop, size, winingPop=NULL, new=F,
                          method="random", probs=dnorm,
                          prob.option=list("sd"=10, "mean"=22)) {
  #print(dim(loosingPop))
  #if(!is.null(winingPop))
  #    print(dim(winingPop))
  #if(length(size)==0 || size==0)return(data.frame(Age=numeric(),Sex=character()))
  if(nrow(loosingPop)==0){
    kill <- 0
  }else if(method=="random"){
    kill <- tryCatch(
      sample(x=1:nrow(loosingPop), size=size,
             prob=probs(loosingPop$Age, mean=prob.option$mean, sd=prob.option$sd)),
      error=function(e){
        print(paste0("problem with population replacement for settlement of size:",
                     nrow(loosingPop), " need to loose ", size));0
        }
      )
  }
  #print(paste("diff",nrow(popdistrib)-size,"new",size))
  if(!is.null(winingPop)){
    winingPop <- rbind(winingPop, loosingPop[kill,])
  }
  loosingPop <- loosingPop[-kill,]
  if(!is.null(winingPop))
    return(list(loosingPop, winingPop))
  else
    return(loosingPop)
  
}


## Function 18. Check sites touching
#' @title Check sites touching
#' @description
#' Check who's touching a given site
#'
#' @param i Index of the site checked
#' @param sites Raster with site coordinates, cultures and carrying capacities
#' @param Ne population size of all sites
#' @param homophily if true, return all sites that touch (even same culture)
#' @param buffersize Buffer size around a given site to consider contacts.
#' It's a factor that multiplies the population size Ne 
#' 
#' @return Returns a raster with the sites that are touching site `i`
#' @importFrom sf st_intersects st_make_valid
#' @importFrom terra buffer
#' @export
whotouch <- function(i, sites, Ne, homophily=F, buffersize=200){
  touch <- st_intersects(
    st_make_valid(st_as_sf(buffer(sites[i], Ne[i] * buffersize))),
    st_make_valid(st_as_sf(buffer(sites, Ne * buffersize))))
  if( length(touch) > 0 ){
    enemies <- unlist(touch)
    if(homophily){
      enemies <- enemies[enemies != i]
    } else {
      enemies <- enemies[sites$culture[enemies] != sites$culture[i]]
    }
  } else {
    enemies <- NA
  }
  return(enemies)
}


## Function 19. Model a simple fight
#' @title Model a simple fight
#' @description 
#' A function to compute lost during a fighting.
#' The winner and looser are decided probabilistically from their relative size.
#' It then uses a binomial to model the loss of population sizes,
#' and assigns a probability of 0.9 for the winner and 0.4 for the looser.
#' @param Ne list of population sizes for the fighting settlement
#' @param a indice of the first settlement
#' @param b indice of the second settlement
#' 
#' @return Returns the updated population size of both settlements engaged in the fight
#' @export
simplefight <- function(Ne, a, b){
  if(runif(1) < Ne[a] / (Ne[a] + Ne[b])){
    v <- a
    l <- b
  }
  else{
    v <- b
    l <- a
  }
  # Keep the original pop sizes for reporting outcome
  one <- Ne
  # Update population sizes using a binomial
  Ne[v] <- rbinom(n=1, prob=0.9, size=Ne[v])
  Ne[l] <- rbinom(n=1, prob=0.4, size=Ne[l])
  print(
    paste("victory", v, "(", one[v], "-", Ne[v],") over", l, 
          "(",one[l],"-",Ne[l],"), total of: ", (one[v]-Ne[v]) + (one[l]-Ne[l]), "people"))
  return(Ne)
}   


## Function 20. Model fight with better probabilities
#' @title Model fight with better probabilities
#' @description
#' A function to compute lost during a fighting.
#' The winner and looser are decided probabilistically from their relative size.
#' It then uses a binomial to model the loss of population sizes,
#' with probability based on their relative sizes.
#' @param Ne list of population sizes for the fighting settlement
#' @param a indice of the first settlement
#' @param b indice of the second settlement
#' 
#' @return Returns the updated population size of both settlements engaged in the fight
#' @export
fightbetterloss <- function(Ne,a,b){
  if( runif(1) < Ne[a]/(Ne[a] + Ne[b]) ){
    v <- a
    l <- b
  }
  else{
    v <- b
    l <- a
  }
  one <- Ne
  Ne[v] <- rbinom(n=1, prob=1 - Ne[l]/(Ne[v] + Ne[l]), size=Ne[v])
  Ne[l] <- rbinom(n=1, prob=1 - Ne[v]/(Ne[v] + Ne[l]), size=Ne[l])
  print(paste0("victory ", v, "(", one[v], "-", Ne[v],") over ", l,
               " (", one[l], "-", Ne[l], "), tot: ", (one[v]-Ne[v]) + (one[l]-Ne[l]), "losses"))
  return(Ne)
}   


## Function 21. Draw a war symbol where two clans are fighting
#' @title Draw a war symbol where two clans are fighting
#' @description
#' Draws a war symbol in the sites raster at the point of intersection between
#' fighting clans
#' @param sites Raster with site coordinates, cultures and carrying capacities
#' @param a Index of first settlement
#' @param b Index of second settlement
#' @param Ne Population sizes list
#' @param buffersize buffer size around a given site to consider contacts.
#' It's a factor that multiplies the population size Ne 
#' @param plot Whether to make a plot or not
#' @param sizewar Size of the war symbol 
#' 
#' @return Raster of the intersection point between sites a and b, if any.
#' @importFrom terra buffer crop spatSample
#' @export
#'
warpoints <- function(sites, a, b, Ne, buffersize=300, plot=T, sizewar=2){
  meetpoints <- crop(
    buffer(sites[a], 1+Ne[a] * buffersize),
    buffer(sites[b], 1+Ne[b] * buffersize)
  )
  if( length(meetpoints)>0 ){
    p <- spatSample(meetpoints, 1)
    if(plot & length(p)>0){
      plot(p, add=T, bg="red", pch="🔥", cex=sizewar,
           col=adjustcolor("yellow", 0.1))
      plot(p, add=T, bg="yellow", pch="⚔️" ,cex=sizewar)
    }
    return(p)
  }
  else return(NULL)
}



## Function 22. Run simulation
#' @title Run simulation
#' @description
#' This function runs a stochastic simulation in which different cultures
#' positioned in sites in a raster interact, grow, die, fight, migrate,...
#' 
#' @param cultures Vector of cultures to be simulated. Default is `NULL`,
#' in which case it is taken from `sites`. Culture names must also be present in
#' as names in the named vectors with the simulation parameters for each culture.
#' @param viable Viable SpatVector of the territory
#' @param sites SpatVector of sites
#' @param dem Digital Elevation Model SpatRaster of the map
#' @param ressources SpatVector with resources position
#' @param water SpatRaster with water
#' @param foldervid If `visu=TRUE`, folder to save plots with simulation snaps
#' @param visu logical; whether to plot simulation snaps
#' @param visumin logical; whether to plot a minimal visualization of the simulation
#' @param ts Length of the simulation in years
#' @param Kbase Named vector with carrying capacities for the cultures
#' @param cul_ext Named vector. Spatial penalty to extent: lower, bigger penality
#' @param penal_cul Named vector. Penality of occupational area:
#' if low, other sites can come close
#' @param prob_birth Named vector. Probability of giving birth every year
#' @param prob_survive Named vector. Probability of dying when the pop size is greater than the
#' carrying capacity
#' @param prob_split Named vector. Probability of creating a new split settlement when the pop
#' size is greater than the carrying capacity
#' @param prob_move Probability of migrating to a existing settlement when Ne > K
#' @param minimals Named vector. How big, proportionally, the group of migrants
#' should be to create a new city vs migrate to a existing one.
#' @param bufferatack Maximum distance around which a settlement can fight
#' @param buffersettl Minimum distance around a site in which a new settlement cannnot settle
#' @param Nts Initiallized list of sites. Created with [initlistsites].
#' Default is `NULL`, in which case it's created inside the function from `sites`.
#' @param Ips Initial population structure. Created with [initpopstruc].
#' Default is `NULL`, in which case it's created inside the function from `sites`
#'
#' @return
#' A list with site data across the simulation period, population structures, war
#' casualties and updated sites positions.
#' @importFrom terra erase spatSample vect crds extract
#' @importFrom sf st_cast st_combine st_as_sf
#' @export
#'
run_simulation <- function(cultures=NULL,
                           viable=NULL,
                           sites=NULL,
                           dem=NULL,
                           ressources=NULL,
                           water=NULL,
                           foldervid="pathtofinal",
                           visu=FALSE,
                           visumin=TRUE,
                           ts=20000,
                           Kbase=c("HG"=35, "F"=120),
                           cul_ext=c("HG"=7, "F"=6),
                           penal_cul=c("HG"=4, "F"=5),
                           prob_birth=c("HG"=0.3, "F"=0.5),
                           prob_survive=c("HG"=0.8, "F"=0.6),
                           prob_split=c("HG"= .2, "F"=0.6),
                           prob_move=c("HG"=0.2, "F"=0.1),
                           minimals=c("HG"=.14, "F"=.20), 
                           bufferatack=400,
                           buffersettl=2000,
                           Nts=NULL,
                           Ips=NULL
){
  ## Run stochastic process  
  
  Ks <- sites$Ks
  cultures <- sites$culture
  if(is.null(Nts)){ 
    INs <- round(runif(length(sites), 0.85, 0.95) * sites$Ks) #Population size at initialisation
    Ips <- lapply(INs, initpopstruc) #initialise population structure for all sites
    Nts <- initlistsites(Ips, ts=ts)
    frame <- 0
    mint <- 2
  } else {##should check and test howto start back a simulation
    mint <- nrow(Nts) 
    frame <- nrow(Nts) 
  }
  
  ### visualisation =====
  if(!dir.exists(foldervid) & visu){
    dir.create(foldervid)
  }
  ###
  
  warcasualties <- vector("integer", ts)
  
  for (i in 2:(ts+1)){
    countcult <- table(sites$culture[Nts[i-1, ] > 0])
    if ( length(countcult) != 2 ) {
      return(
        list(Nts=Nts[,1:i], 
             warcasualties=warcasualties[1:i],
             Ips=Ips,
             sites=sites
        )
      )
    }
    print(
      paste("year", i, "total", sum(sapply(Ips,nrow)),
            "with", length(sites), "sites (", 
            paste0(paste(names(countcult), countcult, sep=":"), collapse=","), ")"))
    if (visumin){
      ### visualisation =====
      frame <- frame+1
      filename <- sprintf("map_%06d.png", frame)
      png(file.path(foldervid,filename), width=800, height=800, pointsize=20)
      plotMap(dem, water, paste0("year ",i))
      ########
    }
    inactives <- (Nts[i-1,]==0)
    for ( s in sample(seq_along(sites)[!inactives]) ){
      if ( visu ) {
        ### visualisation =====
        frame <- frame+1
        filename <- sprintf("map_%08d.png", frame)
        png(file.path(foldervid,filename), width=800, height=800, pointsize=20)
        plotMap(dem,water,paste0("year ", i))
        ########
      }
      
      city <- NULL
      Ips[[s]] <- Gpd( #compute new population for the sites
        Ips[[s]], K = Ks[[s]],
        p_offspring = prob_birth[sites$culture[s]],
        prob = prob_survive[sites$culture[s]]
      )
      newN <- nrow(Ips[[s]]) #count population size
      
      if(newN >= (Ks[[s]])){ #if new population is more than carrying capacity: migration scenario
        migrants <- newN - round(Ks[[s]]*0.9)
        ##Creation of new city
        new_site <- NULL
        #if(sites$culture[s]=="F")print(paste("possib",migrants, (minimals[sites$culture[s]]*sites$Ks[s])))
        tmp <- Nts[i-1,]
        tmp[Nts[i,] > 0] <- Nts[i, Nts[i,] > 0]
        #tmp=tmp+sqrt(sites$Ks)
        havemoved <- F
        
        if (migrants >= (minimals[sites$culture[s]]*sites$Ks[s]) & runif(1)<prob_split[sites$culture[s]] ){
          #if supopulation > 10 people, 10% chance of creation of a new city
          
          #print(paste("look for new spot for ",migrants, "from site",s,"culture",sites$culture[s]))
          #mean of area of influence
          infarea <- (sqrt(tmp)+penal_cul[cultures]) * buffersettl
          buffersize <- rnorm(length(infarea), infarea, infarea * 0.1)
          buffersize[tmp==0] <- 0.00001
          territory <- erase(viable, buffer(sites, buffersize))
          
          if( length(territory)>0 ){
            #print(paste("found new spot",migrants))
            
            ##select a new site given its distance to the old one and the ressourcesource available in ressources
            d2 <- logisticdecay(
              sites[s], dem, x=20000*cul_ext[sites$culture[s]]
            )
            w <- (0.7 * d2 + 0.3*ressources) / (0.7*minmax(d2)[2] + 0.3*minmax(ressources)[2])
            new_site <- spatSample(
              x=mask(
                w * logisticdecay(sites[s], dem, k=0.00002,
                                  x=20000*cul_ext[sites$culture[s]]),
                territory),
              size=1, method="weights", xy=T)[1:2]
            new_site <- vect(new_site, geom=c("x","y"))
            
            if ( length(new_site)>0 & all(!is.na(crds(new_site))) ){
              ##add new site to site listes
              ##initialise population struc of new site
              #print(paste("total sites:",length(Ips)))
              #print(paste("dim Nts:",dim(Nts)[2]))
              #print(paste("site sf Nts:",length(sites)))
              
              Ips[[length(Ips)+1]] <- initpopstruc(n=migrants) #initialise a fake populaition, will be updated by real migrants later
              new_site$culture <- sites$culture[s]
              new_site$Ks <- round(initKs(
                Kbase, sites=new_site, ressources,
                sizeex="F", rate=0.45))
              print(paste0("new settlement (", sites$culture[s], ") of K ",
                           new_site$Ks, " and pop ", migrants))
              
              sites <- rbind(sites, new_site)
              
              Ks[length(Ks)+1] <- new_site$Ks
              city <- length(Ips)
              Nts <- cbind(Nts, rep(0,ts+1))
              Nts[i, city] <- migrants
              cultures <- c(cultures, cultures[s])
              #print(paste("new site sf Nts:",length(sites)))
              #print(paste("new dim Nts:",dim(Nts)[2]))
              #print(paste("new total sites:",length(Ips)))
              havemoved <- T
            }
          }
        }
        ## if no creation of new city happen, there is a certain probability that people will move
        if( length(new_site)==0 && runif(1) < prob_move[sites$culture[s]] ){
          
          #getj
          att <- extract(ressources,sites)[,2]
          space <- sites$Ks - (Nts[i-1,] + migrants)
          dis <- extract(logisticdecay(sites[s], dem, k=0.00002, x=1), sites)[,2]
          attractivity <- att * space * dis
          #attractivity=attractivity*(1+10*(sites$culture[s]==sites$culture)) #4 times more likely to go to similar culture
          attractivity[s] <- min(attractivity)-1
          attractivity <- exp(attractivity)/sum(exp(attractivity))
          attractivity[Nts[i-1,]<10] <- 0 
          attractivity[sites$culture!=sites$culture[s]] <- 0 
          if(any(is.na(attractivity))){
            print(attractivity)
            attractivity[is.na(attractivity)] <- 0
          }
          
          city <- sample(size=1, x=seq_along(sites), prob=attractivity)
          Nts[i,city] <- Nts[i-1,city] + migrants
          print(paste(migrants, "migrant from", sites$culture[s],
                      "to", sites$culture[city]))
          havemoved <- T
        }
        if( havemoved ){
          
          #print(paste("old spot",migrants," for ",nrow(Ips[[s]])))
          #print(paste("old new spot",migrants," for ",nrow(Ips[[city]])))
          
          #if(city>length(Ips))print(paste("problem, migrants:",migrants))
          #print(paste("the other:",city))
          Ips[c(s,city)] <- changePopSize(
            loosingPop=Ips[[s]], winingPop=Ips[[city]], size=migrants
          )
          newN <- newN - migrants
          #print(paste("loosing ",newN," vs ",nrow(Ips[[s]])))
          #print(paste("wining ",newN," vs ",nrow(Ips[[city]])))
        }
        
      }
      Nts[i,s] <- newN
      
      if (visu){
        ###visualisation=========
        sitescols <- rep(1,length(sites))
        siteslwd <- rep(1,length(sites))
        ii=NULL
        if(!is.null(city)){
          sitescols[s] <- "yellow"
          sitescols[city] <- "red"
          siteslwd[s] <- 3
          siteslwd[city] <- 3
          ii <- st_cast(st_combine(st_as_sf(sites[c(s, city)])), "LINESTRING")
        }
        if (!is.null(ii)){
          plot(ii ,add=T)
        }
        tmp <- Nts[i-1,]
        tmp[Nts[i,]>0] <- Nts[i,Nts[i,]>0]
        plot(sites, cex=(as.integer(Nts[i,]>0) * 0.3 + Nts[i,]/200), 
             pch=21, add=T, bg=rainbow(2, alpha=0.6)[as.factor(sites$culture)],
             lwd=siteslwd, col=sitescols)
        dev.off()
        ###=======================
      }
    }
    if(visumin){
      plot(sites, cex=(as.integer(Nts[i,]>0) * 0.3 + Nts[i,]/200),
           pch=21, add=T, bg=rainbow(2, alpha=0.6)[as.factor(sites$culture)])
    }
    potentialfighters <- which(sites$culture=="F" & Nts[i,]>50)
    for (s in sample(x=potentialfighters, size=round(length(potentialfighters)*0.1))){
      buff <- bufferatack
      potentialvictims <- which(sites$culture !=sites$culture[s] & Nts[i,]>0) 
      clash <- whotouch(s, sites, Ne=Nts[i,], buffersize=buff)
      if(length(clash)>0 && !is.na(clash)){
        if(length(clash) == 1){
          attack <- clash
        } else {
          attack <- sample(clash, 1)
        }
        newns <- fightbetterloss(Ne=Nts[i,], a=s, b=attack)
        casualties <- sum(Nts[i, c(s,attack)] - newns[c(s,attack)])
        warcasualties[i] <- casualties
        sizew <- casualties^2/4000
        warpoints(sites, s, attack, Ne=Nts[i,],
                  buffersize=buff, sizewar=sizew+0.5)
        
        #effectively kill people in population (should be done taking into account age pyramid to be more realistic)
        Ips[[s]] <- changePopSize(loosingPop=Ips[[s]],
                                  size=(Nts[i,s] - newns[s]))
        Ips[[attack]] <- changePopSize(loosingPop=Ips[[attack]],
                                       size=(Nts[i, attack] - newns[attack]))
        Nts[i,] <- newns
        print(paste0("fight : #", s, " (",
                     cultures[s], ") left with ", Nts[i,s],
                     " (bef:", Nts[i-1,s], ") ind., attacked: #", attack, " (",
                     cultures[attack], ") left with ", Nts[i,attack],
                     " (bef:", Nts[i-1,attack],") ind., #death=",casualties))
      }
    }
    if(visumin){
      dev.off()
    }
  }
  return(list(Nts=Nts, warcasualties=warcasualties, Ips=Ips, sites=sites))
}
