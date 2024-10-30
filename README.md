# The Archaeoriddle


## Preamble

The Archaeoriddle Project is a project that has been carried over almost 3 years, led by the [Computational and Digital Archaeology Lab](https://www.arch.cam.ac.uk/research/laboratories/cdal) at the McDonald Institute at the university of Cambridge. It has been made possible mainly thanks to a Small Grant from the British Library, but would not have been possible without the support of the Marie Slobodwska-Curie (H2020-MSCA-IF No. 101020631/ArchBiMod), and the ENCOUNTER project.


This repository gather together  the elements developed throughout this project ; which can be divided in three main components that are all detailed later in this file.

1. [The Bookdown](?tab=readme-ov-file#the-bookdown-bd) : compiled online version [here](www.thearchaeoriddle.com). It's a standalone document detailngs every aspect of the project, allowing they reproduction and modification (files in: [:file_folder: ./doc/bookdown/](./doc/bookdown/)).
2. [The Original Challenge](the-original-challenge) one instance of archaeoriddlś simulation, including the website, and 5 participants contribution (in fold: [:file_folder: ./doc/shinyapp/](./doc/shinyapp/) & [:file_folder: ./doc/bookdown/data_original/](./doc/bookdown/data_original/)).
2. [The R package](the-r-package) : contains all the above and the underlying R-functions, tests and associated documentation ([:file_folder: ./](./))


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

The Original Challenge correspond to a specific instance of the archaeoriddle, call 'Rabbithole'. This includes : a landscape, an 'ecological map', a set of parameters that have been used to carry set of simulations among which  _one_ has been chosen. The output of the simulation has been used to generate a serie of data sets publicly shared with archaeologist, in an attempt to :



## The R-Package 

This repository is meant to be installed as a package; thus using `devtools::install_github("acortell3/archaeoriddle")` (until we, maybe one day, make it to CRAN?)


The general structure of the repository is that of a normal R package, but it contains a few more things.

- `doc/`
- `pop_id.Rmd`
- `tex_files/`
- `interactive_brain_map.md`
- `Explanation_of_ideas_brain_map.md`
- `div/`
- `man/`
- `DESCRIPTION`
- `archaeoriddle.Rproj`
- `NAMESPACE`
- `R/`
- `README.md`

more specifically in `doc`:


## `doc`

Doc contains various things developed through [the archaeoriddle project](https://theia.arch.cam.ac.uk/archaeoriddle). The archaeordile project is a CDAL project funded by the European Commission (H2020-MSCA-IF No. 101020631/ArchBiMod) and the British Academy.

- `doc/bookdown/` : the code for a  bookdown describing the code and the methods behind the simulation used in the project
- `doc/shinyapp/` : the code of  shiny app (the one behind the site available [here](https://theia.arch.cam.ac.uk/archaeoriddle))
- `doc/fake_papers/` :  latex code for sever fake papers and poster presented in conferences


Then you can start the server using:

```bash
Rscript  -e  "shiny::runApp('.',port=1234)"
```

