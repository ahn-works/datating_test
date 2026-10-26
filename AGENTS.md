# 🏛️ OOMU (오뮤) 통합 에이전트 지침서 (AGENTS.md)

> **자동 로드 안내**: 본 파일(`AGENTS.md`)은 Antigravity 에이전트가 세션 시작 및 매 작업 턴마다 자동으로 가장 먼저 읽어들여 메모리에 상주시키는 **최상위 통합 지침**입니다. 사용자가 매번 긴 프롬프트 머리말을 복사·붙여넣지 않아도 아래의 모든 지침과 로컬 AI 모델(Claude 7종 / GPT 9종) 라우팅이 자동 적용됩니다.

---

## 🏆 0. [최우선 제0원칙 — 모든 작업 시작 전 가장 먼저 읽고 적용할 것] 글로벌 1티어 디자인 아카이브 & 대기업 경쟁 앱 상시 벤치마킹 & 네이티브 모바일 UX 절대 준수 규칙

에이전트는 어떤 화면·컴포넌트·리스트·모달을 디자인하거나 수정할 때든 **코드를 한 줄이라도 작성하기 전에 반드시 아래 글로벌 1티어 디자인 아카이브 및 국내 1티어 경쟁 앱들의 실제 모바일 네이티브 UX/UI 패턴을 먼저 참고(벤치마킹)하여 100점 마감으로 결과물을 도출**해야 합니다.

### 0-1. 글로벌 1티어 3대 디자인 아카이브 & 국내 선행 벤치마킹 기준 (Mobbin · TDS · 29CM/컬리 · 당근/위피)
1. **Mobbin (모빈 - 실리콘밸리 글로벌 1위 상용 앱 아카이브)**:
   - **Airbnb, Bumble, Hinge, Uber** 등 상용 출시된 300,000+ 실제 모바일 스크린 플로우 기준.
   - 지도 위 바텀시트 오버레이 탐색(Sheet-over-Map), 매끄러운 다단계 온보딩, 불필요한 입력을 줄인 미니멀 폼 디자인.
2. **토스 디자인 시스템 (TDS - 대한민국 모바일 UX의 정점)**:
   - **마찰 제로(Zero-Friction)**: 유저가 멈칫하거나 헷갈리지 않는 4-Tier 한글 타이포그래피 행간(1.4~1.5)과 여백 체계.
   - 4단계 촉각 햅틱 피드백(`HapticFeedback`), 닫기 편한 러버밴드 바텀시트, 텅 빈 화면(Empty State)에서의 명확한 원-액션 유도.
3. **29CM & 마켓컬리 에디토리얼 레이아웃 (30대 감성 매거진 큐레이션)**:
   - 배경(오트밀 로즈 크림 `#FAF6F7`)과 카드 표면(순백 `#FFFFFF`)의 확실한 명도 분리 + `1px hairline border (#E2E8F0)` + `0.03` 미세 음영.
   - 기계적 나열이 아닌 에디토리얼 헤드라인 ("퇴근길 가볍게 들르는 연남동 와인바", "이번 주말, 브런치 산책 갈 동네 친구").
4. **국내 하이퍼로컬 & 소셜 레퍼런스**:
   - **당근마켓(동네모임)**, **문토(MUNTO)**: 좌측 88×88 정방형 썸네일 + 우측 태그/2줄 제목/일정·장소/아바타 스택 & 정원 표시.
   - **위피(WIPPY)**: 틴더식 스와이프 배제, 가치관 Q&A 문답, 취향 태그 칩, 주말 단골 아지트 중심 스토리 카드.

