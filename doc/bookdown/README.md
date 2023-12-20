The bookdown should have its own readmett

To compile the bookdown in R, when you are inside this folder 

```{r}
> bookdown::render_book(".",output_dir="/var/www/html/archaeoriddle/")
```

# TODO

all functions in the R scripts in this current folder need to be moved before to be part of a package? At least need to be cleaned and easily reused. The part of the bookdown that are describing thing that are not use (but to explain the ideas)  ned to be clarified. 

Ultimately, what the bookdown will be used for?
- check the archaeoriddle experience?
- do different simulation? 
- explore ABM/simulatin in general

question is: book do discribe the process : extended vignette
             tools to explore agent base modeling & archaeology: package?


