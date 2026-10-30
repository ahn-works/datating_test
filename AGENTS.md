# 🏛️ OOMU (오뮤) 통합 에이전트 지침서 (AGENTS.md)

> **자동 로드 안내**: 본 파일(`AGENTS.md`)은 Antigravity 에이전트가 세션 시작 및 매 작업 턴마다 자동으로 가장 먼저 읽어들여 메모리에 상주시키는 **최상위 통합 지침**입니다. 사용자가 매번 긴 프롬프트 머리말을 복사·붙여넣지 않아도 아래의 모든 지침과 로컬 AI 모델(Claude 7종 / GPT 9종) 라우팅, 그리고 새로 추가된 22종 전문 엔지니어링 & 옵시디언 스킬이 개인 PC와 사무실 PC 구분 없이 100% 자동 적용됩니다.

---

## 🎨 0. OOMU UI/UX 디자인 기준 (단일 기준: docs/OOMU_UI_GUIDE.md 참조)

OOMU의 모든 화면·컴포넌트·리스트 작업 시 **단일 진실 공급원인 [docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)를 기준으로 설계 및 검증**합니다.

1. **핵심 방향**:
   - 2030 여성이 안심하고 편안하게 모임을 탐색·참여할 수 있는 차분하고 선명한 로컬 커뮤니티.
   - 단일 브랜드 색상 `#F25767` 및 중립 배경 `#FAF6F7`, 8dp 여백 시스템, 최소 48×48dp 터치 타깃 준수.
   - 콘텐츠 특성(제목, 주소, 시간)에 맞게 유연한 줄바꿈을 적용하며 획일적 1줄 말줄임이나 비대칭 짤림을 배제합니다.
   - 모든 모임의 금액 표기는 `1/N 안심 정산` 또는 `무료 참여`로 통일합니다.
   - **커뮤니티 피드 & 상세 타이포그래피 계층 (Typography Hierarchy)**:
     - 제목(Title): 피드 `16.5dp` / 상세 `18.5dp`, `FontWeight.w800`, 깊은 블랙 `Color(0xFF19181B)`, `letterSpacing: -0.35~-0.4`, 줄간격 `1.35`, 최대 2줄 말줄임
     - 제목-본문 간격: `8~12dp` 고정 확보 (제목과 본문이 뭉쳐 보이는 답답함 차단)
     - 본문(Content): 피드 `13.5dp` / 상세 `14.5dp`, `FontWeight.w400`, 차콜 그레이 `Color(0xFF4A4446)`, `letterSpacing: -0.15`, 쾌적한 줄간격 `1.55~1.65`
     - 서브태그 뱃지: 제목 상단 배치, 코랄 틴트 배지 (`#FFF0F2`, 보더 `#FCD3D9`, 텍스트 `coralAccent`)
     - 피드 카드: 내부 패딩 `18dp`, 둥근 모서리 `20dp`, 미세 1px 테두리 `Color(0xFFF0E8EA)`
   - **동네 위치 실시간 연동 (Neighborhood Matching)**:
     - 유저 프로필 위치(`location`, 예: `여수시 화장동`)를 홈 상단 앱바 타이틀, 피드 모임, 번개 탭과 100% 실시간 연동
     - `OomuUiHelpers.formatLocationNeighborhood` 기반으로 동/구 단위 매칭을 수행하여 타 지역(마포구 등)이 임의 노출되지 않도록 보장
2. **화면 경로 기준**:
   - `main.dart` 기준 실제 활성 화면인 `soso_car_home_screen.dart`, `soso_car_detail_screen.dart` 등을 직접 수정하며, 부존재 경로(`lib/features/...`)는 사용하지 않습니다.
3. **완료 및 검증 기준**:
   - UI 작업 완료 검증은 정적 분석(문법/괄호 무결성), 보안 규칙 검증, 실제 로컬 렌더링 확인으로 분리하여 판정합니다 (자동 `git push`/배포 강제 제외). 도구 미비로 실행하지 못한 항목은 '미검증'으로 명시합니다.

---

## 📂 1. 분리 관리되는 세부 지침 및 전문 스킬 파일 맵 (총 22종 완벽 탑재)

