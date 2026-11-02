# 🎯 OOMU 작업별 프롬프트 & 스킬/모델 참조 가이드

> **단일 디자인 기준**: 모든 UI/UX 수치는 **[docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)**를 유일한 기준으로 삼습니다.

---

## 1️⃣ 문서 및 스킬 참조 원칙 (과도한 다중 열람 및 강제 호출 해제)

1. **단일 디자인 가이드**: 색상·타이포그래피·간격·터치 영역 수치는 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)만 따르며 여러 문서에 중복 복사하지 않습니다.
2. **스킬 1개 기본 선택**: 매 턴마다 다수의 문서를 강제로 열람하지 않습니다. 워크스페이스 스킬의 실제 탐색·로딩 원본 경로는 `.agents/skills/<name>/SKILL.md`이며, **작업에 가장 관련 있는 스킬 1개를 기본으로 선택**하고 필요한 경우에만 추가 참조합니다.
3. **로컬 AI 브릿지 선택적 사용**: 로컬 프록시(`http://127.0.0.1:1337/v1`, `scripts/claude_client.py`) 호출은 매 턴 강제하지 않으며, 인앱 AI 기능(`lib/services/ai_service.dart`) 연동이나 명시적 요청 시에만 사용합니다.
4. **보안 규칙 준수**: `.antigravity/rules/security_distribution_rules.md` 및 `docs/SECURITY_AGENT_GUIDE.md`의 3계층 Zero-Secret 보안 규칙은 상시 준수합니다.

---

## 2️⃣ 실제 화면 경로별 체크리스트 (`lib/screens/` 기준)

> **경로 안내**: 과거 지침의 `lib/features/...` 경로는 존재하지 않으며, `main.dart` 기준 실제 활성 화면인 `lib/screens/...` 파일에 적용합니다.

### ① 홈 & 모임 화면 (`lib/screens/soso_car_home_screen.dart`, `lib/screens/soso_car_detail_screen.dart`)
- **적용 기준**: [docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)
- **핵심 체크리스트**:
  1. **컬러·타이포·간격**: [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 단일 수치를 따릅니다 (구형 분홍 배경 `#FAF6F7` 및 주황 강조 `#FF6B4A`는 사용 금지 예시).
  2. **유연한 텍스트 렌더링**: 주소·시간·모임 소개 등 주요 정보가 작은 화면(360~390px) 및 글자 확대 시에도 `RenderFlex overflow` 없이 표시되도록 처리합니다 (Flutter `TextStyle`에 없는 `WordBreak.keepAll` 사용 금지).
  3. **금액 표기 원칙**: 실제 확인된 비용 정보(`fee`/`cost`/`price`)가 있을 때만 표시하며, 임의의 `'무료 참여'`나 `'1/N 안심 정산'` 배지로 대체하지 않습니다.

### ② 아지트 스팟 화면 (`lib/screens/soso_spot_screen.dart`, `lib/screens/explore_map_screen.dart`)
- **적용 기준**: [docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)
- **핵심 체크리스트**:
  1. **네이티브 큐레이션 UX Writing**: 공급자 중심의 투박한 문구 대신 친근한 라이프스타일 문구를 사용합니다.
  2. **배지 및 레이아웃**: 배지 색상은 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 컬러 규칙을 따르며, 구형 주황 틴트(`#FFF4EB` + `#FF6B35`) 강제를 배제하고 한 줄에서 겹치지 않도록 `Expanded`/`Flexible`로 정렬합니다.

### ③ 채팅방 & 알림 화면 (`lib/screens/chat_screen.dart`, `lib/screens/soso_car_chat_screen.dart`, `lib/screens/notification_screen.dart`)
- **적용 기준**: [docs/OOMU_UI_GUIDE.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md) 및 `lib/services/ai_service.dart`
- **핵심 체크리스트**:
  1. **인앱 AI 연동 폴백 안전성**: 로컬 프록시 미구동 환경에서도 기본 추천 멘트로 안전하게 폴백되도록 예외 처리를 유지하고, 추천 문구 컨테이너에 무리한 고정 `height`를 주지 않습니다.
