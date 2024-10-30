# The Archaeoriddle

If you don't know where to start, you may want to have a look at [thearchaeoriddle.com](https://thearchaeoriddle.org/)

## Preamble

The Archaeoriddle Project is a project that has been carried over almost 3 years, led by the [Computational and Digital Archaeology Lab](https://www.arch.cam.ac.uk/research/laboratories/cdal) at the McDonald Institute at the university of Cambridge. It has been made possible mainly thanks to a Small Grant from the British Library (BL/), but would not have been possible without the support of the Marie Slobodwska-Curie (H2020-MSCA-IF No. 101020631/ArchBiMod), and the ENCOUNTER project.

This repository gather together all the elements developed throughout this project; which can be divided in three main components that are all detailed later in this file.

1. [The Bookdown](?tab=readme-ov-file#the-bookdown) : compiled online version [here](www.thearchaeoriddle.com). It's a standalone document detailngs every aspect of the project, allowing they reproduction and modification (:file_folder: [./doc/bookdown/](./doc/bookdown/)).
2. [The Original Challenge](?tab=readme-ov-file#the-original-challenge) one instance of archaeoriddle's simulation, including the website, and 5 participants contribution (:file_folder: [./doc/shinyapp/](./doc/shinyapp/) & [./doc/bookdown/data_original/](./doc/bookdown/data_original/)).
2. [The R package](?tab=readme-ov-file#the-r-package) : contains all the above and the underlying R-functions, tests and associated documentation (:file_folder: [./](./))


*Note:* The version v0.1 of this repository is the version that has been shared with reviewers during the revision process of the paper "ASSESSING THE INFERENTIAL POWER OF QUANTITATIVE METHODS IN ARCHAEOLOGY VIA SIMULATED DATASETS: THE ARCHAEORIDDLE CHALLENGE", written by:
Cortell-Nicolau, A.1, Carrignon, S.1, Rodíguez-Palomo, I.1, Hromada, D.2, Kahlenberg, R.3, Mes, A.1, Priss, D.4, Yaworsky, P.5,6,7, Zhang, X.8, Brainerd, L.1, Lewis, J.1, Redhouse, D.1, Simmons, C.1, Coto-Sarmiento, M.9, Daems, D.10, Deb, A.11, Lawrence D.2, O’Brien, M.12, Riede, F.5,6, Rubio-Campillo, X.9, Crema, E1.
This version includes the modifications asked by the reviewers and is the one archived on zenodo with the DOI: . 


## General Description

This repository has the structure of an R package and can be seen as is. This aallow each sub-component of the Archaeoriddle to easily use and call function and datashare among the different part of the project. It also greatly simplify the use of the different functions used throughout the bookdown, for anywa who would like to play and recreate its own archaeoriddle.


## The Bookdown {#bd}

The bookdown is available online at: [www.thearchaeoriddle.org](https://www.thearchaeoriddle.org). It is associated with a [forum](https://www.thearchaeoriddle.org/forum) to allow anyone interested to discuss about the probject, problems encountered, and inferances in archaeology in general to interact.

The source for the bookdown are store in `doc/bookdown/`.
This folder contains all the files and documents needed to compile the Archaeoriddle's bookdown. It also houses both the output and original files for the original Archaeoriddle's challenge.

To compile the bookdown in R, run the following code when you are inside this folder:

```R
bookdown::render_book(".", output_dir = "/var/www/html/archaeoriddle/")
```


## The Original Challenge 

The Original Challenge correspond to a specific instance of the archaeoriddle, call 'Rabbithole'. This includes : a landscape, an 'ecological map', a set of parameters that have been used to carry set of simulations among which  _one_ has been chosen. The output of the simulation has been used to generate a serie of data sets publicly shared with archaeologist.

Then you can start the server using:

Files & folder used for this:

- [:file_folder: doc/shinyapp/]() : the code of  shiny app (the one behind the site available [here](https://theia.arch.cam.ac.uk/archaeoriddle))
- [📄 doc/shinyapp/README.md]() : README explaininghow to recreate the shiny app
- [:file_folder: ./doc/fake_papers/README.md]() :  latex code for sever fake papers and poster presented in conferences where the Original Challenge was presented.

```bash
Rscript  -e  "shiny::runApp('.',port=1234)"
```


## The R-Package 

This overal structure of this repository is a R package. 
To install it, the most simple way will be by using `devtools` function `github_install()` by doing: `devtools::install_github("acortell3/archaeoriddle")`.
Most of the functions defined in the package are described in details in [the bookdown](https://www.thearchaeoriddle).

This will be used if you want to follow the  allows to easily use the function defined in  thus using `devtools::install_github("acortell3/archaeoriddle")` 




## Full file Structure:

- [:file_folder: doc/](./doc/./doc/):
- [:file_folder: div/](./div/./div/):
- [:file_folder: man/](./man/./man/):
- [:file_folder: R/](./R/.R/):
- [📄 DESCRIPTION](./DESCRIPTION):
- [📄 archaeoriddle.Rproj](./archaeoriddle.Rproj):
- [📄 NAMESPACE](./NAMESPACE):
- [📄 README.md](./README.md):


### `doc/`

- [:file_folder: doc/bookdown/](./doc/bookdown/): cf section [The Bookdown](?tab=readme-ov-file#the-bookdown)
- [:file_folder: doc/shinyapp/](./doc/shinyapp/): cf section [The Bookdown](?tab=readme-ov-file#the-original-challenge)
- [:file_folder: doc/tex_files/](./doc/tex_files//): a few `tex` file used to layout ideas
- [📄 brain_map_colabm.png](./doc/brain_map_colabm.png) : image representing an early reflection about the project
- [📄 Explanation_of_ideas_brain_map.md](./doc/Explanation_of_ideas_brain_map.md): Markdown file detailing programming languages, world options, and more.
- [📄 interactive_brain_map.md](./doc/interactive_brain_map.md): Markdown guide for using Markmap visualization; contains programming language options and more.
- [📄 pop_id.Rmd](./doc/pop_id.Rmd): R Markdown file about population ideas and environmental qualities for hunting/farming.

### `man/`
- [📄 A_rates.Rd]

### `R/`

- [📄 anthropogenic_deposition.R](./R/anthropogenic_deposition.R): Simulates anthropogenic bone deposition rates at a site.
- [📄 climate.R](./R/climate.R): Generates power law noise and simulates environmental fluctuations.
- [📄 init_simulation.R](./R/init_simulation.R): Initializes carrying capacities, population matrices, and site lists for simulations.
- [📄 logistic_decay.R](./R/logistic_decay.R): Applies logistic decay to resources around points in a raster.
- [📄 natural_deposition.R](./R/natural_deposition.R): Models deposition and post-deposition effects of archaeological materials.
- [📄 perlin_noise.R](./R/perlin_noise.R): Creates Perlin noise for 2-D slope and elevation autocorrelation.
- [📄 population.R](./R/population.R): Manages stochastic population dynamics, growth, and mortality.
- [📄 record_loss.R](./R/record_loss.R): Simulates taphonomic losses in archaeological records.
- [📄 run_simulation.R](./R/run_simulation.R): Runs a simulation of cultural interactions, migration, and conflicts.
- [📄 tools.R](./R/tools.R): Utility functions for visualization, data extraction, and map plotting.


