col_ramp <- colorRampPalette(c("#54843f", "grey", "white"))

### Population protocol

## Function 1. Generation of population dynamics
#' @title Gpd
#' Returns a data.frame with two columns, where the number of rows is the number of
#' people. The first column contains the ages and the second column contains the sex.
#' @param x: Input data. A data frame or matrix with two columns and nrow = Initial
#' population. One row per individual. The first column is the age of the individual.
#' The second column is the sex of the individual, and must be c("F","M").
#' @param W_fer_age: Vector with two values. The first value is the youngest age
#' at which is considered that women can have children for prehistoric societies.
#'  The second value is the oldest age at which is considered that women can 
#'  have children. Default is c(10,30).
#' @param M_fer_age: Vector with two values. The first value is the youngest age
#' at which is considered that men can have children for prehistoric societies.
#' The second value is the oldest age at which is considered that men can have 
#' children. Default is c(15,40)
#' @param  P_o: Probability of a woman having a son per year. Default is 0.3.
#' @param prob: Probability that an individual will die if total population
#' exceeds K. Default is 0.8
#' @param K: Carrying capacity.
#' @param ...: This function uses the embedded function death(). 
#' Their arguments can be added.
#' @export

Gpd <- function(x, W_fer_age = c(10,45), M_fer_age = c(15,55),
                P_o = 0.3, prob = 0.8, K, ...){
  
  ### Process of having offspring
  
  # Female fertile population
  W <- x[x[,2]=="F",]
  W_fert <- W[W$Age>W_fer_age[1] & W$Age<W_fer_age[2],]
  
  # Male fertile population
  M <- x[x[,2]=="M",]
  M_fert <- M[M$Age>M_fer_age[1] & M$Age<M_fer_age[2],]
  
  ## Probability of having descendance per woman
  # Penalisation in case there are too few men
  pen <- round(nrow(M_fert)*2/nrow(W_fert),2) ## Assumes one man can have two women
  pen[pen>1] <- 1 ## The men penalisation can never multiply the birth rate per woman
  
  ## Probability of a woman having a son per year
  P_o <- P_o*pen
  
  Offspring <- sum(rbinom(nrow(W_fert),1,P_o))
  x$Age <- x$Age+1 ## They get one year older
  New_pop <- data.frame("Age" = rep(0,Offspring),                        
                        "Sex" = sample(c("M","F"),Offspring,prob=c(0.5,0.5),replace = TRUE))
  x <- rbind(x,New_pop)
  
  ### Process of dying
  
  vec_d <- apply(x,1,death,...)
  x <- x[vec_d==0,]
  
  ## Apply carrying capacty restrictions
  x <- K_lim(x, K = K, prob = prob)
  
  return(x)
}

## Function 2. Simulation of death process
#' @title death
#' Returns a value (0,1) where 0 = person lives and 1 = person dies, based
#' on pd (the probability matrix)
#' Thought to use with apply
#' @param x: An integer with the age of the person
#' @param pd: The probability matrix for mortality by age
#' @export

## The age-structured data frame is based on Gurven, Kaplan and Supa, 2007.
## It is extracted adapted after computation from their text (not graphs or tables)

death <- function(x,pd=data.frame("Age" = c(0:99),
                                  "P_d" = c(rep(0.14,1),
                                            rep(0.16,4),
                                            rep(0.05,5),
                                            rep(0.01,24),
                                            rep(0.03,14),
                                            rep(0.1,10),
                                            rep(0.3,42)))){
  age <- as.numeric(x[1])
  return(rbinom(1,1,prob = pd[pd$Age==age,2]))
}

## Function 3. Simulation of carrying capacity limitation
#' @title K_lim
#' If the population exceeds the carrying capacity, it eliminates oversize
#' with 0.8 probability per person exceeding.
#' @param x: Data frame or matrix. Population (number of people)
#' @param K: Integer. Carrying capacity. Provided by the user
#' @param prob: It is the probability of dying when surpassing carrying capacity
#' @export

