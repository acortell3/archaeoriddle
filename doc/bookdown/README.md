The bookdown should have its own readmett

To compile the bookdown in R, when you are inside this folder 

```{r}
> bookdown::render_book(".",output_dir="/var/www/html/archaeoriddle/")
```

For this to work you will need to load the package ; as the bookdown uses the functions from the package.

To install the package you can uses

- `devtools::install_github("acortell3/archaeoriddle")` => this will install the package that you will then need to load using `library(archaeoriddle)`. 
- `install.packages(here::here() ,repos=NULL,type="source")` to install your locla, devlopment version
Note that in this case ; if you make any modification to the function in the package and want to compile the bookdown in a way that includes the modifications you will need to re-install the package with your new modificiation. And thus push the modifications to the git repository or change "acortell3/archaeoriddle" to your ow or to the local directory
- load the package using `devtools::load_all()`. This will reload anychange you have made to the package.

# TODO

all functions in the R scripts in this current folder need to be moved before to be part of a package? At least need to be cleaned and easily reused. The part of the bookdown that are describing thing that are not use (but to explain the ideas)  ned to be clarified. 

Ultimately, what the bookdown will be used for?
- check the archaeoriddle experience?
- do different simulation? 
- explore ABM/simulatin in general

question is: book do discribe the process : extended vignette
             tools to explore agent base modeling & archaeology: package?


