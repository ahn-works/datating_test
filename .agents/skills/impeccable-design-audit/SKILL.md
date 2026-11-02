---
name: impeccable-design-audit
description: Paul Bakaus(전 구글, jQuery UI)의 Impeccable 기반 디자인 어휘 및 P0~P3 휴리스틱 디자인 감사 스킬. 모든 디자인 수치는 docs/OOMU_UI_GUIDE.md 단일 기준을 따릅니다.
---

# Impeccable Design Audit & Polish Skill (OOMU Edition)

이 스킬은 화면의 시각적 결함(타이포그래피 구분 실패, 어색한 여백, 과도한 박스 중첩, 터치 타깃 미달)을 진단하고 교정하기 위한 **디자인 감사(Design Audit) 기준**입니다.

> **단일 디자인 수치 기준**:
> 모든 색상, 타이포그래피 크기·두께·줄간격, 카드 패딩·외곽선, 최소 터치 타깃 수치는 본 문서에 중복 복사하지 않고 유일한 기준 문서인 **[`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)**를 따릅니다.

---

## 1. P0~P3 디자인 감사 심각도 분류 (Audit Severity)

### 🚨 P0 (치명적 결함 — 즉시 수정)
- **Visual Overflow / Clipping**: `RenderFlex overflowed`, 텍스트/배지 잘림, 작은 화면(360px)이나 텍스트 확대(1.3x~2.0x) 시 레이아웃 붕괴.
- **Touch Target Violation**: 버튼, 아이콘, 탭, 좋아요/댓글 영역이 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 최소 터치 영역 기준에 미달하는 경우.
- **Emoji / UTF-16 Corruption**: 서로게이트 페어 이모지(🎲, 🏃‍♀️, 🇰🇷 등) 사이에 제어문자(`\u2060`)를 삽입해 깨진 문자(``)가 노출되는 현상.

### ⚠️ P1 (시각적 위계 붕괴 — 최우선 교정)
- **Title vs Body Indistinguishable (제목·본문 구분 불능)**:
  - 커뮤니티/피드에서 제목과 본문의 글자 크기·색상·간격 차이가 부족해 한 덩어리로 뭉쳐 보이는 현상. 구체적인 제목·본문·메타 수치는 [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md) `[2. 타이포그래피 위계]`를 따릅니다.
- **Card-in-Card Nesting (카드 안의 카드 중첩 금지)**:
  - 카드 컨테이너 내부에 또 보더/배경 박스를 여러 겹 중첩해 정보 밀도와 여백을 해치는 구조.

### 🔶 P2 (조형 및 리듬 결함)
- **Inconsistent Spacing**: 8dp 그리드(`docs/OOMU_UI_GUIDE.md` `[3. 레이아웃 & 컴포넌트 규칙]`)에서 벗어난 임의의 간격 혼용.
- **Color Over-saturation (사용 금지 예시)**: 구형 분홍 배경(`#FAF6F7`), 구형 주황 강조(`#FF6B4A`), 또는 한 화면에 3가지 이상의 원색 배지가 동시에 경쟁하는 현상.

### 🔹 P3 (마이크로 폴리싱)
- 아이콘 크기와 텍스트 베이스라인 정렬 불일치, 구분선(Divider) 과다 사용.

---

## 2. 감사 수행 절차 (`/audit` -> `/polish`)

1. [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)의 컬러·타이포그래피·레이아웃 수치를 기준으로 대상 화면을 점검합니다.
2. 위젯 트리의 P0~P2 위반 사항을 식별하여 교정합니다.
3. 교정 후 `flutter test` 및 `flutter analyze`로 회귀가 없는지 확인합니다.
