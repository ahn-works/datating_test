# 🎯 OOMU 작업별 고정 프롬프트 & 로컬 AI 모델(Claude 7종 / GPT 9종) 자동 라우팅 지침

> **적용 범위**: 본 문서는 사용자가 매번 프롬프트를 복사·붙여넣기하지 않아도 에이전트가 **모든 턴(Turn) 시작 시 자동으로 선행 적용**해야 하는 **고정 머리말 지침, 화면 경로별 실전 프롬프트, 로컬 AI 모델(총 16종) 라우팅 규칙**을 분리·정의합니다.

---

## 1️⃣ [상시 자동 동기화] 필수 선행 열람 및 메모리 상주 파일 6종

에이전트는 OOMU 프로젝트의 모든 작업을 수행할 때 아래 6개 핵심 지침 및 로컬 AI 브릿지 명세를 상시 기준(Single Source of Truth)으로 삼습니다.

1. **`AI_INSTRUCTIONS.md`**: 질문 키워드별 자동 프롬프트 트리거 & 로컬 설치된 Claude 7종 / GPT 9종 모델 매핑 통합 지침
2. **`.antigravity/rules/ui_ux_design_rules.md`**: 12년 차 수석 프로덕트 디자이너 UI/UX 토큰 (배경 `#F8F9FA` vs 카드 `#FFFFFF` 분리 또는 테마 토큰, `1px solid #EFF1F5` 보더, 파스텔 뱃지, UX 겹침/Overflow 0%, `+더보기 ▾` 트레이, 2030/B2B UX Writing 규칙)
3. **`.antigravity/rules/prompt_routing_rules.md` (본 문서)** & **`docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`**: 고정 머리말 및 `[상황 1]~[상황 5]`·화면별 실전 프롬프트 및 로컬 모델 매칭 가이드
4. **`ddg_proxy.py` & `scripts/claude_client.py`**: 로컬 `http://127.0.0.1:1337/v1`, API Key `'pk-dummy'`로 백그라운드 구동 중인 무료 Claude 7종 / GPT 9종 호출 브릿지
5. **`lib/services/ai_service.dart` & `lib/features/matching/match_controller.dart`**: Flutter 앱 내 `OomuAiService` 로컬 AI 연동 서비스 및 하이브리드 매칭 컨트롤러
6. **`docs/OOMU_MASTER_SPEC.md` & `.antigravity/rules/security_distribution_rules.md`**: OOMU 통합 마스터 스펙 및 3계층 Zero-Secret 보안 규칙

---

## 2️⃣ [모든 작업 요청 시 자동 발동] 고정 머리말 규칙 (Auto-Prepend Header)

사용자가 짧은 한 줄로 요청하더라도(예: *"디자인 수정해줘"*, *"겹침 해결해줘"*, *"문구/B2B 수정해줘"*, *"풀스택 연동해줘"*), 에이전트는 내부적으로 아래 고정 머리말이 앞에 붙은 것으로 간주하고 **100% 동일하게 실행**합니다.

```markdown
[필수 선행 지시: 파일 열람 및 모델 매칭]
작업하기 전에 반드시 아래 규칙과 로컬 AI 모델을 100% 적용한다:
- 디자인/UX/카피 규칙: `.antigravity/rules/ui_ux_design_rules.md`, `.antigravity/rules/prompt_routing_rules.md`, `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`, `AI_INSTRUCTIONS.md`
- 로컬 설치 AI 브릿지 (`http://127.0.0.1:1337/v1`, Key `'pk-dummy'`):
  - UI/UX 디테일 & 2030/B2B 카피 생성: `.venv\Scripts\python.exe scripts/claude_client.py --model claude-3-5-sonnet` (또는 `claude-3-sonnet`, `claude-haiku-4.5`, `claude-opus-4`)
  - 레이아웃 겹침(Overflow) 0% & 풀스택/알고리즘 검증: `.venv\Scripts\python.exe scripts/claude_client.py --model o4-mini` (또는 `gpt-4.1`, `o3-mini`, `gpt-4o`)
  - 앱 내부 AI 연동 시: `lib/services/ai_service.dart` (`OomuAiService.instance`) 사용
