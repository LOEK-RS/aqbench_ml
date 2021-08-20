

library(CAST,lib.loc="/home/m/mludwig2/R/")

library(parallel)
library(doParallel)
library(raster)
library(purrr)


raster::rasterOptions(tmpdir = "/scratch/tmp/mludwig2/temp")


model = readRDS("model_allvars_randomcv.RDS")

cov = stack("/scratch/tmp/mludwig2/aqbench/predictors.grd")


rfPrediction = raster::predict(cov, model)
writeRaster(rfPrediction, "/scratch/tmp/mludwig2/aqbench/allvars_randomcv_prediction.grd")

rm(rfPrediction)
gc()

cl <- makeCluster(20)
registerDoParallel(cl)
rfAOA = CAST::aoa(newdata = cov, model = model, cl = cl)
stopCluster(cl)

writeRaster(rfAOA, "/scratch/tmp/mludwig2/aqbench/allvars_randomcv_aoa.grd")