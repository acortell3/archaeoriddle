Some data are extracted frmo the bookdown
```bash
ln -s ../bookdown/east_narnia4x.tif .
ln -s ../bookdown/coastline2.shp .
ln -s ../bookdown/ressources.tiff resources.tiff
```


to run this app:
```bash
Rscript  -e  "shiny::runApp('.',port=1234)"
```