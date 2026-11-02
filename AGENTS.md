# 🏛️ OOMU 에이전트 핵심 지침서 (AGENTS.md)

> **목적**: 대표님이 일일이 화면의 문제점(간격, 글자 크기, 컬러 부조화, 말줄임, 세션/동네 꼬임)을 찾아서 설명하지 않아도, **에이전트가 스스로 디자이너·엔지니어의 눈으로 문제를 발견하고 수정**하도록 만드는 실전 행동 지침입니다.

---

## 🚨 0. 최우선 행동 원칙 (대표님 피로도 제로 원칙)

1. **대표님께 문제 진단을 떠넘기지 않는다 (Proactive Expert Audit)**
   - 대표님이 "화면 봐줘", "디자인 다듬어줘", "검토해"라고만 요청하셔도, 에이전트는 "어디를 고칠까요?"라고 되묻거나 표면적인 수치만 바꾸고 끝내지 않습니다.
   - 반드시 아래 **[1. 전문가 시각 5대 자동 점검표]**를 기준으로 코드와 실제 화면(스크린샷)을 스스로 전수 검사하여, 일반인이 설명하기 어려운 미세 결함까지 찾아내어 고칩니다.
2. **과장된 보고 금지 (No Hype)**
   - "100% 완벽", "무결점", "1티어 풀-피니시" 같은 미사여구를 보고서에 쓰지 않습니다.
   - 실제로 발견한 문제점과 수정한 결과(Before/After 차이, 스크린샷, 정적 분석 통과 여부)만 담백하고 정직하게 보고합니다.
3. **슬래시(`/`) 명령어 안내 원칙**
   - 슬래시 명령어는 현재 IDE 환경에서 실제 지원되는지 확인되지 않은 경우 임의로 추천하지 않습니다.

---

## 🎨 1. 전문가 시각 5대 자동 점검표 (코드·화면 작업 시 필수 체크)

> **디자인 수치 단일 기준**: 모든 색상, 타이포그래피, 간격(Spacing), 터치 타깃 수치는 중복 복사하지 않고 유일한 기준 문서인 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)를 따릅니다.

에이전트는 어떤 화면을 다루든 아래 5가지를 스스로 점검하고 위반 사항을 즉시 수정합니다.

### ① 컬러 조화 & 강조 포인트 절제 (60-30-10 법칙)
- **핑크 범벅(Pink Soup) 금지**: 구형 분홍 배경(`#FAF6F7`)이나 비활성 칩, 카드 테두리, 아이콘 배경까지 전부 분홍빛으로 칠하는 구형 방식은 사용 금지 예시입니다.
- **단일 컬러 토큰 준수**: 배경·표면·텍스트·강조 포인트의 구체적인 색상 코드와 비율은 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 `[1. 컬러 시스템]`을 유일한 기준으로 적용합니다.
- **원색 충돌 금지**: 한 화면에 코랄(`#F25767`), 파랑(`#3B68FF`), 초록(`#0D9488`), 주황(`#FFF0EB` / `#FF6B4A`) 배지를 동시에 섞어 쓰지 않습니다.

### ② 타이포그래피 위계 & 어색한 줄바꿈(Widow/Truncation) 제거
- **상단 앱바(AppBar) 동네 이름 잘림 금지**: `여수시 화장동`이 `여수시 화...`처럼 잘리지 않도록 상단바의 불필요한 장식 배지(`이웃 54명...`)나 과도한 아이콘 원형 배경을 덜어내어 동네 이름이 온전히 보이게 합니다.
- **외톨이 글자(1~2글자 줄바꿈) 금지**:
  - 예: `동네 친구 & 연인 만들 / 기`, `와플집 가보신 / 분?`, `(20 / 대 중후반)`처럼 마지막 한 글자만 다음 줄로 떨어지거나 단어 중간이 끊어지지 않도록 문구 길이·패딩·자간을 다듬습니다 (Flutter `TextStyle`에 존재하지 않는 `WordBreak.keepAll` 속성은 사용하지 않음).
- **글자 크기 및 대비**: 섹션 헤더·카드 제목·본문·메타의 폰트 크기와 줄간격 수치는 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 `[2. 타이포그래피 위계]`를 참조합니다.

### ③ 간격(Spacing)·정렬·카드 중첩 제거
- **카드 안의 박스(Card-in-Card) 지양**: 카드 내부에 또 두꺼운 회색 테두리 박스를 넣어 세로 공간을 낭비하지 않습니다. 구체적인 카드 패딩·외곽선·여백 수치는 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 `[3. 레이아웃 & 컴포넌트 규칙]`을 참조합니다.
- **가로 칩 바 2중 적층 지양**: 상단에 서로 다른 모양의 가로 스크롤 태그/카테고리 바가 2줄 연속으로 쌓여 시선을 어지럽히지 않도록 통합·정리합니다.
- **하단 탭바(Bottom Navigation)**: 탭 선택 시 과도하게 큰 분홍색 원형 후광이 상하단 영역을 침범하지 않도록 깔끔한 아이콘+라벨 하이라이트로 유지합니다.

### ④ 눈에 안 보이는 세션·상태·데이터 정합성
- **계정 전환 시 잔류 상태(Stale State) 차단**: 로그인/로그아웃/계정 전환 시 이전 계정의 동네(`location`), 닉네임, 찜(`savedMeetups`), 차단/신고 등 사용자별 상태가 남지 않도록 `globalData`와 화면 상태를 즉시 초기화·동기화합니다.
- **동네 및 이미지 맥락 일치**: 유저 동네가 `여수시 화장동`이면 홈·번개·커뮤니티·소개팅 모두 여수시 모임이 노출되어야 하며, 지역 모임에 서울 랜드마크(롯데타워 등) 사진이 어색하게 매칭된 시드 데이터도 함께 교정합니다.

