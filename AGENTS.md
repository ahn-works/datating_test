# 🏛️ OOMU 단일 전체 지침서 (AGENTS.md)

> **목적**: 본 문서는 OOMU 프로젝트의 **유일한 단일 전체 개발·디자인·운영 지침(SSOT)**입니다.  
> 보안 지침은 [`SECURITY.md`](SECURITY.md), 품질 검수 및 QA 지침은 [`QA_AUDIT_GUIDELINES.md`](QA_AUDIT_GUIDELINES.md) 단일 문서를 따르며, 그 외 모든 설계 및 구현 원칙은 본 문서 하나로 통합합니다. (3대 단일 지침 체계)

---

## 🚨 0. 최우선 행동 원칙 (대표님 피로도 제로 & Cloudflare Code Mode MCP 상시 적용)

0. **⚡ Cloudflare Code Mode MCP 상시 적용 원칙 ([`code-mode-mcp`](https://blog.cloudflare.com/ko-kr/code-mode-mcp) / [`cloudflare/agents`](https://github.com/cloudflare/agents))**
   - **매 작업 필수 적용**: 에이전트는 모든 작업 수행 시 개별 도구/API를 1건씩 수십 번 왕복 호출하여 토큰과 시간을 낭비하는 대신, **Cloudflare Code Mode MCP(`https://mcp.cloudflare.com/mcp`, `@cloudflare/codemode`)의 `search()` + `execute()`(단일 코드 샌드박스 일괄 실행) 패러다임**을 상시 적용합니다.
   - **Progressive Discovery & Batch Code Execution**:
     1) 필요한 API/스키마만 경량 탐색(`search`)하여 컨텍스트 점유를 ~1,000 토큰 수준으로 최소화합니다.
     2) 다단계 조회·데이터 정합성 검증·Firestore/R2/네이버 지도 배치 처리는 개별 툴 연쇄 호출 대신 **단일 실행 코드(`execute` / 일괄 스크립트)**로 묶어 한 번의 턴에 처리하고 최종 요약 결과만 반환합니다.
   - **전역 및 프로젝트 설정 위치**: 전역 MCP 설정(`~/.gemini/config/mcp_config.json`의 `cloudflare-code-mode`), 전역 규칙(`~/.gemini/config/rules/cloudflare_code_mode_mcp.md`), 백엔드 패키지(`functions/package.json`의 `@cloudflare/codemode`, `agents`)에 상시 연결되어 있습니다.

1. **원본 시안 1:1 실측 대조 원칙 (Visual Diff Mandatory & No Superficial Audits)**
   - 대충 코드 몇 줄만 고치고 주관적으로 "완료되었다"고 보고하는 대충 검토 행위를 엄격히 금지합니다.
   - UI/디자인 작업 시 반드시 사용자가 첨부/지정한 **원본 시안 파일(이미지, JSX, 피그마 등)을 에이전트가 직접 `read_file`로 열어보고**, 실제 구동 중인 앱의 화면을 **Playwright 등으로 실측 캡처하여 1:1로 나란히 대조(Side-by-Side)**합니다.
   - 상단 헤더, 카테고리 칩 모양, 폰트 크기, 카드 종횡비(16:10), 여백, 우상단 하트 아이콘, 플로팅 버튼까지 요소별 차이점(Gap)이 0건임을 실측 증거(스크린샷)로 검증한 후에만 배포 및 완료 보고를 올립니다. (대표님이 3차, 5차 재검토하게 만드는 피로도 원천 차단)
2. **미사여구 및 과장 금지 (No Hype)**
   - "100% 완벽", "무결점" 등의 표현을 금지하고, 실제 원본과 대조하여 발견한 갭과 수정한 결과(수치, 실측 캡처 비교, 정적 분석, 테스트 통과 수치)만 정직하게 보고합니다.
3. **웹 캐시(Service Worker) 잔류 사전 차단**
   - 배포 후 사용자가 "그대로다"라고 느끼는 주원인인 브라우저/서비스 워커 캐시 문제를 사전에 방지하도록 캐시 무효화 및 브라우저 새로고침 안내를 철저히 병행합니다.
4. **슬래시(`/`) 명령어 안내 원칙**
   - 현재 IDE에서 실제로 지원되는지 확인되지 않은 슬래시 명령어는 임의로 추천하지 않습니다.

