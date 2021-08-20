# palma FFS

library(caret)
library(CAST, lib.loc = "/home/m/mludwig2/R")
library(parallel)
library(doParallel)


aqb = readRDS("aqb.RDS")
ctrl = readRDS("ctrl.RDS")
predictors = readRDS("predictors.RDS")





cl <- makeCluster(30)
registerDoParallel(cl)

ffsModel = CAST::ffs(predictors = aqb %>% dplyr::select(matches(predictors)),
                     response = aqb$o3_average_values,
                     method = "ranger",
                     tuneLength = 1,
                     num.trees = 200,
                     trControl = ctrl,
                     importance = "impurity")


stopCluster(cl)
saveRDS(ffsModel, "model_ffs_spatialcv.RDS")