K_lim <- function(x,K,prob = 0.8){
  p <- nrow(x)
  if (p>K){
    o <- rbinom(p-K,1,prob)
    o <- sum(o[o==1])
    o[o==0] <- 1 ## Avoids problem eliminating all the df if remove == 0
    x <- x[-sample(1:nrow(x),o,replace = FALSE),]
  }
  return(x)
}


## Function 4. 
#' @title A_rates
#' Simulation of samples generated per year (anthropogenic deposition rates)
#' Returns the Kilograms of bone produced per year in a site.
#' @param x: Integer (user provided), vector or data.frame. It is the number of 
#' people inhabiting the site. If data.frame, the number of people is the number 
#' of rows. If vector, it is the length of the vector.
#' @param kcalpers: Quantity of kilocalories consumed per year per adult person.
#' For easier computation, it has a range of [1.5,2.5]. Defaul is 2
#' @param kcalmeat_eat: Proportion of kilocalories extracted from meat. Range [0,1].
#' Default is 0.45, based on Cordain et al (2000)
#' @param kcalmeat_prod: Quantity of kiocalories per meat kilogram. Range [1,2.5]
#' Default is 1.5, considering goat meat.
#' @param in_camp_eat: Proportion of food consumed within the camp. Range [0,1]. 
#' Default is 0.55 based on Collette-Barbesque et al. (2016).
#' @param in_camp_stay: Proportion of time spent in a specific camp. Valid for 
#' groups with high mobility. The proportion is computed within the function, but
#' the user introduces the weeks of occupation of the camp, where the maximum is
#' 52 (full year). Default is 13 (weeks, or 0.25 of the year).
#' three months a year.
#' @param kg: Bone proportion for each animal consumed. Default is 0.07 for now, 
#' based on Johnston et al. (2021), but perhaps I should change that. Review
#' @export

A_rates <- function(x,
                   kcalpers = 2,
                   kcalmeat_eat = 0.45,
                   kcalmeat_prod = 1.5,
                   in_camp_eat = 0.55,
                   in_camp_stay = 13,
                   kg = 0.07){
  
  if (in_camp_stay > 52) stop('A year cannot have more than 52 weeks')
  
  if (is.data.frame(x) == TRUE){
    P <- nrow(x)
  } else if (length(x) == 1){
    P <- x
  } else {
    P <- length(x)
  }
  
  B <- kcalpers*365
  M <- kcalmeat_eat
  R <- kcalmeat_prod
  S <- in_camp_eat
  O <- round(in_camp_stay/52,2)
  Kg <- kg

  C <- B*M
  
  G <- (C*S)/R ## Quantity (in kg) of animal consumed per person in camp during year t
  
  A <- P*O*Kg*G ## kilograms of meat consumed within a camp by the group
  W <- round((1000*A)/4) ## samples extracted from that meat
  
  return(W)
}


## Function 5. 
#' @title D_along
#' It distributes the samples produced in one specific year along the depth of the
#' site, without any kind of post-depositional alteration, and according to 
#' pre-established post-deposition rates. Returns a vector with the samples exponentially
#' distributed. The vector is as long as L/r and the error (Pb) is considered.
#' @param x: Integer (user provided), vector or data.frame. It is the number samples
#' produced at a specifi 't'.
#' @param r: Is the deposition rates. At this moment, values > than 0.5 are not accepted.
#' If values with two or more decimals are provided, the function will automatically round 
#' the value to one decimal.
#' @param Max_bone_thickness: Maximum thickness of bones within the assemblage. Four
#' values are possible: small ('s') = 2.5 cm; medium ('m') = 5 cm; large ('l') = 10 cm
#' and very large ('vl') = 20 cm. Default is 'm'.
#' @param Pb: Proportion of samples buried sample at tmax, considering error. Pb 
#' cannot be higher or equal to 1. Default is 0.9999, which stands for 99.99%.
#' @export

