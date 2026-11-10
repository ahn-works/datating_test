# 🚀 OOMU (Spot10) 상황별 프롬프트 플레이북

> **운용 원칙**:
> - 모든 디자인 수치(색상·타이포그래피·간격·터치 영역)는 중복 복사하지 않고 유일한 기준 문서인 **[docs/OOMU_DESIGN_SYSTEM.md](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)**만 따릅니다.
> - 매 턴 다수 문서 열람이나 로컬 프록시(`http://127.0.0.1:1337/v1`, `scripts/claude_client.py`) 호출을 강제하지 않으며, 워크스페이스 원본 스킬 경로(`.agents/skills/`)에서 **관련 스킬 1개를 기본으로 선택**하고 필요한 경우에만 추가 참조합니다.
> - 슬래시(`/`) 명령어는 현재 IDE에서 실제 지원되는지 확인되지 않으면 추천하지 않습니다.

---

## 1. 📋 상황별 참고 프롬프트 템플릿

### 🎨 [상황 1] UI/UX 리디자인 & 레이아웃 겹침(Overflow) 0%
- **기본 참조 가이드**: [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)
- **기본 선택 스킬 (1개)**: `.agents/skills/impeccable-design-audit/SKILL.md` (또는 `.agents/skills/frontend-design/SKILL.md`)

```markdown
[역할 및 목표]
`docs/OOMU_DESIGN_SYSTEM.md`를 유일한 디자인 수치 기준으로 삼아 대상 화면의 시각적 위계와 레이아웃 안정성을 개선해줘.

[대상 파일 경로]
- 예: `lib/screens/soso_car_home_screen.dart`, `lib/screens/soso_car_detail_screen.dart`

[핵심 체크리스트]
1. 컬러·타이포그래피·간격 단일 기준:
   - 모든 색상·폰트 크기·여백·보더·터치 타깃 수치는 `docs/OOMU_DESIGN_SYSTEM.md`를 참조할 것.
   - 구형 분홍 배경(`#FAF6F7`), 주황 강조(`#FF6B4A`, `#FFF4EB`, `#E85D04`)는 사용 금지 예시이므로 적용하지 말 것.
   - 비용 정보는 실제 데이터가 있을 때만 표시하고 임의의 `'1/N 안심 정산'` 배지를 강제하지 말 것.
2. UX 겹침(Overlap) 및 텍스트 깨짐(Overflow) 차단:
   - `Row` 내부의 가변 텍스트는 `Expanded` 또는 `Flexible`로 감싸 우측 배지나 아이콘과 겹치지 않게 할 것.
   - Flutter `TextStyle`에 존재하지 않는 `WordBreak.keepAll` 속성은 사용하지 말 것.
```

---

### ✍️ [상황 2] B2B 제휴(아지트) & 2030 소셜 UX Writing
- **기본 참조 가이드**: [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)
- **기본 선택 스킬 (1개)**: `.agents/skills/taste-anti-slop/SKILL.md`

```markdown
[역할 및 목표]
화면의 기계적인 문구("데이터가 없습니다", "입력하세요")를 걷어내고, 2030 로컬 커뮤니티 감성에 맞는 자연스러운 한국어 문구로 다듬어줘.

[문구 교정 가이드라인]
1. B2C 모임 탐색/참여 문구:
   - (X) "모임이 없습니다." -> (O) "아직 열린 모임이 없어요. 첫 번째 모임을 열어볼까요?"
2. B2B 아지트 큐레이션 문구:
   - 배너 광고 느낌 대신 `"✨ OOMU 공식 인증 아지트"` 등 자연스러운 큐레이션 문구로 표기.
```

---

### 🏗️ [상황 3] 풀스택(Flutter + Firebase + 인앱 AI) 아키텍처 및 상태 정합성
- **기본 선택 스킬 (1개)**: `.agents/skills/flutter-expert-performance/SKILL.md`

```markdown
[구현 요구사항]
1. 실제 파일 경로 준수:
   - 서비스 레이어(`lib/services/`), 공통 상태(`lib/utils/global_data.dart`), 실제 화면(`lib/screens/`) 경로를 기준으로 작업할 것 (존재하지 않는 `lib/features/...` 참조 금지).
2. 세션 및 상태 정합성:
   - 계정 전환·로그아웃·게스트 전환 시 이전 사용자별 상태가 남지 않도록 초기화하고 지연된 비동기 응답이 새 세션을 덮어쓰지 않게 방어할 것.
3. 보안 준수:
   - `.antigravity/rules/security_distribution_rules.md`에 따라 실제 외부 API Secret은 절대 코드에 하드코딩하지 말 것.
```

---

### 🔍 [상황 4] 화면 검증 및 정적 분석
- **기본 선택 스킬 (1개)**: `.agents/skills/playwright-e2e-testing/SKILL.md`

```markdown
[검증 절차]
1. 관련 단위/위젯 테스트(`flutter test`) 및 정적 분석(`flutter analyze`)을 실행해 오류·경고·정보 메시지 및 종료 코드를 확인한다.
2. UI 표시가 변경된 경우 로컬 환경에서 실제 화면을 확인하고, 웹 검증 결과를 Android 실기기 검증으로 과장하지 않는다.
```
