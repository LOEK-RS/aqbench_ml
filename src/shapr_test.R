# shapr test

library(shapr)


model = readRDS("data/models/model_allvars_randomcv.RDS")

aqb_test = readRDS("data/predictions/pred_test_allvars_randomcv.RDS")



expl = shapr::shapr(x = model$trainingData, model = model$finalModel, n_combinations = 50)


aqb_test_sample = aqb_test[100:106,]


e = shapr::explain(x = aqb_test_sample, explainer = expl, approach = "ctree",
                   prediction_zero = mean(aqb_test$o3_average_values))

e$dt
plot(e)
