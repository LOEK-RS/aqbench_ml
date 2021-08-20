library(raster)
library(ncdf4)
library(tidyverse)



ncin = nc_open("data/covariates/gridded_metadata.nc")





# netcdf to raster parser

vars = capture.output(print(ncin))
vars = stringr::str_trim(vars)
vars = vars[4:37]

# extract categorial variables
vars_chr = vars[str_detect(vars, "string")]
vars = vars[!vars %in% vars_chr]

vars = word(vars, start = 2, end = 2)
vars = str_remove(vars, "\\[longitude,latitude\\]")
vars


lon = ncdf4::ncvar_get(ncin, "lon")
lat = ncdf4::ncvar_get(ncin, "lat")

vars = vars[!vars %in% c("lon", "lat")]
vars

mats = map(vars, function(v){
    
    cur = ncdf4::ncvar_get(ncin, v)
    cur = raster(t(cur), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat),
           crs=crs("+init=epsg:4326"))
    names(cur) = v
    return(cur)
    
})
mats2 = stack(mats)

mats2[[2]] = flip(mats2[[2]])
writeRaster(mats2, "data/covariates/gridded_metadata.grd")

