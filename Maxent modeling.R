library(raster)
library(dismo)
library(rJava)
library(rgdal)
library(sdmpredictors)

basis_points <- read.csv("주산지_좌표.csv") # 주산지 좌표
df_points <- df[,c('lon', 'lat')] # 위경도만(종의 출현 정보만)
climate <- stack(bio1, bio2, bio3, bio4, bio5, bio6) # 예측에 사용할 환경 변수 stack

kor_extent <- extent(125,130.9,33.11,38.613) # 우리나라 해역
kor_climate <- crop(climate, ext) # 우리나라 해역의 환경 변수만 추출

## k-fold cross validation을 이용해 Maxent 모델 학습
set.seed(123)
## Enmeval 패키지를 통해 얻은 하이퍼파라미터 적용
xm <- maxent(kor_climate,  basis_points, args=c(
  'maximumbackground=1000','randomtestpoints=30','replicates=10','replicatetype=Crossvalidate',
  'betamultiplier=2.5','hinge=true',
  'responsecurves=true','jackknife=true'))

xm # 결과 실행
