# 🤖 Antigravity AI Agent Directive (OOMU / Spot10 Project)
> **이 문서는 OOMU(우리 동네 취향 모임) 프로젝트를 다루는 모든 AI 에이전트(Antigravity 등)가 항상 첫 번째로 읽고 절대적으로 준수해야 하는 시스템 지침서입니다.**

## 0. 🔒 필수 보안 및 3계층 분배 규칙 (Security Distribution Rules) — 필독!
작업을 시작하기 전, 에이전트는 반드시 **`.antigravity/rules/security_distribution_rules.md`** 및 **`docs/SECURITY_AGENT_GUIDE.md`**를 최우선으로 읽고 다음 3단계 분배 원칙을 철저히 지켜야 합니다.

1. **보안 파일 및 자격 증명 (Firebase Firestore ONLY)**:
   - Cloudflare R2 S3 API Secret Access Key, Firebase 서비스 키, 민감 개인정보는 **절대 Git에 커밋하지 않습니다.**
   - 모든 자격 증명은 Firestore `config/r2_storage`에 안전하게 보관되며, 런타임에 동적으로 로드됩니다.
2. **사진 및 미디어 스토리지 (Cloudflare R2 ONLY)**:
   - 프로필 사진, 모임 커버 사진, 채팅 사진은 모두 Cloudflare R2 (`oomu-spot` 버킷)에 저장됩니다.
   - 깃허브에는 대용량 사용자 사진을 직접 올리지 않으며, 비이미지 파일 업로드는 차단합니다.
   - 이미지는 AWS SigV4 Presigned GET URL 또는 R2 Public CDN URL을 통해 안전하게 표시합니다.
3. **순수 소스코드, 문서, UI 및 지침 (GitHub ONLY)**:
   - Flutter/Dart 소스코드, 마크다운 가이드 문서, 테스트 코드는 깃허브에서 투명하게 관리됩니다.
   - 커밋 전 항상 `scripts/verify_security_rules.ps1` 또는 `scripts/verify_security_rules.sh`를 실행하여 제로 시크릿(Zero-Secret) 상태를 검증합니다.

## 1. 🎯 프로젝트 정체성 및 통합 명세서 확인
- **프로젝트명:** OOMU (우리 동네 취향 모임 / Spot10 전면 개편)
- **최고 우선순위 명세서:** `docs/OOMU_MASTER_SPEC.md`
  - 이전의 8개 파편화된 아티팩트(UX 진행률 대시보드, 구조 설계서, 작업계획서 등)는 모두 `OOMU_MASTER_SPEC.md` 단일 파일로 완벽하게 통합 및 압축되었습니다.
  - 에이전트는 작업을 시작하기 전 반드시 위 마스터 스펙 파일을 읽고 프로젝트의 딥러닝/매칭 알고리즘과 비즈니스 로직을 완벽히 이해해야 합니다.

## 2. ⚡ UI/UX 프론트엔드 개발 절대 원칙 (전면 동적 작동)
기획자님의 특별 지시사항에 따라, 모든 UI 컴포넌트는 다음 원칙을 무조건 따릅니다.

1. **모든 요소의 100% 동적(Dynamic) 작동화**
   - 단순히 디자인만 보여주는 정적(Static) UI나 더미 텍스트 하드코딩은 절대 금지합니다.
   - 버튼 클릭, 투표 진행, 프로필 교환, 정산 송금 등 **사용자 상호작용이 발생하는 모든 요소는 상태가 실시간으로 변하는 `StatefulWidget`으로 구현**해야 합니다.
2. **디자인 픽셀(px) 고정 절대 금지 (No Fixed Design)**
   - 기기 화면 크기(Mobile, Tablet 등)에 맞게 유연하게 반응(Responsive)해야 합니다.
   - `Expanded`, `Flexible`, `LayoutBuilder` 등을 적극 활용하며, 높이나 너비를 절대값(px)으로 하드코딩하는 것을 엄격히 금지합니다.
3. **바텀시트(Bottom Sheet) 중심의 인터랙션 설계**
   - 사용자 입력(신청 메시지, 투표 항목 작성 등)을 받을 때는 새 화면(Route)으로 넘기지 말고, `showModalBottomSheet`를 띄워 현재 채팅창/화면 맥락(Context)을 유지하게 만드세요.

## 3. 🛠️ 백엔드 및 예외 처리 원칙
- **방어적 코딩 (Defensive Coding):** 파이어베이스(Firestore, Cloud Functions) 연동 시, 반드시 `try-catch` 블록을 작성하여 통신 에러를 방어하세요.
- **우아한 실패 (Graceful Degradation):** 통신 지연(Loading)이나 에러 발생 시 앱이 멈추지 않고, 스켈레톤 로딩이나 Fallback UI가 부드럽게 렌더링되도록 처리하세요.

## 4. 🚀 에이전트 행동 지침 (Action Item)
- 이 프로젝트 레포지토리에 처음 접근한 AI는 사용자에게 **"안녕하세요! OOMU 프로젝트 지침(AI_INSTRUCTIONS.md)을 완벽히 숙지했습니다. 모든 디자인을 반응형으로 구성하고 동적 기능 연동을 준비했습니다."**라고 보고한 뒤 작업을 시작하세요.
- 새로운 화면이나 컴포넌트를 생성할 때는 무조건 `docs/OOMU_MASTER_SPEC.md`의 기획 의도에 맞는지 자체 검증(Self-Correction) 과정을 거치세요.


## 4. REA(리버스 엔지니어링 MCP) 사용 지침 — 필독
- 이 프로젝트는 Antigravity에 **REA MCP**(`rea`)가 연결되어 있습니다. 앱 빌드 산출물(APK/웹 빌드) 검증, UI/동작 확인, 로그 분석이 필요할 때 **반드시 `docs/REA_GUIDE.md`를 먼저 읽고** 그 규칙에 따라 사용하세요.
- 우리 소유 앱만 분석하며, 임시 분석 파일은 작업 후 삭제(Zero-Trace)합니다.
- 소스 코드로 답이 나오는 일반 분석에는 REA를 쓰지 않습니다.
