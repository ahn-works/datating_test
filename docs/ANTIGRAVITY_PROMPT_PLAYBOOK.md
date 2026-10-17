# 🚀 OOMU (Spot10) 안티그래비티 상황별 프롬프트 플레이북 (12년 차 수석 디자이너 & 로컬 설치 Claude/GPT 모델 완전 매핑판)

> **자동 트리거 연동 안내**: `AI_INSTRUCTIONS.md` 및 `.antigravity/rules/ui_ux_design_rules.md`에 지침이 등록되어 있어, 새 채팅창에서 **"디자인 수정해줘"**, **"겹침 해결해줘"**, **"B2B 만들어줘"**, **"풀스택 연동해줘"**, **"아이디어 추천해줘"**라고만 입력해도 에이전트가 자동으로 이 플레이북의 프롬프트와 로컬 설치 모델(`Claude` / `GPT`)을 읽고 실행합니다.

---

## 1. 📊 모델 전체 라인업: 안티그래비티 내장 5종 vs 로컬 설치 `g4f` 모델 (Claude 7종 + GPT 9종)

### 1-1. 안티그래비티 UI 내장 5개 모델 (채팅창 하단 선택기)
| 내장 모델명 | 실전 강점 및 한계 | 추천 활용 전략 |
| :--- | :--- | :--- |
| **`Gemini 4 Argon High`** *(기본)* | **무제한급 쿼터 & 빠른 터미널/다중 파일 수정**. 단, **그냥 시키면 UI가 투박하고 카피가 기계적**임. | **평소 코딩 주력 엔진**으로 쓰되, 디자인/카피는 아래 **로컬 설치 Claude/GPT 모델**과 결합하거나 본 문서의 `[상황 1~5]` 프롬프트로 강제 제어 |
| **`Claude Sonnet 4.6 (Thinking)`** | **UI/UX 디테일, 여백, 컴포넌트 미학 우수**. 단, 연속 질문 시 쿼터 제한 발생. | 핵심 화면(홈/아지트/바텀시트) 1차 마스터피스 생성 시 선택 |
| **`Claude Opus 4.6 (Thinking)`** | **최상위 추론 및 전체 디자인 시스템 설계**. 쿼터 소모가 가장 빠름. | 출시 직전 전체 아키텍처 점검 시 1회성 타격용 (평소에는 로컬 `claude-opus-4` / `claude-3-opus`로 대체) |
| **`Gemini 4 Argon Low`** | 단순 반복 수정 속도가 매우 빠름. | 오타 수정, `flutter analyze` 린트 정리용 |
| **`GPT-OSS 120B (Medium)`** | 독립적인 오픈웨이트 시각으로 코드 리뷰 가능. | 백엔드 쿼리 교차 검증용 |

---

### 1-2. 로컬 가상 API(`ddg_proxy.py`, `http://127.0.0.1:1337/v1`)에 설치된 무료 모델 리스트 (총 16종)

> **호출 방법 (횟수 제한 없음, API Key: `'pk-dummy'`)**:
> - **터미널/에이전트 CLI 호출**: `.venv\Scripts\python.exe scripts/claude_client.py --model <모델명> --prompt "<질문>"`
> - **Flutter 앱 내부 호출**: `lib/services/ai_service.dart` (`OomuAiService(model: '<모델명>')`)

#### 🟣 [설치된 Claude 모델 리스트 — 7종]
1. **`claude-3-5-sonnet`** : **[디자인/UI 코딩 1순위]** Flutter 위젯 디테일, 카드/바텀시트 여백·타이포그래피 위계, 마이크로 인터랙션 설계
2. **`claude-opus-4`** : **[최상위 디자인 시스템 총괄]** 앱 전체 컬러·타이포 토큰 설계 및 플레이스토어 출시 수준 전면 리빌딩
3. **`claude-3-opus`** : **[12년 차 수석 기획 & UX 감사]** B2B/B2C 수익화 기획, 사용자 이탈 방지 동선 설계, 출시 전 휴리스틱 감사
4. **`claude-3-sonnet`** : **[B2B 세일즈 카피 & 대시보드]** 동네 아지트 파트너(사장님) 제휴 제안 문구, 스폰서십 노출 UI 설계
5. **`claude-haiku-4.5`** : **[2030 소셜 UX Writing]** 토스·당근 스타일의 설레는 한국어 마이크로카피, 온보딩/빈 화면(Empty State) 문구
6. **`claude-sonnet-4`** : **[복합 풀스택 & 반응형 상태관리]** 다중 화면 `StatefulWidget`/Riverpod 상태 동기화 및 예외 방어 로직
7. **`claude-3-haiku`** : **[초고속 실시간 AI 브릿지]** 앱 런타임 실시간 아이스브레이킹 질문, 모임 한 줄 요약 기본 모델