### A. 디자인, 모바일 성능 & E2E 검증 스킬 (16종)
| 구분 | 파일 경로 | 핵심 역할 |
| :--- | :--- | :--- |
| **OOMU 프론트엔드 디자인** | [.agents/skills/frontend-design/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/frontend-design/SKILL.md) | 30대 찐친·여성안심 철학, 5대 AI 클리셰 배제, Flutter 모바일 인체공학 터치/바텀시트, 2-Pass 디자인 검증 |
| **Emil 모션 & 마이크로 인터랙션** | [.agents/skills/emil-motion-design/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/emil-motion-design/SKILL.md) | scale(0) 금지, ease-in 금지, 스프링 물리, 버튼 탭 햅틱, 120fps GPU 렌더링 |
| **Impeccable 디자인 감사** | [.agents/skills/impeccable-design-audit/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/impeccable-design-audit/SKILL.md) | 48dp 터치 타깃, 카드 안의 카드 중첩 금지, 60+ 안티-슬롭, P0~P3 디자인 감사 |
| **Taste 브랜드 아트 디렉션** | [.agents/skills/taste-anti-slop/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/taste-anti-slop/SKILL.md) | AI 뻔한 편향(Inter, 3열 아이콘) 거부, OOMU 2030 감성 Vibe 일관성 유지 |
| **Flutter 120fps 성능 최적화** | [.agents/skills/flutter-expert-performance/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/flutter-expert-performance/SKILL.md) | Impeller 120fps 최적화, const 엄수, 메모리 누수 방지, Thumb-zone 인체공학 |
| **Playwright 모바일 E2E 검증** | [.agents/skills/playwright-e2e-testing/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/playwright-e2e-testing/SKILL.md) | Pixel 7 / iPhone 모바일 뷰포트 에뮬레이션, 콘솔 에러 제로, 비주얼 회귀 테스트 |
| **에스크로 1/N 안심 정산** | [.agents/skills/escrow-split-billing/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/escrow-split-billing/SKILL.md) | 동네 소모임 투명 1/N 안심 정산, 원화 표기 배제, 토스/카카오페이 송금 링크 |
| **하이퍼로컬 피드 엔진** | [.agents/skills/karrot-hyperlocal-feed/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/karrot-hyperlocal-feed/SKILL.md) | 당근마켓급 88x88 썸네일, 2줄 제목, 동네 인증 배지, 100:100 대칭 2열 그리드 |
| **매너온도 & 신뢰 배지** | [.agents/skills/manner-temp-badges/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/manner-temp-badges/SKILL.md) | 36.5도 기준 색상 변화 게이지, 본인인증(PASS/SMS) 배지, 클린 호스트 마크 |
| **여성 안심 & 악성유저 차단** | [.agents/skills/women-safe-anti-creep/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/women-safe-anti-creep/SKILL.md) | 호스트 승인제 신청 모달, 여성 전용 필터, 1-Click 비밀 신고/차단, 안심 귀가 타이머 |
| **모임 개설 및 상세 엔진** | [.agents/skills/event-meetup-engine/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/event-meetup-engine/SKILL.md) | 모임 상세 & 4단계 개설 플로우, 참여자 아바타 스택(AvatarStack), D-Day 카운트다운 |
| **피그마 모바일 토큰 매핑** | [.agents/skills/figma-mobile-tokens/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/figma-mobile-tokens/SKILL.md) | 선셋 코랄 팔레트, 8dp 그리드 스페이싱, Pretendard 타이포그래피 스케일 동기화 |
| **플루이드 마이크로 인터랙션** | [.agents/skills/fluid-micro-interactions/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/fluid-micro-interactions/SKILL.md) | 슬리버(Sliver) 패럴랙스 스크롤 헤더, 햅틱 피드백, 스프링 바운스 스크롤 피직스 |
| **인터랙티브 아이스브레이킹 게임** | [.agents/skills/interactive-game-icebreakers/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/interactive-game-icebreakers/SKILL.md) | 30대 동네친구/자만추 온라인 아이스브레이킹 미니게임(노래방 배틀, 타로 카드 등) UI |
| **샤드씨엔 모바일 컴포넌트** | [.agents/skills/shadcn-mobile-components/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/shadcn-mobile-components/SKILL.md) | 1px 정밀 보더 카드, 인피드 아코디언 더보기/접기, 슬림 필 도트 인디케이터 |
| **위피 감성 소셜 자만추** | [.agents/skills/wippy-social-jamanchu/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/wippy-social-jamanchu/SKILL.md) | 30대 자연스러운 자만추·스토리형 프로필, 가치관 문답, 라이프스타일 칩 컴포넌트 |

