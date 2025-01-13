library(dismo)
library(raster)
library(rJava)
library(MASS)
library(ENMeval)
# 예측에 사용할 모든 환경 변수 stack
env = stack(bio1, bio2, bio3, bio4, bio5, bio6)

# 예측에 필요한 background point를 결정하는 과정
occ <-  read.csv("종의 출현 정보.csv") # 종이 출현한 정보(위경도)
## ENMeval 패키지로 하이퍼파라미터 튜닝을 하기 위해 위경도를 x, y 좌표로 변경해야 함
colnames(occ)[1]<-'x'
colnames(occ)[2]<-'y' 

occur.ras <- rasterize(occ,env,1)
presences <- which(values(occur.ras)==1)
pres.locs <- coordinates(occur.ras)[presences,]

# density 계산
dens <- kde2d(pres.locs[,1], pres.locs[,2], n=c(nrow(occur.ras), ncol(occur.ras))
              ,lims=c(extent(env)[1],extent(env)[2],extent(env)[3],extent(env)[4]))
dens.ras <- raster(dens, env)
dens.ras2 <- resample(dens.ras, env)

# background points, 기본 값은 10000
bg <- xyFromCell(dens.ras2, sample(which(!is.na(values(subset(env,1)))), 10000
                                   , prob=values(dens.ras2)[!is.na(values(subset(env,1)))]))

# ENMeval 패키지로 하이퍼파라미터 튜닝
enmeval_results <- ENMevaluate(occ, env, method = "randomkfold", "kfolds = 10", algorithm="maxent.jar",
                               bg.coords = bg,RMvalues = seq(0.5, 4, 0.5), fc = c("L", "LQ", "H", "LQH", "LQHP", "LQHPT"))

# 하이퍼파라미터 튜닝 결과 저장
indices <- which(enmeval_results@results$delta.AIC == 0)
ssp_204050_하이퍼파라미터 <-  enmeval_results@results[indices, ]
ssp_204050_하이퍼파라미터$tune.args  # delta.AIC == 0일 때, rm.0.5_fc.LQ
write.csv(enmeval_results@results, "튜닝_결과.csv")