# 2023년 공공데이터 활용 아이디어 경진대회
## 개인 프로젝트
### 주제 선정 이유
- 삼면이 바다로 둘러싸인 우리나라는 지형 이점을 이용해 다양한 양식 방법을 통해 양식수산업의 맥을 이어오고 있음.
- 그중에서도 해수면 가두리 양식은 낮은 설비 비용으로 비교적 많은 양의 어류를 기를 수 있는 경제적인 장점을 가지고 있으며, 바닷물을 이용하는 양식법 중 가장 많은 경영체가 있음.
- 그러나, 기후변화(한파, 폭염)로 인한 저·고수온, 집중호우로 인한 저염분화 등 해양 환경에 변화를 주고 있음.
- 수온 변화에 취약한 해수면 가두리 양식(이하 ‘해상 가두리’)은 매년 수산 피해가 속출하고 있지만, 이에 대한 대책이 미흡한 상황.
- 기상청과 환경부에서 발간한 ‘한국 기후변화 평가보고서 2020’에 따르면, 현재 추세대로 온실가스가 배출될 경우 21세기 말 폭염일수가 3.5배 증가할 것으로 예상되는 만큼, 향후 집단 폐사와 같은 수산 피해의 빈도수가 증가할 것으로 전망.
- 특히, 해상 가두리의 주요 품종들의 경우, 지역 소득의 근간으로서 이러한 피해는 어가뿐만 아니라 소비자 물가에도 영향을 미침.
- 이에 대한 위기 대응 방안으로, 주요 품종들의 주산지가 현재 대비 미래에 어떻게 변하는지 예측한다면 사전에 피해를 예방할 수 있음.
- 또한, 환경 변화에 발맞추어 제주 연안에서 출현하던 아열대 어종이 북상하여 남해, 동해, 독도 연안에서도 출현율이 증가하고 있는 점을 고려하여 어획량이 많은 아열대 어종 중 위기가 예상되는 지역에서 서식하기 적합한 어종을 찾아 새로운 지역특화 양식 어종으로 도입하는 전략을 제안함.

예측을 위해 사용되는 데이터는 크게 3가지 입니다. 

