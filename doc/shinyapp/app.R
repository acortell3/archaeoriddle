## Load libraries
library(shiny)
library(shinythemes)
library(terra)
library(sf)
library(shinyjs)

## Sampling function
plotmap <- function(x,hl=NULL){ ## x is the map and y is the grid
  
  col_ramp <- colorRampPalette(c("#54843f", "grey", "white"))
  
  #grid <- st_make_grid(x, 0.5)
  grid <- readRDS("grid.RDS")
  plot(x^1.9,col=col_ramp(50),legend=F,reset=F,main="Rabbithole" )
  plot(grid, lwd = 0.5, add = TRUE)
  plot(coast_line, add = TRUE)
  plot(st_geometry(com_sites_sf), add = TRUE, col = "darkred", pch = 16)
  if(!is.null(hl) & length(hl)>0){
      hcl=rep("yellow",length(hl))
      hcl[hl  %in% c(66,30,14,45,65)]="red"
      plot(grid[hl], add = TRUE, col = adjustcolor(hcl,.6),lwd=2)
      hl_coord=sapply(grid[hl],st_centroid)
      text(t(hl_coord)[,1],t(hl_coord)[,2],hl)
  }

}

survey <- function(x = 5){
  selected <- locator(x)
  selected_spatial <- st_multipoint(x=cbind(selected$x,selected$y))
  good_cells <- as.data.frame(st_intersects(grid,selected_spatial))[,1]
  
  
  plot(grid[selected], add = TRUE, col = "blue")
  
  return(good_cells)
}

rabbithole_height <- rast("east_narnia4x.tif")
rabbithole_water <- rabbithole_height
rabbithole_water[rabbithole_water>mean(rabbithole_water[])]=NA
coast_line <- st_geometry(st_read("coastline2.shp"))
sq14 <- read.csv("public/square_14.csv")[,-1]
sq30 <- read.csv("public/square_30.csv")[,-1]
sq45 <- read.csv("public/square_45.csv")[,-1]
sq65 <- read.csv("public/square_65.csv")[,-1]
sq66 <- read.csv("public/square_66.csv")[,-1]

good_cells <- c()

#This is a quickfix to avoid the 'F' of farmer to be changed by FALSE"
sq14$economy <- rep("F",4)
sq45$economy <- "F"

com_sites <- rbind(sq14,sq30,sq45,sq65,sq66)
com_sites_sf <- st_as_sf(com_sites, coords = (c("lon","lat")))
env <- rast("resources.tiff")
#grid <- st_make_grid(rabbithole_height, 0.5)
grid <- readRDS("grid.RDS")



### WORKSHOP PROGRAMM
people_info <- data.frame (
						   name = c("Simon Carrignon", 
									"Deborah Priß & Raphael Kahlenberg", 
									"Alexes Mes",
									"Peter Michael Yaworsky" ,
									"Xuan Zhang",
									"Daniel Hromada",
									"Coffee Break",
									"Alfredo Cortell-Nicolau",
									"Round table, Future work & Publication"),
						   hour = c(
									"14:00",
									"14:20",
									"14:40",
									"15:00",
									"15:20",
									"15:40",
									"16:00",
									"16:30",
									"16:55"
									),
						   abstract = c(
										"Introduction to Archaeoriddle & a simple LLM solution.", 
										"An ABM approach to the Archaeoriddle.",
										"Quantile Regression and the Bayesian Framework to tackle regional variations in dispersal's tempo.",
										"A multimodal approach, from Logistic Regressions to Spatio-temporal Species Distribution Models.",
										"Using Point Process Modelling to detect cooperation cs competition.",
										"AI and dialectic.",
										"We all need a break, don't we?",
										"The final revelation, code and conclusions",
										"During the round table we invite people who haven't submitted proposal to discuss other approaches they think would have been interesting to explore. We will also gather ideas and opinions about the whole projects and propose to anyone interested to join us in writing a paper about modelling in archaeology and why and how we should keep such approaches as open and collaborative as possible."
						   )
)


################################################################################
#######################
################################################################################
###### SHINY APP ######
################################################################################
#######################
################################################################################