D_along <- function(x,r, Max_bone_thickness = "m", Pb = .9999){
  
  # Define W
  W <- x
  
  # Define parameter r
  r <- round(r,1)
  if(r>0.5) stop("values > 0.5 are not accepted for param 'r'")
  
  # Define parameter Max_bone_thickness (L)
  if (Max_bone_thickness == 's'){
    L <- 2.5
  } else if (Max_bone_thickness == 'm'){
    L <- 5
  } else if (Max_bone_thickness == 'l'){
    L <- 10
  } else if (Max_bone_thickness == 'vl'){
    L <- 20
  }
  
  # Constraints for parameter Pb
  if (Pb >= 1) stop("Pb must be lower than 1")
  
  # Define tmax
  tm <- L/r
  ss <- rep(0,round(tm)) ## Vector to distribute samples over
  
  # Estimate lambda
  l <- -log(1-Pb)/tm
  tl <- 0 # Year where the sample is deposited
  tu <- 1 # Year when it is covered
  
  for (i in 1:tm){
    Wb <- W*(1-exp(-l*(tu-tl))) ## Apply formula
    Wbprev <- W*(1-exp(-l*((tu-1)-tl))) ## To substract values previous to tu
    ss[i] <- round(Wb-Wbprev) ## Number of samples for each year
    tu <- tu + 1
  }
  
  return(ss)
}


## Function 6. 
#' @title Pop_stoch
#' It reproduces the population stochastic process. The result is a vector with the 
#' number of individuals for each year.
#' @param Pop: Integer with the initial population
#' @param K: Only if model_pop = TRUE. In this case, it is the carrying capacity
#' @param ts: Time-span, the number of years considered for the process
#' @param prob: Probability that an individual will die if total population
#' exceeds K. Default is 0.8
#' @param K: Carrying capacity.
#' @param ...: This function uses the functions Gpd(), and thus it also uses
#' death() and K_lim(). The additional arguments can be added.
#' @export

Pop_stoch <- function(Pop, K, prob = 0.8, ts, ...){
  
  ## Create initial population
  Ip <- Pop
  Ip <- data.frame("Age" = sample(10:30,Ip,10:30, replace = TRUE),
                   "Sex" = sample(c("M","F"), Ip, prob = c(0.5,0.5), replace = TRUE))
    
  pop <- c()
  
  ## Run stochastic process  
  for (i in 1:ts){
    pop[i] <- nrow(Gpd(Ip, K = K, prob = prob, ...))
    Ip <- Gpd(Ip, K = K, prob = prob, ...)
  }
  
  return(pop)
}

## Function 7. 
#' @title Rec_c
#' It spreads the different amount of samples accord different profundities
#' @param x: Vector with the number of samples per year
#' @param persqm: If TRUE, the total record is divided by the area of the site
#' (in square meters), so that the output belongs to each square meter. Default is
#' FALSE
#' @param area: Only if persqm = TRUE. In this case, the total area of the site 
#' must be provided
#' @param ts: Time-span, the number of years considered for the process
#' @param InitBP: Initial year considered for the process. In BP.
#' @param ...: This function uses the functions D_along(). The additional 
#' arguments can be added.
#' @export

Rec_c <- function(x, persqm = FALSE, area, ts, InitBP, ...){
  
  ## Whether sqm division must be included or not
  if (persqm == TRUE){
    x <- x/area
  }
  
  ## Spread dates along different depths
  matdim <- length(x)
  mat <- matrix(nrow=matdim,ncol=matdim)
  
  for (i in 1:matdim){
    new <- D_along(x[i], ...)
    st <- i-1
    pos <- c(rep(0,st),new)
    pos <- pos[1:matdim]
    mat[,i] <- pos
  }
  mat[is.na(mat)] <- 0
  
  ## Names for columns (each year)
  years <- seq(InitBP,InitBP-ts)
  nyears <- c()
  for (i in 1:matdim){
    nyears[i] <- paste0(years[i], " BP")
  }
  colnames(mat) <- nyears
  
  ## Names for rows (each depth)
  ## Extract arguments as a list
  Extract_param <- function(x, ...){ 
    extras <- list(...)
    return(list(extras=extras)) 
  }

  dr <- Extract_param(D_along, ...)
  dr <- dr$extras$r
  
  d <- rev(cumsum(rep(dr,nrow(mat)))) ## computes depths
  rownames(mat) <- paste0("d = ", d, " cm")

  return(mat)
}



