# 🤖 Antigravity AI Agent Directive (OOMU / Spot10 Project)
> **이 문서는 OOMU(우리 동네 취향 모임) 프로젝트를 다루는 모든 AI 에이전트(Antigravity 등)가 항상 첫 번째로 읽고 절대적으로 준수해야 하는 시스템 지침서입니다.**

## 0. 🔒 필수 보안 및 3계층 분배 규칙 (Security Distribution Rules) — 필독!
작업을 시작하기 전, 에이전트는 반드시 **`.antigravity/rules/security_distribution_rules.md`** 및 **`docs/SECURITY_AGENT_GUIDE.md`**를 최우선으로 읽고 다음 3단계 분배 원칙을 철저히 지켜야 합니다.

1. **보안 파일 및 자격 증명 (Firebase Firestore ONLY)**:
   - Cloudflare R2 S3 API Secret Access Key, 공공데이터 API 키(KOPIS/TourAPI), AI 키(Gemini), Firebase 서비스 키, 민감 개인정보는 **절대 Git에 커밋하지 않습니다.**
   - 모든 자격 증명은 Firestore `config/r2_storage` 및 `config/api_keys`에 안전하게 보관되며, 런타임에 동적으로 로드됩니다.
2. **사진 및 미디어 스토리지 (Cloudflare R2 ONLY)**:
   - 프로필 사진, 모임 커버 사진, 채팅 사진은 모두 Cloudflare R2 (`oomu-spot` 버킷)에 저장됩니다.
   - 깃허브에는 대용량 사용자 사진을 직접 올리지 않으며, 비이미지 파일 업로드는 차단합니다.
   - 이미지는 AWS SigV4 Presigned GET URL 또는 R2 Public CDN URL을 통해 안전하게 표시합니다.
3. **순수 소스코드, 문서, UI 및 지침 (GitHub ONLY)**:
   - Flutter/Dart 소스코드, 마크다운 가이드 문서, 테스트 코드는 깃허브에서 투명하게 관리됩니다.
   - 커밋 전 항상 `scripts/verify_security_rules.ps1` 또는 `scripts/verify_security_rules.sh`를 실행하여 제로 시크릿(Zero-Secret) 상태를 검증합니다.

---

## 1. 🎯 프로젝트 정체성 및 통합 명세서 확인
- **프로젝트명:** OOMU (우리 동네 취향 모임 / Spot10 전면 개편)
- **최고 우선순위 명세서:** `docs/OOMU_MASTER_SPEC.md`
  - 이전의 8개 파편화된 아티팩트(UX 진행률 대시보드, 구조 설계서, 작업계획서 등)는 모두 `OOMU_MASTER_SPEC.md` 단일 파일로 완벽하게 통합 및 압축되었습니다.
  - 에이전트는 작업을 시작하기 전 반드시 위 마스터 스펙 파일을 읽고 프로젝트의 딥러닝/매칭 알고리즘과 비즈니스 로직을 완벽히 이해해야 합니다.

---

## 2. 🚨 [핵심] 질문 키워드별 자동 프롬프트 로드 & 로컬 설치 모델(Claude/GPT) 매칭 지침

사용자가 새로운 채팅창에서 아래와 같은 **특정 질문(트리거 키워드)**을 입력하면, 에이전트는 **즉시 `.antigravity/rules/ui_ux_design_rules.md`와 `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md` 파일을 `view_file`로 먼저 읽고**, 해당 상황의 **12년 차 수석 디자이너/아키텍트 프롬프트**와 **로컬 설치 모델(`http://127.0.0.1:1337/v1`)**을 자동으로 결합하여 작업을 수행해야 합니다.

### 2-1. 특정 질문(Trigger) ➔ 자동 읽을 파일 및 실행 프롬프트 매핑

