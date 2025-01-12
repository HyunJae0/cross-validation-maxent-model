library(raster)
library(ggplot2)
library(sdmpredictors)
library(dismo)


## 최소, 평균, 최대 수온
bio1 <- raster("Present.Surface.Temperature.Min.tif")
bio2 <- raster("Present.Surface.Temperature.Mean.tif")
bio3 <- raster("Present.Surface.Temperature.Max.tif")

kor_extent <- extent(125,130.9,33.11,38.613) # 우리나라 해역
colors <-  colorRampPalette(c("#5E85B8","#EDF0C0","#C13127"))
colors2 <-  colorRampPalette(c("#00ff80","#ffff00","#ff0000"))

## 시각화 예시
par(mfrow = c(1, 3))
temp_min <- crop(bio1,kor_extent)
plot(temp_min, col=colors(100000),axes=FALSE, box=FALSE)
title("Present Surface Salinity Min (쨘C)",cex.sub = 2.25, line=-15)

temp_mean <- crop(bio2,kor_extent)
plot(temperature_mean, col=colors(100000),axes=FALSE, box=FALSE)
title(cex.sub = 2.25, sub = "Present Surface Temperature Mean (쨘C)")

temp_max <- crop(bio3,kor_extent)
plot(temp_max, col=colors(100000),axes=FALSE, box=FALSE)
title(cex.sub = 2.25, sub = "Present Surface Temperature Max (쨘C)")


## crop한 파일 저장 예시
RCP85_salinity_min <- crop(bio10,kor_extent)
RCP85_salinity_mean <- crop(bio11,kor_extent)
RCP85_salinity_max <- crop(bio12,kor_extent)


## 예측에 사용할 변수를 .tif 형식으로 저장
output_path <- "저장할 경로/RCP85_salinity_max.tif"  
output_path1 <- "저장할 경로/RCP85_salinity_min.tif"  
output_path2 <- "저장할 경로/RCP85_salinity_mean.tif"

writeRaster(RCP85_salinity_max, filename = output_path, format = "GTiff")
writeRaster(RCP85_salinity_min, filename = output_path1, format = "GTiff")
writeRaster(RCP85_salinity_mean, filename = output_path2, format = "GTiff")


