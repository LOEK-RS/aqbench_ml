# model allvars spatial cv

library(raster)
library(sf)
library(tidyverse)
library(spampling)
library(caret)



cov = stack("data/covariates/gridded_metadata.grd")
aqb = st_read("data/AQ_bench_dataset.gpkg")


aqb = spampling::grid_folds(aqb)


# fold index for caret
index = spampling::fold2index(aqb)

predictors = names(cov)



ctrl = caret::trainControl(method = "cv", index = index$index, indexOut = index$indexOut)

aqb = aqb %>% st_drop_geometry()

rfmodel = caret::train(x = aqb %>% select(all_of(predictors)),
                       y = aqb$o3_average_values,
                       method = "ranger",
                       tuneLength = 5,
                       trControl = ctrl,
                       importance = "impurity")

saveRDS(rfmodel, "data/models/model_allvars_spatialcv.RDS")


