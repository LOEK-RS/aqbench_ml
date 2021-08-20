# prepare palma model ffs spatial cv


# model allvars spatial cv

source("src/00_setup.R")



cov = stack("data/covariates/predictors.grd")
aqb = st_read("data/trainingdata/AQ_bench_dataset_extraction.gpkg")


aqb = spampling::grid_folds(aqb)


# fold index for caret
index = spampling::fold2index(aqb)

predictors = names(cov)
ctrl = caret::trainControl(method = "cv", number = length(index$index),
                           index = index$index, indexOut = index$indexOut,
                           savePredictions = "final")

aqb = aqb %>% st_drop_geometry()

saveRDS(ctrl, "src/palma/ctrl.RDS")
saveRDS(aqb, "src/palma/aqb.RDS")
saveRDS(predictors, "src/palma/predictors.RDS")


