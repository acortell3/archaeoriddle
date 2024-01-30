# The Archaeoriddle


Archaeoriddle is a package, a scientific endeavour, a concourse, a game, a teaching tools, a simulaiton,... bref, it's anything you want it to be!


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



## LEGACY STUFF
Some data are extracted from the bookdown
```bash
ln -s ../bookdown/east_narnia4x.tif .
ln -s ../bookdown/coastline2.shp .
ln -s ../bookdown/ressources.tiff resources.tiff
```

to run this app in the root folder, you first need to link files that are going to be used by shiny:

```bash
ln -s doc/shinyapp/app.R .
ln -s doc/shinyapp/grid.RDS .
ln -s doc/bookdown/fakedata/public/ .
ln -s doc/shinyapp/www/ .
```

Then you can start the server using:

```bash
Rscript  -e  "shiny::runApp('.',port=1234)"
```