- 수정 완료 후 반드시 `flutter analyze` 및 `flutter test`로 에러 0건을 검증한다.
```

---

## 3️⃣ 로컬 설치 AI 16종 (Claude 7종 + GPT 9종) 작업별 자동 라우팅 매트릭스

- **접속 엔드포인트**: `http://127.0.0.1:1337/v1` (`ddg_proxy.py`, `g4f` 백엔드)
- **고정 API Key**: `'pk-dummy'` (외부 유료 과금 0원, Git 커밋 허용 화이트리스트)
- **CLI 실행 명령**: `.venv\Scripts\python.exe scripts/claude_client.py --model <모델명> "<프롬프트>"`

| 작업 도메인 / 트리거 키워드 | 1순위 주력 모델 | 2순위 / 보조 모델 | 핵심 활용 목적 |
| :--- | :--- | :--- | :--- |
| **🎨 UI/UX 디자인 개편 & B2B/2030 마이크로카피** (`디자인`, `색감`, `폰트`, `문구`, `제휴`, `아지트`) | `claude-3-5-sonnet`, `claude-3-sonnet` | `claude-haiku-4.5`, `claude-sonnet-4` | 12년 차 프로덕트 디자이너 감성 토큰 점검, 2030 네이티브 큐레이션 카피 생성 |
| **📐 레이아웃 겹침(Overflow) 0% & 반응형 검증** (`짤림`, `겹침`, `오버플로우`, `박스크기`, `더보기`) | `o4-mini`, `o3-mini` | `gpt-4.1`, `claude-3-5-sonnet` | `Row`/`Column` 내 `Expanded`/`Flexible` 누락 검출, `maxLines`·`ellipsis`·`+더보기 ▾` 트레이 검증 |
| **🏛️ 마스터 아키텍처 & 복합 비즈니스 로직 설계** (`아키텍처`, `설계`, `전체 구조`, `리팩토링`) | `claude-opus-4`, `claude-3-opus` | `gpt-4.5`, `gpt-4` | 대규모 상태관리, B2B 에스크로/정산 구조 설계, 보안 아키텍처 검증 |
| **🔗 풀스택 연동 (Flutter ↔ Firestore ↔ R2)** (`연동`, `구현`, `DB`, `클라우드`, `크롤링`) | `gpt-4.1`, `gpt-4o` | `o4-mini`, `claude-sonnet-4` | 비동기 스트림, Firestore 트랜잭션, R2 Presigned URL, 에러 핸들링 및 테스트 코드 작성 |
| **⚡ 실시간 인앱 AI 기능 & 초고속 배치 생성** (`자만추`, `아이스브레이킹`, `트렌드 생성`, `요약`) | `claude-3-haiku`, `gpt-4o-mini` | `gpt-4.1-mini`, `gpt-4.1-nano` | `OomuAiService` 실시간 채팅 코칭, 프로필 요약, `sync_trends.py` 핫플 키워드 생성 |

---

## 4️⃣ 화면 경로별 실전 프롬프트 템플릿 3선 (작업 시 자동 매핑)

해당 파일 경로(`lib/features/...`)를 수정할 때 에이전트는 아래 각 시나리오의 상세 지침을 자동으로 결합하여 수행합니다.

