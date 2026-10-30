---
name: impeccable-design-audit
description: Paul Bakaus(전 구글, jQuery UI)의 Impeccable 기반 디자인 어휘 및 P0~P3 휴리스틱 디자인 감사 스킬. 48×48dp 터치 타깃, 타이포그래피 계층, 카드 안의 카드 중첩 금지, 60+ 안티-슬롭 규칙을 강제합니다.
license: MIT
---

# 📐 Impeccable 디자인 어휘 & 휴리스틱 디자인 감사 가이드 (Mobile)

본 스킬은 **Paul Bakaus(구글 전 웹 크리에이터 총괄, jQuery UI 창시자)**의 `pbakaus/impeccable` 프로젝트에 기반하여, AI 코딩 에이전트가 뻔한 AI 슬롭(AI Slop)을 배제하고 프로덕션 수준의 시각 완성도와 모바일 인체공학을 갖추도록 강제하는 지침입니다.

---

## 🚫 1. 60+ 안티-슬롭(Anti-Slop) 탐지 규칙

AI가 모바일 화면을 구성할 때 무의식적으로 생성하는 아래 5대 결함을 원천 차단합니다:

1. **카드 안의 카드(Card-in-Card) 중첩 금지**:
   - 큰 카드 컨테이너 내부에 또 그림자나 보더가 있는 하위 카드를 2중, 3중으로 중첩하여 화면을 답답하게 만드는 행위를 금지합니다.
   - 정보 구분은 중첩 카드가 아닌 **섬세한 디바이더(`1px solid #EFF1F5`), 명도 차이(`bg-neutral` vs `bg-card`), 또는 여백(8dp/16dp)**으로 해결합니다.
2. **보라색-파란색 AI 기본 그라데이션 금지**:
   - 템플릿 느낌을 주는 보라색-파란색 네온 그라데이션 대신, **OOMU 단일 브랜드 컬러(`#F25767`) 및 파스텔 틴트(`#FFF4EB`, `#F1F5F9`)**를 정밀하게 사용합니다.
3. **8px 협소 패딩 금지**:
   - 컨테이너 내부 여백을 8px로 비좁게 설정하여 글자가 테두리에 닿는 현상을 배제합니다. 카드 내부 패딩은 최소 **16dp~20dp**를 유지합니다.
4. **기계적인 1줄 말줄임(Ellipsis) 금지**:
   - 긴 제목, 주소, 소개글을 무조건 1줄로 자르지 않고, **최대 2줄 허용(`maxLines: 2`) 또는 자연스러운 줄바꿈**을 기본으로 합니다.
5. **텍스트 저대비(Low Contrast) 방지**:
   - 연한 회색 배경 위에 연한 회색 텍스트(`#94A3B8`)를 얹어 눈이 피로한 디자인을 금지합니다. 본문은 최소 WCAG AA 기준(4.5:1 이상)인 `#334155` 또는 `#0F172A`를 준수합니다.

---

## 📱 2. 모바일 인체공학 터치 타깃 (48×48dp)

엄지손가락으로 조작하는 모바일 화면의 모든 터치 요소는 최소 48×48dp의 유효 터치 영역을 확보해야 합니다.

```dart
// ❌ BAD: 시각적 크기가 작아 터치 실패율이 높은 아이콘 버튼
GestureDetector(
  onTap: () {},
  child: Icon(Icons.close, size: 16),
);

// ✅ GOOD: 시각 크기는 작더라도 유효 터치 타깃 48x48dp 보장
IconButton(
  iconSize: 20,
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
  padding: const EdgeInsets.all(12),
  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
  onPressed: () {},
);
```

---

## 🔍 3. P0 ~ P3 디자인 감사(Critique) 프레임워크

코드를 작성하거나 수정한 뒤 에이전트는 스스로 아래 4단계 감사를 수행합니다:

- **P0 (치명적 배포 불가 / Blocking)**:
  - 텍스트 오버플로우(`RenderFlex overflowed by N pixels`) 발생 여부
  - 터치 타깃이 겹치거나 화면 밖으로 잘려서 클릭이 불가능한 경우
- **P1 (심각한 UX 결함 / Severe)**:
  - 키보드가 올라왔을 때 하단 입력창이 가려지는 현상 (`resizeToAvoidBottomInset`)
  - 텍스트 대비가 낮아 야외에서 글자가 보이지 않는 경우
- **P2 (시각적 통일성 / Visual Consistency)**:
  - 8dp 여백 시스템(8, 16, 24, 32dp)을 벗어난 임의의 여백(11px, 17px 등) 사용 여부
  - 폰트 굵기(Weight)와 크기(Scale)가 디자인 시스템 토큰과 불일치하는 경우
- **P3 (미세 디테일 / Polish)**:
  - 탭 시 햅틱 피드백 누락 여부
  - 비어있는 상태(Empty State)의 카피라이팅이 사용자 친화적인지 여부
