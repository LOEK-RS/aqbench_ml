library(ranger)
library(tree)

aqb = st_read("data/observations/AQ_bench_dataset_extraction.gpkg")
ffs_model = readRDS("data/models/model_ffsnolat_juelichcv.RDS")

aqb_spatial = aqb %>% select(all_of(c("id", "country", "htap_region", ffs_model$selectedvars)))
aqb = aqb %>% select(all_of(c(ffs_model$selectedvars, "o3_average_values"))) %>% st_drop_geometry()


rfmodel = caret::train(o3_average_values ~ ., data = aqb,
                       method = "ranger", 
                       tuneGrid = data.frame(mtry = 2, splitrule = "variance", min.node.size = 1000),
                       num.trees = 5,
                       trControl = trainControl(method = "none"))


####################


node_prediction = predict(object = rfmodel$finalModel, data = aqb, type = "terminalNodes", predict.all = TRUE)
node_prediction = as.data.frame(node_prediction$predictions) %>%
    mutate(id = aqb_spatial$id)



new_prediction = predict(object = rfmodel$finalModel, data = aqb[3,], type = "terminalNodes", predict.all = TRUE)
new_prediction = as.data.frame(new_prediction$predictions)


same_nodes = map_dfr(seq(ncol(new_prediction)), function(x){
    node_prediction %>% dplyr::filter(node_prediction[,x] == new_prediction[,x]) %>% select(id)
})


same_nodes = table(same_nodes) %>% as.data.frame()
same_nodes$same_nodes = as.numeric(as.character(same_nodes$same_nodes))


aqb_spatial = left_join(aqb_spatial, same_nodes, by = c("id" = "same_nodes"))


aqb_spatial %>% dplyr::filter(!is.na(Freq)) %>% mapview::mapview(cex = "Freq", zcol = "Freq", na.col = "transparent")
