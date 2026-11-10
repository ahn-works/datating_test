# 🤖 Antigravity AI Agent Directive (OOMU / Spot10 Project)
> **이 문서는 OOMU(우리 동네 취향 모임) 프로젝트를 다루는 AI 에이전트를 위한 시스템 지침서입니다.**

## 🎨 00. OOMU UI/UX 단일 기준 안내 (docs/OOMU_DESIGN_SYSTEM.md)

모든 UI/UX 작업 시 색상·타이포그래피·간격·터치 타깃 수치는 여러 문서에 중복 복사하지 않고 유일한 기준 문서인 **[docs/OOMU_DESIGN_SYSTEM.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)**를 참조합니다.
- **단일 디자인 기준**: 배경·표면·텍스트·강조 포인트 색상 및 타이포그래피·여백·터치 영역 수치는 [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)를 유일한 기준으로 적용합니다 (구형 분홍 배경 `#FAF6F7`, 주황 강조 `#FF6B4A`는 사용 금지 예시).
- **콘텐츠 중심 유연한 레이아웃**: 주소·시간·소개 등 주요 정보의 자연스러운 줄바꿈 허용 및 비대칭 짤림 방지 (Flutter `TextStyle`에 없는 `WordBreak.keepAll` 적용 지시 금지).
- **금액 표기 원칙**: 실제 확인된 비용 정보(`fee`/`cost`/`price`)가 있을 때만 표시하며, 임의의 `'무료 참여'`나 `'1/N 안심 정산'` 배지로 대체하지 않습니다 (`docs/OOMU_DESIGN_SYSTEM.md` 단일 기준).
- **실제 활성 화면 수정**: `main.dart` 기준 실제 활성 화면(`lib/screens/soso_car_home_screen.dart`, `lib/screens/soso_car_detail_screen.dart` 등)을 수정합니다.

---

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
- **통합 명세서:** `docs/OOMU_MASTER_SPEC.md` (기획 및 도메인 스펙 참조용)

---

## 2. 🧭 스킬 선택 및 선택적 로컬 AI 브릿지 안내

- **단일 스킬 우선 참조 원칙**: 매 턴마다 다수의 지침 문서를 강제로 열람하거나 외부 로컬 모델을 무조건 호출하지 않습니다. 워크스페이스 스킬의 실제 탐색·로딩 원본 경로는 `.agents/skills/<name>/SKILL.md`이며, **작업 성격에 가장 적합한 관련 스킬 1개를 기본으로 선택**하고 복합 작업 시에만 필요한 스킬을 추가 참조합니다.
- **슬래시 명령어 원칙**: 슬래시(`/`) 명령어는 현재 IDE에서 실제 지원되는지 확인되지 않은 경우 추천하지 않습니다.
- **선택적 로컬 AI 브릿지 (`http://127.0.0.1:1337/v1`)**: 앱 내 실시간 AI 기능(`lib/services/ai_service.dart`, `OomuAiService`) 또는 사용자가 명시적으로 로컬 프록시 모델(`scripts/claude_client.py`) 테스트를 요청한 경우에만 선택적으로 활용합니다.

### 📂 OOMU 핵심 화면 실제 경로 (`lib/screens/`)
> 과거 문서의 `lib/features/...` 경로는 존재하지 않으며, 실제 활성 화면은 아래 `lib/screens/` 경로입니다.

1. **홈·번개·커뮤니티·소개팅 및 모임 상세/개설**:
   - `lib/screens/soso_car_home_screen.dart`, `lib/screens/soso_car_detail_screen.dart`, `lib/screens/soso_car_host_screen.dart`, `lib/screens/community_post_detail_screen.dart`, `lib/screens/community_post_create_screen.dart`
   - 모든 색상·타이포그래피·간격·배지 스타일은 [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md) 단일 기준을 따릅니다.
2. **아지트 스팟 및 정산 화면**:
   - `lib/screens/soso_spot_screen.dart`, `lib/screens/second_spot_screen.dart`, `lib/screens/middle_spot_map_screen.dart`, `lib/screens/soso_wallet_screen.dart`, `lib/screens/wallet_history_screen.dart`
3. **채팅·마이·프로필 화면**:
   - `lib/screens/chat_screen.dart`, `lib/screens/soso_car_chat_screen.dart`, `lib/screens/my_page_screen.dart`, `lib/screens/user_profile_screen.dart`, `lib/screens/profile_edit_screen.dart`

---

## 3. ⚡ UI/UX 프론트엔드 개발 원칙
모든 UI 컴포넌트는 **[`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)**의 디자인 기준과 아래 원칙을 따릅니다.

1. **동적(Dynamic) 상태 연동**: 사용자 상호작용이 발생하는 요소는 실제 상태가 반영되도록 구현합니다.
2. **레이아웃 겹침(Overflow) 0%**: `Expanded`, `Flexible`, `LayoutBuilder` 등을 활용하여 다양한 화면 크기(360~430px)와 글자 확대(1.0~2.0배)에서 글자가 겹치거나 깨지지 않도록 설계합니다.
3. **바텀시트(Bottom Sheet) 안전 영역**: `showModalBottomSheet` 사용 시 `isScrollControlled: true` 및 키보드 `viewInsets.bottom` 패딩을 고려합니다.

## 4. 🛠️ 백엔드 및 예외 처리 원칙
- **방어적 코딩 (Defensive Coding):** 파이어베이스(Firestore, Cloud Functions) 및 AI 서비스 연동 시 `try-catch` 블록으로 통신 에러를 방어합니다.
- **우아한 실패 (Graceful Degradation):** 통신 지연(Loading)이나 에러 발생 시 앱이 멈추지 않고 Fallback UI가 렌더링되도록 처리합니다.

## 5. 🚀 완료 보고 전 필수 검증 게이트
- **Flutter / Dart 코드 수정 시**: `flutter analyze` 및 `flutter test`를 실행하여 오타 및 에러 여부를 확인한 뒤 정직하게 보고합니다.
- **보안 규칙 검증**: 커밋/배포 전 `scripts/verify_security_rules.ps1` 통과 여부를 확인합니다.

## 6. REA(리버스 엔지니어링 MCP) 사용 지침
- 앱 빌드 산출물(APK/웹 빌드) 분석이 필요한 특수 상황에서만 `docs/REA_GUIDE.md` 규칙에 따라 사용하며, 소스 코드로 확인 가능한 일반 작업에는 사용하지 않습니다.

---

## 7. 📱 SMS 및 본인인증 서비스 연동 원칙 (알리고 영구 배제 & 솔라피 표준화)
- **알리고(Aligo) 금지**: 알리고는 비사업자 개인에게 API Key 발급을 차단하므로 사용하지 않습니다.
- **솔라피(SOLAPI, 구 CoolSMS) 표준**: 개인 회원도 휴대폰 본인인증(PASS)으로 발신번호 등록이 가능한 솔라피를 표준으로 유지합니다.

## 8. ⚙️ 운영 스크립트 참고
- 자동화 워크플로우: `.github/workflows/oomu_cron_ops.yml`