| 사용자의 질문 / 명령어 트리거 예시 | 에이전트가 즉시 읽어야 할 지침 파일 | 자동 적용할 상황별 프롬프트 섹션 | 연동할 로컬 설치 모델 (Claude / GPT) |
| :--- | :--- | :--- | :--- |
| **"디자인 수정해줘"**, **"UI 다듬어줘"**, **"화면이 너무 촌스러워"**, **"플레이스토어 출시 수준으로 고쳐줘"** | `.antigravity/rules/ui_ux_design_rules.md`<br>`docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md` | **`[상황 1] 12년 차 수석 프로덕트 디자이너 UI/UX 리디자인`** | **Claude**: `claude-3-5-sonnet`, `claude-opus-4`<br>**GPT**: `gpt-4o`, `gpt-4.1` |
| **"겹침 해결해줘"**, **"글자 깨짐/Overflow 고쳐줘"**, **"반응형 레이아웃 잡아줘"** | `.antigravity/rules/ui_ux_design_rules.md`<br>`docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md` | **`[상황 1] UX 겹침(Overlap/Overflow) 0% 구조 수술`** | **Claude**: `claude-3-5-sonnet`, `claude-sonnet-4`<br>**GPT**: `o4-mini`, `gpt-4.1` |
| **"문구 수정해줘"**, **"카피 다듬어줘"**, **"B2B 만들어줘"**, **"스폰서십/아지트 화면 짜줘"** | `.antigravity/rules/ui_ux_design_rules.md`<br>`docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md` | **`[상황 2] B2B 제휴 & 2030 마이크로카피 UX Writing`** | **Claude**: `claude-3-sonnet`, `claude-haiku-4.5`<br>**GPT**: `gpt-4.5`, `gpt-4o` |
| **"풀스택 연동해줘"**, **"기능 구현해줘"**, **"DB/상태관리 연결해줘"**, **"백엔드 API 붙이자"** | `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`<br>`docs/OOMU_MASTER_SPEC.md` | **`[상황 3] 풀스택(Flutter + Supabase/Firebase + 로컬 AI) 아키텍처`** | **Claude**: `claude-sonnet-4`, `claude-3-haiku`<br>**GPT**: `gpt-4.1`, `o3-mini`, `gpt-4o-mini` |
| **"아이디어 추천해줘"**, **"기획/수익화 모델 추천해줘"**, **"차별화 포인트 뽑아줘"** | `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`<br>`docs/OOMU_MASTER_SPEC.md` | **`[상황 4] 서비스 아이디어 & B2C/B2B 수익화 기획 추천`** | **Claude**: `claude-3-opus`, `claude-opus-4`<br>**GPT**: `gpt-4.5`, `o3-mini` |
| **"전체 화면 감사해줘"**, **"출시 전 디자인/UX 점검해줘"** | `.antigravity/rules/ui_ux_design_rules.md`<br>`docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md` | **`[상황 5] 로컬 무료 AI 브릿지 연동 & 출시 전 UX 감사`** | **Claude**: `claude-3-opus`, `claude-3-5-sonnet`<br>**GPT**: `gpt-4.1`, `o4-mini` |

> **필수 실행 규칙**: 특히 사용자가 **"디자인 수정해줘"**라고만 짧게 말하더라도, 에이전트는 절대 임의로 단순 색상만 바꾸지 말고 **반드시 `.antigravity/rules/ui_ux_design_rules.md`와 `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`의 `[상황 1]` 및 `[상황 2]` 프롬프트를 읽은 뒤**, 12년 차 수석 디자이너 기준(배경 `#F8F9FA` vs 카드 `#FFFFFF` 분리, 파스텔 뱃지, `Expanded`/`Flexible`을 통한 겹침 0%, 2030/B2B UX Writing)을 100% 적용하여 코드를 수정해야 합니다.

---

### 2-2. 프로젝트에 설치된 로컬 가상 API(`g4f`) 모델 전체 리스트 (`ddg_proxy.py` 구동 중)
- **로컬 서버 주소 (Base URL)**: `http://127.0.0.1:1337/v1`
- **API Key**: `'pk-dummy'` (인증 불필요, 무제한 호출 가능)
- **CLI 브릿지 호출 명령어**: `.venv\Scripts\python.exe scripts/claude_client.py --model <모델명> --prompt "<질문>"`

#### 🟣 A. 설치된 Claude 모델 리스트 (총 7종)
1. **`claude-3-haiku`** (기본값 / 초고속 응답)
   - **특장점**: 응답 속도 1위, 실시간 앱 내 채팅 요약, 아이스브레이킹 질문 생성, 빠른 마이크로카피(버튼/토스트/에러 문구) 대량 생성에 최적.
2. **`claude-haiku-4.5`** (차세대 고감도 경량 모델)
   - **특장점**: 기존 Haiku의 빠른 속도를 유지하면서 한국어 2030 커뮤니티 감성 문구와 자연스러운 UX Writing 품질이 대폭 향상된 모델.
