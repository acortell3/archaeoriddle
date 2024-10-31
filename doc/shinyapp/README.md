Some data are extracted frmo the bookdown
```bash
ln -s ../bookdown/data_original/east_narnia4x.tif .
ln -s ../bookdown/data_original/coastline2.shp .
ln -s ../bookdown/data_original/ressources.tiff resources.tiff
```


to run this app:
```bash
Rscript  -e  "shiny::runApp('.',port=1234)"
```

To deploy that as a shiny app directory one will need to move a few files around and split app.R in different files ui.R, server.R and global.R
