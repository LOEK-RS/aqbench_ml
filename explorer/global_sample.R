# create regular global sample for prediction

predictors = raster::stack("data/covariates/predictors.grd")



global_points = st_make_grid(x = st_bbox(predictors), cellsize = 5, what = "centers") %>% st_as_sf()



global_points_extract = raster::extract(predictors, global_points, df = TRUE)
global_points = global_points %>% mutate(global_points_extract)


st_write(global_points, "data/observations/global_sample.gpkg")
