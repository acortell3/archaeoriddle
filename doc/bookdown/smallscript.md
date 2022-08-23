to generate multiple experiment in parallel
```
for t in {1..5} ; do Rscript scriptmini.R newset_$t > log_new_set$t 2> log_new_set$t.err &  done
```



to produce video for gruop of output: 
```
for i in test*_? ; do ffmpeg -i "$i/map_000%3d.png" "${i}_out.mp4" ; done
```