ui <- fluidPage(
  #shinythemes::themeSelector(),
  theme = shinytheme("slate"),
  tags$head(tags$style(HTML('.modal-header{background-color:#DD3553;text-align:center}'))),
  tags$head(tags$style(HTML('.modal-body{background-color:white;color:black}'))),
  tags$style(HTML(" .name { cursor: pointer; color: white; text-decoration: underline; } ")),
  tags$script(HTML(" $(document).ready(function() { $('.abstract').hide(); $('.name').click(function() { $(this).next('.abstract').toggle(); }); }); ")),
  titlePanel(title = div(HTML("<p style='font-family:Courier New'>Archaeo-riddle</p>"), img(src = "logo_cdal.png", height = 45, align = "right")),windowTitle = "Archaeo-riddle"),
  h4(HTML("<p style='font-family:Courier New'>Trying methods to improve archaeological inference</p>")),
  hr(),
  useShinyjs(),
  #withMathJax(),
  
  
  tabPanel("The Model",
           tabsetPanel(id="menu",
             tabPanel(HTML("<p style='font-family:Courier New'><b>What is archaeo-riddle?</b></p>"),
                      fluidRow(
                        column(width = 9,
                               helpText(HTML("<p style='font-family:Courier New'>Advances in archaeological practice have led to the development of a plethora of inferential techniques to reconstruct the human past. However, their ability to achieve their goals can never be properly estimated, as we will never have an absolute knowledge of what really happened in the past.</p>")),
                               helpText(HTML("<p style='font-family:Courier New'>Archaeo-riddle is a collaborative project developed to explore the current limits of such  methods. We simulated a virtual  world and its archaeological record, and ask you, the participants, to answer a series of questions about what happened. Just like in the real world, some questions will have a clear answer, while others may not. But in contrast to the real world, we actually know what happened, and can measure how accurate and  robust our inferential techniques are. All participants will have access to the same virtual dataset and contextual background (modulo a few user-driven choices). They will have the opportunity to answer a series of research questions with the method of their choice. The process generating the simulated dataset, i.e. what happened, will be revealed only at the very end. We believe this to be an opportunity to reflect and discuss archaeological theory and method. </p>")),
                               helpText(HTML("<p style='font-family:Courier New'>Which techniques work better than others? Why, and how much accuracy can they achieve? Do they converge to the same answer? Why does a particular statistical tool work? </p>")),
                               helpText(HTML("<p style='font-family:Courier New'>We are aware that the range of archaeological inquiries is too vast to be incorporated in a virtual-world setting. Thus, we have decided to narrow our focus on a particular phenomenon (transition to farming), and a particular kind of dataset (site locations with radiocarbon dates and a background environmental map). We believe this provides an opportunity to apply a wide range of techniques, from dispersal models to radiocarbon based demographic inference, from site location analyses to eco-cultural niche models and more. </p>"))),
                        column(width = 3,
                               img(src='Simon_EAA.JPG', height = 400))),
                      helpText(HTML("<p style='font-family:Courier New'>Our goal is not to make claims about the superiority of any method over another, but to create an opportunity for a collaborative reflection, in an entertaining and pressure-free environment (anonymous participation is also welcome). In doing this, we want to help the discipline in continuing the path already started towards a more robust theoretical and methodological framework.</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>If you are interested in participating, keep reading the next tabs!!</p>")),
                      helpText(HTML('<iframe width="560" height="315" src="https://www.youtube.com/embed/mlaqdo95FBY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><a rel="me" href="https://fediscience.org/@archaeoriddle">.</a>'), align = "center"),
                      helpText(HTML("<p style='font-family:Courier New'>This project is being carried out by the CDAL, from the University of Cambridge. The researchers involved are:</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Alfredo Cortell-Nicolau (<em>as Dr. Pants</em>)</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Simon Carrignon (<em>as speaker</em>)</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Leah Brainerd (<em>as hunter-gatherer (Rab)</em>)</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Charles B. Simmons (<em>as farmer (Pop)</em>)</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Joseph Lewis (<em>as Dr. Stones</em>)</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Enrico R. Crema (<em>as random unexpected walker</em>)</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>With the priceless collaboration of Jasmine Vieri and Chris Stevens</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>If you want to join us, drop us a line!! Alfredo and Simon's contact at the <b><em>'How to participate?'</em></b> tab!</p>"))),

             tabPanel(HTML("<p style='font-family:Courier New'><b>How to participate?</b></p>"),
                      tabsetPanel(
                        tabPanel(HTML("<p style='font-family:Courier New'><b>Rules</b></p>"),
                                 helpText(HTML("<p style='font-family:Courier New'>There are no specific requirements. All you need to do is to download the data, play around, and be willing to share your thoughts with the wider community!! However, we do provide some general guidance to streamline your experience: </p>")),
                                 helpText(HTML("<p style='font-family:Courier New'><b><em>Guidance</em></b></p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 20px'><u><em>1. Context:</em></u> 1. This is a simulated archaeological context. You can find some contextual information and what our virtual archaeologists currently know in the tab <b><em>'The story: what do we know?'</em></b></p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 20px'><u><em>2. Data:</em></u> The tab <b><em>'Data'</em></b> provides some additional information. This consists of:</p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 60px'><u><em>2.1. Core shared data:</em></u> Core shared data: This dataset is the same for everyone. It primarily consists of a raster map containing some information about the background environment, coordinates of the locations of the known sites, and radiocarbon dates.</p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 60px'><u><em>2.2. Additional data</em></u> Additional data: Each participant can carry out additional virtual site surveys to collect more information. You can select up to five grid squares from our map and obtain additional data from those locations. To keep the game fair, we ask participants (and research groups) not to make multiple requests and download datasets from more than five grid squares. While we will inspect each request, we ask participants to collaborate with us. This is not about winning, it is about learning!</p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 20px'><u><em>3. Objectives:</em></u> Once participants (and research groups) have their own data, they can use any kind of methodology or analysis that they want in order to answer the research questions proposed in the tab <b><em>'RQs'</em></b>. Participants can answer any number of RQs that they want to (even all of them!). In fact, they can also propose their own questions and are indeed encouraged to do so.</p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 20px'><u><em>4. Timing and contact:</em></u> The ‘experiment’ started officially on the 6th September 2022. After that, we are allowing approximately one year for the participants to play and develop their methods. During this year, we can be in touch as much as you want. We post new information and news (and videos!) periodically on twitter or mastodon, so you can follow us there to stay tuned!</p>"),tags$a("Mastodon",rel="me",href="https://fediscience.org/@archaeoriddle"),tags$a(img(src = "twitter_logo.png", height = 40), href = "http://twitter.com/archaeoriddle"),HTML("<p>In any case, if you need any additional information, or just want to discuss different aspects of the project, you can contact </p>"),tags$a("Alfredo",href="mailto:ac2320@cam.ac.uk", text = "Alfredo"),HTML("<p> or </p>"),tags$a("Simon",href="mailto:sc2297@cam.ac.uk", text = "Simon")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 20px'><u><em>5. Workshop:</em></u> We will organise a dedicated workshop in the next EAA Conference at Belfast (Aug-Sept 2023). In this workshop, we will show what actually happened and share and discuss all of the mehodological proposals made by the participants.</p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 20px'><u><em>6. Publication:</em></u> At the conclusion of the workshop, anyone willing to do so, will be invited to participate in a collaborative paper, where we will show (1) the actual process and the model used to create it, (2) the different contributions and approaches used by the participants and (3) a collaborative reflection of the overall experiment.</p>")),
                                 helpText(HTML("<p style='font-family:Courier New;text-indent: 20px'><u><em>7. Involvement:</em></u> Of course, the level of involvement that you wish to have is entirely up to you. From participating anonymously, not submitting your analyses and results, to even help us coordinate things. Just feel free to join and play in any way you like!</p>"))),
                        tabPanel(HTML("<p style='font-family:Courier New'><b>Workshop/grant sign up</b></p>"),
                                 fluidRow(
                                   column(width = 3,
                                     img(src='Leah_EAA.JPG', height = 400)),
                                   column(width = 9,
                                     helpText(HTML("<p style='font-family:Courier New'>Archaeoriddle is able to help participants wanting to give it a go. More particularly, we will give <b>£650</b> to the best proposals for the attendance at our workshop in the next EAA meeting in Belfast. These funds will be granted to the researcher presenting the proposal (in the case it is a research group, it will be this group deciding how to dispose of them). They will be given as a prize/single payment, and winners will decide how to use them (no accountability or reports for archaeoriddle are needed). It doesn't matter whether you have already signed up for the EAA or not. If you have not signed up, you can use these to pay fees/travel etc, but if you have, you can use them as a refund to you own expenses. The only thing we do ask is that winners <em>will</em> have to present their own methodological solution at the workshop held in Belfast.</p>")),
                                     helpText(HTML("<p style='font-family:Courier New'>Now, if you want to participate and opt in for the $$, please provide </p>"),tags$a("Alfredo",href="mailto:ac2320@cam.ac.uk", text = "Alfredo"),HTML("<p> or </p>"),tags$a("Simon",href="mailto:sc2297@cam.ac.uk", text = "Simon")),
                                     helpText(HTML("<p style='font-family:Courier New'>With a document containing the following information:</p>")),
                                     helpText(HTML("<p style='font-family:Courier New'> - Name and affiliation of authors involved</p>")),
                                     helpText(HTML("<p style='font-family:Courier New'> - Short abstract describing the general idea of the approach undertaken, specifying how the particular methods employed can answer the chosen research question(s) (max 200 words)</p>")),
                                     helpText(HTML("<p style='font-family:Courier New'> - Specific details on the methods employed/planned. Including methods, packages, algorithmic/mathematical description of the methods and script if relevant/available (max 200 words, not counting the script, if provided)</p>")),
                                     helpText(HTML("<p style='font-family:Courier New'> - Short explanation of the strategies used to select the additional tiles from this webpage (see <b>data</b>)</p>")),
                                     )),
                                 helpText(HTML("<p style='font-family:Courier New'>The deadline to send us your proposals will be <b>16th June</b>. This is the real, for sure, very final deadline. There will be no extensions (we mean it), so please, do make sure to <b> send your proposal on time!!</b></p>")),
                        helpText(HTML("<p style='font-family:Courier New'>Each participant will present their results as a communication in a workshop at the next European Association of Archaeologists (EAA) conference (Belfast, 30th August to 2nd September) and, if willing to do so, will take part on a common publication. (Please, note that <b>accepting the award implies the commitment to present your results at the workshop in the EAA)</b></p>")),))),
             tabPanel(HTML("<p style='font-family:Courier New'><b>The story: What do we <em>know</em>?</b></p>"),
                      helpText(HTML("<p style='font-family:Courier New'>We have a simulated land (see <b><em>data</em></b> for the map) called Rabbithole. We know from archaeological evidence that two distinct populations live in Rabbithole. One of them, the rabbit skinners, had a hunter-gatherer economy, while the other one, the poppy chewers, relied primarily on farming for their survival.</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>What archaeologists know about Rabbithole is that poppy chewers dispersed in this region and eventually led to the demise of the rabbit skinners culture. However, what they do not know is how exactly did this happen. Did the rabbit skinners promote the expansion of the poppy chewers by adopting their culture and subsistence economy? How was their growth rate compared to that of the poppy chewers? Did perhaps a conflict between the two populations led to the extinction and disappearance of the rabbit skinners?</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Unfortunately, the acidic soils of Rabbithole do not provide an optimal context for the preservation of human remains. To date, very few human remains of poppy chewers have been recovered,but their level of preservation does not allow us to extract their DNA. Interestingly, some of these remains show evidence of violence, but the lack of remains from rabbit skinners does not allow us to determine whether these are episodic signs of violence, or evidence of systematic warfare either within poppy chewers communities or between poppy chewers and rabbit skinners.</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>But, why don't you watch Pop and Rab show you a bit about their cultural transmission processes!?</p>"),),
                      helpText(HTML('<iframe width="560" height="315" src="https://www.youtube.com/embed/BPCymQvf1xs" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'), align = "center")),
             tabPanel(HTML("<p style='font-family:Courier New'><b>RQs</b></p>"),
                      helpText(HTML("<p style='font-family:Courier New'>Our main goal is to reconstruct the relationship between the rabbit skinners and the poppy chewers, and the process that led to the transition to a farming economy in Rabbithole. In order to achieve this primary objective, we propose the following research questions:</p>")),
                      helpText(HTML("<p style='font-family:Courier New'><b><em><u>RQ1.</u></em></b><em> What was the relationship between the two groups? Was it peaceful or hostile?</em></p>")),
                      helpText(HTML("<p style='font-family:Courier New'><b><em><u>RQ2.</u></em></b><em> What was the population trajectory of each group?</em></p>")),
                      helpText(HTML("<p style='font-family:Courier New'><b><em><u>RQ3.</u></em></b><em> What was the rate of dispersal of poppy chewers?</em></p>")),
                      helpText(HTML("<p style='font-family:Courier New'>You can try to answer one, two or all of them, or you can even propose questions of your own! The key is assessing how our methods work within a known environment!</p>"))),
             tabPanel(HTML("<p style='font-family:Courier New'><b>Data</b></p>"),
                      helpText(HTML("<p style='font-family:Courier New'>This is where you can actually get your data, and this is how it works:</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>The dots you can see in the map are the currently known sites; by clicking on ‘bibliographic data’ you can download all the data that we have at the moment and by clicking on 'Maps' you will download a zip which contains a map and the paleoenvironmental model developed by Dr. Stones and Dr. Pants (basically another map with fitness values). You may have to work out your data a little bit, but that's just real life, isn't it?? This information will be the same for every participant.</p>")),
                      helpText(HTML("<p style='font-family:Courier New'>However, you can also do your own surveys to complement your dataset! By clicking on the map you will see below the number of the patch you are surveying. You can select up to five more patches/grid squares for your own survey. Once you have decided which five additional patches you want to survey on, you can click on the survey button, which will open a google form. Fill it up with the required information and we will privately send the additional data to you. </p>")),
                      helpText(HTML("<p style='font-family:Courier New'>Once one user (e-mail) has required five patches, we won’t send another five, so think well which ones you want to ask for. We advise to play a little bit with the common data before asking any additional patches. If different users from the same university/research group require the additional data, we will require confirmation that you are not working on the project together.</p>")),
                      helpText(HTML("<p style='font-family:Courier New'><em><u>And we are on!!! Start downloading your data! But think well which additional patches you want,since you only have one shot!</em></u></p>")),
                      downloadButton('download',"Bibliographic data"),
                      downloadButton('download2',"Maps"),
                      actionButton("survey","Survey",onclick ="window.open('https://docs.google.com/forms/d/e/1FAIpQLSelI6Pukd76N2AujprbKVoCMw2T2tPapTITvEEEr0DZQqcK6g/viewform', '_blank')"),
                      fluidRow(
                        column(width = 5,
                               plotOutput("Map", click = "plot_click", hover = hoverOpts(id = "plot_hover"))),
                        column(width = 3,
                               helpText(HTML("<p style='font-family:Courier New'><u><em> Possible square(s) to survey:</u> </br>(click on the map to get their ID)</em></p>"),div(style="width:180px",verbatimTextOutput("info")),HTML("<p style='font-family:Courier New;font-size:9pt'><em>You'll need to copy paste these ID in your submission when you will click on \"Survey\".</em></p>"))),
                        column(width = 4,
                               helpText(HTML("<p style='font-family:Courier New'><u><em>Additional information</em></u></p>")),
                               helpText(HTML("<p style='font-family:Courier New'>Your data consists of:</p>")),
                               helpText(HTML("<p style='font-family:Courier New'>- One map with height values and another one with values with probabilities of settlement according to environmental fitness (these are common both for the rabbit skinners and the poppy chewers).</p>")),
                               helpText(HTML("<p style='font-family:Courier New'>- For every site:</p>")),
                               helpText(HTML("<p style='font-family:Courier New; text-indent: 20px'>- Site name</p>")),
                               helpText(HTML("<p style='font-family:Courier New; text-indent: 20px'>- Coordinates</p>")),
                               helpText(HTML("<p style='font-family:Courier New; text-indent: 20px'>- Radiocarbon dates</p>")),
                               helpText(HTML("<p style='font-family:Courier New; text-indent: 20px'>- Cultural affiliation of the site (is it a rabbit skinner site or a poppy chewer site)</p>")),
                               helpText(HTML("<p style='font-family:Courier New'>- It is assumed that there are no research biases in the collection of radiocarbon dates </p>"))))),
             tabPanel(HTML("<p style='font-family:Courier New'><b>News and comments</b></p>"),
                      fluidRow(
                        column(width = 3,
                               img(src='Joe_EAA.JPG', height = 400)),
                        column(width = 9,
                               helpText(HTML("<p style='font-family:Courier New; text-indent: 20px'>- Great news!! We are happy to announce that we can provide some help for participants to attend to our last workshop in the next EAA Conference (Belfast). Therefore, send us your proposal and we will select the ten best proposals (see <b> Workshop/grant sign up</b>), which will be granted <b>£650</b> to spend at their will at the next EAA conference! </p>")),                      
                               helpText(HTML("<p style='font-family:Courier New; text-indent: 20px'>- If you want to stay tuned, you can either drop us a line (you have the contacts in the <em><b>'How to participate?'</b></em> tab), keep checking this website, or follow us on twitter.</p>"), 
                                        tags$a(img(src = "twitter_logo.png", height = 40), href = "http://twitter.com/archaeoriddle"))))),
                       tabPanel(id="vs",value="ws",title=HTML("<p style='font-family:Courier New'><b>EAA Workshop</b></p>"),
                      fluidRow(
                        column(width = 1),
                        column(width = 3,
							   tags$br(), img(src='eaa_logo.jpg'), tags$br(), tags$br(), img(src='ba_logo.png',width="150px")
							   ),
                        column(width = 5,
                               strong(tags$h2(style='font-weight:900;color:white;font-family:Courier New'," The Archaeoriddle Workshop"),
									  tags$h3(style='font-family:Courier New',"Saturday 2nd September 2023, Lanyon Building, room G059")),                      
							   tags$br(),
                               helpText(HTML("<p style='font-family:Courier New;'> The Archaeoriddle Workshop. In this workshop the final results and the proposals from all participants will be presented.  All the code and methods use to generate the data will be unveiled. The workshop take place during <a href='https://www.e-a-a.org/EAA2023/'>EAA Belfast</a> on the Saturday Afternoon at Lanyon Building (G059). It will start at 14h00 and finish early enough to leave time to people to join the annual EAA dinner party .</p> </br>")),                      
                               helpText(HTML("<p style='font-family:Courier New;'> <b> Program:</b> </p>")),                      
                               tags$ul(
                                       lapply(1:nrow(people_info), function(i) {
                                                  tags$li( tags$span(class = 'name', people_info$name[i]), ' – ', people_info$hour[i], tags$div(class = 'abstract', people_info$abstract[i]))})),
                               helpText(tags$br(),
HTML('<p style="font-family:Courier New;">  Every participant of the workshop is invited  to join us on the day before for an Ice Breaker dinner at the <a href="https://www.holohanspantry.co.uk/">Holohans</a>.. If you plan on comming <b><a href="ac2320@cam.ac.uk"> write us </a></b></p>'),tags$br(), 
HTML(' <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2312.0136764801796!2d-5.94126240385261!3d54.586133102218994!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x486108f1c8439857%3A0x30b0e6f91e0da027!2sHolohan&#39;s%20Pantry!5e0!3m2!1sen!2suk!4v1692553480159!5m2!1sen!2suk" width="600" height="450" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe></p> ')),                      
                               )))
           )),
  
  
)


#''


server <- function(input, output,session) {

	good_cells <- c()
	## Plot map
	output$Map <- renderPlot({plotmap(rabbithole_height)},width = 500, height = 500)
	observe({
		query <- parseQueryString(session$clientData$url_search)
		if ("tab" %in% names(query)) {
			updateTabsetPanel(session, "menu", selected = query$tab)
		}
		utm_source <- query[['utm_source']]
		message(paste(Sys.time(),"connect from:",utm_source))
	})

	## Get name of cells for survey data
   observe({
                             x <- req(input$plot_click$x)
                             y <- req(input$plot_click$y)
                             selected_spatial <- st_multipoint(x=cbind(x,y))
                             tmp_cell <- as.data.frame(st_intersects(grid,selected_spatial))[,1]
                             if(tmp_cell %in% good_cells) good_cells <<- good_cells[good_cells != tmp_cell]
                             else{
                                 if(length(good_cells) == 5) showModal(modalDialog(title=HTML("uuuuuppss"),HTML("<p style=\"text-align:center\"> you can't select more than 5 square, sorry! </br> ¯\\_(ツ)_/¯</p>"),easyClose=TRUE,size="s",footer=NULL))
                                 else{
                                     if(tmp_cell %in% c(66,30,14,45,65))showModal(modalDialog(title="you sure???",paste("This square (#",tmp_cell,") is publicly available! you may not want to survey it..."),easyClose=TRUE,size="s",footer=NULL))
                                     good_cells <<- c(good_cells, tmp_cell)
                                 }
                             }
                             output$Map <- renderPlot({plotmap(rabbithole_height,good_cells)},width = 500, height = 500)
                             output$info <-renderText({
                                 trail=rep("",length(good_cells))
                                 trail[good_cells %in% c(66,30,14,45,65)]=" (public)"
                                 paste0("square #",good_cells, trail ,"\n")
                             })
                            })
  
  ## Download common data
  b_dat <- reactive(com_sites)
  output$download <- downloadHandler(
    filename = function(){"Biblio_data.csv"}, 
    content = function(fname){
      message(paste(Sys.time(),"download bibliodata"))
      write.csv(b_dat(), fname)
    }
  )
  
  output$download2 <- downloadHandler(
    filename = function(){"Maps.zip"}, 
    content = function(file){
      message(paste(Sys.time(),"download maps"))
      files <- c("east_narnia4x.tif","resources.tiff");
      zip(file,files)
    },
    contentType = "application/zip"
  )
  
}

shinyApp(ui = ui, server = server)