### ⑤ 인체공학 터치 영역 & 레이아웃 안정성
- 모든 클릭·탭 요소의 최소 터치 영역 및 오버플로우 방지 기준은 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 `[3. 레이아웃 & 컴포넌트 규칙]`을 따릅니다.
- `Row` 안의 가변 텍스트는 반드시 `Expanded`/`Flexible`로 감싸 `RenderFlex overflow`가 발생하지 않게 합니다.

---

## 📂 2. 실제 코드 경로 및 핵심 참조 파일

> **주의**: 존재하지 않는 구형 경로(`lib/features/...`, `c:/Users/developersim/...`)는 절대 참조하지 않습니다.

### A. 실제 활성 화면 경로 (`lib/screens/`)
- **앱 진입/인증**: [lib/main.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/main.dart), [lib/screens/login_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/login_screen.dart), [lib/screens/profile_setup_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/profile_setup_screen.dart)
- **메인 통합 허브 (홈·번개·커뮤니티·소개팅 탭)**: [lib/screens/soso_car_home_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_home_screen.dart)
- **모임 상세/개설**: [lib/screens/soso_car_detail_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_detail_screen.dart), [lib/screens/soso_car_host_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_host_screen.dart)
- **커뮤니티 상세/작성**: [lib/screens/community_post_detail_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_detail_screen.dart), [lib/screens/community_post_create_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_create_screen.dart)
- **채팅/마이/프로필**: [lib/screens/chat_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/chat_screen.dart), [lib/screens/soso_car_chat_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_chat_screen.dart), [lib/screens/my_page_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/my_page_screen.dart), [lib/screens/user_profile_screen.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/user_profile_screen.dart)
- **공통 데이터/헬퍼**: [lib/utils/global_data.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/global_data.dart), [lib/utils/oomu_ui_helpers.dart](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart)

### B. 핵심 디자인·검증 스킬 (`.agents/skills/` 원본 기준, 기본 1개 선택)
워크스페이스 스킬의 실제 탐색·로딩 원본 경로는 `.agents/skills/<name>/SKILL.md`입니다. 매 턴 다수의 문서를 강제 열람하지 않고 **작업 성격에 가장 적합한 관련 스킬 1개를 기본으로 선택**하며, 복합 작업 시에만 필요한 스킬을 추가 참조합니다:
1. [impeccable-design-audit](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/impeccable-design-audit/SKILL.md): 타이포그래피 위계, 카드 중첩 금지, 여백·정렬·컬러 감사
2. [taste-anti-slop](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/taste-anti-slop/SKILL.md): 촌스러운 AI 클리셰(과도한 배지, 원색 남발) 제거 및 2030 로컬 커뮤니티 톤 유지
3. [frontend-design](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/frontend-design/SKILL.md): 모바일 인체공학 레이아웃 및 바텀시트/카드 설계
4. [emil-motion-design](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/emil-motion-design/SKILL.md): 자연스러운 탭 반응 및 마이크로 인터랙션
5. [flutter-expert-performance](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/flutter-expert-performance/SKILL.md): Flutter 위젯 리빌드 최적화 및 상태 관리
6. [playwright-e2e-testing](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/playwright-e2e-testing/SKILL.md): 모바일 뷰포트 실제 화면 캡처 및 자동 검증

---

## 🛠️ 3. 작업 완료 전 필수 검증 절차

1. **정적 분석**: `C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat analyze` (컴파일 에러 및 경고 0건 확인, 로컬에 Flutter SDK가 없는 PC에서는 `python scripts/verify_dart_syntax.py` 실행)
2. **보안 지침 절대 준수 (보안 지침 수정 금지)**:
   - [`.antigravity/rules/security_distribution_rules.md`](file:///c:/Users/DT4/Downloads/oomu_app/.antigravity/rules/security_distribution_rules.md) 및 [`docs/SECURITY_AGENT_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/SECURITY_AGENT_GUIDE.md)의 **3계층 Zero-Secret 보안 원칙**은 절대 수정하거나 완화하지 않습니다.
   - 실제 외부 유료 API 키(`AIza...`, `sk-...`, R2 SecretKey 등)는 코드/Git/APK에 하드코딩하지 않고 Firestore(`config/api_keys`, `config/r2_storage`)에서 런타임 로드합니다.
   - 작업 완료 및 커밋 전 `powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1` 통과를 반드시 확인합니다.
3. **시각적 자기 검증**: 화면 수정 후에는 가능한 한 로컬 프리뷰 또는 브라우저 캡처를 통해 **내가 고친 화면의 컬러·간격·글자 줄바꿈이 실제로 자연스러운지 에이전트가 직접 눈으로 확인**한 뒤 보고합니다.
4. **배포 정책**: 대표님이 커밋/배포를 요청하신 경우에만 `git push origin main` 및 GitHub Actions 배포 성공 여부를 확인합니다.
5. **SMS/본인인증**: 비사업자 개인 프로젝트이므로 사업자등록증이 강제되는 알리고(Aligo)는 사용하지 않고 **솔라피(SOLAPI)**를 표준으로 유지합니다.
