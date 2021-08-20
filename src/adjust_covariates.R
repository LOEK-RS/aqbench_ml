# modify covariates

source("src/00_setup.R")

cov = stack("data/covariates/gridded_metadata.grd")

cov$forests_25km = cov$evergreen_needleleaf_forest_25km + cov$evergreen_broadleaf_forest_25km +
    cov$deciduous_needleleaf_forest_25km + cov$deciduous_broadleaf_forest_25km + cov$mixed_forest_25km

cov$savannas_25km = cov$savannas_25km + cov$woody_savannas_25km

cov$shrublands_25km = cov$closed_shrublands_25km + cov$open_shrublands_25km

cov$absolute_latitude = abs(coordinates(cov)[,2])

boxplot(coordinates(cov))



boxplot(cov$absolute_latitude)

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


cov = cov[[predictors]]

writeRaster(cov, "data/covariates/predictors.grd")



# create update aqbench training set

cov = stack("data/covariates/predictors.grd")

aqb = st_read("data/trainingdata/AQ_bench_dataset.gpkg")
aqb = aqb %>% select(id, country, htap_region, matches("o3"))

aqb_extract = raster::extract(cov, aqb)
aqb = cbind(aqb_extract, aqb)

aqb = aqb %>% select(id, country, htap_region, everything())

st_write(aqb, "data/trainingdata/AQ_bench_dataset_extraction.gpkg", append = FALSE)
