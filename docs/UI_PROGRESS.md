# 📋 OOMU UI 단계별 작업 진행 및 검증 기록 (docs/UI_PROGRESS.md)

## 📌 현재 단계: [1단계] 백업과 지침 정리 (완료)

### 1. 작업 개요
- **목표**: 2030 여성 중심의 안전하고 편안한 로컬 커뮤니티 기준 정립 및 파편화된 UI 지침 중복·충돌 해소.
- **원칙**: 앱 소스코드는 수정하지 않고, 지침 문서 정리 및 사전 안전 백업 완료.

### 2. 백업 생성 및 무결성 검증
- **백업 파일 경로**: `C:\Users\DT4\Downloads\oomu_app_backups\oomu_app_before_ai_20261027-151416.zip`
- **백업 용량**: 444.52 MB (466,113,156 bytes)
- **포함 파일 수**: 32,586개 파일
- **SHA-256 해시**: `8dd10b5992de2980a1aad04488ad299b11d0baec4ca3cd5582b7ee66e484374c`
- **무결성 검사 (`testzip()`)**: 손상 파일 0건 통과 (`None`)
- **보존된 이전 백업**:
  1. `oomu_app_before_ai_20261027-135124.zip` (최초 백업)
  2. `oomu_app_before_ai_20261027-141342.zip` (체크포인트 2)
  3. `oomu_app_before_ai_20261027-142715.zip` (체크포인트 3)

### 3. 지침 정리 내역
1. **단일 UI 가이드 수립**: `docs/OOMU_UI_GUIDE.md`를 단일 진실 공급원(Single Source of Truth)으로 신설.
2. **지침 중복 및 충돌 해소**:
   - `AGENTS.md`, `AI_INSTRUCTIONS.md`, `.agents/rules/oomu_integrated_rules.md`, `.antigravity/rules/ui_ux_design_rules.md`, `.antigravity/rules/prompt_routing_rules.md`, `.agents/skills/frontend-design/SKILL.md`에서 과도하게 반복되던 수식어('100점·무결점·12년 차')와 불필요한 모델 강제 호출 규칙을 실제 작업 및 검증 가능한 기준으로 단일화.
   - 분홍 코랄 `#F25767`을 브랜드 Primary Action 공식 색상으로 확정하고 주황 코랄과의 충돌 해소.
   - Flutter 기본 Text 위젯에 없는 `wordBreak: WordBreak.keepAll` 전역 지시 폐기.
   - 모든 문구 1줄 말줄임, 획일적 대칭 2열 강제 대신 콘텐츠 특성(주소/시간/소개)에 맞는 유연한 레이아웃 적용.
3. **화면 경로 단일화**:
   - `main.dart` 기준 실제 활성 화면(`soso_car_home_screen.dart`, `soso_car_detail_screen.dart` 등)과 미연결 레거시 화면(`home_screen.dart`, `party_screen.dart` 등)을 명확히 분류.
   - 부존재 가상 경로(`lib/features/...`) 오기록 수정.
4. **UI 완료 기준 분리**:
   - UI 작업 기준에서 `git push` 및 자동 배포를 분리하여 로컬 정적 검증과 실제 렌더링 확인으로 한정.

---

---

## 📌 [2단계] 실행환경과 기준화면 (`02_실행환경과_기준화면.txt`) (완료)
- **실행 환경 점검**:
  - 디스크 C: 잔여 공간 1.1GB~0.6GB 미만으로, 대용량 SDK 신규 설치 시 용량 고갈 위험 확인.
  - 전역 PATH 조작 및 운영 DB 쓰기를 방지하고, 기확보된 390×844 기준 캡처(`docs/design_references/` 6종)를 기준 화면으로 동기화.
- **기준 화면 보유**:
  - `docs/design_references/oomu-home-390.jpg` (홈 화면 기준)
  - `docs/design_references/oomu-meetup-card-390.jpg` (모임 카드 기준)
  - `docs/design_references/oomu-detail-390.jpg` (상세 상단 기준)
  - `docs/design_references/oomu-detail-lower-390.jpg` (상세 하단 기준)
  - `docs/design_references/oomu-community-390.jpg` (커뮤니티 기준)
  - `docs/design_references/oomu-profile-390.jpg` (프로필/마이페이지 기준)

---

## 📌 [레퍼런스 적용 단계] 한국 모임 앱 5종 레퍼런스 적용 및 정적 비교 시안 확정 (2026-10-27)
- **목표**: 문토·프립·당근 SEED·소모임·위피의 공개 웹 및 공식 문서 관찰 사실을 OOMU의 2030 여성 안심 커뮤니티 기준에 맞게 재해석하여 디자인 방향 확정.
- **격리 시안 파일**: `docs/prototypes/oomu_design_reference_prototype.html`
- **검증 결과**: `scripts/verify_before_report.py --html` 100% 문법·렌더링 무결성 통과.
- **주요 채택 기준**:
  1. **문토**: 목적 중심의 3대 탭(번개/아지트/메이트) 및 밝은 바탕+사진·제목 중심 분위기. (과밀한 다단 기획 배너 배제)
  2. **프립**: 카드 내 명확한 정보 위계(사진 ➔ 제목 ➔ 일정/장소 ➔ 주최자 ➔ 참여인원) 및 불필요한 테두리 배제. (원화 대신 `1/N 안심 정산` 표기)
  3. **당근 SEED**: 역할별 간격 토큰(좌우 16~20, 카드내부 16, 정보간 6~8, 묶음 12~16, 섹션 24~32dp), 글자 크기+줄높이+두께 일체 정의, 최소 48×48dp 터치 타깃 보장, 보조 지도 버튼의 시각적 무게 절제.
  4. **소모임·위피**: 취미/지역 기반 정모 과업 및 프로필 관심사 대화 시작점 보조 참고 (네이티브 미확인 수치 배제).

