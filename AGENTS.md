# 🏛️ OOMU (오뮤) 통합 에이전트 지침서 (AGENTS.md)

> **자동 로드 안내**: 본 파일(`AGENTS.md`)은 Antigravity 에이전트가 세션 시작 및 매 작업 턴마다 자동으로 읽어들여 메모리에 상주시키는 **최상위 통합 지침**입니다. 사용자가 매번 긴 프롬프트 머리말을 복사·붙여넣지 않아도 아래의 모든 지침과 로컬 AI 모델(Claude 7종 / GPT 9종) 라우팅이 자동 적용됩니다.

---

## 📂 1. 분리 관리되는 세부 지침 파일 맵 (Single Source of Truth)

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
   - **적용 기준**: `.antigravity/rules/ui_ux_design_rules.md`의 12년 차 수석 프로덕트 디자이너 토큰(배경/카드 명도 분리, `1px solid #EFF1F5`, 파스텔 틴트 뱃지 `#FFF4EB`, 2030/B2B 큐레이션 카피 `"✨ OOMU 공식 인증 아지트"`) 100% 반영.
2. **"짤림/겹침 해결해줘" / "레이아웃 수정해줘"**
   - **주력 모델**: `o4-mini`, `o3-mini`, `gpt-4.1`
   - **적용 기준**: `Row` 내부 `Expanded`/`Flexible` 필수, `maxLines` + `TextOverflow.ellipsis`, 고정 `height` 금지, 서브태그 우측 짤림 방지를 위한 `+N 더보기 ▾` / `접기 ▴` 트레이 구조 적용.
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

