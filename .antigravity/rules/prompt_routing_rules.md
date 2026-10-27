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
- [완료 보고 전 필수 검증 게이트]: 사용자에게 완료했다고 말하기 전에 반드시 `.\.venv\Scripts\python.exe scripts/verify_before_report.py --html "<HTML시안경로>"` (HTML 시안 수정 시) 및 `flutter analyze` / `flutter test` (Dart 코드 수정 시)를 실행하여 오타·JS 문법 에러(백지 화면)·괄호 짝 불일치 0건을 확인한 후에만 완료 보고를 작성한다.
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

## 4️⃣ 화면 경로별 실전 프롬프트 템플릿 3선 (실제 lib/screens 경로 매핑)

> **경로 안내**: 과거 지침의 `lib/features/...` 경로는 실존하지 않으며, `main.dart` 기준 실제 앱 화면인 `lib/screens/...` 파일에 적용합니다.

### ① 홈 & 모임 화면 (`lib/screens/soso_car_home_screen.dart`, `lib/screens/soso_car_detail_screen.dart`)
- **적용 규칙**: [docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md) + `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`의 **`[상황 1]` & `[상황 2]`**
- **필수 체크리스트**:
  1. **카테고리 체계**: 기본 진입 탭은 `전체`이며, 3대 대분류 탭(`⚡ 오늘 번개`, `☕ 취향 아지트`, `🏃‍♂️ 라이프 메이트`)과 각 서브태그를 유지하고 우측 짤림 없는 레이아웃 보장.
  2. **배경 & 카드 위계**: Scaffold 배경 `#FAF6F7`과 모임 카드 표면 `#FFFFFF`을 명확히 분리하고, 8dp 여백 시스템과 1px 미세 보더 적용.
  3. **유연한 텍스트 렌더링**: 주소·시간·모임 소개 등 주요 정보가 작은 화면(360~390px)에서도 읽기 쉽게 적절히 줄바꿈되도록 처리하며, 비대칭 짤림 방지.
  4. **금액 미표시 원칙**: 모든 모임 목록 및 상세에서 원화 금액 숫자 대신 `1/N 안심 정산` 또는 `무료 참여` 표기.

### ② 아지트 스팟 화면 (`lib/screens/soso_spot_screen.dart`, `lib/screens/explore_map_screen.dart`)
- **적용 규칙**: [docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md) + `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`의 **`[상황 3]`**
- **필수 체크리스트**:
  1. **2030 네이티브 큐레이션 UX Writing**: 공급자 중심 투박한 문구를 **"✨ OOMU 공식 인증 아지트"**, **"🔥 오늘 번개 웰컴 혜택 스팟"** 등 세련된 라이프스타일 언어로 다듬을 것.
  2. **파스텔 틴트 뱃지 & 레이아웃**: 혜택 뱃지는 파스텔 틴트(`배경 #FFF4EB + 텍스트 #FF6B35`)로 처리하고, 상태 뱃지가 한 줄에서 겹치지 않도록 `Expanded` 정렬.

### ③ 채팅방 & 알림 화면 (`lib/screens/chat_screen.dart`, `lib/screens/soso_car_chat_screen.dart`, `lib/screens/notification_screen.dart`)
- **적용 규칙**: `lib/services/ai_service.dart` (`OomuAiService.instance`) + `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`의 **`[상황 4]`**
- **필수 체크리스트**:
  1. **로컬 AI 모델 실시간 연동**: `chat_screen.dart`에서 `OomuAiService.instance.generateIcebreakerTopics()` 연동 칩 버튼과 바텀시트 UI 제공.
  2. **폴백 안전성 및 레이아웃**: 로컬 프록시 미구동 환경에서도 기본 추천 멘트로 우아하게 폴백되도록 예외 처리를 유지하고, 추천 문구 컨테이너에 고정 `height`를 주지 말 것.

