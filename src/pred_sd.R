


cov_stamp = raster::stack("~/development/aoa_disassembly/tests/testdata/aqb_stamp.grd")
cov_all = raster::stack("data/covariates/predictors.grd")
cov_stamp_v = getValues(cov_all)

m1 = readRDS("data/models/model_allvars_juelichcv.RDS")
p1 = predSD(m1, cov_all)
raster::plot(p1)

writeRaster(p1, "data/predictionSDs/sd_allvars_juelichcv.grd", overwrite = TRUE)


m2 = readRDS("data/models/model_ffs_juelichcv.RDS")
p2 = predSD(m2, cov_all)
raster::plot(p2)
writeRaster(p2, "data/predictionSDs/sd_ffs_juelichcv.grd", overwrite = TRUE)

m3 = readRDS("data/models/model_nolat_juelichcv.RDS")
p3 = predSD(m3, cov_all)
raster::plot(p3)
writeRaster(p3, "data/predictionSDs/sd_nolat_juelichcv.grd", overwrite = TRUE)

m4 = readRDS("data/models/model_ffsnolat_juelichcv.RDS")
p4 = predSD(m4, cov_all)
raster::plot(p4)
writeRaster(p4, "data/predictionSDs/sd_ffsnolat_juelichcv.grd", overwrite = TRUE)



predSD = function(model, cov){
    
    res = cov[[1]]
    #p = raster::predict(cov, model)
    cov = getValues(cov)
    
    model = model$finalModel
    
    print("predicting now")
    psd = predict(model, cov, predict.all = TRUE, num.trees = 100)
    print("apply 1")
    p = apply(psd$predictions, 1, FUN = mean)
    print("apply 2")
    psd = apply(psd$predictions, 1, FUN = sd)
    
    res = raster::setValues(x = res, values =  round(psd / p, 2)*100)
    return(res)
    
    
}

df = data.frame(allvars = getValues(p1),
                ffs = getValues(p2),
                nolat = getValues(p3),
                ffsnolat = getValues(p4))

df2 = reshape2::melt(df, value.name = "SD")

ggplot(df2, aes(y = SD, x = variable))+
    geom_boxplot()