3. **`claude-3-sonnet`** (표준 밸런스형)
   - **특장점**: B2B 파트너스(동네 아지트 사장님) 제안 문구, 스폰서십 대시보드 기획, 백엔드-프론트엔드 API 데이터 매핑에 안정적.
4. **`claude-3-5-sonnet`** (UI/UX 코드 설계 & 디테일 최강자)
   - **특장점**: 안티그래비티 기본 모델(`Argon`)이 약한 **섬세한 Flutter UI/UX 컴포넌트, 여백/타이포그래피 위계, 마이크로 인터랙션 코드 작성**에 가장 뛰어난 핵심 디자인 코딩 모델.
5. **`claude-sonnet-4`** (복합 풀스택 아키텍처 & 상태관리)
   - **특장점**: 다중 파일 리팩토링, Riverpod/StatefulWidget 상태 동기화, 예외 처리 및 방어적 코딩 설계에 적합.
6. **`claude-3-opus`** (12년 차 수석 프로덕트 디자이너 & 전략 기획)
   - **특장점**: 플레이스토어 상용 앱 수준의 심층 UX 휴리스틱 감사, B2B/B2C 수익화 기획, 복잡한 사용자 여정(User Flow) 병목 진단에 최적.
7. **`claude-opus-4`** (최상위 플래그십 총괄 추론)
   - **특장점**: 앱 전체 디자인 시스템(Design Token) 리빌딩 및 대규모 아키텍처 의사결정이 필요할 때 사용하는 최상위 모델.

#### 🟢 B. 설치된 GPT 모델 리스트 (총 9종)
1. **`gpt-4o`** (표준 올라운더)
   - **특장점**: 정형화된 JSON 스키마 출력, REST/Supabase API 명세 설계, 다목적 풀스택 코드 생성에 가장 안정적.
2. **`gpt-4o-mini`** (초경량·대량 반복 처리)
   - **특장점**: `scripts/sync_trends.py`의 트렌드 키워드 추출, 초기 더미 데이터(모임/장소/리뷰) 대량 시딩, 빠른 문법 검증용.
3. **`gpt-4.1`** (최신 코딩·리팩토링 특화 플래그십)
   - **특장점**: 긴 컨텍스트의 Flutter/Dart 코드 리팩토링, 클린 아키텍처 분리, 레거시 코드 구조 개선에 탁월.
4. **`gpt-4.1-mini`** (고속 코드 스니펫 & 테스트 생성)
   - **특장점**: 단위/통합 테스트(`test/ai_service_test.dart` 등) 자동 작성, 모델 클래스(`fromJson`/`toJson`) 보일러플레이트 즉시 생성.
5. **`gpt-4.1-nano`** (초저지연 분류·태깅 전용)
   - **특장점**: 사용자 입력 텍스트의 카테고리 자동 분류, 금지어/스팸 필터링, 취향 태그 매칭용 초경량 모델.
6. **`gpt-4`** (안정적 클래식 추론)
   - **특장점**: 보안 규칙 검증(`firestore.rules`), 약관/개인정보처리방침 문구 검토, 정교한 비즈니스 규칙 검증.
7. **`gpt-4.5`** (고감도 크리에이티브 & 브랜딩)
   - **특장점**: 감성적인 브랜드 스토리텔링, B2B 제휴 제안서 카피라이팅, 앱 스토어 출시 홍보 문구 작성에 강점.
8. **`o3-mini`** (수리·논리·알고리즘 추론 특화)
   - **특장점**: OOMU 취향 매칭 점수 알고리즘, B2B 스폰서십 노출 가중치 및 ROI 정산 로직, 복잡한 쿼리 최적화 계산.
9. **`o4-mini`** (차세대 고속 추론 & 레이아웃 디버깅)
   - **특장점**: Flutter `RenderFlex overflowed` 원인 추적, 복잡한 비동기(`Future`/`Stream`) 레이스 컨디션 디버깅, 반응형 비율 계산.

---

### 2-3. 📂 OOMU 핵심 화면 경로별 자동 작업 지침 (홈/파티 · 아지트/정산 · 채팅/자만추 AI 연동)

