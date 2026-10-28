# 🎨 OOMU 통합 UI/UX 단일 가이드 (docs/OOMU_UI_GUIDE.md)

> **문서 목적**: OOMU(Spot10) 앱의 화면·컴포넌트·인터랙션을 다루는 모든 에이전트와 개발자가 기준으로 삼는 **단일 진실 공급원(Single Source of Truth)**입니다.  
> 여러 지침 문서(`AGENTS.md`, `AI_INSTRUCTIONS.md`, 규칙 파일들)의 UI 지침 중복·충돌을 해소하고, 실제 로컬 코드 및 렌더링 결과에 기반한 현실적이고 검증 가능한 기준을 제공합니다.

---

## 1. 서비스 핵심 정체성 및 톤앤매너
- **서비스 정의**: 2030 여성이 안전하고 자유롭게 일상 모임을 열고 참여하는, 차분하고 읽기 쉬운 로컬 커뮤니티.
- **방향성**:
  - 자극적인 데이팅/설렘 클리셰(틴더식 스와이프, 과도한 이성 어필, 선정적 색상) 및 관공서 표 스타일 배제.
  - 지나치게 많은 홍보 뱃지·'LIVE' 수치·인증 마크를 남발하지 않고, 확인 가능한 실제 데이터만 깔끔하게 전달.
  - 신규 매칭·안심귀가 기능 구현은 별도 과제로 분리하고, 현재 단계에서는 **기존 기능의 시각적 명확성과 인체공학적 사용성**에 집중.

---

## 2. 컬러 시스템 (Color Palette)
단일하고 일관된 테마 색상을 사용하며, 장식용 칩마다 무지개색을 임의 배정하지 않습니다.

| 역할 | 토큰명 / 헥스코드 | 용도 |
| :--- | :--- | :--- |
| **Brand / Primary Action** | `#F25767` (코랄 로즈) | 주요 액션 버튼(신청, 등록), 활성 탭 인디케이터, 핵심 강조 |
| **Background** | `#FAF6F7` (소프트 로즈 크림) | 앱 전체 스캐폴드 배경, 여백 영역 |
| **Surface / Card** | `#FFFFFF` (순백) | 리스트 카드, 바텀시트, 팝업, 인풋 필드 배경 |
| **Primary Text** | `#202124` / `#221B1D` | 화면 제목, 카드 타이틀, 핵심 본문 |
| **Secondary Text** | `#667085` / `#635559` | 일정·장소 메타데이터, 부제목, 라벨 |
| **Border / Divider** | `#E7E9ED` / `#EFE4E6` | 1px 미세 구분선, 카드 외곽선 |
| **Trust / Success** | `#0D9488` (딥 틸) | 본인인증·검증된 호스트 배지, 거리 안내 |
| **Destructive / Error** | `#E11D48` (로즈 레드) | 신고, 차단, 삭제, 에러 상태 아이콘 |

---

## 3. 타이포그래피 (Typography)
- **기본 서체**: Pretendard 공식 배포 (또는 시스템 고딕 폴백).
- **계층 및 크기 기준**:
  - **대제목 (Screen Header)**: 20~22sp, FontWeight.w700, 행간(height) 1.3~1.4
  - **섹션/카드 제목 (Card Title)**: 16~18sp, FontWeight.w600, 행간 1.4
  - **본문 (Body)**: 15sp, FontWeight.w400~w500, 행간 1.5
  - **보조 메타 (Caption/Meta)**: 13sp, FontWeight.w400
  - **초소형 보조 (Tiny Tag)**: 12sp (중요하지 않은 짧은 뱃지 표시로만 제한)
- **텍스트 줄바꿈 및 오버플로우 원칙**:
  - Flutter 기본 `Text` 위젯에 존재하지 않는 `wordBreak: WordBreak.keepAll` 전역 강제 지시를 배제하고, 공식 Text API(`overflow`, `maxLines`, `softWrap`)를 준수합니다.
  - 모든 문구를 기계적으로 1줄 말줄임하지 않고, 주소·시간·모임 소개 등 정보 전달이 필요한 항목은 2줄 이상 유연하게 줄바꿈합니다.
  - 전역 폰트 확대를 차단하는 방식으로 겹침을 숨기지 않고, 글자가 커져도 유연하게 확장되는 레이아웃을 제공합니다.

