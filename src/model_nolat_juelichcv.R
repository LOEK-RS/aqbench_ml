cov = raster::stack("data/covariates/predictors.grd")
aqb = st_read("data/observations/AQ_bench_dataset_extraction.gpkg")


folds = read.csv("data/folds/general_datasplit.csv")

# attach fold information
aqb = left_join(aqb, folds) %>% st_drop_geometry()

# split in training and test
aqb_test = aqb %>% dplyr::filter(set == "test")
aqb = aqb %>% dplyr::filter(set != "test") %>% mutate(fold = as.numeric(set))


# fold index for caret
index = spampling::fold2index(aqb)

predictors = names(cov)
predictors = predictors[c(-1,-2)]


ctrl = caret::trainControl(method = "cv", number = 4,
                           index = index$index, indexOut = index$indexOut,
                           savePredictions = "final")

tg = expand.grid(mtry = c(2,5,7,10,12,15),
                 splitrule = "variance",
                 min.node.size = 5)



rfmodel = caret::train(x = aqb %>% select(all_of(predictors)),
                       y = aqb$o3_average_values,
                       method = "ranger",
                       num.trees = 200,
                       max.depth = 0,
                       tuneGrid = tg,
                       trControl = ctrl,
                       importance = "impurity")

rfmodel

saveRDS(rfmodel, "data/models/model_nolat_juelichcv.RDS")
aqb_test$pred_o3_average_values = stats::predict(rfmodel, aqb_test)


saveRDS(aqb_test, "data/validations/validation_nolat_juelichcv.RDS")