> **상시 분리·통합 지침 참조**: 고정 머리말 규칙과 화면 경로별 실전 프롬프트 템플릿은 **`.antigravity/rules/prompt_routing_rules.md`** 및 **`.agents/rules/oomu_integrated_rules.md` (`trigger: always_on`)**, **`AGENTS.md`**에 분리·등재되어 매 턴 자동 로드됩니다.

에이전트는 아래 화면 그룹에 대한 수정·고도화 요청을 받으면 별도 설명이 없어도 해당 경로의 파일들과 매칭된 로컬 AI 모델(`scripts/claude_client.py` 및 `lib/services/ai_service.dart`)을 즉시 적용해야 합니다.

1. **① 홈 화면 & 아지트/모임 카드 디자인 + 겹침 전면 수술**
   - **대상 경로**: `lib/features/home/home_screen.dart`, `lib/features/party/party_screen.dart`, `lib/screens/home_screen.dart`, `lib/screens/home_sub_screens.dart`, `lib/screens/party_screen.dart`, `lib/screens/party_detail_screen.dart`, `lib/screens/party_host_screen.dart`, `lib/screens/party_application_screen.dart`, `oomu_prototype.html`
   - **적용 모델**: `claude-3-5-sonnet` (UI 디테일·여백), `o4-mini` (겹침/Overflow 0% 검증)
   - **필수 작업**:
     - **확정 카테고리 체계**: 기본 진입 탭은 `전체`이며, 3대 대분류 탭(`⚡ 오늘 번개`: `#혼술바동행 #불금코노·술 #맛집털기 #오늘번개` / `☕ 취향 아지트`: `#공연·전시 #카페·디저트 #보드게임·방탈출 #북카페·독서` / `🏃‍♂️ 라이프 메이트`: `#러닝·운동 #1인가구장보기/소분 #동성캠핑 #동네산책`)과 **`+N 더보기 ▾` / `접기 ▴` 확장 트레이**(서브태그 우측 짤림 0%)를 유지합니다.
     - 배경(`#F8F9FA`)과 카드(`#FFFFFF`) 대비 분리, `Row` 내부 가변 텍스트 `Expanded`/`Flexible` 적용으로 작은 화면에서도 겹침 0% 보장, 2030 감성 카피 및 B2B 네이티브 스폰서십(`"✨ OOMU 공식 인증 아지트"`) 문구 적용.

2. **② 아지트 스팟(B2B) & 1/N 에스크로 정산(지갑) 고급화**
   - **대상 경로**: `lib/features/venue/venue_screen.dart`, `lib/features/admin/b2b_settlement_screen.dart`, `lib/screens/soso_spot_screen.dart`, `lib/screens/second_spot_screen.dart`, `lib/screens/middle_spot_map_screen.dart`, `lib/screens/soso_wallet_screen.dart`, `lib/screens/wallet_history_screen.dart`, `lib/screens/travel_payment_screen.dart`
   - **적용 모델**: `claude-3-sonnet` / `claude-3-5-sonnet` (B2B 제휴 카피), `o3-mini` / `o4-mini` (정산/ROI 수식 및 겹침 방지), `gpt-4.1` (풀스택 상태관리)
   - **필수 작업**: 사장님 제휴 아지트를 배너 광고가 아닌 '네이티브 큐레이션 카드'("웰컴 드링크 제공", "노쇼 방지 에스크로 보장")로 표현하고, 모든 정산/결제/바텀시트 요소를 100% 동적 `StatefulWidget`으로 구현.

3. **③ 채팅 & 자만추/동네크루 로컬 AI(`OomuAiService`) 실시간 연동**
   - **대상 경로**: `lib/features/chat/chat_screen.dart`, `lib/screens/chat_screen.dart`, `lib/screens/party_chat_preview_screen.dart`, `lib/screens/neighborhood_crew_screen.dart`, `lib/screens/local_friends_screen.dart`, `lib/screens/natural_meeting_detail_screens.dart`
   - **연동 서비스/컨트롤러**: `lib/services/ai_service.dart` (`OomuAiService`), `lib/features/matching/match_controller.dart` (`OomuMatchController`)
   - **적용 모델**: 로컬 `http://127.0.0.1:1337/v1`의 `claude-3-haiku` / `claude-haiku-4.5` / `claude-3-5-sonnet` / `o4-mini` (API Key: `'pk-dummy'`)
   - **필수 작업**: 채팅방 상단 및 모임 프리뷰/바텀시트에 `'✨ AI 아이스브레이킹 대화 주제 추천'` 및 `'모임 한 줄 요약'` 버튼을 12년 차 디자이너 UI(`#FFF4EB` 파스텔 칩 + 스켈레톤 로딩 + 우아한 Fallback)로 배치하고, 클릭 시 실제 로컬 Claude 모델 응답이 실시간 렌더링되도록 구현.