## Function 8. Short term taphonomic loss
#' @title short_loss
#' Returns a data frame in the same form that the inserted data frame with 
#' reduced values for short-term taphonomic loss process
#' @param x: A vector with the amount of sample per depth. If used for many years, use
#' with apply function, where the rows of the data frame are the depths and the columns 
#' the years.
#' @param theta_s: Probability of the record surviving after the first year after deposition
#' @export

short_loss <- function(x,theta_s){
  res <- c()
  for (i in 1:length(x)){
    res[i] <- rbinom(1,x[i],theta_s)
  }
  return(res)
}

## Function 9. Long term taphonomic loss
#' @title long_loss
#' Returns a data frame in the same form that the inserted data frame with 
#' reduced values for short-term taphonomic loss process
#' @param x: A vector with the amount of sample per depth. If used for many years, use
#' with apply function, where the rows of the data frame are the depths and the columns 
#' the years.
#' @param theta_l: Probability of the record surviving after the first year after deposition
#' @param it: Initial time. Initial year of occupation in BP.
#' @export

long_loss <- function(x, theta_l, it){
  t <- it+1950
  
  for (i in 1:ncol(x)){
    prob <- theta_l^(t-i)
    s <- x[,i]
      for (k in 1:length(s)){
        s[k] <- rbinom(1,s[k],prob)
               
      }
    x[,i] <- s  
  }
  return(x)
}


#' @param pt a vector point around witch decvay is computed
#' @param rast a raster to compute distances
#' @param L sstarting point of decay
logisticdecay <- function(pt,rast,L=1,k=0.0001,x0=60000){
    ds=distance(rast,pt)
    (L-L/(1+exp(-k*(ds-x0))))
}

#' @param n number of individuals
#' @param ages initial ages
#' @param p_sex proportion of the different sex
#' return a dataframe with age and sex of every individual of the population
initpopstruc <- function(n=100,ages=10:30,p_sex=c(0.5,0.5)) data.frame("Age" = sample(ages,n,ages, replace = TRUE), "Sex" = sample(c("M","F"), n, prob = p_sex, replace = TRUE))   

#' @param list_sites a list of population for all initial sites of the simulation
#' @param ts length of simulation
initlistsites <- function(list_sites,ts=200){
    Nts=matrix(0,nrow=ts+1,ncol=length(list_sites))
    Nts[1,]=sapply(list_sites,nrow)
    Nts
}


#sample through an existing population
#This should be change by a funciton that allow to: sample the existing pop and kill some, swapp between two pop
#@param size size of moving/killed population
changePopSize <- function(loosingPop,winingPop=NULL,size,new=F,method="random",probs=dnorm,prob.option=list("sd"=10,"mean"=22)) {
    #print(dim(loosingPop))
    #if(!is.null(winingPop))
    #    print(dim(winingPop))
    #if(length(size)==0 || size==0)return(data.frame(Age=numeric(),Sex=character()))
    if(nrow(loosingPop)==0)kill=0
    else if(method=="random")kill=sample(x=1:nrow(loosingPop),size=size,prob=probs(loosingPop$Age,mean=prob.option$mean,sd=prob.option$sd))
    #print(paste("diff",nrow(popdistrib)-size,"new",size))
    if(!is.null(winingPop)){winingPop=rbind(winingPop,loosingPop[kill,])}
    loosingPop=loosingPop[-kill,]
    if(!is.null(winingPop))
        return(list(loosingPop,winingPop))
    else
        return(loosingPop)

}