### 0-2. OOMU 10대 상용화 플러터 디자인 스킬 체계 (MIT 라이선스 / 상업용 100% 보장)
에이전트는 모든 UI 작업 시 아래 10대 검증된 상용 컴포넌트 스킬을 직교 참조하여 결함 없는 고감도 화면을 구현합니다:
1. `karrot-hyperlocal-feed`: 당근마켓 스타일 88×88 정방형 피드, 2줄 말줄임, 100:100 대칭 2열 그리드
2. `wippy-social-jamanchu`: 위피 스타일 30대 가치관 Q&A 스토리 카드, 안심 프로필 교환
3. `event-meetup-engine`: 문토/EventHub 스타일 인원 아바타 스택(AvatarStack), 하단 고정 신청 바
4. `women-safe-anti-creep`: 여성 안심 호스트 승인제, 여성 전용 필터, 1-Click 비밀 차단/신고 (UGC 규정 준수)
5. `manner-temp-badges`: 실시간 매너온도 게이지(36.5°C 기준), PASS/SMS 인증 뱃지, 칭찬 후기 칩
6. `interactive-game-icebreakers`: 밸런스 토론 배틀, 온라인 노래방 점수 내기, 타로 궁합 카드
7. `escrow-split-billing`: 1/N 안심 정산 영수증 바텀시트, 토스/카카오페이 간편 송금 연동
8. `shadcn-mobile-components`: 1px 미세 보더 카드, 슬림 필 도트 인디케이터(━━ • • •)
9. `fluid-micro-interactions`: 4단계 햅틱 피드백(Haptics), 슬리버 패럴랙스 스크롤 헤더
10. `figma-mobile-tokens`: 피그마 ↔ Flutter 토큰(선셋 코랄, 8dp 그리드, Pretendard 타이포)

### 0-3. 🎯 [100점 풀-피니시 (Full-Finish) 절대 원칙] (바이브 코딩 땜질 0% 강제)
에이전트는 사용자가 화면이나 기능을 요청했을 때 "대충 위젯 뼈대만 만들거나", "일부 파일만 땜질하고 끝내는 행위"를 엄격히 금지하며, 다음 **5대 완성 게이트**를 모두 충족해야만 작업 완료로 보고합니다:

1. **4-State Full Coverage (상태값 4종 전수 구현)**:
   - 데이터 로딩 중(Shimmer 스켈레톤), 빈 화면(Empty State - 따뜻한 감성 일러스트 & 즉시 행동 유도 CTA 버튼), 에러 발생 시(재시도 버튼), 정상 데이터 화면을 100% 구현.
2. **픽셀 단위 마이크로 마감 (Micro-Detail Polish)**:
   - 8dp 그리드 여백 시스템(Padding 16, 20, 24dp), 1px 미세 보더, `wordBreak: WordBreak.keepAll` (한글 단어 보존), 최소 48×48dp 터치 타깃, `RenderFlex overflow` 0건 검증.
3. **조잡함 원천 차단 (배열 & 시각적 위계 정돈)**:
   - **메인 피드**: 난잡한 잡탕 배치를 퇴출하고, [상단 퀵 필터 칩 ➡️ 2열 100:100 대칭 트렌드 스냅 카드 ➡️ 당근 스타일 88×88 정방형 동네 모임 리스트]로 시각적 호흡 정리.
   - **탐색 화면 (Explore/Discovery)**: 지도(카카오맵) 핀 오버레이와 카테고리/동네/거리별 필터 바텀시트가 결합된 전용 탐색 뷰 완결.
   - **모임 상세보기**: 관공서 폼 스타일을 퇴출하고, 29CM 스타일 대형 슬리버 패럴랙스 헤더 ➡️ 호스트 신뢰도 카드 ➡️ 참여 멤버 아바타 스택 ➡️ 하단 고정 신청 바 완결.
4. **30대 공감 현실 카피라이팅 (Realistic Copywriting)**:
   - 기계적인 "테스트1", "모임 제목" 전면 퇴출. 실제 서울/수도권 및 전국 주요 핫플(성수, 연남, 을지로, 삼청동)과 30대 싱글/직장인이 공감하는 스토리형 카피 기본 탑재.