---

## 4. 간격, 터치 타깃 및 모서리 (Spacing & Geometry)
- **8dp 그리드 시스템**: 여백은 `4`, `8`, `12`, `16`, `20`, `24`, `32dp`를 표준으로 합니다.
  - 연관된 정보(예: 제목과 날짜) 사이는 좁게(4~8dp), 서로 다른 정보 블록 사이는 넓게(16~24dp) 배치해 시각적 그룹핑을 강화합니다.
- **최소 터치 타깃 (Touch Target)**: 탭 가능한 모든 버튼, 아이콘, 칩은 시각적 크기와 무관하게 최소 **48×48 logical pixel** 이상의 인터랙션 영역을 보장합니다.
- **모서리 곡률 (Border Radius)**:
  - 버튼/인풋: `12dp`
  - 카드 표면: `16dp`
  - 바텀시트: `24dp` (상단 라운딩)
  - 모든 영역에 보더, 그림자, 카드를 과도하게 중첩하지 않습니다.

---

## 5. 실제 화면 경로 맵 (Screen Architecture Map)
`main.dart`의 실제 빌드 트리를 기준으로 추적한 화면 목록입니다.

### 5-1. 활성 화면 (Active Screens — 실제 사용 중)
1. **앱 진입 및 게이트웨이**:
   - `lib/main.dart`: `Spot10App` 엔트리포인트, `_AuthGate` 분기
   - `lib/screens/login_screen.dart`: 로그인 화면
   - `lib/screens/profile_setup_screen.dart`: 신규 가입자 프로필 설정 화면
2. **홈 및 대시보드**:
   - `lib/screens/soso_car_home_screen.dart`: `OOMUHomeScreen` (모임, 커뮤니티, 채팅, 마이페이지 탭 통합 허브)
3. **모임 상세 및 개설**:
   - `lib/screens/soso_car_detail_screen.dart`: 모임 상세 페이지 (실제 연결 경로)
   - `lib/screens/soso_car_host_screen.dart`: 모임 개설 폼 (실제 연결 경로)
4. **프로필 및 설정**:
   - `lib/screens/my_page_screen.dart`: 마이페이지 탭
   - `lib/screens/profile_edit_screen.dart`: 프로필 수정 화면
   - `lib/screens/user_profile_screen.dart`: 타인 프로필 조회 화면
5. **커뮤니티**:
   - `lib/screens/community_post_detail_screen.dart`: 동네 커뮤니티 상세
   - `lib/screens/community_post_create_screen.dart`: 동네 커뮤니티 글 작성
6. **탐색 및 지도**:
   - `lib/screens/explore_map_screen.dart`: 카카오맵 기반 동네 탐색
   - `lib/screens/soso_spot_screen.dart`: 스팟 정보
   - `lib/screens/filter_screen.dart`: 카테고리/지역 상세 필터
7. **채팅 및 알림**:
   - `lib/screens/chat_screen.dart`: 채팅 목록
   - `lib/screens/soso_car_chat_screen.dart`: 개별 모임 단체 채팅방
   - `lib/screens/notification_screen.dart`: 알림함
8. **공통 상태 및 지원 화면**:
   - `lib/screens/empty_state_screen.dart`: 공통 빈 상태
   - `lib/screens/error_screen.dart`: 공통 네트워크 오류 상태
   - `lib/screens/saved_meetups_screen.dart`: 찜한 모임 목록
   - `lib/screens/event_detail_screen.dart`: 공연/전시 이벤트 상세

### 5-2. 레거시/미연결 화면 (Legacy / Disconnected Screens — 삭제 금지, 보존)
현재 `main.dart` 빌드 트리에서 직접 도달하지 않으나 코드가 보존되어 있는 화면:
- `lib/screens/home_screen.dart` (구형 홈)
- `lib/screens/party_screen.dart` (구형 모임 목록)
- `lib/screens/party_detail_screen.dart` (구형 모임 상세)
- `lib/screens/party_host_screen.dart` (구형 모임 개설)
- `lib/screens/party_application_screen.dart` (구형 모임 신청)
- `lib/screens/local_friends_screen.dart` (구형 동네 친구 목록)
- `lib/screens/travel_payment_screen.dart` (구형 정산 화면)

