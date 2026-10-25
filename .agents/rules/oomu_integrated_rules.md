---
trigger: always_on
---
# 🏛️ OOMU (오뮤) 통합 마스터 지침 & 로컬 AI 16종 (Claude 7종 / GPT 9종) 상시 자동 발동 규칙

본 규칙(`trigger: always_on`)은 OOMU 워크스페이스의 모든 대화 턴에서 **사용자가 별도의 세팅 프롬프트나 머리말을 붙여넣지 않아도 에이전트가 자동으로 가장 먼저 읽고 100% 선행 적용**하는 최상위 통합 지침입니다.

## 🏆 0. [최우선 제0원칙 — 모든 작업 시작 전 가장 먼저 읽을 것] 대기업 경쟁 앱 상시 벤치마킹 & 네이티브 모바일 UX 절대 준수 규칙
에이전트는 모든 UI/UX·모임 리스트·배너·상세 화면·버튼을 작업할 때 **반드시 먼저 당근마켓(동네모임), 위피(WIPPY), 문토(MUNTO), 소모임, 오늘의집, 무신사(MUSINSA), 29CM 등 대기업/1티어 경쟁 앱의 실제 네이티브 모바일 패턴을 참고하여 설계·구현**합니다.
1. **모임·큐레이션 리스트 다량 노출 시 표준 모바일 패턴 3원칙**:
   - **절대 금지**: 안드로이드/iOS 앱에 없는 PC 웹 게시판형 `< 이전  1 / N 페이지  다음 >` 하단 바 사용 절대 금지.
   - **필수 적용**: ① 좌우 100 : 100 대칭 2열 스냅 `PageView` + **미니멀 슬림 도트 인디케이터(`━━ • • •`)**, ② 섹션 하단 인피드 아코디언 풀와이드 버튼(**`더보기 +N ▾` / `접기 ▴`**), ③ 섹션 헤더 우측 심플 **`전체보기 >` 텍스트 액션**(클릭 시 바텀시트)으로 구현합니다.
2. **좌우 100 : 100 대칭 & 우측 화면 경계 짤림(Clipping) 0% 원칙**:
   - 모바일 뷰포트(`480px` 프레임 포함) 안에서 두 번째 카드가 65%만 보이고 나머지 35%나 제목 글자가 우측 화면 끝에 잘리는 현상을 원천 금지합니다 (`Row` + `Expanded` : `Expanded` 1:1 분할 및 `MediaQuery` 폭 동기화 필수).
3. **금액 미표시(`1/N 안심 정산`) 원칙**:
   - 원화 숫자(`원`, `₩`) 표기를 전면 배제하고 모든 모임/상세/신청 UI에서 `1/N 안심 정산` 또는 `무료 참여`로 통일합니다.

---

## 1. 상시 동기화 필수 지침 문서 체계 (6대 핵심 파일)
에이전트는 모든 작업 시 아래 분리·통합된 문서들을 기준(Single Source of Truth)으로 삼아 동작합니다:
1. **`AI_INSTRUCTIONS.md`**: 질문 키워드별 자동 프롬프트 트리거 & 로컬 설치 Claude 7종 / GPT 9종 모델 매핑 통합 지침
2. **`.antigravity/rules/ui_ux_design_rules.md`**: 경쟁 앱 벤치마킹 기준 및 12년 차 수석 프로덕트 디자이너 UI/UX 토큰 (배경 `#F8F9FA` vs 카드 `#FFFFFF` 분리 또는 선택 테마 토큰, `1px solid #EFF1F5` 보더, 파스텔 틴트 뱃지 `#FFF4EB`, UX 겹침/Overflow 0%, `+더보기 ▾` 트레이, 2030/B2B UX Writing)
3. **`.antigravity/rules/prompt_routing_rules.md` & `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`**: 고정 머리말 및 `[상황 1]~[상황 5]`·화면 경로별(`home_screen.dart`, `party_screen.dart`, `venue_screen.dart`, `b2b_settlement_screen.dart`, `chat_screen.dart`, `match_controller.dart`) 실전 프롬프트 템플릿
4. **`ddg_proxy.py` & `scripts/claude_client.py`**: 로컬 `http://127.0.0.1:1337/v1`, API Key `'pk-dummy'`로 구동되는 무료 Claude 7종 / GPT 9종 브릿지
5. **`lib/services/ai_service.dart` & `lib/features/matching/match_controller.dart`**: Flutter 앱 내 `OomuAiService.instance` 로컬 AI 연동 서비스 및 하이브리드 매칭 컨트롤러
6. **`docs/OOMU_MASTER_SPEC.md` & `.antigravity/rules/security_distribution_rules.md`**: OOMU 통합 마스터 스펙 및 3계층 Zero-Secret 보안 규칙

---

## 2. 로컬 설치 AI 16종 (Claude 7종 + GPT 9종) 자동 매칭 규칙
- **로컬 엔드포인트**: `http://127.0.0.1:1337/v1` (API Key: `'pk-dummy'`)
- **CLI 호출 명령**: `.venv\Scripts\python.exe scripts/claude_client.py --model <모델명> "<프롬프트>"`
- **설치된 16종 모델 전체 목록**:
  - **Claude 7종**: `claude-3-haiku`, `claude-haiku-4.5`, `claude-3-sonnet`, `claude-3-5-sonnet`, `claude-sonnet-4`, `claude-3-opus`, `claude-opus-4`
  - **GPT 9종**: `gpt-4o`, `gpt-4o-mini`, `gpt-4.1`, `gpt-4.1-mini`, `gpt-4.1-nano`, `gpt-4`, `gpt-4.5`, `o3-mini`, `o4-mini`