#### 🟢 [설치된 GPT 모델 리스트 — 9종]
1. **`gpt-4.1`** : **[풀스택 아키텍처 & 리팩토링 1순위]** Flutter + Supabase/Firebase 클린 아키텍처 설계 및 대규모 코드 리팩토링
2. **`gpt-4o`** : **[표준 올라운더 & JSON 스키마]** UI 바인딩용 JSON 데이터 구조 설계, REST API 연동 표준 코드 작성
3. **`o4-mini`** : **[레이아웃 겹침(Overflow) & 비동기 디버거]** `RenderFlex overflowed` 비율 계산 및 `Future`/`Stream` 레이스 컨디션 해결
4. **`o3-mini`** : **[알고리즘 & B2B 정산 수리 추론]** OOMU 취향 매칭 점수 수식, B2B 스폰서십 노출 가중치 및 ROI 정산 알고리즘
5. **`gpt-4.5`** : **[브랜드 스토리텔링 & 프리미엄 카피]** B2B 파트너스 제안서, 앱 스토어 홍보 카피, 브랜드 보이스 설계
6. **`gpt-4.1-mini`** : **[고속 보일러플레이트 & 테스트]** 모델 직렬화(`fromJson`/`toJson`) 및 단위 테스트(`test/ai_service_test.dart`) 자동 생성
7. **`gpt-4o-mini`** : **[대량 트렌드/더미 데이터 시딩]** `scripts/sync_trends.py` 실시간 트렌드 태그 생성 및 실제 같은 모임 데이터 시딩
8. **`gpt-4.1-nano`** : **[초저지연 분류/태깅]** 실시간 채팅 키워드 추출, 모임 자동 카테고리 분류, 스팸/금지어 필터링
9. **`gpt-4`** : **[보안/정책 검증]** `firestore.rules` 및 `.antigravity/rules/security_distribution_rules.md` 보안 규칙 검증

---

## 2. 📋 상황별 실전 프롬프트 템플릿 (Claude & GPT 설치 모델 매칭 포함)

---

### 🎨 [상황 1] 12년 차 수석 프로덕트 디자이너 UI/UX 리디자인 & 레이아웃 겹침(Overflow) 0%
> - **자동 발동 키워드**: `"디자인 수정해줘"`, `"UI 다듬어줘"`, `"촌스러워"`, `"겹침 해결해줘"`
> - **매칭된 로컬 설치 모델**:
>   - **Claude**: `claude-3-5-sonnet` (위젯 디테일·여백 설계), `claude-opus-4` (전체 디자인 토큰 총괄)
>   - **GPT**: `o4-mini` (레이아웃 픽셀/비율 겹침 계산), `gpt-4o` (컴포넌트 구조화)

```markdown
[역할 및 목표]
너는 토스(Toss), 당근, 에어비앤비(Airbnb), 크림(KREAM)에서 12년 이상 모바일 앱을 총괄한 '수석 프로덕트 디자이너(Principal Product Designer) 겸 Flutter UI 엔지니어'야.
지금 즉시 `.antigravity/rules/ui_ux_design_rules.md`를 읽고, 아래 대상 화면을 구글 플레이스토어에 바로 상용 출시 가능한 수준으로 전면 리디자인해줘.

[연동할 로컬 설치 모델 (Claude & GPT)]
- UI 위젯 계층 및 여백/타이포그래피 설계 보조: `.venv\Scripts\python.exe scripts/claude_client.py --model claude-3-5-sonnet` (또는 `--model claude-opus-4`)
- 레이아웃 겹침(RenderFlex overflow) 비율 역산 검증: `.venv\Scripts\python.exe scripts/claude_client.py --model o4-mini` (또는 `--model gpt-4o`)

[대상 파일 및 화면]
- 수정할 파일 경로: [예: lib/screens/home_screen.dart]

[절대 준수 디자인 시스템 & UX 디테일 규칙]
1. 촌스러운 원색/기본 Material 느낌 완전 제거:
   - 배경은 눈이 편안한 웜 오프화이트(`#F8F9FA`), 카드 표면은 순백색(`#FFFFFF`) + 미세 보더(`1px solid #EFF1F5`) + 소프트 그림자(`blurRadius: 16, offset: Offset(0, 4), color: Color(0x0A000000)`)로 깊이감을 줄 것.
   - 뱃지(Chip)는 쨍한 원색 배경을 절대 쓰지 말고, 채도를 낮춘 파스텔 틴트 배경(예: `#FFF4EB` 배경 + `#E85D04` 텍스트)으로 고급스럽게 표현할 것.