(1) 해양 환경 변수 - Bio-ORACLE(https://bio-oracle.org/)
- 현재 추세대로 온실가스가 배출되는 경우(RCP 8.5 시나리오)를 상정한 근미래(2040-2050)와 먼 미래(2090-2100) 수온과 염도에 대한 래스터(raster) 데이터를 사용합니다.
- 래스트 데이터는 격자 형태로 지리적인 개체를 표현합니다. Bio-ORACLE에서 제공하는 래스터 데이터의 각 격자에는 해양 영역에 대한 수온과 염도에 대한 값이 담겨 있습니다.

(2) 주요 품종의 주산지 위치 정보
- 해상 가두리의 주요 품종의 주산지(주된 생산지)가 어디인지 파악하기 위해 MDIS에서 제공받은 '과거(2005, 2010, 2015, 2020년) 어업총조사' 결과를 사용하니다.
- 주산지 선정은 데이터의 양식면적(ha)을 기준으로 box plot을 통해 분포를 확인하여 일정 규모 이상의 양식지만 추출하였습니다.
- 그리고 해당 양식지(주산지)들의 위치 정보(위경도)를 사용합니다.

(3) 아열대 어종의 위치 정보
- R의 'dismo 패키지'의 gbif 함수를 통해 아열대 어종들의 출현 위치 정보(위경도)를 사용합니다.

해양 환경 변수와 주산지 위치 표본을 입력하여 주산지 위치/아열대 어종 출현 위치의 환경 특성을 학습해서 근미래와 먼 미래 대상 종의 잠재 출현 확률분포를 확인합니다. 이 확률분포를 통해 미래 주산지 적합도를 확인하고, 지역특화 양식 어종이 될 수 있는 아열대 어종을 선정합니다. 

Stack
```
Python
QGIS
R
Maxent
```

# 코드 실행
## Data Preprocessing
## 1.1 해양 환경 변수
온실가스로 인한 수온과 염도의 변화가 주산지의 적합도에 미치는 영향을 현재와 대비하여 보기 위해, 기존 관련 연구인 'RCP 시나리오에 따 른 해양교란생물 유령멍게 (Ciona robusta)의 서식지 분포 예측'에서 사용한 연중 최대, 최소, 평균 수온과 연중 평균 염도 래스터 데이터를 사용했습니다.

Bio-ORACLE에서 제공하는 해양 환경 변수는 전 세계에 대한 해양 영역에 대한 값이기 때문에 우리나라 해역에 맞춰 추출하였습니다.
```
## 예시
bio1 <- raster("Present.Surface.Temperature.Min.tif")
kor_extent <- extent(125,130.9,33.11,38.613)
temp_min <- crop(bio1,kor_extent)
```
<img src="./img/해양 환경 변수.png" width="50%">

## 1.2 주요 품종의 주산지 선정과 주산지의 위경도 추출
주산지 선정은 box plot을 이용하여 주요 품종별 양식 면적의 분포를 확인해서 양식 면적 값이 이상치로 분류되는 지역들을 주산지로 선정하였습니다.
https://github.com/HyunJae0/cross-validation-maxent-model/tree/main/%EC%A3%BC%EC%82%B0%EC%A7%80%20%EC%84%A0%EC%A0%95

다음 그림은 2005, 2010, 2015, 2020년 전복류 양식 면적에 대한 box plot입니다.
<img src="./img/전복 양식면적.png" width="50%">

QGIS(https://www.qgis.org/) 프로그램을 사용해 주소를 위경도 좌표로 변환하기 위해 어업총조사 데이터 정의서를 따라 숫자를 주소로 변환하였습니다. (예를 들어 11 -> '서울')
변환 방법은 다음 글을 참고하였습니다. (https://sangdee.tistory.com/2)

## 1.3 아열대 어종의 위치 정보
아열대 어종의 위치 정보는 R에서 제공하는 'rgbif' 라이브러리를 사용해서, GBIF(https://www.gbif.org/)에서 제공하는 데이터를 사용하였습니다. 마찬가지로 우리나라 해역에 맞춰 위치(위경도) 정보를 추출하였습니다.

GBIF에서 위치 정보를 받아오는 과정은 다음 예시와 같습니다. 다음 코드는 해삼의 모든 출현 정보를 GBIF에서 받아온 다음, 한국 해역에 맞춰 출현 위치 정보(위경도)를 추출하는 과정입니다.
```
library(rgbif)
occ <- occ_data(
  taxonKey =  222, # 해삼에 대한 key
    basisOfRecord = c("FOSSIL_SPECIMEN","HUMAN_OBSERVATION","MATERIAL_CITATION","MATERIAL_SAMPLE",
                    "LIVING_SPECIMEN","MACHINE_OBSERVATION","OBSERVATION","PRESERVED_SPECIMEN",
                    "OCCURRENCE"), # 모든 출현 정보
  country = 'KR', # Korea
  occurrenceStatus = "PRESENT" 
  )


## 각 출현 정보의 위경도
a <- occ$FOSSIL_SPECIMEN$data$decimalLatitude
a1 <- occ$FOSSIL_SPECIMEN$data$decimalLongitude
b <- occ$HUMAN_OBSERVATION$data$decimalLatitude
b1 <- occ$HUMAN_OBSERVATION$data$decimalLongitude
c <- occ$MATERIAL_CITATION$data$decimalLatitude
c1 <- occ$MATERIAL_CITATION$data$decimalLongitude
d <- occ$MATERIAL_SAMPLE$data$decimalLatitude
d1 <- occ$MATERIAL_SAMPLE$data$decimalLongitude
e <- occ$LIVING_SPECIMEN$data$decimalLatitude
e1 <- occ$LIVING_SPECIMEN$data$decimalLongitude
f <- occ$MACHINE_OBSERVATION$data$decimalLatitude
f1 <- occ$MACHINE_OBSERVATION$data$decimalLongitude
g <- occ$OBSERVATION$data$decimalLatitude
g1 <- occ$OBSERVATION$data$decimalLongitude
h <- occ$PRESERVED_SPECIMEN$data$decimalLatitude
h1 <- occ$PRESERVED_SPECIMEN$data$decimalLongitude
i <- occ$OCCURRENCE$data$decimalLatitude
i1 <- occ$OCCURRENCE$data$decimalLongitude
## 모든 위경도 통합
combined_lat <- c(a,b,c,d,e,f,g,h,i)
combined_lon <- c(a1,b1,c1,d1,e1,f1,g1,h1,i1)
```

```
해삼 <- data.frame(lon = combined_lon,lat = combined_lat)
해삼_p <- na.omit(해삼) # na 값은 제거

해삼_po <- 해삼_p %>%
  filter(lon >= 125 & lon <= 130.9 & 
           lat >= 33.11 & lat <= 38.613)

해삼_points <- 해삼_po[,c('lon','lat')]
## 출현 정보 저장
write.csv(해삼_points, "해삼출현좌표.csv", row.names = FALSE)
```

## 2. Maxent Modeling
MaxEnt 모형은 다양한 공간 규모와 환경요인 변수를 기반으로 종의 지리적 분포, 서식지 적합성 등을 예측하는 생태적 지위 모형(Ecological Niche Model) 중 하나로서, 최대 엔트로피를 기반으로 동식물의 출현 지점 자료만을 가지고 잠재 출현 확률분포를 예측할 수 있는 머신러닝 기법입니다. Maxent 식은 다음과 같습니다.

![image](https://github.com/user-attachments/assets/6f27ac9f-a3b6-499e-a5a6-ca184ff6fc96)

여기서 z는 위치 x_i에서의 J개의 환경 변수 벡터이고 람다는 회귀 계수 벡터입니다. 분자는 다음과 같이 계산됩니다.

![image](https://github.com/user-attachments/assets/71b401bd-7fac-4bbd-afc4-42e31b44bdc1)

분자는 위치 x_i에서의 '발생 가능성'을 나타냅니다. 분모는 모든 위치 x_i에 대한 합이므로, P(z(x_i))는 0과 1사이의 확률값으로 변환됩니다. 즉, P(z(x_i)) 값은 특정 위치 x_i에서의 '발생 가능 확률'입니다.

### 2.1 Maxent Model Hyperparameter Tuning
모델의 하이퍼파라미터 튜닝 과정은 아래 .R 파일에 기술되어 있습니다.
https://github.com/HyunJae0/cross-validation-maxent-model/blob/main/ENMeval_hyperparameter_tuning.R

튜닝에 필요한 것은 종의 출현 정보(위경도 좌표)와 예측에 사용할 환경 변수들. 그리고 background points라는 좌표입니다. 

background points는 종이 출현하고 서식할 수 있는 환경의 좌표입니다. (종이 관찰되지 않았지만 모델링에 참고할 무작위 지점으로 실제 출현 좌표와 동일한 좌표를 포함하고 가지게 될 수도 있습니다.)

출현 정보와 환경 변수들은 이미 가지고 있으므로 튜닝을 하기 위해서는 background points가 필요합니다. 다음 코드들은 background points를 생성하는 과정입니다.
```
env = stack(bio1, bio2, bio3, bio4, bio5, bio6)
occ <-  read.csv("종의 출현 정보.csv") # 종이 출현한 정보(위경도)
occur.ras <- rasterize(occ,env,1) #occ는 종의 출현 정보 # env는 예측에 사용할 환경 변수들
presences <- which(values(occur.ras)==1)
pres.locs <- coordinates(occur.ras)[presences,]
```
occ(출현 좌표)와 env(환경 변수 레이어)를 기반으로 출현 위치를 raster 형태로 변환합니다. 이 raster에서 각 셀값이 1인 셀(종이 관찰된 위치)을 선택합니다.

pres.locs <- coordinates(occur.ras)[presences, ]을 통해 종이 관찰된 셀들의 실제 좌표를 추출하여 저장합니다. 이렇게 하면 종이 출현한 모든 좌표를 일반 행렬 형태로 얻을 수 있습니다.

그다음, 한국 해역 크기에 맞게(env의 범위) 출현 지점의 공간 분포를 고려한 출현 지점의 커널 밀도를 계산합니다. 최종적으로 env와 동일한 형태(셀 크기, 범위)를 갖는 커널 밀도 추정 raster가 생성됩니다. 이 raster를 사용해서 background points를 생성합니다. 
```
bg <- xyFromCell(dens.ras2, sample(which(!is.na(values(subset(env,1)))), 10000
                                   , prob=values(dens.ras2)[!is.na(values(subset(env,1)))]))
```
실제로 유효한 데이터(해양 환경 변수이므로 수온, 염도 값)가 있는 셀(NA가 아닌 셀)을 이용해서 kde2d로 추정된 밀도를 추출 확률로 사용합니다. 즉, 종이 많이 발생한 지역일수록 background point도 많이 뽑히게 됩니다.

일반적으로 background point 10,000개를 추출하지만, background point를 추출하기 위한 종의 실제 출현 좌표의 수가 적을 경우, 1,000개에서 5,000개 사이로 background point를 추출합니다.

이렇게 background points까지 생성하였으면, 다음과 같이 ENMeval 패키지의 ENMevaluate( ) 메서드로 하이퍼파라미터 튜닝을 진행합니다. 
```
enmeval_results <- ENMevaluate(occ, env, method = "randomkfold", "kfolds = 10", algorithm="maxent.jar",
                               bg.coords = bg,RMvalues = seq(0.5, 4, 0.5), fc = c("L", "LQ", "H", "LQH", "LQHP", "LQHPT"))
```
여기서 사용되는 입력은 occ(종의 실제 출현 좌표), env(환경 변수 레이어들의 stack), bg.coords(위에서 만든 background point)입니다. 
method = 'randomkfold'와  'kfolds = 10'은 랜덤으로 fold 10개를 만들어 k-fold cross validation을 수행하겠다는 의미입니다.

RMvalues = seq(0.5, 4, 0.5)와 fc = c("L", "LQ", "H", "LQH", "LQHP", "LQHPT")는 Maxent에서 사용되는 가능한 모든 feature 조합을 값 0.5부터 4까지 0.5 간격으로 탐색하겠다는 의미입니다.

위의 6가지 feature를 사용한 조합 중 Delta AIC 값이 0이 되는 하이퍼파라미터를 선택합니다. AIC = -2ln(L) + 2k로 -2ln(L)은 모형의 적합도, k는 추정된 파라미터의 개수입니다. 그러므로 AIC 점수가 낮을수록 적합한 모델입니다.

Delta AIC는 최적 모델과 모델의 AIC 점수 차이입니다. 즉, 최적 모델의 경우 자기 자신의 AIC 점수 차이는 0이 됩니다. 그러므로 Delta AIC = 0일 때의 조합("L", "LQ", "H", "LQH", "LQHP", "LQHPT"들의 조합)을 찾는 것입니다.
```
which(enmeval_results@results$delta.AIC == 0)
```

하이퍼파라미터에 대한 설명: https://groups.google.com/g/maxent/c/yRBlvZ1_9rQ

### 2.2 Maxent Model Cross Validation
2.1에서 얻은 하이퍼파라미터와 모델의 입력값으로 환경 변수 레이어 스택과 종의 출현 좌표를 넣어서 Maxent 모델을 구성합니다. 이때, 다음과 같이 fold 수인 'replicates'와 'replicatetype=Crossvalidate'를 지정하여 cross validation을 수행할 수 있습니다.
```
xm <- maxent(kor_climate,  basis_points, args=c(
  'maximumbackground=1000','randomtestpoints=30','replicates=10','replicatetype=Crossvalidate',
  'betamultiplier=2.5','hinge=true',
  'responsecurves=true','jackknife=true'))
```
위의 코드는 10 fold cross validation이므로 10개의 서로 다른 fold로부터 10개의 예측 결과물이 생성됩니다. 각 fold마다 학습에 사용된 데이터가 다르기 때문에, 모델이 추정한 예측 결과인 서식 적합도(적합 확률)지도도 조금씩 달라질 수 있습니다. 그러므로 보다 안정적인 분포 추정을 하기 위해 다음과 같이 평균을 이용해서 종합적인 예측 지도를 만듭니다.
```
plot(mean(predict_204050), main="SSP5-8.5 2040-2050", col = colors(100000),box = FALSE, axes = FALSE, zlim = c(0,1))
```

아래 .R 파일에 기술되어 있습니다.
https://github.com/HyunJae0/cross-validation-maxent-model/blob/main/Maxent.R

# 결과
Maxent 모델의 기본 결과로, 모델의 설명력을 나타내는 ROC 값과 근미래와 먼 미래에 대한 종의 잠재 출현 확률분포를 받을 수 있습니다. 이외에도 별도의 설정을 통해 각 환경 변수가 Maxent 예측에 어떻게 영향을 미치는지 보여주는 'Response curves'와 Maxent 모델에 대한 환경 변수의 기여도를 나타내는 'Analysis of variable contributions' 등 다양한 결과를 확인할 수 있습니다.

![image](https://github.com/user-attachments/assets/301d5682-453d-4f82-bf71-752d2aa49369)

예를 들어 다음 그림은 전복 주산지와 전복에 대한 Maxent 결과입니다.

<img src="./img/전복 주산지.png" width="50%">

<img src="./img/전복 결과.png" width="50%">
위의 그림은 잠재 확률분포를 시각화한 것으로 0(파란색)에 가까울수록 해당 영역에서 출현할 확률이 낮은 것이며, 1(빨간색)에 가까울수록 해당 영역에서 출현할 확률이 높은 것을 나타냅니다. 
사용된 위치 정보가 주산지 좌표이기 때문에, 현재 수온과 염도에 전복류 주산지가 적합한 것으로 해석할 수 있습니다. 그러나 근미래와 먼 미래에는 전복류에 적합한 영역이 사라진 것을 확인할 수 있습니다.

"실제로, 전복의 서식 최고 수온은 20도이고 한계 수온은 30도인 점을 고려했을 때, 예측에 사용한 근미래와 먼 미래 수온 값이 이 범위를 초과하므로, 현재와 같은 온실가스 배출 추세(RPC 8.5 시나리오)가 지속될 경우 전복류 양식의 위기가 예상된다."는 결과를 도출할 수 있습니다.
