Some data are extracted frmo the bookdown
```bash
ln -s ../bookdown/east_narnia4x.tif .
ln -s ../bookdown/coastline2.shp .
ln -s ../bookdown/ressources.tiff resources.tiff
```


to run this app in the root folder:
```bash
ln -s doc/shinyapp/grid.RDS .
ln -s doc/bookdown/fakedata/public/ .
ln -s doc/shinyapp/www/ .



Rscript  -e  "shiny::runApp('.',port=1234)"
```
