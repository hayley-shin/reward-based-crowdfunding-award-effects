/*===============
WeB2022
DID 최종 코드
===============*/

* 1. 데이터 불러오기
set more off
use matched_df_v1, clear


* 2. 중복 삭제
duplicates drop maker_Id Date,force


* 3. 시간변수 선언
tsset maker_Id Date


* 4. 필요한 변수 생성
// DID 변수 생성
gen DID = awards_Maker*awards_After
by maker_Id, sort: gen DID_initial=DID*Initial_0_25
by maker_Id, sort: gen DID_middle=DID*Middle_25_75
by maker_Id, sort: gen DID_initial2=DID*Initial_0_33
by maker_Id, sort: gen DID_middle2=DID*Middle_33_67
// 로그 및 표준화(standarization)
gen LDailyBackerCnt = log(DailyBackerCnt)
egen Lproject_PeriodDays = std(project_PeriodDays)
egen Lproject_Likes = std(project_Likes)
egen Lproject_RewardAvgPrice = std(project_RewardAvgPrice)


* 5. DID 돌리기

// 1차 가장 기본적인 모형
reg LDailyBackerCnt i.awards_Maker i.awards_After ///
DID ///
Lproject_PeriodDays Lproject_RewardAvgPrice i.maker_Id i.Month

reg LDailyBackerCnt i.awards_Maker i.awards_After DID Lproject_PeriodDays Lproject_RewardAvgPrice i.maker_Id i.Month

// 2차 Dynamic 보는 모형
// 초기, 중기, 말기를 0-25, 25-75, 75-100
reg LDailyBackerCnt i.awards_Maker i.awards_After Initial_0_25 Middle_25_75 ///
DID DID_initial DID_middle ///
Lproject_PeriodDays Lproject_RewardAvgPrice i.maker_Id i.Month

reg LDailyBackerCnt i.awards_Maker i.awards_After ///
i.DID##i.Initial_0_25 i.DID##i.Middle_25_75 ///
Lproject_PeriodDays Lproject_RewardAvgPrice i.maker_Id i.Month

// 초기, 중기, 말기를 0-33, 33-67, 67-100
reg LDailyBackerCnt i.awards_Maker i.awards_After Initial_0_33 Middle_33_67 ///
DID DID_initial2 DID_middle2 ///
Lproject_PeriodDays Lproject_RewardAvgPrice i.maker_Id i.Month

reg LDailyBackerCnt i.awards_Maker i.awards_After ///
i.DID##i.Initial_0_33 i.DID##i.Middle_33_67 ///
Lproject_PeriodDays Lproject_RewardAvgPrice i.maker_Id i.Month

// 1. 가장 기본적인 모형에서도 수상 여부 더미 p값이 0.111인데 괜찮은지
// 2. 초기, 중기, 말기 0-33, 33-67, 67-100로 가져가도 괜찮은지 -> robust하게 보려고 initial, middle, ending을 33으로도 나왔는데 안정적으로 잘 나온다 (슬라이드 추가)




