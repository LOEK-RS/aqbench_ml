
library(future)
library(ranger)
library(furrr)
library(sf)
library(tidyverse)


ffsmodel = readRDS("data/models/model_ffsnolat_juelichcv.RDS")


# terminal nodes of original training data
aqb = st_read("data/observations/AQ_bench_dataset_extraction.gpkg")

train_nodes = predict(object = ffsmodel$finalModel,
                      data = aqb %>% st_drop_geometry(),
                      type = "terminalNodes", predict.all = TRUE)
train_nodes = as.data.frame(train_nodes$predictions) %>%
    mutate(id = aqb$id)



# terminal nodes of new data

global_points = st_read("data/observations/global_sample.gpkg")

new_nodes = predict(object = ffsmodel$finalModel,
                    data = global_points %>% st_drop_geometry(), type = "terminalNodes", predict.all = TRUE)
new_nodes = as.data.frame(new_nodes$predictions)

cat("test TESTETSTSTTTETSTTTES")
# check

# for each new point w (rows in new_nodes)
# which training points (id of train_nodes)
plan(multicore)
same_nodes = furrr::future_map(seq(nrow(new_nodes)), function(w){
    print(w)
    # for each tree x (columns in train_nodes)
    same_nodes_tree = map_dfr(seq(ncol(new_nodes)), function(x){
        train_nodes %>% dplyr::filter(train_nodes[,x] == new_nodes[w,x]) %>% select(id)
    })
    same_nodes_tree = table(same_nodes_tree) %>% as.data.frame()
    same_nodes_tree[,1] = as.numeric(as.character(same_nodes_tree[,1]))
    return(same_nodes_tree)
    
})


saveRDS(same_nodes, "explorer/rf_sample_influence_same_nodes.RDS")



# how often is each training point used?