#' @param Kbase baseline carrying capacity or different culturesj
#' @param sites raster with site and culture
#' @param ressources a raster type for fall sites
#' @param rate, adjust proba of big cities (lower the higher) 
initKs <- function(Kbase=c("HG"=30,"F"=120),sites,ressources,sizeexp=NULL,rate=.5){
    Ks=round(Kbase[sites$culture]+rnorm(length(sites),0,10))
    while(any(Ks<1)) Ks=round(Kbase[sites$culture]+rnorm(length(sites),0,10))
    #Ks[sites$culture=="F"]=Ks[sites$culture=="F"]*runif(sum(sites$culture=="F"),1,1)
    tmp=Ks*(1+extract(ressources,sites)[,2])
    if(!is.null(sizeexp))tmp[sites$culture==sizeexp]=Ks[sites$culture==sizeexp]*(1+rexp(sum(sites$culture==sizeexp),rate=rate)*extract(ressources,sites[sites$culture==sizeexp])[,2])
    tmp
}

plotMap <- function(height,water,maintitle=""){
        plot(height^1.9,col=col_ramp(50),legend=F,reset=F,main=maintitle )
        plot(water,col="lightblue",add=T,legend=F)
}


#' check who's touchin site i
#' @param i indice of the site checked
#' @param sites raster with site coordinates,  cultures and karying capacityes
#' @param homophily if true, return all sites that touch (even same culture)
#' @param Ne population size of all sites (could be remove if Ne was stored in the raster)
whotouch <- function(i,sites,homophily=F,buffersize=200,Ne){
     touch=st_intersects(st_make_valid(st_as_sf(buffer(sites[i],Ne[i]*buffersize))),st_make_valid(st_as_sf(buffer(sites,Ne*buffersize))))
    if(length(touch)>0){
        enemies=unlist(touch)
        if(homophily) enemies=enemies[enemies!=i]
        else enemies=enemies[sites$culture[enemies]!=sites$culture[i]]
    }
    else enemies=NA
    enemies
}

#' @tile simplefight
#' A function to compute lost during a fighting
#' return the updated population size of both settlements engaged in the fight
#' @param Ne list of population size for the fighting settlement
#' @param a indice of the first settlement
#' @param b indice of the second settlement
simplefight <- function(Ne,a,b){
    if(runif(1)<Ne[a]/(Ne[a]+Ne[b])){
        v=a
        l=b
    }
    else{
        v=b
        l=a
    }
    one=Ne
    Ne[v]=rbinom(n=1,prob=.9,size=Ne[v])
    Ne[l]=rbinom(n=1,prob=.4,size=Ne[l])
    print(paste("victory",v,"(",one[v],"-", Ne[v],") over",l,"(",one[l],"-",Ne[l],"), total of:",(one[v]-Ne[v])+(one[l]-Ne[l]),"people"))
    return(Ne)
}   

#' @tile fightbetterloss
#' A function to compute lost during a fighting
#' return the updated population size of both settlements engaged in the fight
#' @param Ne list of population size for the fighting settlement
#' @param a indice of the first settlement
#' @param b indice of the second settlement
fightbetterloss <- function(Ne,a,b){
    if(runif(1)<Ne[a]/(Ne[a]+Ne[b])){
        v=a
        l=b
    }
    else{
        v=b
        l=a
    }
    one=Ne
    Ne[v]=rbinom(n=1,prob=1-Ne[l]/(Ne[v] + Ne[l]),size=Ne[v])
    Ne[l]=rbinom(n=1,prob=1-Ne[v]/(Ne[v] + Ne[l]),size=Ne[l])
    print(paste0("victory ",v,"(",one[v],"-", Ne[v],") over ",l," (",one[l],"-",Ne[l],"), tot:",(one[v]-Ne[v])+(one[l]-Ne[l]),"losses"))
    return(Ne)
}   