2. 타이포그래피 위계 (Hierarchy):
   - 헤드라인(`18~20sp, FontWeight.w700, letterSpacing: -0.5, #191F28`)
   - 본문/서브(`13~14sp, FontWeight.w400, height: 1.4, #4E5968`)
   - 캡션/메타정보(`12sp, FontWeight.w500, #8B95A1`)
3. UX 겹침(Overlap) 및 텍스트 깨짐(Overflow) 원천 차단:
   - 모든 `Row` 내부의 가변 텍스트는 반드시 `Expanded` 또는 `Flexible`로 감싸고 `maxLines: 1`, `overflow: TextOverflow.ellipsis`를 지정해 우측 뱃지나 아이콘과 절대 겹치지 않게 할 것.
   - 이미지 위 텍스트 오버레이(`Stack`) 사용 시, 반드시 하단 `LinearGradient` 스크림(`Colors.transparent` -> `Colors.black.withOpacity(0.75)`)을 깔고 상단 뱃지와 하단 타이틀 영역을 분리할 것.
   - 고정 높이(`height: 200` 등) 대신 내부 패딩(`EdgeInsets.all(16~20)`)으로 기기 해상도마다 유연하게 늘어나도록 반응형 설계할 것.
```

---

### ✍️ [상황 2] B2B 제휴(아지트/스폰서) & 2030 소셜 UX Writing (문구/카피 전면 교정)
> - **자동 발동 키워드**: `"문구 수정해줘"`, `"카피 다듬어줘"`, `"B2B 만들어줘"`, `"스폰서십 화면 짜줘"`
> - **매칭된 로컬 설치 모델**:
>   - **Claude**: `claude-3-sonnet` (B2B 파트너 세일즈 카피), `claude-haiku-4.5` (2030 커뮤니티 마이크로카피)
>   - **GPT**: `gpt-4.5` (고감도 브랜드 스토리텔링), `gpt-4o` (다중 카피 시안 JSON 추출)

```markdown
[역할 및 목표]
너는 12년 차 시니어 UX 라이터(UX Writer)이자 B2B SaaS/로컬 커머스 브랜드 디렉터야.
현재 화면에 들어간 개발자스러운 기계적 문구("데이터가 없습니다", "모임 목록", "입력하세요", "광고")를 전부 걷어내고, 2030 유저에게는 '취향 기반의 설렘'을, B2B 파트너(동네 공간 사장님/스폰서)에게는 '매출과 신뢰를 주는 전문 비즈니스 파트너십' 톤앤매너로 전면 교체해줘.

[연동할 로컬 설치 모델 (Claude & GPT)]
- B2B 제휴/스폰서십 카피 생성: `.venv\Scripts\python.exe scripts/claude_client.py --model claude-3-sonnet` (또는 `--model gpt-4.5`)
- 2030 마이크로카피/빈 화면/토스트 문구 생성: `.venv\Scripts\python.exe scripts/claude_client.py --model claude-haiku-4.5`

[대상 파일]
- [예: lib/screens/home_screen.dart, lib/features/venue/venue_b2b_sheet.dart]

[문구 교정 가이드라인]
1. B2C 모임 탐색/참여 문구 (감도 높은 2030 커뮤니티 스타일):
   - (X) "모임이 없습니다." -> (O) "아직 열린 모임이 없어요. 이번 주말, 첫 번째 취향 호스트가 되어볼까요?"
   - (X) "참여하기" -> (O) "같이 자리 비워두기 (남은 2석)"
