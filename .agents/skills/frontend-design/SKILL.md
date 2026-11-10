---
name: frontend-design
description: OOMU (우무 / Spot10) 전용 모바일 UI/UX 프론트엔드 디자인 지침. 모든 디자인 수치는 docs/OOMU_DESIGN_SYSTEM.md 단일 기준을 따르며, 2030 자연스러운 로컬 모임 및 여성 안심 커뮤니티 UI를 설계할 때 사용합니다.
---

# OOMU (우무 / Spot10) 프론트엔드 디자인 가이드

> **단일 디자인 기준 (Single Source of Truth)**:
> 모든 색상, 타이포그래피, 간격(Spacing), 카드 반경, 최소 터치 영역 수치는 본 파일에 중복 복사하지 않고 유일한 기준 문서인 **[`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)** 및 [`lib/utils/oomu_ui_helpers.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart)를 따릅니다.

---

## 🏆 0. 레퍼런스 및 핵심 설계 방향

1. **Mobbin (모빈 - mobbin.com)**:
   - 지도 위 바텀시트 오버레이 탐색(Sheet-over-Map), 불필요한 입력을 줄인 미니멀 폼 디자인.
2. **토스 디자인 시스템 (TDS)**:
   - 유저가 멈칫하거나 헷갈리지 않는 한글 타이포그래피 위계와 여백 체계 (`docs/OOMU_DESIGN_SYSTEM.md` 참조).
   - 촉각 햅틱 피드백(`HapticFeedback`), 닫기 편한 바텀시트, 빈 화면(Empty State)에서의 명확한 행동 유도.
3. **에디토리얼 레이아웃 & 컬러 절제**:
   - 구형 분홍 배경(`#FAF6F7`)이나 주황 강조(`#FF6B4A`)는 **사용 금지 예시**입니다.
   - 중립 배경과 순백 카드 표면의 명도 분리 및 미세 보더 규격은 [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)의 `[1. 컬러 시스템]`을 따릅니다.

---

## 🎯 1. 화면 구현 핵심 체크리스트

### ① 상태값 대응 (4-State Coverage)
- 정상 데이터 상태뿐 아니라 **[1. 로딩 중]** ➡️ **[2. 데이터 없음 (Empty State)]** ➡️ **[3. 네트워크 오류/실패]** ➡️ **[4. 정상 데이터]** 흐름을 점검합니다.

### ② 마이크로 마감 및 줄바꿈 규칙
- 여백, 보더, 최소 터치 영역 수치는 [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md)의 `[3. 레이아웃 & 컴포넌트 규칙]`을 준수합니다.
- **한글 줄바꿈**: Flutter `TextStyle`에 존재하지 않는 `WordBreak.keepAll` 속성은 절대 사용하지 않으며, 제어문자(`\u2060`, `\u00A0`)를 원문 문자열에 삽입해 이모지를 깨뜨리지 않습니다.
- 레이아웃 겹침(`RenderFlex overflow`)이 발생하지 않도록 `Row` 내부 가변 텍스트에 `Expanded`/`Flexible`을 적용합니다.

### ③ 정보 배열 & 시각적 위계 정돈
- **메인 피드**: 주소·일시·참여 인원 등 핵심 메타 정보가 명확하게 읽히도록 정돈합니다.
- **금액 표기 원칙**: 실제 확인된 비용 데이터(`fee`/`cost`/`price`)가 있을 때만 표시하며, 임의의 `'무료 참여'`나 `'1/N 안심 정산'` 배지를 강제하지 않습니다 (`docs/OOMU_DESIGN_SYSTEM.md` 단일 기준).
- **실제 활성 화면 수정**: 존재하지 않는 `lib/features/...`가 아닌 `lib/screens/` 하위 실제 활성 화면을 수정합니다.

---

## 2. OOMU 브랜드 아이덴티티 원칙

### ① 2030 자연스러운 로컬 모임 & 자만추 무드
- 사람을 좌우로 넘겨 평가하는 스와이프 카드를 배제하고, 취향·동네·라이프스타일이 드러나는 스토리형 프로필과 소모임 카드를 구성합니다.

### ② 여성 안심 우선주의 (Women-First & Anti-Creep)
- 방장 승인제 그룹 모임 기반으로 설계하며, 여성 전용 필터, 1-Click 신고/차단 등 안전장치를 찾기 쉬운 위치에 배치합니다.

---

## 3. 디자인 토큰 참조 (`docs/OOMU_DESIGN_SYSTEM.md`)

- **컬러 시스템**: [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md) `[1. 컬러 시스템 (60-30-10 원칙)]` 참조
- **타이포그래피 위계**: [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md) `[2. 타이포그래피 위계]` 참조
- **레이아웃 & 컴포넌트 규칙**: [`docs/OOMU_DESIGN_SYSTEM.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_DESIGN_SYSTEM.md) `[3. 레이아웃 & 컴포넌트 규칙]` 참조

---

## 4. 배제해야 할 안티패턴 (사용 금지 예시)

1. **스와이프 데이팅앱 클리셰**: 좌우로 넘겨 사람을 버리는 Tinder식 스와이프 UI.
2. **핑크 범벅(`#FAF6F7`) 및 원색 남발**: 화면 전체를 분홍빛으로 칠하거나 한 화면에 파랑·초록·주황(`#FF6B4A`)·코랄 배지를 동시에 섞어 쓰는 구성.
3. **카드 안의 박스(Card-in-Card)**: 카드 내부에 또 두꺼운 회색 테두리 박스를 중첩해 세로 공간을 낭비하는 구성.
4. **선정적/가벼운 멘트**: 자극적인 카피나 확인되지 않은 허위 배지(`'1/N 안심 정산'` 일괄 강제 등).