---

## 3. ⚡ UI/UX 프론트엔드 개발 절대 원칙 (전면 동적 작동 & 12년 차 수석 디자이너 기준)
기획자님의 특별 지시사항에 따라, 모든 UI 컴포넌트는 반드시 **`.antigravity/rules/ui_ux_design_rules.md`**의 디자인 토큰(웜 오프화이트 `#F8F9FA` 배경, `#191F28` 타이포그래피, 파스텔 틴트 뱃지, UX 겹침/Overflow 0%, 2030/B2B 감도 높은 UX Writing)과 다음 원칙을 무조건 따릅니다.

1. **모든 요소의 100% 동적(Dynamic) 작동화**
   - 단순히 디자인만 보여주는 정적(Static) UI나 더미 텍스트 하드코딩은 절대 금지합니다.
   - 버튼 클릭, 투표 진행, 프로필 교환, 정산 송금 등 **사용자 상호작용이 발생하는 모든 요소는 상태가 실시간으로 변하는 `StatefulWidget`으로 구현**해야 합니다.
2. **디자인 픽셀(px) 고정 절대 금지 & 레이아웃 겹침(Overflow) 0% (No Fixed Design)**
   - 기기 화면 크기(Mobile, Tablet 등)에 맞게 유연하게 반응(Responsive)해야 합니다.
   - `Expanded`, `Flexible`, `LayoutBuilder` 등을 적극 활용하며, 텍스트/칩 컨테이너의 높이나 너비를 절대값(px)으로 하드코딩하여 글자가 겹치거나 잘리는 현상을 엄격히 금지합니다.
3. **바텀시트(Bottom Sheet) 중심의 인터랙션 설계**
   - 사용자 입력(신청 메시지, 투표 항목 작성 등) 받을 때는 새 화면(Route)으로 넘기지 말고, `showModalBottomSheet`(`isScrollControlled: true`, 키보드 `viewInsets.bottom` 패딩 필수)를 띄워 현재 채팅창/화면 맥락(Context)을 유지하게 만드세요.

## 4. 🛠️ 백엔드 및 예외 처리 원칙
- **방어적 코딩 (Defensive Coding):** 파이어베이스(Firestore, Cloud Functions) 및 로컬 AI 서버(`http://127.0.0.1:1337/v1`) 연동 시, 반드시 `try-catch` 블록을 작성하여 통신 에러를 방어하세요.
- **우아한 실패 (Graceful Degradation):** 통신 지연(Loading)이나 에러 발생 시 앱이 멈추지 않고, 스켈레톤 로딩이나 Fallback UI가 부드럽게 렌더링되도록 처리하세요.

## 5. 🚀 에이전트 행동 지침 (Action Item)
- 이 프로젝트 레포지토리에 처음 접근한 AI는 사용자에게 **"안녕하세요! OOMU 프로젝트 지침(AI_INSTRUCTIONS.md)을 완벽히 숙지했습니다. 모든 디자인을 반응형으로 구성하고 동적 기능 연동을 준비했습니다."**라고 보고한 뒤 작업을 시작하세요.
- 새로운 화면이나 컴포넌트를 생성할 때는 무조건 `docs/OOMU_MASTER_SPEC.md`의 기획 의도에 맞는지 자체 검증(Self-Correction) 과정을 거치세요.

## 6. REA(리버스 엔지니어링 MCP) 사용 지침 — 필독
- 이 프로젝트는 Antigravity에 **REA MCP**(`rea`)가 연결되어 있습니다. 앱 빌드 산출물(APK/웹 빌드) 검증, UI/동작 확인, 로그 분석이 필요할 때 **반드시 `docs/REA_GUIDE.md`를 먼저 읽고** 그 규칙에 따라 사용하세요.
- 우리 소유 앱만 분석하며, 임시 분석 파일은 작업 후 삭제(Zero-Trace)합니다.
- 소스 코드로 답이 나오는 일반 분석에는 REA를 쓰지 않습니다.
