# pududuk-frontend

LG 사내/사외 식당 추천 및 맞춤 메뉴 안내 서비스  
Flutter(GetX) 기반의 크로스플랫폼 앱

---

## 주요 기능

- **사내/사외 식당 구분 선택**  
  사내: 아워홈, CJ, 풀무원 등  
  사외: 회사 근처 맛집 추천
- **설문조사(나이, 성별, 대기시간, 지역, 선호/비선호 음식)**
  - 입력값은 shared_preferences에 저장/불러오기 지원
- **맞춤 메뉴 추천 결과**
  - 1~3위 대표 메뉴 썸네일, 점수, 기타 추천 메뉴 리스트
  - 사외 선택 시에만 "지도로 보기" 버튼 노출
- **지도 기반 맛집 랭킹**
  - 네이버 지도 연동, 맛집 카드, 기타 순위 표시
- **상태관리 및 라우팅**
  - GetX 기반의 Controller, Binding, Route 구조
- **설정(설문 재입력) 및 UX 개선**
  - 컬러 테마, 입력 UX, 라우팅 오류 등 지속 개선

---

## 주요 화면

### 1. 사내/사외 식당 선택

![사내/사외 식당 선택](assets/readme/affiliation_select.png)

### 2. 추천 결과

![추천 결과](assets/readme/recommend_result.png)

### 3. 기타 추천 메뉴 및 하단 버튼

![기타 추천 메뉴](assets/readme/recommend_others.png)

### 4. 설문조사 입력

![설문조사](assets/readme/survey.png)

### 5. 지도 기반 맛집 랭킹

![지도 맛집 랭킹](assets/readme/map_result.png)

> 이미지 파일 경로는 실제 프로젝트 내 assets 또는 첨부된 이미지로 교체해 주세요.

---

## 실행 방법

1. 패키지 설치

   ```bash
   flutter pub get
   ```

2. 앱 실행

   ```bash
   flutter run
   ```

3. (웹 실행)
   ```bash
   flutter run -d chrome
   ```

---

## 폴더 구조

- `lib/app/modules/affiliation/` : 사내/사외 식당 선택
- `lib/app/modules/survey/` : 설문조사
- `lib/app/modules/recommend_result/` : 추천 결과/지도
- `lib/app/routes/` : 라우팅
- `lib/app/utils/` : 공통 유틸/컬러/환경설정

---

## 기술 스택

- Flutter 3.x
- GetX (상태관리, 라우팅)
- shared_preferences (로컬 저장)
- 네이버 지도 플러그인 (flutter_naver_map)
- 기타: screenshot, share_plus 등

---

## 기타

- 사내식당 선택 시 지도 아이콘이 노출되지 않으며, 사외식당 선택 시에만 지도 기능이 활성화됩니다.
- 설문조사, 추천 결과, 지도 등 모든 UX는 실제 사용성/피드백을 반영하여 지속 개선 중입니다.

---

**문의/기여 환영합니다!**