### B. 옵시디언 지식 & 마크다운 스킬 (6종)
| 스킬명 | 경로 | 핵심 역할 |
| :--- | :--- | :--- |
| **defuddle** | [.agents/skills/defuddle/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/defuddle/SKILL.md) | HTML 및 웹 콘텐츠를 읽기 쉬운 깔끔한 마크다운으로 변환 및 노이즈 제거 |
| **json-canvas** | [.agents/skills/json-canvas/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/json-canvas/SKILL.md) | 모임/지식 캔버스 시각화 데이터(.canvas) 구조 생성, 수정 및 파싱 |
| **knap** | [.agents/skills/knap/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/knap/SKILL.md) | 마크다운 문서를 Obsidian 형식으로 신속 파싱 및 서식 자동 변환 |
| **obsidian-bases** | [.agents/skills/obsidian-bases/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/obsidian-bases/SKILL.md) | 옵시디언 볼트 베이스 및 코어 지식 구조 제어 및 데이터 관리 |
| **obsidian-cli** | [.agents/skills/obsidian-cli/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/obsidian-cli/SKILL.md) | Obsidian CLI 터미널 명령을 통한 지식 베이스 검색, 관리 및 인덱싱 |
| **obsidian-markdown** | [.agents/skills/obsidian-markdown/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/obsidian-markdown/SKILL.md) | 옵시디언 특화 GFM 마크다운 서식(콜아웃, 내부 링크, 위키링크) 표준화 |

