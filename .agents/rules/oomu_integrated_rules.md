---
trigger: always_on
---
# 🏛️ OOMU 상시 자동 발동 핵심 규칙 (oomu_integrated_rules.md)

본 규칙(`trigger: always_on`)은 모든 대화 턴에서 자동 적용되며, [AGENTS.md](file:///c:/Users/DT4/Downloads/oomu_app/AGENTS.md) 및 [docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)와 100% 동일한 기준을 따릅니다.

## 1. 에이전트 핵심 태도 (대표님께 검수 부담을 떠넘기지 않는다)
- **능동적 전문가 감사 (Proactive Audit)**: 대표님이 일일이 화면의 어색한 점(컬러 부조화, 글자 크기, 간격, 외톨이 줄바꿈, 동네/세션 꼬임)을 찾아내어 지시하지 않아도, 에이전트가 먼저 코드와 화면을 점검하여 문제 목록을 도출하고 수정합니다.
- **과장 표현 금지**: "100% 완벽", "무결점" 같은 허세 섞인 보고를 금지하고, 실제 발견·수정한 구체적 항목만 정직하게 보고합니다.
- **스킬 및 명령어 원칙**: 워크스페이스 스킬은 원본 경로인 `.agents/skills/`에서 작업 성격에 맞는 관련 스킬 1개를 기본으로 선택해 참조합니다. 슬래시 명령어는 현재 IDE에서 실제 지원되는지 확인되지 않은 경우 추천하지 않습니다.

## 2. 컬러 & 디자인 시스템 (단일 기준: `docs/OOMU_UI_GUIDE.md`)
- 모든 색상·타이포그래피·간격·터치 타깃 수치는 중복 복사하지 않고 유일한 기준 문서인 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)를 따릅니다.
- **핑크 범벅 및 원색 남발 금지 (사용 금지 예시)**: 구형 분홍 배경(`#FAF6F7`)이나 한 화면에 파랑(`#3B68FF`), 초록(`#0D9488`), 주황(`#FFF0EB` / `#FF6B4A`), 핑크(`#F25767`) 배지를 동시에 섞어 쓰는 구형 방식은 금지합니다.

## 3. 타이포그래피·간격·레이아웃 디테일 기준
- **상단 앱바(AppBar)**: 동네 이름(`여수시 화장동`)이 `여수시 화...`처럼 잘리지 않도록 불필요한 장식 배지(`이웃 54명...`)와 아이콘 배경 원을 정리합니다.
- **외톨이 줄바꿈(Widow) 금지**: `만들 / 기`, `가보신 / 분?`, `(20 / 대 중후반)`처럼 1~2글자만 다음 줄로 떨어지거나 단어 중간이 끊어지지 않도록 카피·패딩·폰트 크기를 조정합니다 (Flutter `TextStyle`에 없는 `WordBreak.keepAll` 지시 금지).
- **카드 안의 박스(Card-in-Card) 금지**: 카드 내부에 또 두꺼운 테두리 박스를 중첩하지 않고 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md) 규격의 여백으로 깔끔하게 정돈합니다.
- **가로 스크롤 칩 2중 적층 금지**: 화면 상단에 태그 바와 카테고리 바가 2줄 연속으로 쌓여 복잡해 보이지 않도록 정돈합니다.
- **하단 네비게이션 바**: 선택된 탭 뒤에 과도한 분홍색 원형 배경이 튀어나오지 않도록 깔끔한 아이콘+라벨 하이라이트를 사용합니다.

## 4. 보이지 않는 세션·상태·동네 정합성 점검
- 로그인/로그아웃/계정 변경 시 이전 계정의 동네(`location`), 닉네임, 찜(`savedMeetups`), 차단/신고 등 사용자별 상태가 남지 않도록 상태 초기화를 항상 확인합니다.
- 유저 프로필 동네(예: `여수시 화장동`)와 홈·번개·커뮤니티·소개팅 모임 지역 및 썸네일 사진 맥락(여수 모임에 서울 롯데타워 사진 사용 금지 등)이 일치하는지 스스로 점검합니다.

## 5. 실제 수정 경로 및 사전 검증
- 실제 활성 화면인 `lib/screens/soso_car_home_screen.dart`, `lib/screens/soso_car_detail_screen.dart`, `lib/screens/community_post_detail_screen.dart` 등을 직접 수정합니다 (존재하지 않는 `lib/features/...` 참조 금지).
- 코드 수정 후 `flutter analyze`(또는 `verify_dart_syntax.py`) 및 `verify_security_rules.ps1` 통과를 확인한 뒤 보고합니다.
- **3계층 Zero-Secret 보안 지침 수정 금지**: [`.antigravity/rules/security_distribution_rules.md`](file:///c:/Users/DT4/Downloads/oomu_app/.antigravity/rules/security_distribution_rules.md) 및 [`docs/SECURITY_AGENT_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/SECURITY_AGENT_GUIDE.md)는 절대 임의 수정하지 않으며, 모든 유료 API 키 하드코딩 금지 및 Firestore 런타임 로드 원칙을 100% 유지합니다.