### ① 홈 & 파티 화면 (`lib/features/home/home_screen.dart`, `lib/features/party/party_screen.dart`, `oomu_prototype.html`)
- **적용 규칙**: `.antigravity/rules/ui_ux_design_rules.md` + `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`의 **`[상황 1]` & `[상황 2]`**
- **필수 체크리스트**:
  1. **카테고리 체계**: 기본 진입 탭은 `전체`이며, 3대 대분류 탭(`⚡ 오늘 번개`, `☕ 취향 아지트`, `🏃‍♂️ 라이프 메이트`)과 각 서브태그(`+더보기 ▾` / `접기 ▴` 트레이 방식으로 우측 짤림 0% 보장)를 정확히 유지할 것.
  2. **배경 & 카드 위계**: 전체 Scaffold 배경(`#F8F9FA` 또는 선택된 OOMU 테마 배경)과 모임 카드 표면(`#FFFFFF`)을 명확히 분리하고, 카드 테두리 `1px solid #EFF1F5` 및 초미세 그림자(`rgba(17, 24, 39, 0.04)`)를 적용할 것.
  3. **Overflow 0% 보장**: 카드 내부 `Row`의 제목/서브텍스트/태그가 작은 스마트폰 화면(320px~375px)에서도 절대 겹치거나 우측으로 잘리지 않도록 `Expanded`, `Flexible`, `maxLines`, `TextOverflow.ellipsis`를 완벽히 적용할 것 (`o4-mini` / `gpt-4.1` 기준 검증).
  4. **트렌드 & 동네모임 피드 배치**: 상단 히어로 배너 아래에 실시간 모임 피드를 배치하고, 피드 중간(인피드)에 KOPIS/R2 실사 포스터 기반 트렌드 큐레이션을 자연스럽게 결합하며, 블럭형(`⊞`)·목록형(`☰`) 뷰 토글을 지원할 것.

### ② 아지트 스팟 & B2B 정산 화면 (`lib/features/venue/venue_screen.dart`, `lib/features/admin/b2b_settlement_screen.dart`)
- **적용 규칙**: `.antigravity/rules/ui_ux_design_rules.md` + `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`의 **`[상황 3]`**
- **필수 체크리스트**:
  1. **2030 네이티브 큐레이션 UX Writing**: 로컬 설치된 `claude-3-5-sonnet` / `claude-opus-4`를 활용하여 공급자 중심의 투박한 문구(*"수수료 차감"*, *"B2B 광고 매장"*)를 **"✨ OOMU 공식 인증 아지트"**, **"🔥 오늘 번개 웰컴 드링크 혜택 스팟"**, **"안심 에스크로 정산 내역"** 등 세련된 큐레이션 언어로 다듬을 것.
  2. **파스텔 틴트 뱃지 & 레이아웃**: 혜택 뱃지는 파스텔 틴트(`배경 #FFF4EB + 텍스트 #FF6B35`)로 처리하고, 금액 숫자 및 상태 뱃지가 한 줄에서 겹치지 않도록 `Expanded`와 `TextAlign.end`로 정렬할 것.

### ③ 채팅방 아이스브레이킹 & 자만추 매칭 화면 (`lib/features/chat/chat_screen.dart`, `lib/features/matching/match_controller.dart`)
- **적용 규칙**: `lib/services/ai_service.dart` (`OomuAiService.instance`) + `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`의 **`[상황 4]`**
- **필수 체크리스트**:
  1. **로컬 AI 모델 실시간 연동**:
     - `chat_screen.dart`: `OomuAiService.instance.generateIcebreakerTopics()` (`claude-3-haiku` / `claude-3-5-sonnet` 연동)를 호출하는 **'✨ AI 대화 주제 추천'** 칩 버튼과 깔끔한 바텀시트/배너 UI를 제공할 것.
     - `match_controller.dart`: `OomuAiService.instance.generateSecretMatchCompatibility()` (`o4-mini` / `gpt-4.1` / `claude-3-5-sonnet` 연동)로 매칭 궁합 코멘트를 생성할 것.
  2. **폴백 안전성 및 레이아웃**: 로컬 프록시(`127.0.0.1:1337`) 미구동 환경에서도 기본 추천 멘트로 우아하게 폴백(Fallback)되도록 예외 처리를 유지하고, 추천 문구 박스에 고정 `height`를 주지 말 것.