---

## 📌 [3단계] 공통디자인과 상세화면 (`03_공통디자인과_상세화면.txt`) (완료)
- **수정 대상**: `lib/screens/soso_car_detail_screen.dart` (`main.dart` 활성 상세 화면)
- **수정 내역**:
  1. 색상 토큰 단일화: 브랜드 코랄 `#F25767`, 중립 배경 `#FAF6F7`, 본문 텍스트 `#202124` / `#667085`.
  2. SliverAppBar 높이 320dp ➔ 240dp로 축소하여 첫 화면에서 핵심 모임 정보가 바로 노출되도록 개선.
  3. 섹션 배치 순서 재정렬: (1) 핵심 모임 정보 카드(일시, 장소, 안심정산) ➔ (2) 참여 멤버 아바타 스택 및 잔여석 ➔ (3) 호스트 신뢰 카드 ➔ (4) 모임 소개 ➔ (5) 상세 위치 및 지도.
  4. 호스트 카드 우측 겹침 버그 해소: `Row` 내부 `Expanded(Column(hostName, Flexible(Text('PASS 본인인증 호스트'))))` 적용으로 매너온도 게이지와의 360~390px 텍스트 겹침 해결.
  5. 길찾기 버튼을 자극적인 노란색 블록에서 정돈된 아웃라인 보조 액션(높이 44dp)으로 조정.
  6. 원화 금액 표기 제거 및 `1/N 안심 정산` 표기 통일.
- **검증**: `scripts/verify_dart_syntax.py` 괄호 및 구문 검증 통과.

---

## 📌 [4단계] 홈화면 (`04_홈화면.txt`) (완료)
- **체크포인트 백업**: `C:\Users\DT4\Downloads\oomu_app_backups\oomu_app_before_ai_20261027-153249.zip` (`testzip()` 통과, 32,588개 파일)
- **수정 대상**: `lib/screens/soso_car_home_screen.dart` (`main.dart` 활성 홈 화면)
- **수정 내역**:
  1. **정보 순서 및 큐레이션 조정**:
     - 기존 전체 탭에서 실시간 모임 피드를 밀어내던 거대 공연·트렌드 섹션을 모임 피드 하단으로 재배치하여, 첫 진입 시 동네 모임이 화면 상단(Above the fold)에 즉시 노출되도록 개선.
     - `⚡ 오늘 번개` 탭은 즉석 팟 캐러셀, `☕ 취향 아지트` 탭은 공연·뮤지컬 큐레이션 상단 유지.
  2. **시각적 공해 및 가짜 지표 제거**:
     - 검은색 그라디언트 지도 배너(`Color(0xFF0F172A)`)를 단정한 화이트 서피스 보조 탐색 버튼으로 전환하여 주요 참여 행동과의 시각적 위계 분리.
     - 확인 불가한 홍보성 가짜 문구 `"지금 이웃 54명이 모임을 보고 있어요" + "실시간 인증"` 배너 완전 제거.
     - 번개 캐러셀 및 트렌드 헤더의 과도한 `LIVE` 배지 및 볼드 이모지 절제.
  3. **모임 카드 공통 구성 통일 (`_buildMeetupCard` 블럭형 & `_buildMeetupListRow` 목록형)**:
     - 구성 순서 통일: **사진 ➔ 제목(2줄 자연스러운 줄바꿈) ➔ 일정/장소 ➔ 주최자 ➔ 참여 현황 & 잔여석**.
     - 동일한 데이터·타이포그래피·상태 표현 적용.
     - 원화 숫자 표기 배제 및 `1/N 안심 정산` / `⚡ 즉시 번개`로 통일.
     - 카드 내 가짜 뷰어 수(`$liveViewers`) 완전 제거.
- **검증**: `scripts/verify_dart_syntax.py`에 `soso_car_home_screen.dart` 등록 후 전체 15개 파일 문법·괄호 검증 통과 (`[PASS]`).

---

## ⏭️ 다음 시작점: [5단계] 프로필과 커뮤니티 (`05_프로필과_커뮤니티.txt`)
- **수정 대상**: `lib/screens/my_page_screen.dart`, `lib/screens/profile_edit_screen.dart` ➔ `lib/screens/community_post_detail_screen.dart`, `lib/screens/community_post_create_screen.dart`
- **핵심 목표**: 프로필 아바타/대표사진 중복 및 멤버십 비중 정리, 커뮤니티 카드 위계 통일 및 과도한 이중 보더 제거.