5. **빌드 검증 & 깃 배포 (Zero Regression)**:
   - `flutter analyze` 경고/에러 0건 확인, 보안 스크립트(`verify_security_rules.ps1`) 통과, `git push origin main` 후 GitHub Actions 초록불 확인.

### 0-4. 절대 금지 5대 조잡함 안티패턴 (Anti-Patterns — 위반 시 즉시 재작업)
- ❌ **PC 웹 게시판형 페이지네이션 바 금지**: 안드로이드/iOS 네이티브 앱에 존재하지 않는 `< 이전  1 / N 페이지  다음 >` 형태의 하단 페이지 전환 바는 절대 사용 금지.
- ❌ **우측 카드 65% 지점 짤림(Clipping) 및 비대칭 배치 금지**: 모바일 뷰포트(`480px` 프레임 포함) 안에서 첫 번째 카드와 두 번째 카드의 크기가 다르거나(예: 100% vs 65%), 우측 화면 경계에 걸려 제목·버튼 글자가 잘리는 레이아웃 절대 금지 (`MediaQuery` 폭 동기화 및 `Expanded` 1:1 분할 필수).
- ❌ **원화 금액(`원`, `₩`, 구체적 참가비 숫자) 노출 금지**: 모든 모임·상세·신청·큐레이션 카드는 가격 대신 **`1/N 안심 정산`** 또는 **`무료 참여`**로만 표기.
- ❌ **틴더식 좌우 스와이프 평가 UI 금지**: 사람을 물건처럼 넘겨버리는 스와이프 UI 대신 감성 스토리 카드 사용.
- ❌ **무미건조한 텍스트 덩어리 화면 금지**: 썸네일과 아바타 없는 딱딱한 관공서 표 스타일 금지.

---

## 📂 1. 분리 관리되는 세부 지침 파일 맵 (Single Source of Truth)

| 구분 | 파일 경로 | 핵심 역할 |
| :--- | :--- | :--- |
| **통합 프롬프트 트리거** | [`AI_INSTRUCTIONS.md`](file:///c:/Users/developersim/Desktop/datating_test/AI_INSTRUCTIONS.md) | 질문 키워드별 자동 프롬프트 트리거 & 4대 핵심 도메인 통합 지침 |
| **OOMU 프론트엔드 디자인 스킬** | [.agents/skills/frontend-design/SKILL.md](file:///C:/Users/DT4/Downloads/oomu_app/.agents/skills/frontend-design/SKILL.md) | 30대 찐친·여성안심 철학, 5대 AI 클리셰 배제, Flutter 모바일 인체공학 터치/바텀시트, 2-Pass 디자인 검증 |
| **프롬프트 & 모델 라우팅** | [`.antigravity/rules/prompt_routing_rules.md`](file:///c:/Users/developersim/Desktop/datating_test/.antigravity/rules/prompt_routing_rules.md) | 고정 머리말 규칙, 화면 경로별 실전 프롬프트 3선, 로컬 Claude 7종/GPT 9종 자동 매칭표 |
| **12년 차 UI/UX 디자인 규칙** | [`.antigravity/rules/ui_ux_design_rules.md`](file:///c:/Users/developersim/Desktop/datating_test/.antigravity/rules/ui_ux_design_rules.md) | 경쟁 앱 벤치마킹 기준, 배경 `#F8F9FA` vs 카드 `#FFFFFF` 분리, 파스텔 뱃지, Overflow 0%, 2030/B2B UX Writing |
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
> 알리고는 웹 회원가입 시 '개인' 유형이 있더라도, **API Key 발급 페이지( dmin/api/auth.html)에서 자바스크립트 checkCert() 검사를 통해 강제로 사업자등록 인증 페이지(/admin/account.html)로 튕겨내므로 사업자등록증이 없는 개인 개발자는 API Key 발급이 물리적으로 불가능**합니다.
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
