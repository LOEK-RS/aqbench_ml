cov = raster::stack("data/covariates/predictors.grd")
aqb = st_read("data/observations/AQ_bench_dataset_extraction.gpkg")
aqb$climatic_zone = as.factor(aqb$climatic_zone)

folds = read.csv("data/folds/general_datasplit.csv")

# attach fold information
aqb = left_join(aqb, folds) %>% st_drop_geometry()

# split in training and test
aqb_test = aqb %>% dplyr::filter(set == "test")
aqb = aqb %>% dplyr::filter(set != "test") %>% dplyr::mutate(fold = as.numeric(set))


# fold index for caret
index = spampling::fold2index(aqb)

predictors = names(cov)



ctrl = caret::trainControl(method = "cv", number = 4,
                           index = index$index, indexOut = index$indexOut,
                           savePredictions = "all")

tg = expand.grid(mtry = c(2,5,7,10,12,15,20),
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

saveRDS(rfmodel, "data/models/model_allvars_juelichcv.RDS")
aqb_test$pred_o3_average_values = stats::predict(rfmodel, aqb_test)


saveRDS(aqb_test, "data/predictions/pred_test_allvars_juelichcv.RDS")