- **작업 성격별 모델 자동 선택**:
  1. **UI/UX 디테일, 색감/타이포그래피, 2030/B2B 마이크로카피**: `claude-3-5-sonnet` (주력) / `claude-3-sonnet`, `claude-haiku-4.5`, `claude-opus-4`
  2. **레이아웃 겹침(Overflow) 0% 검증 & 반응형 구조 점검**: `o4-mini` (주력) / `o3-mini`, `gpt-4.1`
  3. **풀스택 연동(Flutter ↔ Firestore ↔ R2) & 비동기 코드 구현**: `gpt-4.1` (주력) / `gpt-4o`, `claude-sonnet-4`
  4. **복합 비즈니스 아키텍처 설계 & B2B 에스크로/정산 검증**: `claude-opus-4` (주력) / `claude-3-opus`, `gpt-4.5`
  5. **앱 내부 실시간 AI (`OomuAiService`) & 트렌드 배치(`sync_trends.py`)**: `claude-3-haiku`, `gpt-4o-mini`

---

## 3. OOMU 표준 카테고리 & 12년 차 UI/UX 절대 원칙
1. **기본 진입 탭 및 3대 대분류**:
   - 기본 진입은 항상 **`전체`** 탭이며, 대분류는 **`⚡ 오늘 번개`** (`#전체`, `#혼술바동행`, `#불금코노·술`, `#맛집털기`, `#오늘번개`), **`☕ 취향 아지트`** (`#전체`, `#공연·전시`, `#카페·디저트`, `#보드게임·방탈출`, `#북카페·독서`), **`🏃‍♂️ 라이프 메이트`** (`#전체`, `#러닝·운동`, `#1인가구장보기/소분`, `#동성캠핑`, `#동네산책`)로 구성합니다.
   - 서브태그는 절대 우측으로 잘리지 않도록 1줄 기본 노출 + **`+N 더보기 ▾` / `접기 ▴` 확장 트레이** 또는 반응형 `Wrap` 구조를 사용합니다.
   - `⚡ 오늘 번개` 탭에는 당일/주말 즉시 참여 가능한 일상 번개(술약, 밥약, 코노, 카페 등)만 배치하며, 사전 예매가 필요한 먼 날짜의 콘서트/뮤지컬은 `☕ 취향 아지트` 및 인피드 트렌드 섹션에 배치합니다.
2. **UX 겹침(Overflow) 0% 원칙**:
   - `Row` 내부 가변 텍스트 옆에는 반드시 `Expanded` 또는 `Flexible` + `maxLines` + `TextOverflow.ellipsis`를 선언합니다.
   - 텍스트가 들어가는 컨테이너에 고정 `height`를 부여하지 않고 `padding`과 `constraints: BoxConstraints(minHeight: ...)`로 유동 확장합니다.
3. **3계층 Zero-Secret 보안**:
   - 실제 외부 유료 API 키(`AIza...` 서버키, `sk-...`, R2 SecretKey)는 절대 코드에 하드코딩하지 않고 Firestore `config/api_keys`, `config/r2_storage`에서 런타임 로드합니다. (단, 로컬 프록시용 `'pk-dummy'`는 허용)
   - 커밋 전 `powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1` 및 `flutter analyze` 통과를 원칙으로 합니다.

---

## 4. 완료 보고 전 필수 오타·문법·화면 렌더링 사전 검증 규칙 (Pre-Report Gate)
- **사전 검증 없는 완료 보고 절대 금지**: 에이전트가 작업을 마쳤다고 판단하더라도, 실제 화면이 백지로 뜨거나 오타/문법 에러(`SyntaxError`, 따옴표 줄바꿈 깨짐, 괄호 불일치 등)가 남아있는 상태로 사용자에게 완료 보고하는 것을 엄격히 금지합니다.
- **필수 실행 검증 절차**:
  1. **HTML 시안(`oomu_prototype.html` 등) 및 Python 스크립트 수정 시**: 반드시 `.\.venv\Scripts\python.exe scripts/verify_before_report.py --html "<HTML경로>"`를 실행하여 `<script>` 내 JS 문자열 줄바꿈 깨짐·괄호 짝·`render()` 정상 호출 여부를 검증하고 `[SUCCESS]`를 확인한 뒤 보고합니다.
  2. **Flutter(`lib/**`) 코드 수정 시**: 반드시 `flutter analyze` 및 `flutter test`를 실행하여 컴파일 에러 및 오타 0건을 확인한 뒤 보고합니다.

---

## 5. 📱 SMS & 본인인증 프로바이더 선정 및 검증 절대 수칙
1. **알리고(Aligo) 추천 및 연동 원천 금지**: 알리고는 개인 계정 API Key 발급 시 사업자 인증 페이지로 강제 리다이렉트되어 개인 개발자의 API 이용이 불가능합니다.
2. **솔라피(SOLAPI, 구 CoolSMS) 표준 채택**: 비사업자 개인도 휴대폰 본인인증만으로 API Key 발급 및 본인 발신번호 무료 등록이 가능하며, 1,000원~10,000원 소액 충전을 지원합니다.

## 6. ⚙️ 24/7 B2B 자율 무인 운영 & Notion 보고 체계
- .github/workflows/oomu_cron_ops.yml을 통해 시드 모임 생성, 밸런스 게임 배달, 유령 모임 청소, 유해 콘텐츠 검사, 휴면 유저 리텐션, 노션 일일 경영 보고서, DB 정기 백업을 24시간 자율 수행합니다.
- 에이전트는 유료 직원 수준의 프로페셔널한 책임감으로 모든 기술 명세와 정책을 사전 100% 검증(verify_before_report.py)한 후 보고합니다.