##draw a war symbole where two clans are fighting
warpoints <- function(sites,a,b,Ne,buffersize=300,plot=T,sizewar=2){
    meetpoints=crop(buffer(sites[a],1+Ne[a]*buffersize),buffer(sites[b],1+Ne[b]*buffersize))
    if(length(meetpoints)>0){
    p=spatSample(meetpoints,1)
    if(plot & length(p)>0){
        plot(p,add=T,bg="red",pch="🔥",cex=sizewar,col=adjustcolor("yellow",.1))
        plot(p,add=T,bg="yellow",pch="⚔️",cex=sizewar)
    }
    p
}
else NULL
}


run_simulation <- function(cultures=NULL,
                           viable=viable,
                           sites=sites,
                           dem=height.ras,
                           ressources=ress,
                           water=height.wat,
                           foldervid="pathtofinal",
                           visu=F,visumin=TRUE,
                           ts=20000,#length of simulation in year
                           Kbase=c("HG"=35,"F"=120),#difference in K for the two cultures
                           cul_ext=c("HG"=7,"F"=6),#spatial penality to extent: lower, bigger penality
                           penal_cul=c("HG"=4,"F"=5),#penality of occupational area: low, other sites can cam close
                           prob_birth=c("HG"=0.3,"F"=0.5),#proba to give birth every year
                           prob_survive=c("HG"=0.8,"F"=0.6),#proba to die when pop > K
                           prob_split=c("HG"=.2,"F"=.6),#proba to create new settlement when Ne > K
                           minimals=c("HG"=.14,"F"=.20),#how big the group of migrant should be to create a new city vs migrate to a existing one 
                           bufferatack=400,#distance max around which settlement can fight
                           buffersettl=2000,#distance min around which settlement cannnot settle
                           Nts=NULL,
                           Ips=NULL,
                           prob_move=c("HG"=0.2,"F"=0.1) #proba to migrate to existing settlement when Ne > K
                           ){
    ## Run stochastic process  

    Ks=sites$Ks
    cultures=sites$culture
    if(is.null(Nts)){ 
        INs=round(runif(length(sites),.85,.95)*sites$Ks) #Population size at initialisation
        Ips <- lapply(INs,initpopstruc ) #initialise population structure for all sites
        Nts=initlistsites(Ips,ts=ts)
        frame=0
        mint=2
    }
    else{##should check and test howto start back a simulation
       mint=nrow(Nts) 
       frame=nrow(Nts) 
    }
    
    ### visualisation =====
    if(!dir.exists(foldervid))dir.create(foldervid)
    ###

    warcasualties=vector("integer",ts)

    for (i in 2:(ts+1)){
        countcult=table(sites$culture[Nts[i-1,]>0])
		if(any(countcult==0)) return(list(Nts=Nts,warcasualties=warcasualties,Ips=Ips,sites=sites))
        print(paste("year",i,"total",sum(sapply(Ips,nrow)),"with",length(sites),"sites (",paste0(paste(names(countcult),countcult,sep=":"),collapse=","),")"))
        if(visumin){
            ### visualisation =====
            frame=frame+1
            filename=sprintf("map_%06d.png", frame)
            png(file.path(foldervid,filename),width=800,height=800,pointsize=20)
            plotMap(dem,water,paste0("year ",i))
            ########
        }
        inactives=(Nts[i-1,]==0)
        for(s in sample(seq_along(sites)[!inactives])){

            if(visu){
                ### visualisation =====
                frame=frame+1
                filename=sprintf("map_%08d.png", frame)
                png(file.path(foldervid,filename),width=800,height=800,pointsize=20)
                plotMap(dem,water,paste0("year ",i))
                ########
            }

            city=NULL
            Ips[[s]] <- Gpd(Ips[[s]], K = Ks[[s]], P_o=prob_birth[sites$culture[s]],prob = prob_survive[sites$culture[s]] ) #compute new population for the sites
            newN=nrow(Ips[[s]]) #count population size

            if(newN>=(Ks[[s]])){ #if new population is more than carrying capacity: migration scenario
                migrants=newN-round(Ks[[s]]*0.9)
                ##Creation of new city
                new_site=NULL
                #if(sites$culture[s]=="F")print(paste("possib",migrants, (minimals[sites$culture[s]]*sites$Ks[s])))
                tmp=Nts[i-1,]
                tmp[Nts[i,]>0]=Nts[i,Nts[i,]>0]
                #tmp=tmp+sqrt(sites$Ks)
                havemoved=F

                if(migrants>= (minimals[sites$culture[s]]*sites$Ks[s]) & runif(1)<prob_split[sites$culture[s]] ){ #if supropulation > 10 people, 10% chance of creation of a new city

                    #print(paste("look for new spot for ",migrants, "from site",s,"culture",sites$culture[s]))
                    #mean of area of influence
                    infarea=(sqrt(tmp)+penal_cul[cultures])*buffersettl
                    buffersize=rnorm(length(infarea),infarea,infarea*.1)
                    buffersize[tmp==0]=0
                    territory=erase(viable,buffer(sites,buffersize))

                    if(length(territory)>0){
                        #print(paste("found new spot",migrants))

                        ##select a new site given its distance to the old one and the ressourcesource available in ressources
                        d2=logisticdecay(sites[s],dem,x=20000*cul_ext[sites$culture[s]])
                        w=(.7*d2+.3*ressources)/(.7*minmax(d2)[2] + .3*minmax(ressources)[2])
                        new_site=spatSample(x=mask(w*logisticdecay(sites[s],dem,k=0.00002,x=20000*cul_ext[sites$culture[s]]),territory),size=1,method="weights",xy=T)[1:2]
                        new_site=vect(new_site,geom=c("x","y"))

                        if(length(new_site)>0 & all(!is.na(crds(new_site)))){
                            ##add new site to site listes
                            ##initialise population struc of new site
                            #print(paste("total sites:",length(Ips)))
                            #print(paste("dim Nts:",dim(Nts)[2]))
                            #print(paste("site sf Nts:",length(sites)))

                            Ips[[length(Ips)+1]]=initpopstruc(n=migrants) #initialise a fake populaition, will be updated by real migrants later
                            new_site$culture=sites$culture[s]
                            new_site$Ks=round(initKs(Kbase,sites=new_site,ressources,sizeex="F",rate=.45))
                            print(paste0("new settlement (",sites$culture[s],") of K ",new_site$Ks, " and pop ",migrants))

                            sites=rbind(sites,new_site)

                            Ks[length(Ks)+1]=new_site$Ks
                            city=(length(Ips))
                            Nts=cbind(Nts,rep(0,ts+1))
                            Nts[i,city]=migrants
                            cultures=c(cultures,cultures[s])
                            #print(paste("new site sf Nts:",length(sites)))
                            #print(paste("new dim Nts:",dim(Nts)[2]))
                            #print(paste("new total sites:",length(Ips)))
                            havemoved=T
                        }
                    }
                }
                ## if no creation of new city happen, there is a certain probability that people will move
                if(length(new_site)==0 && runif(1)<prob_move[sites$culture[s]] ){

                    #getj
                    att=extract(ressources,sites)[,2]
                    space=sites$Ks-(Nts[i-1,]+migrants)
                    dis=extract(logisticdecay(sites[s],dem,k=0.00002,x=1),sites)[,2]
                    attractivity=att*space*dis
                    #attractivity=attractivity*(1+10*(sites$culture[s]==sites$culture)) #4 times more likely to go to similar culture
                    attractivity[s]=min(attractivity)-1
                    attractivity=exp(attractivity)/sum(exp(attractivity))
                    attractivity[Nts[i-1,]<10]=0 
                    attractivity[sites$culture!=sites$culture[s]]=0 
                    if(any(is.na(attractivity))){
                        print(attractivity)
                        attractivity[is.na(attractivity)]=0
                    }

                    city=sample(size=1,x=seq_along(sites),prob=attractivity)
                    Nts[i,city]=Nts[i-1,city]+migrants
                    print(paste(migrants,"migrant from",sites$culture[s],"to",sites$culture[city]))
                    havemoved=T
                }
                if(havemoved){

                    #print(paste("old spot",migrants," for ",nrow(Ips[[s]])))
                    #print(paste("old new spot",migrants," for ",nrow(Ips[[city]])))

                    #if(city>length(Ips))print(paste("problem, migrants:",migrants))
                    #print(paste("the other:",city))
                    Ips[c(s,city)]=changePopSize(loosingPop=Ips[[s]],winingPop=Ips[[city]],size=migrants)
                    newN=newN-migrants
                    #print(paste("loosing ",newN," vs ",nrow(Ips[[s]])))
                    #print(paste("wining ",newN," vs ",nrow(Ips[[city]])))
                }

            }
            Nts[i,s]=newN


            if(visu){
                ###visualisation=========
                sitescols=rep(1,length(sites))
                siteslwd=rep(1,length(sites))
                ii=NULL
                if(!is.null(city)){
                    sitescols[s]="yellow"
                    sitescols[city]="red"
                    siteslwd[s]=3
                    siteslwd[city]=3
                    ii=st_cast(st_combine(st_as_sf(sites[c(s,city)])),"LINESTRING")
                }
                if(!is.null(ii))plot(ii,add=T)
                tmp=Nts[i-1,]
                tmp[Nts[i,]>0]=Nts[i,Nts[i,]>0]
                plot(sites,cex=(as.integer(Nts[i,]>0)*0.3+Nts[i,]/200),pch=21,add=T,bg=rainbow(2,alpha=.6)[as.factor(sites$culture)],lwd=siteslwd,col=sitescols)
                dev.off()
                ###=======================
            }
        }
        if(visumin){
            plot(sites,cex=(as.integer(Nts[i,]>0)*0.3+Nts[i,]/200),pch=21,add=T,bg=rainbow(2,alpha=.6)[as.factor(sites$culture)])
        }
        potentialfighters=which(sites$culture=="F" & Nts[i,]>50)
        for(s in sample(x=potentialfighters,size=round(length(potentialfighters)*.1))){
            buff=bufferatack
            potentialvictims=which(sites$culture !=sites$culture[s] & Nts[i,]>0) 
            clash=whotouch(s,sites ,Ne=Nts[i,],buffersize=buff)
            if(length(clash)>0 && !is.na(clash)){
                if(length(clash)==1)attack=clash
                else attack=sample(clash,1)
                newns=fightbetterloss(Ne=Nts[i,],a=s,b=attack)
                casualties=sum(Nts[i,c(s,attack)]-newns[c(s,attack)])
                warcasualties[i]=casualties
                sizew=casualties^2/4000
                warpoints(sites,s,attack,Ne=Nts[i,],buffersize=buff,sizewar=sizew+.5)

                #effectively kill people in population (should be done taking into account age pyramid to be more realistic)
                Ips[[s]]=changePopSize(loosingPop=Ips[[s]],size=(Nts[i,s]-newns[s]))
                Ips[[attack]]=changePopSize(loosingPop=Ips[[attack]],size=(Nts[i,attack]-newns[attack]))
                Nts[i,]=newns
                print(paste0("fight : #", s," (",cultures[s],") left with ",Nts[i,s]," (bef:",Nts[i-1,s],") ind., attacked: #",attack," (",cultures[attack],") left with ",Nts[i,attack]," (bef:",Nts[i-1,attack],") ind., #death=",casualties))
            }
        }
        if(visumin)dev.off()
    }
    return(list(Nts=Nts,warcasualties=warcasualties,Ips=Ips,sites=sites))
}



