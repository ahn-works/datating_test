# 🏛️ OOMU 단일 전체 지침서 (AGENTS.md)

> **목적**: 본 문서는 OOMU 프로젝트의 **유일한 단일 전체 개발·디자인·운영 지침(SSOT)**입니다.  
> 보안 지침은 [`SECURITY.md`](SECURITY.md) 단일 문서를 따르며, 그 외 모든 설계 및 구현 원칙은 본 문서 하나로 통합합니다.

---

## 🚨 0. 최우선 행동 원칙 (대표님 피로도 제로)

1. **능동적 전문가 감사 (Proactive Audit)**
   - 대표님이 문제를 일일이 찾아 설명하지 않아도, 에이전트가 디자이너·엔지니어의 시각으로 코드와 실제 화면(스크린샷)을 스스로 전수 점검하여 미세 결함까지 선제적으로 수정합니다.
2. **미사여구 및 과장 금지 (No Hype)**
   - "100% 완벽", "무결점" 등의 표현을 금지하고, 실제 발견한 문제와 수정한 결과(수치, 정적 분석, 테스트 통과)만 정직하게 보고합니다.
3. **슬래시(`/`) 명령어 안내 원칙**
   - 현재 IDE에서 실제로 지원되는지 확인되지 않은 슬래시 명령어는 임의로 추천하지 않습니다.

---

## 🎨 1. 컬러 & 디자인 시스템 (단일 디자인 표준)

### ① 60-30-10 컬러 시스템
- **배경 (60%)**: 퓨어 화이트 (`#FFFFFF`) 및 은은한 오프화이트/크림톤 (`#F8F9FA`, `#FAFAFA`).
- **표면/카드 (30%)**: 정갈한 화이트 표면 + `1px` 초미세 테두리 (`#F0F0F0` 또는 `#E5E7EB`). 
- **강조 포인트 (10%)**: OOMU 시그니처 코랄 (`#FF5A5F` / `#F25767`) 및 절제된 보조 뱃지.
- **금지 사항**:
  - 화면 전체가 핑크빛으로 뒤덮이는 **구형 핑크 범벅(Pink Soup, `#FAF6F7`) 절대 금지**.
  - 한 화면에 코랄, 파랑, 초록, 주황 등 원색 뱃지를 무분별하게 혼합하는 행위 금지.

### ② 타이포그래피 위계 & 외톨이 줄바꿈(Widow) 방지
- **상단 앱바(AppBar)**: 동네 이름(`여수시 화장동`)이 `여수시 화...`처럼 잘리지 않도록 불필요한 장식 뱃지나 과도한 아이콘 배경 원을 덜어내어 온전히 노출합니다.
- **외톨이 글자(1~2글자 줄바꿈) 방지**:
  - `동네 친구 & 연인 만들 / 기`, `와플집 가보신 / 분?`처럼 마지막 1~2글자만 다음 줄로 떨어지지 않도록 문구, 패딩, 자간을 다듬습니다. (Flutter에 없는 `WordBreak.keepAll` 속성은 사용하지 않음).
- **폰트 위계**:
  - 화면 타이틀: `20~22px` (Bold / Pretendard)
  - 섹션 헤더: `16~18px` (SemiBold)
  - 카드 본문: `14~15px` (Regular / Medium, `#262626`)
  - 캡션/메타: `12~13px` (`#8E8E93`)

### ③ 간격(Spacing) & 레이아웃 안정성
- **카드 안의 박스(Card-in-Card) 금지**: 카드 내부에 불필요하게 두꺼운 회색 테두리 박스를 중첩하지 않고 패딩(`16px`)과 간격으로 깔끔하게 구분합니다.
- **2중 가로 칩 스크롤 지양**: 상단에 태그 바와 카테고리 바가 2줄 연속으로 쌓이지 않도록 정리합니다.
- **인체공학 터치 타깃**: 모든 클릭/탭 요소는 최소 `44x44px` 이상의 터치 영역을 확보합니다.
- **오버플로우 방지**: `Row` 내 가변 텍스트는 반드시 `Expanded` 또는 `Flexible`로 감싸 `RenderFlex overflow`를 원천 차단합니다.

---

## 📂 2. 실제 코드 경로 및 단일 아키텍처 (SSOT)

> 존재하지 않는 레거시 경로(`lib/features/...`, `c:/Users/developersim/...`)는 절대 참조하지 않습니다.

- **앱 진입 & 인증**: [`lib/main.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/main.dart), [`lib/screens/login_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/login_screen.dart), [`lib/screens/profile_setup_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/profile_setup_screen.dart)
- **메인 통합 허브 (홈·번개·커뮤니티·소개팅)**: [`lib/screens/soso_car_home_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_home_screen.dart)
- **모임 상세 / 개설**: [`lib/screens/soso_car_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_detail_screen.dart), [`lib/screens/soso_car_host_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_host_screen.dart)
- **커뮤니티 상세 / 작성**: [`lib/screens/community_post_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_detail_screen.dart), [`lib/screens/community_post_create_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_create_screen.dart)
- **채팅 / 마이 / 프로필**: [`lib/screens/chat_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/chat_screen.dart), [`lib/screens/soso_car_chat_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_chat_screen.dart), [`lib/screens/my_page_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/my_page_screen.dart), [`lib/screens/user_profile_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/user_profile_screen.dart)
- **공통 서비스 & 헬퍼**: [`lib/services/auth_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/auth_service.dart), [`lib/services/solapi_sms_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/solapi_sms_service.dart), [`lib/services/kakao_map_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/kakao_map_service.dart), [`lib/services/r2_storage_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/r2_storage_service.dart), [`lib/utils/global_data.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/global_data.dart), [`lib/utils/oomu_ui_helpers.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart)

---

## 🔄 3. 세션 무결성 & 데이터 정합성

1. **계정 전환 시 잔류 상태(Stale State) 100% 차단**
   - 로그아웃 또는 계정 변경 시 이전 사용자의 동네(`location`), 닉네임, 찜 목록, 차단/신고 내역이 화면에 남지 않도록 `globalData`를 즉시 초기화합니다.
   - 이전 비동기 요청의 응답이 계정 전환 후 도착하여 새 세션을 덮어쓰지 못하도록 세션 토큰 검증을 유지합니다.
2. **동네 및 썸네일 맥락 일치**
   - 사용자의 현재 설정 동네(예: `여수시 화장동`)와 피드/지도/커뮤니티의 지역이 완벽히 일치해야 합니다.
   - 여수시 모임 카드에 서울 롯데타워 등 엉뚱한 사진이 매칭되지 않도록 맥락을 일치시킵니다.

---

## 🛠️ 4. 작업 완료 전 필수 검증 절차 (3단계)

에이전트는 모든 코드 작업 완료 후 반드시 아래 3단계를 수행하여 통과를 확인해야 합니다:

1. **보안 지침 검증 ([`SECURITY.md`](SECURITY.md))**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1
   ```
2. **구문 및 정적 분석**:
   ```powershell
   python scripts/verify_dart_syntax.py
   C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat analyze
   ```
   (컴파일 에러 0건 필수)
3. **단위 및 위젯 테스트**:
   ```powershell
   C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat test
   ```
   (전체 테스트 통과 필수)
