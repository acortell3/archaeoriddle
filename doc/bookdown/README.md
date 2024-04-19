This folder contains all the files and documents needed to compile the Archaeoriddle's bookdown. It also houses both the output and original files for the original Archaeoriddle's challenge.

To compile the bookdown in R, run the following code when you are inside this folder:

```R
bookdown::render_book(".", output_dir = "/var/www/html/archaeoriddle/")
```
