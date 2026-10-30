---
name: emil-motion-design
description: Emil Kowalski(Linear, Sonner) 철학 기반 마이크로 인터랙션 및 모션 디자인 스킬. scale(0) 금지, ease-in 금지, 스프링 물리(Spring Physics), 햅틱 피드백(HapticFeedback), 60~120fps GPU 렌더링 최적화를 적용합니다.
license: MIT
---

# ⚡ Emil Kowalski 마이크로 인터랙션 & 모션 디자인 가이드 (Flutter / Mobile)

본 스킬은 Vercel, Linear 출신의 최고급 디자인 엔지니어 **Emil Kowalski(animations.dev, Sonner)**의 모션 디자인 철학과 물리 기반 인터랙션 원칙을 Flutter 및 모바일 앱 환경에 이식한 표준 가이드입니다.

---

## 🚫 1. 절대 금지 규칙 (The Hard "No-Slop" Rules)

### 1) 진입 시 `scale(0)` 절대 금지
- **이유**: 현실 세계의 물체는 무(0)에서 뿅 하고 나타나지 않습니다. `scale(0)`은 부자연스럽고 인위적인 'AI 슬롭' 티가 납니다.
- **표준**: 진입 애니메이션은 **`scale(0.95)` 또는 `scale(0.92)`에서 시작하여 페이드인(`opacity: 0 -> 1`)**과 함께 자연스럽게 안착해야 합니다.

```dart
// ❌ BAD: scale(0)으로 튀어나오는 어색한 애니메이션
Transform.scale(scale: animation.value, child: child); // 0.0 -> 1.0

// ✅ GOOD: 0.95에서 부드럽게 커지며 페이드인
Opacity(
  opacity: opacityAnimation.value, // 0.0 -> 1.0
  child: Transform.scale(
    scale: 0.95 + (0.05 * scaleAnimation.value), // 0.95 -> 1.0
    child: child,
  ),
);
```

### 2) UI 애니메이션에 `ease-in` 사용 금지
- **이유**: `ease-in`은 시작이 느려 유저의 터치에 기기가 굼뜨게 반응하는(Laggy) 느낌을 줍니다.
- **표준**: 진입이나 전환은 반드시 **즉시 반응하고 끝에서 부드럽게 감속하는 커브(Fast-out, Slow-in 또는 Spring)**를 사용합니다.
  - Flutter 표준: `Curves.easeOutCubic`, `Curves.fastOutSlowIn`
  - 물리 스프링: `SpringSimulation(SpringDescription(mass: 1, stiffness: 180, damping: 20), ...)`

### 3) 묻지마 전체 페이드인(All Fade-in) 금지
- 화면이 열릴 때 모든 텍스트, 카드, 헤더가 0.5초 동안 서서히 나타나는 불필요한 페이드인은 유저를 기다리게 만드는 고질적 안티패턴입니다.
- **원칙**: 정적 콘텐츠는 즉시 표시하고, **유저의 행동(탭, 드래그, 스와이프, 모달 오픈)이 일어나는 인터랙션 요소에만 정밀하게 모션을 집중**합니다.

---

## 👆 2. 컴포넌트별 필수 손맛 (Micro-Interactions)

### 1) 탭 가능한 모든 버튼: 즉각적인 스케일 다운 (`scale: 0.97`)
버튼을 손가락으로 누르는 순간(Down) 시각적으로 0.97배 살짝 눌리며 미세 진동이 울려야 합니다.

```dart
class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BouncyButton({super.key, required this.child, required this.onTap});

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
```

### 2) 햅틱 피드백(Haptic Feedback) 표준 매트릭스
촉각은 모바일 앱의 퀄리티를 결정짓는 핵심 감각입니다.
- **카테고리 탭 / 칩 선택 / 토글**: `HapticFeedback.selectionClick()`
- **버튼 탭 / 모임 찜하기 / 하트**: `HapticFeedback.lightImpact()`
- **참여 신청 완료 / 결제 성공 / 안심 귀가 타이머 시작**: `HapticFeedback.mediumImpact()`
- **경고 / 차단 / 신고 / 네트워크 에러**: `HapticFeedback.heavyImpact()`

---

## 🚀 3. 120fps 무지연 렌더링 규칙 (GPU-Accelerated)

1. **위젯 재계산(Rebuild)을 유발하는 `width`, `height`, `padding` 애니메이션 금지**:
   - 레이아웃 트리를 다시 계산(Relayout)하게 만들어 저사양 안드로이드 기기에서 프레임 드랍(Jank)이 발생합니다.
2. **반드시 GPU 변환 속성만 사용**:
   - `Transform.translate` (위치 이동)
   - `Transform.scale` (크기 변화)
   - `Opacity` (투명도 변화)
3. **무거운 하위 트리는 `RepaintBoundary`로 격리**:
   - 애니메이션이 발생하는 위젯 영역만 GPU 텍스처로 격리하여 주변 UI의 불필요한 Repaint를 0%로 차단합니다.
