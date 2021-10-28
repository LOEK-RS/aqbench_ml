
library(viridis)
global_sample = st_read("data/observations/global_sample.gpkg")
same_nodes = readRDS("explorer/rf_sample_influence_same_nodes.RDS")



global_sample$number_of_samples =  map_int(same_nodes, function(obs){
    return(nrow(obs))
})

plot(global_sample[,"number_of_samples"], pch = 16, pal = plasma)



aoa = readRDS("data/aoas/aoa_ffsnolat_juelichcv.RDS")

aoa_extract = raster::extract(aoa[[2]], global_sample, df = TRUE)
global_sample$AOA = aoa_extract$AOA




plot(global_sample[,"AOA"])


boxplot(global_sample$number_of_samples ~ global_sample$AOA)