### C. 프로젝트 핵심 규칙 문서
| 구분 | 파일 경로 | 핵심 역할 |
| :--- | :--- | :--- |
| **통합 프롬프트 트리거** | [`AI_INSTRUCTIONS.md`](file:///c:/Users/developersim/Desktop/datating_test/AI_INSTRUCTIONS.md) | 질문 키워드별 자동 프롬프트 트리거 & 4대 핵심 도메인 통합 지침 |
| **프롬프트 & 모델 라우팅** | [`.antigravity/rules/prompt_routing_rules.md`](file:///c:/Users/developersim/Desktop/datating_test/.antigravity/rules/prompt_routing_rules.md) | 고정 머리말 규칙, 화면 경로별 실전 프롬프트 3선, 로컬 Claude 7종/GPT 9종 자동 매칭표 |
| **12년 차 UI/UX 디자인 규칙** | [`.antigravity/rules/ui_ux_design_rules.md`](file:///c:/Users/developersim/Desktop/datating_test/.antigravity/rules/ui_ux_design_rules.md) | 배경 `#F8F9FA` vs 카드 `#FFFFFF` 분리, 파스텔 뱃지, Overflow 0%, 2030/B2B UX Writing |
| **3계층 Zero-Secret 보안** | [`.antigravity/rules/security_distribution_rules.md`](file:///c:/Users/developersim/Desktop/datating_test/.antigravity/rules/security_distribution_rules.md) | Git/APK API 키 하드코딩 금지 (`pk-dummy` 예외), Firestore `config/*` 런타임 로드 |
| **상황별 프롬프트 플레이북** | [`docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`](file:///c:/Users/developersim/Desktop/datating_test/docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md) | `[상황 1]~[상황 5]` 시나리오별 프롬프트 및 로컬 AI 모델 호출 가이드 |
| **통합 마스터 스펙** | [`docs/OOMU_MASTER_SPEC.md`](file:///c:/Users/developersim/Desktop/datating_test/docs/OOMU_MASTER_SPEC.md) | 하이브리드 아키텍처, B2B 아지트 & 정산, 에스크로, 트렌드 파이프라인 명세 |

---

## 🤖 2. 로컬 설치 AI 브릿지 (Claude 7종 + GPT 9종, 총 16개 모델) 상시 활용 규칙

- **구동 서버**: `ddg_proxy.py` (`http://127.0.0.1:1337/v1`, OpenAI 호환 엔드포인트)
- **고정 API Key**: `'pk-dummy'` (100% 무료 로컬 브릿지)
- **CLI 호출 명령**: `.venv\Scripts\python.exe scripts/claude_client.py --model <모델명> "<프롬프트>"`
- **Flutter 앱 내 서비스**: `lib/services/ai_service.dart` (`OomuAiService.instance`)

### 작업 요청별 자동 매칭 모델
1. **"디자인 수정해줘" / "문구·B2B 다듬어줘"**
   - **주력 모델**: `claude-3-5-sonnet`, `claude-3-sonnet`, `claude-haiku-4.5`, `claude-opus-4`
   - **적용 기준**: **제0원칙(당근·위피·문토·오늘의집·무신사 벤치마킹)** 및 `.antigravity/rules/ui_ux_design_rules.md`의 12년 차 수석 프로덕트 디자이너 토큰(배경/카드 명도 분리, `1px solid #EFF1F5`, 파스텔 틴트 뱃지 `#FFF4EB`, 2030/B2B 큐레이션 카피 `"✨ OOMU 공식 인증 아지트"`) 100% 반영.
2. **"짤림/겹침 해결해줘" / "레이아웃 수정해줘"**
   - **주력 모델**: `o4-mini`, `o3-mini`, `gpt-4.1`
   - **적용 기준**: 좌우 100:100 대칭(`Expanded` 1:1 분할), `Row` 내부 `Expanded`/`Flexible` 필수, `maxLines` + `TextOverflow.ellipsis`, 고정 `height` 금지, 서브태그 및 인피드 카드 우측 짤림 방지를 위한 `+N 더보기 ▾` / `접기 ▴` 트레이 구조 적용.
3. **"풀스택 연동해줘" / "기능 구현해줘"**
   - **주력 모델**: `gpt-4.1`, `gpt-4o`, `claude-sonnet-4`, `claude-opus-4`
   - **적용 기준**: Flutter ↔ Firestore ↔ Cloudflare R2 실시간 연동, `OomuAiService`(`claude-3-haiku` / `gpt-4o-mini` / `claude-3-5-sonnet` / `o4-mini`) 및 폴백 안전성 보장.

---

## 🧭 3. OOMU 공식 카테고리 체계 (홈 / 동네모임)

- **기본 진입 탭**: `전체` (전체 모임 + 인피드 실시간 트렌드 큐레이션 + 블럭형 `⊞` / 목록형 `☰` 뷰 전환)
- **1대 탭: `⚡ 오늘 번개` (Today & Now)**
  - 당일/주말 즉시 만나는 오프라인 일상 소모임 (사전 예매가 필요한 먼 날짜 콘서트 배치 금지)
  - 서브태그: `#전체`, `#혼술바동행`, `#불금코노·술`, `#맛집털기`, `#오늘번개`
- **2대 탭: `☕ 취향 아지트` (Hobby & Culture)**
  - 취미, 공연, 전시, 보드게임, 독서 등 취향 기반 모임
  - 서브태그: `#전체`, `#공연·전시`, `#카페·디저트`, `#보드게임·방탈출`, `#북카페·독서`
- **3대 탭: `🏃‍♂️ 라이프 메이트` (Life & Daily)**
  - 1인 가구, 동성 친구, 일상 액티비티 생활 밀착형 모임
  - 서브태그: `#전체`, `#러닝·운동`, `#1인가구장보기/소분`, `#동성캠핑`, `#동네산책`

---

## 🚨 4. 완료 보고 전 필수 사전 검증 게이트 (Pre-Report Verification Gate — 절대 위반 금지)

에이전트는 코드나 HTML 시안/아티팩트를 수정한 뒤 **사용자에게 "완료했습니다"라고 답변하기 전에 반드시 아래 사전 검증을 먼저 실행하여 100% 정상 표시됨을 직접 확인**해야 합니다. 검증 없이 완료 보고만 먼저 하는 행위는 엄격히 금지합니다.

1. **HTML 시안 / 아티팩트 수정 시 (백지 화면·JS 문법 오타 원천 차단)**
   - 파이썬 다중 줄 문자열(`"""..."""`)에서 `\n` 이스케이프가 풀려 JS 단일 따옴표 문자열(`'...'`)이 줄바꿈으로 쪼개지는 `SyntaxError`(화면 백지 현상)가 없는지 반드시 확인합니다.
   - 보고 전 필수 실행 명령:
     ```powershell
     .\.venv\Scripts\python.exe scripts/verify_before_report.py --html "<아티팩트_HTML_절대경로>"
     ```
   - 위 스크립트가 `[SUCCESS] 오타·문법·렌더링 사전 검증 100% 통과!`를 출력하고, 수정된 파일의 핵심 라인(`view_file`)과 DOM 렌더링 엔트리(`render()`)가 정상임을 확인한 뒤에만 완료 보고를 작성합니다.
2. **Flutter / Dart 코드 수정 시**
   - 보고 전 반드시 `flutter analyze` 및 관련 테스트(`flutter test`)를 실행하여 오타·미정의 심볼·문법 에러·`RenderFlex overflow` 위험이 **0건**임을 확인한 후 보고합니다.
3. **보안 및 Git 푸시 전**
   - `powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1` 통과 여부를 확인합니다.

---

## 📱 5. SMS & 본인인증 프로바이더 선정 절대 수칙 (알리고 금지 & 솔라피 표준화)

> **[필독 경고] 알리고(Aligo) 연동 절대 금지**:
> 알리고는 웹 회원가입 시 '개인' 유형이 있더라도, **API Key 발급 페이지(admin/api/auth.html)에서 자바스크립트 checkCert() 검사를 통해 강제로 사업자등록 인증 페이지(/admin/account.html)로 튕겨내므로 사업자등록증이 없는 개인 개발자는 API Key 발급이 물리적으로 불가능**합니다.
> 비사업자 개인 대표님/개발자 프로젝트에 알리고를 추천하거나 연동을 시도하는 행위를 절대 엄금합니다.

### 🌟 비사업자 개인 공식 인증 솔루션: 솔라피 (SOLAPI, 구 CoolSMS)
1. **사업자등록증 불필요**:
   - 휴대폰 본인인증(PASS/SMS)만으로 개인 회원 가입 및 즉시 API Key / API Secret Key 발급이 가능합니다.
2. **발신번호 등록**:
   - 회원 가입 시 인증받은 본인 명의 휴대폰 번호가 무료로 발신번호로 자동/즉시 등록됩니다 (유효기간 24개월).
3. **소액 충전 및 경제적 단가**:
   - 카드/간편결제: 최소 10,000원 (VAT 포함 11,000원)
   - 전용 가상계좌 입금: **최소 1,000원부터 충전 가능** (초기 자본 묶임 방지)
   - 단문 SMS: 건당 10~18원대, 알림톡 8~13원대
4. **개인 발송 한도**:
   - 일일 50~500건 발송 한도 제공 (초기 베타 및 본인인증 용도로 완벽히 충분)

---

## ⚙️ 6. 24/7 B2B 자율 무인 운영 엔진 & GitHub Actions Cron 자동화 체계

OOMU는 대표님이 일일이 수동 관리하지 않아도 앱이 살아 숨쉬는 커뮤니티로 유지되도록 깃허브 액션(.github/workflows/oomu_cron_ops.yml) 기반의 24시간 자율 무인 운영 엔진을 탑재하고 있습니다.

| 파이프라인 | 실행 스크립트 | 실행 주기 (KST) | 핵심 역할 및 B2B 운영 효과 |
| :--- | :--- | :--- | :--- |
| **☕ 주말 핫플/공연 크롤링** | scripts/sync_trends.py | 매주 목요일 23:00 | KOPIS 공연전시 + 공공데이터 서울 핫플을 Firestore에 자동 업데이트 |
| **🧊 콜드 스타트 방지 모임 생성** | scripts/seed_meetups.py | 매주 수/금/토 17:00 | 7개 한국인 감성 페르소나 계정으로 트렌디한 번개 모임 자동 생성 |
| **🗳️ 아침 연애 밸런스 게임** | scripts/daily_balance_game.py | 매일 09:00 | 30여 개 2030 공감 투표 주제를 커뮤니티에 자동 배달하여 앱 체류시간 증대 |
| **🧹 유령 모임 & 지난 카풀 청소** | scripts/cleanup_stale_data.py | 매일 자정 00:00 | 약속 시간이 지난 번개/카풀을 자동 종료(closed) 처리하여 신선도 유지 |
| **🚨 악성/불량 게시글 실시간 필터링** | scripts/content_moderator.py | 상시 및 자정 | 스팸, 성매매, 도박, 외부 메신저 유도 키워드를 감지하여 자동 블라인드 |
| **📉 휴면 유저 컴백 유도 (리텐션)** | scripts/retention_booster.py | 매일 09:00 | 3일 이상 미접속 회원에게 무료 복귀 하트 충전 안내 알림 트리거 |
| **📊 노션 일일 경영 보고서 & 알림** | scripts/daily_ops_report.py | 매일 밤 23:59 | 오늘 가입자, 활성 모임, 잔여 모임 지표를 집계하여 **노션 DB에 행(Row) 자동 동기화** 및 텔레그램 발송 |
| **🛡️ 파이어베이스 정기 백업** | scripts/backup_firestore.py | 매주 일요일 04:00 | Firestore 6대 핵심 컬렉션 전체를 Gzip JSON 압축하여 깃허브 아티팩트로 안전 보관 |

- **독립 실행 구조**: 모든 스크립트는 scripts/firestore_helper.py의 순수 파이썬 REST API 클라이언트로 구동되므로 무거운 SDK 설치 없이 30초 내 완벽 실행됩니다.
- **수동 트리거 지원**: GitHub 저장소의 Actions > OOMU 24/7 B2B Operations & Cron Automation > Run workflow 메뉴에서 언제든지 개별 또는 전체 작업을 즉시 수동 실행할 수 있습니다.

---

## 💼 7. 프로페셔널 직원 마인드셋 & 팩트체크 필수 원칙 (False Claim Zero)

1. **유료 고용된 정직원의 책임감 유지**:
   - 에이전트는 스스로를 단순한 챗봇이 아닌, **대표님의 소중한 자본과 시간을 지키는 1등 프로덕트 엔지니어/운영 직원**으로 인식해야 합니다.
2. **추측성 답변 및 미확인 정책 안내 원천 금지**:
   - 외부 API 연동 가능 여부, 결제/과금 정책, 회원 유형별 제약사항 등을 답변할 때 어설픈 기억이나 추측으로 '사업자 없이 됩니다'라고 잘못 말하지 않습니다.
   - 반드시 **공식 기술 문서, 공식 FAQ, 실제 웹 서비스 DOM/JavaScript 코드, 실제 결제/인증 API 스펙을 100% 교차 검증**한 뒤에만 확정 답변을 드립니다.
3. **사전 검증 통과 전 완료 보고 금지**:
   - 코드 작성이나 세팅 완료 후 '다 되었습니다'라고 말하기 전에, 반드시 브라우저 테스트, 로컬 단위 검증, GitHub Actions 성공 여부를 먼저 확인한 뒤 증거(로그, 스크린샷, 실행 결과)와 함께 보고합니다.

---

## 💻 8. 개인 PC 안티그래비티 원격·교차 연속 작업 가이드 (Cross-PC Continuity)

본 프로젝트는 원격 저장소(`origin main`)를 통해 사무실 PC와 개인 PC 간 완벽한 연속 작업 환경을 제공합니다:
1. **스킬 & 지침 자동 로드**:
   - 개인 PC에서 본 프로젝트를 열거나 `git pull origin main`을 실행하면 `.agents/skills/` 내 22종 스킬(모바일/디자인 16종 + 옵시디언 6종)과 `AGENTS.md` 지침이 Antigravity 에이전트 메모리에 자동 상주합니다.
2. **작업 인수인계 시 필수 순서**:
   - **작업 시작 시**: `git pull origin main`으로 최신 상태 동기화
   - **코드/UI 수정 시**: 실제 활성 경로인 `soso_car_home_screen.dart` 및 `docs/OOMU_UI_GUIDE.md` 기준으로 작업 (부존재 경로 `lib/features/...` 사용 금지)
   - **커밋 전**: `flutter analyze` 및 `powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1` 검증 100% 통과 필수
   - **커밋 후**: `git push origin main` 후 GitHub Actions `Flutter Web Deploy` 초록색 체크(`completed success`)를 반드시 확인합니다.
