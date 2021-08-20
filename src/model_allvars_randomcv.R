library(raster)
library(sf)
library(tidyverse)
library(spampling)
library(caret)


# cov = stack("data/covariates/gridded_metadata.grd")
aqb = st_read("data/AQ_bench_dataset.gpkg")


# unused predictors

# unused_predictors =  c("urban_and_built.up_25km",
#                        "cropland.natural_vegetation_mosaic_25km",
#                        "snow_and_ice_25km",
#                        "barren_or_sparsely_vegetated_25km", 
#                        "wheat_production")



# absolute latitude
aqb$absolute_latitude = st_coordinates(aqb)[,2] %>% abs()

aqb$climatic_zone = as.factor(aqb$climatic_zone)

aqb = aqb %>% st_drop_geometry()

# merge different savannas, forests and shrublands

aqb = aqb %>% mutate(forests_25km = evergreen_needleleaf_forest_25km+
                                        evergreen_broadleaf_forest_25km+
                                        deciduous_needleleaf_forest_25km+
                                        deciduous_broadleaf_forest_25km+
                                        mixed_forest_25km,
                     shrublands_25km = closed_shrublands_25km+
                                           open_shrublands_25km,
                     savannas_25km = woody_savannas_25km+
                                         savannas_25km)




# split in training and test

aqb_testindex = createDataPartition(aqb$o3_average_values, times = 1, p = 0.2, list = FALSE)

aqb_test = aqb[aqb_testindex,]
aqb = aqb[-aqb_testindex,]



predictors = c("climatic_zone",
               "absolute_latitude",
               "alt",
               "relative_alt",
               "water_25km",
               "forests_25km",
               "shrublands_25km",
               "savannas_25km",
               "grasslands_25km",
               "permanent_wetlands_25km",
               "croplands_25km",
               "rice_production",
               "nox_emissions",
               "no2_column",
               "population_density",
               "max_population_density_5km",
               "max_population_density_25km",
               "nightlight_1km",
               "nightlight_5km",
               "max_nightlight_25km")

ctrl = caret::trainControl(method = "cv", number = 5)



rfmodel = caret::train(x = aqb %>% select(all_of(predictors)),
                       y = aqb$o3_average_values,
                       method = "ranger",
                       tuneLength = 5,
                       trControl = ctrl,
                       importance = "impurity")


saveRDS(rfmodel, "data/models/model_allvars_randomcv.RDS")

aqb_test$pred_o3_average_values = stats::predict(rfmodel, aqb_test)
saveRDS(aqb_test, "data/predictions/pred_test_allvars_randomcv.RDS")

