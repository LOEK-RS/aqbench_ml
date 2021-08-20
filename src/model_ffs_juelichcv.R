# model ffs juelich cv

source("src/00_setup.R")


cov = stack("data/covariates/predictors.grd")
aqb = st_read("data/trainingdata/AQ_bench_dataset_extraction.gpkg")
aqb$climatic_zone = as.factor(aqb$climatic_zone)

folds = read.csv("data/folds/general_datasplit.csv")

# attach fold information
aqb = left_join(aqb, folds) %>% st_drop_geometry()

# split in training and test
aqb_test = aqb %>% filter(set == "test")
aqb = aqb %>% filter(set != "test") %>% mutate(fold = as.numeric(set))


# fold index for caret
index = spampling::fold2index(aqb)

predictors = names(cov)



ctrl = caret::trainControl(method = "cv", number = 4,
                           index = index$index, indexOut = index$indexOut,
                           savePredictions = "final")

tg = expand.grid(mtry = 2,
                 splitrule = "variance",
                 min.node.size = 5)


ffsModel = CAST::ffs(predictors = aqb %>% dplyr::select(all_of(predictors)),
                     response = aqb$o3_average_values,
                     method = "ranger",
                     tuneGrid = tg,
                     num.trees = 200,
                     trControl = ctrl,
                     importance = "impurity")


saveRDS(ffsModel, "data/models/model_ffs_juelichcv.RDS")


p = raster::predict(cov, ffsModel)
writeRaster(p, "data/predictions/prediction_ffs_juelichcv.grd", overwrite = TRUE)


aqb_test$pred_o3_average_values = stats::predict(ffsModel, aqb_test)

saveRDS(aqb_test, "data/predictions/predtest_ffs_juelichcv.RDS")