### 5-3. 부존재 가상 경로 (Past Non-Existent Paths — 지침 오기록 수정)
- ❌ `lib/features/home/home_screen.dart`, `lib/features/party/...`, `lib/features/venue/...`, `lib/features/admin/...`, `lib/features/chat/...`
- OOMU 앱은 `lib/screens/...` 평탄화 구조를 사용하므로 지침에서 위 가상 경로를 호출하지 않습니다.

---

## 6. UI 작업 및 검증 원칙 (Verification Protocol)
1. **과도한 수식어 배제**: '100점·무결점·12년 차' 등 측정 불가능한 수식어 대신, 실제 렌더링된 화면과 정적 분석 결과로 완성도를 증명합니다.
2. **검증 단계 분리**:
   - **코드 무결성**: 정적 구문 및 괄호 검사(`scripts/verify_dart_syntax.py`), 컴파일 에러 0건.
   - **보안 검증**: 제로 시크릿(`scripts/verify_security_rules.ps1`).
   - **실제 렌더링**: 로컬 웹/안드로이드 화면 캡처 또는 렌더링 확인. 도구 미비로 실행하지 못한 항목은 솔직하게 '미검증'으로 기록.
3. **배포 및 Git 격리**: 로컬 UI 작업 단계에서 `git push`, 자동 배포를 강제하지 않습니다.
4. **금액 표기 원칙**: 실제 확인된 비용 정보(`fee`/`cost`/`price`)가 있을 때만 표시하며, 정보가 없는데 임의로 `'무료 참여'`나 `'1/N 안심 정산'` 배지로 대체하지 않습니다.

---

## 7. 한국 모임 앱 5종 레퍼런스 재해석 기준 (2026-10-27)
공개 웹 및 공식 디자인 시스템 문서를 바탕으로 검증된 사실과 OOMU 맞춤 적용 기준입니다. (경쟁사 네이티브 내부 실측치가 아니며 OOMU의 초기 제안 기준임)

| 레퍼런스 | 관찰 사실 (공개 웹 / 문서) | OOMU 재해석 및 적용 기준 |
| :--- | :--- | :--- |
| **문토** | 목적별 탐색 구조, 밝은 바탕과 사진·제목 중심의 분위기 형성 | `⚡ 오늘 번개`(즉석), `☕ 취향 아지트`(취미), `🏃‍♂️ 라이프 메이트`(생활) 3대 탭 유지. 다단 기획 배너 과밀은 배제하고 모임 피드를 최우선 노출. |
| **프립** | 사진 → 지역 → 제목 → 일정 정보 위계, 테두리 대신 정렬 중심 그룹핑 | 카드 위계를 **사진 ➔ 제목 ➔ 일정/장소 ➔ 주최자 ➔ 참여인원**으로 단일화. 안심정산 배지는 표시하지 않고 실제 비용 정보만 상세에 노출. |
| **당근 SEED** | 좌우 16px·칩 8px 등 역할별 간격 토큰, 글자 크기+줄높이+두께 일체 정의, 주/보조 액션 무게 분리 | 간격 토큰(좌우 16~20, 카드 내부 16, 정보 간 6~8, 묶음 12~16, 섹션 간 24~32dp) 채택. 최소 48×48dp 터치 타깃 보장 및 보조 지도 버튼의 시각적 무게 절제. |
| **소모임** | 지역/취미 기반 모임 탐색 및 정모 참여 과업 확인 (스토어 안내) | 동네 설정과 관심사 정모 참여라는 핵심 유저 저니만 보조 참고 (네이티브 수치 미확인 명시). |
| **위피** | 프로필 관심사와 일상 사진·문답을 대화 시작점으로 활용 | 프로필의 취향 칩과 일상 문답을 대화 진입점으로 활용하되, 외모/스펙 평가 중심 데이팅 클리셰는 원천 배제. |