5. **기능 고정 원칙 (A~Z 100% 통과 시 잠금, 2026-11-27 대표 지시)**
   - 기능 하나(예: 모임 생성)를 디자인·입력 UI·지도/마커·저장·알림(신청→모임장, 승인→참여자)·나가기·서버 실시간 동기화·권한까지 **A부터 Z까지** 검사한다. 기준: [`docs/OOMU_풀스택_검사기준.md`](docs/OOMU_풀스택_검사기준.md) 5장.
   - 독립 검수 에이전트가 4칸(화면·데이터·백엔드·디자인)을 모두 '통과'로 판정하면 [`docs/FEATURE_FREEZE.md`](docs/FEATURE_FREEZE.md)와 `scripts/feature_freeze.json`에 올려 **고정**한다. 그 뒤로는 손대지 않는다.
   - Branch CI의 `scripts/check_feature_freeze.py`가 고정 파일이 바뀐 push를 실패시킨다. 고쳐야 하면 **대표님 승인 후**에만 커밋 메시지에 `[freeze-unlock: 기능 이름]`을 넣고, 수정 뒤 다시 A~Z 검사해 재고정한다.

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
- **메인 통합 허브 (홈·번개·커뮤니티·소개팅)**: [`lib/screens/oomu_home_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/oomu_home_screen.dart)
- **모임 상세 / 개설**: [`lib/screens/oomu_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/oomu_detail_screen.dart), [`lib/screens/oomu_host_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/oomu_host_screen.dart)
- **커뮤니티 상세 / 작성**: [`lib/screens/community_post_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_detail_screen.dart), [`lib/screens/community_post_create_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_create_screen.dart)
- **채팅 / 마이 / 프로필**: [`lib/screens/chat_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/chat_screen.dart), [`lib/screens/oomu_chat_room_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/oomu_chat_room_screen.dart), [`lib/screens/my_page_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/my_page_screen.dart), [`lib/screens/user_profile_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/user_profile_screen.dart)
- **공통 서비스 & 헬퍼**: [`lib/services/auth_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/auth_service.dart), [`lib/services/solapi_sms_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/solapi_sms_service.dart), [`lib/services/naver_map_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/naver_map_service.dart), [`lib/services/r2_storage_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/r2_storage_service.dart), [`lib/utils/global_data.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/global_data.dart), [`lib/utils/oomu_ui_helpers.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart)

---

## 🔄 3. 세션 무결성 & 데이터 정합성

1. **계정 전환 시 잔류 상태(Stale State) 100% 차단**
   - 로그아웃 또는 계정 변경 시 이전 사용자의 동네(`location`), 닉네임, 찜 목록, 차단/신고 내역이 화면에 남지 않도록 `globalData`를 즉시 초기화합니다.
   - 이전 비동기 요청의 응답이 계정 전환 후 도착하여 새 세션을 덮어쓰지 못하도록 세션 토큰 검증을 유지합니다.
2. **동네 및 썸네일 맥락 일치**
   - 사용자의 현재 설정 동네(예: `여수시 화장동`)와 피드/지도/커뮤니티의 지역이 완벽히 일치해야 합니다.
   - 여수시 모임 카드에 서울 롯데타워 등 엉뚱한 사진이 매칭되지 않도록 맥락을 일치시킵니다.

---

## 🛠️ 4. 작업 완료 및 배포 전 필수 검증 절차 (5단계)

에이전트는 모든 코드 작업 완료 후 반드시 아래 5단계를 순서대로 수행하여 통과를 확인해야 하며, "대충 검토"로 인해 대표님이 반복 확인하는 일이 없도록 실측 증거를 반드시 확보해야 합니다:

1. **원본 시안 1:1 실측 대조 및 화면 캡처 검증 (Visual Diff & Live Inspection)**:
   - 사용자가 제공한 원본 시안(디자인 파일, 이미지, 스펙)을 직접 열람하여 1:1 체크리스트 작성.
   - 실제 구동 중인 앱에서 실측 스크린샷(Playwright 등)을 캡처하여 시안과 나란히 대조.
   - 헤더 아이콘, 카테고리 칩 모양, 섹션 정렬 드롭다운, 카드 비율(16:10), 하트 찜 아이콘, 플로팅 버튼 등 모든 시각적 요소의 일치 여부를 실측 이미지로 전수 검증.
   - 웹 캐시(Service Worker)가 이전 코드를 잡고 있지 않도록 캐시 해제 스크립트 반영 상태 확인.

2. **보안 지침 검증 ([`SECURITY.md`](SECURITY.md))**:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1
   ```
   (7/7 전 항목 PASS 필수)

3. **구문 및 정적 분석**:
   ```powershell
   python scripts/verify_dart_syntax.py
   C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat analyze
   ```
   (수정 파일 구문 통과 및 컴파일 에러 0건 필수)

4. **단위 및 위젯 테스트**:
   ```powershell
   C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat test
   ```
   (기존 기능 회귀 없는 100% 테스트 통과 필수)

5. **프로덕션 릴리즈 빌드 및 배포 (Build & Push)**:
   ```powershell
   C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat build web --release
   git add -A
   git commit -m "..."
   git push origin main
   ```
   (웹 릴리즈 번들 생성 완료 및 GitHub 최신 동기화 완료 필수)