2. B2B 아지트 제휴 / 스폰서십 뱃지 & 대시보드 문구 (전문성 + 전환율 중심):
   - 광고처럼 보이지 않는 '네이티브 큐레이션(Native Curation)' 용어 사용: "광고" 대신 `"✨ OOMU 공식 인증 아지트"`, `"웰컴 드링크 제공 파트너"`로 표기.
   - B2B 제휴 제안 문구: "사장님의 여유 시간대 테이블을 검증된 동네 모임으로 채우세요. 노쇼 방지 에스크로 정산으로 안정적인 단체 매출을 보장합니다."
```

---

### 🏗️ [상황 3] 풀스택(Flutter 프론트엔드 + Supabase/Firebase 백엔드 + 로컬 AI) 아키텍처 연동
> - **자동 발동 키워드**: `"풀스택 연동해줘"`, `"기능 구현해줘"`, `"DB 연결해줘"`, `"상태관리 붙여줘"`
> - **매칭된 로컬 설치 모델**:
>   - **Claude**: `claude-sonnet-4` (복합 상태관리·예외 방어), `claude-3-haiku` (앱 런타임 실시간 AI 호출)
>   - **GPT**: `gpt-4.1` (클린 아키텍처/리팩토링 1순위), `o3-mini` (매칭/정산 로직 계산), `gpt-4.1-mini` (단위 테스트 자동 생성)

```markdown
[역할 및 목표]
너는 12년 차 풀스택 수석 아키텍트(Flutter + Supabase/Firebase + Local AI Proxy)야.
단순 정적(Static) UI가 아니라, 실제 플레이스토어 상용 환경에서 네트워크 지연, 에러, 빈 데이터(Empty), 로딩(Skeleton) 상태까지 완벽하게 제어되는 100% 동적(Dynamic) 풀스택 기능을 구현해줘.

[연동할 로컬 설치 모델 (Claude & GPT)]
- 풀스택 클린 아키텍처 & 리팩토링: `.venv\Scripts\python.exe scripts/claude_client.py --model gpt-4.1` (또는 `--model claude-sonnet-4`)
- 매칭 점수 / 에스크로 정산 수식 검증: `.venv\Scripts\python.exe scripts/claude_client.py --model o3-mini`
- Flutter 앱 런타임 AI 서비스 연동: `lib/services/ai_service.dart` (`OomuAiService`, 기본 `claude-3-haiku` / `gpt-4o-mini`, Base URL: `http://127.0.0.1:1337/v1`, API Key: `'pk-dummy'`)

[구현 요구사항]
1. 아키텍처 분리:
   - 데이터/서비스 레이어(`lib/services/`), 상태 컨트롤러(`lib/features/...`), 프레젠테이션 위젯(`lib/screens/`)을 명확히 분리할 것.
2. 4대 상태(State) UI 필수 구현:
   - `Loading`: 촌스러운 기본 스피너만 중앙에 띄우지 말고, 카드 형태에 맞춘 부드러운 스켈레톤(Shimmer) 또는 인라인 로딩 인디케이터 적용.
   - `Empty` / `Error`: 네트워크 끊김이나 빈 결과 시 다시 시도(Retry) 버튼과 친절한 안내 카피 제공.
   - `Success`: 데이터 변경 시 낙관적 업데이트(Optimistic UI)와 햅틱 피드백(`HapticFeedback.lightImpact()`) 적용.
3. 보안 준수:
   - `.antigravity/rules/security_distribution_rules.md`에 따라 실제 외부 API Secret은 절대 코드에 하드코딩하지 말 것.
```

---

### 💡 [상황 4] 서비스 아이디어 발굴, B2B 수익화 기획 및 킬러 피처 추천
> - **자동 발동 키워드**: `"아이디어 추천해줘"`, `"수익화 모델 추천해줘"`, `"기획 다듬어줘"`
> - **매칭된 로컬 설치 모델**:
>   - **Claude**: `claude-3-opus` (12년 차 수석 기획·BM 설계), `claude-opus-4` (하이브리드 그로스 전략)
>   - **GPT**: `gpt-4.5` (크리에이티브 피처 기획), `o3-mini` (수익성·전환율 시뮬레이션)

```markdown
[역할 및 목표]
너는 로컬 커뮤니티/소셜 디스커버리 앱(당근, 문토, 남의집, 타임레프트 등)을 성공시킨 12년 차 CPO(최고제품책임자)이자 그로스 프로덕트 디자이너야.
현재 우리 OOMU(`docs/OOMU_MASTER_SPEC.md`)의 핵심 기능(동네 모임, 1:N 취향 매칭, B2B 아지트 스폰서십, 에스크로 정산)을 분석해서, 유저 리텐션(재방문율)과 B2B 결제 전환율을 동시에 끌어올릴 수 있는 킬러 피처 3가지를 기획해줘.

[연동할 로컬 설치 모델 (Claude & GPT)]
- 심층 BM 기획 및 사용자 여정 설계: `.venv\Scripts\python.exe scripts/claude_client.py --model claude-3-opus` (또는 `--model gpt-4.5`)
- B2B ROI 및 전환율 수리 모델링: `.venv\Scripts\python.exe scripts/claude_client.py --model o3-mini`

[응답 포맷 (반드시 아래 구조로 제시할 것)]
1. 기능명 & 한 줄 밸류 프로포지션 (2030 유저 관점 + B2B 파트너 관점)
2. 화면 UX 플로우 & 마이크로 인터랙션 설계 (바텀시트/카드 내 어디에 어떤 뱃지와 버튼이 들어가는지 구체적 묘사)
3. 실제 앱에 들어갈 UX Writing 카피 예시 (헤드라인 / 서브카피 / CTA 버튼 문구)
4. 수정/추가해야 할 Flutter 파일 경로와 즉시 적용 가능한 구현 설계도
```

---

### 🔗 [상황 5] 플레이스토어 출시 전 12년 차 수석 디자이너 UX/보안 전수 감사 (Audit)
> - **자동 발동 키워드**: `"전체 화면 감사해줘"`, `"출시 전 점검해줘"`, `"로컬 AI로 디자인 검수해줘"`
> - **매칭된 로컬 설치 모델**:
>   - **Claude**: `claude-3-opus` (휴리스틱 UX 감사), `claude-3-5-sonnet` (위젯 코드 즉시 교정)
>   - **GPT**: `o4-mini` (오버플로우/비동기 버그 스캔), `gpt-4` (보안 규칙 감사)

```markdown
[역할 및 목표]
현재 백그라운드에서 구동 중인 로컬 가상 API 서버(`http://127.0.0.1:1337/v1`)의 설치된 Claude 및 GPT 모델을 모두 활용하여, 대상 화면의 UI/UX 완성도와 보안 규칙을 플레이스토어 출시 기준으로 전수 감사(Audit)하고 코드를 즉시 리팩토링해줘.

[단계별 자동 실행 절차]
1. UX/카피 감수 (Claude):
   - `.venv\Scripts\python.exe scripts/claude_client.py --model claude-3-opus` 또는 `--model claude-3-5-sonnet`을 실행하여 대상 화면의 촌스러운 컬러, 어색한 한국어 문구, B2B 배너 이질감을 진단하고 교정안을 추출할 것.
2. 레이아웃 겹침 & 비동기 버그 감수 (GPT):
   - `.venv\Scripts\python.exe scripts/claude_client.py --model o4-mini` 또는 `--model gpt-4.1`을 활용하여 `Row`/`Column`/`Stack` 내 텍스트 오버플로우 가능성과 예외 처리 누락 구간을 점검할 것.
3. 코드 즉시 반영 및 검증:
   - 추출된 개선안을 Flutter 위젯 코드에 반영하고 `flutter analyze` 및 `test/ai_service_test.dart` 통과 여부를 보고할 것.
```

---

## 3. 💬 기존 OOMU 앱 개발 채팅창 전용: 작업 요청 시 바로 복붙하는 프롬프트

기존에 여러 차례 OOMU를 개발하던 채팅창(`Gemini 4 Argon High` 등)은 이전 대화 문맥에 머물러 있을 수 있으므로, **아래 프롬프트를 복사해서 던지면 새로 구축된 지침 파일들과 로컬 Claude 7종 / GPT 9종 서버를 즉시 읽고 적용**합니다.

### 3-1. [최초 1회 주입용] 기존 OOMU 채팅창 컨텍스트 동기화 프롬프트
```markdown
지금부터 OOMU 앱 작업을 이어가기 전에, 방금 프로젝트에 새로 구축된 아래 핵심 지침 파일과 로컬 AI 서버 연동 파일들을 반드시 `view_file`로 전부 읽고 숙지해줘.

[필수 선행 열람 파일 경로]
1. `AI_INSTRUCTIONS.md` (질문 키워드별 자동 프롬프트 트리거 & 설치된 Claude 7종 / GPT 9종 모델 매핑 지침)
2. `.antigravity/rules/ui_ux_design_rules.md` (12년 차 수석 프로덕트 디자이너 UI/UX 토큰, 배경 `#F8F9FA` vs 카드 `#FFFFFF` 분리, UX 겹침/Overflow 0%, 2030/B2B UX Writing 규칙)
3. `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md` (`[상황 1]~[상황 5]` 상황별 프롬프트 및 로컬 설치 Claude/GPT 모델 매칭 가이드)
4. `scripts/claude_client.py` & `ddg_proxy.py` (로컬 `http://127.0.0.1:1337/v1`, API Key `'pk-dummy'`로 백그라운드 구동 중인 무료 Claude 7종 / GPT 9종 호출 브릿지)
5. `lib/services/ai_service.dart` & `lib/features/matching/match_controller.dart` (Flutter 앱 내 로컬 AI 연동 서비스 및 컨트롤러)

위 5개 경로의 파일을 모두 읽은 뒤, 앞으로 내가 이 채팅창에서 "디자인 수정해줘", "겹침 해결해줘", "문구/B2B 수정해줘", "풀스택 연동해줘"라고 요청할 때마다 무조건 위 지침서의 12년 차 디자이너 기준과 로컬 설치 모델(`claude-3-5-sonnet`, `claude-opus-4`, `gpt-4.1`, `o4-mini` 등)을 결합해서 작업하겠다고 보고해줘.
```

### 3-2. [매번 작업 요청할 때마다 쓰는 만능 프롬프트 템플릿] (OOMU 실제 화면 경로 포함)
```markdown
[필수 선행 지시]
작업 시작 전 반드시 `AI_INSTRUCTIONS.md`, `.antigravity/rules/ui_ux_design_rules.md`, `docs/ANTIGRAVITY_PROMPT_PLAYBOOK.md`를 먼저 읽고 해당 상황의 지침과 로컬 설치 모델(`http://127.0.0.1:1337/v1`, `scripts/claude_client.py`)을 적용해줘.

[이번 작업 대상 OOMU 파일 경로]
- 대상 파일: [아래 OOMU 실제 경로 중 선택 또는 직접 입력]
  - 메인 홈 & 서브: `lib/screens/home_screen.dart`, `lib/screens/home_sub_screens.dart`
  - 모임/파티 상세·개설·신청: `lib/screens/party_screen.dart`, `lib/screens/party_detail_screen.dart`, `lib/screens/party_host_screen.dart`, `lib/screens/party_application_screen.dart`
  - 동네 크루 & 자만추: `lib/screens/neighborhood_crew_screen.dart`, `lib/screens/local_friends_screen.dart`, `lib/screens/natural_meeting_detail_screens.dart`
  - 아지트 스팟 & 2차/중간지점: `lib/screens/soso_spot_screen.dart`, `lib/screens/second_spot_screen.dart`, `lib/screens/middle_spot_map_screen.dart`
  - 에스크로 정산/지갑: `lib/screens/soso_wallet_screen.dart`, `lib/screens/wallet_history_screen.dart`, `lib/screens/travel_payment_screen.dart`
  - 채팅 & 마이페이지: `lib/screens/chat_screen.dart`, `lib/screens/my_page_screen.dart`, `lib/screens/my_page_sub_screens.dart`

[요청 작업 내용]
- 요청 사항: [예: 이 화면 디자인이 너무 촌스럽고 텍스트가 겹쳐 보여. 12년 차 수석 디자이너 수준(플레이스토어 즉시 출시 급)으로 UI/UX 리디자인하고, B2B 아지트 스폰서십 배지와 2030 감성 문구로 전면 수정해줘.]
- 적용할 로컬 모델:
  1) UI/UX 디테일 & 카피: `.venv\Scripts\python.exe scripts/claude_client.py --model claude-3-5-sonnet` (또는 `claude-3-sonnet`, `claude-haiku-4.5`)
  2) 레이아웃 겹침(Overflow) 0% & 풀스택 구조 검증: `.venv\Scripts\python.exe scripts/claude_client.py --model o4-mini` (또는 `gpt-4.1`, `o3-mini`)
```

