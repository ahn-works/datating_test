---
name: flutter-expert-performance
description: AAS(Agentic Awesome Skills)의 Flutter Expert 아키텍처 기반 성능 최적화 스킬. Dart 3 패턴, Impeller 120fps 렌더링, 불필요한 위젯 Rebuild 방지, 메모리 누수 원천 차단을 보장합니다.
license: MIT
---

# 🚀 Flutter Expert: Impeller 120fps & 아키텍처 최적화 가이드

본 스킬은 **`sickn33/agentic-awesome-skills`**의 `flutter-expert` 플레이북에 기반하여, Flutter 앱이 안드로이드 및 웹 전 기종에서 지연 시간 0ms, 초당 120프레임(120fps)의 부드러움을 유지하고 메모리 누수를 원천 차단하도록 돕는 엔지니어링 표준입니다.

---

## ⚡ 1. 120fps Impeller 렌더링 & Rebuild 최적화

1. **`const` 생성자 100% 엄수**:
   - 정적 위젯 트리는 반드시 `const`로 선언하여 부모 위젯이 리빌드될 때 가비지 컬렉터(GC) 부하와 렌더 트리 재연산을 0으로 줄입니다.
2. **`setState` 범위의 극소화**:
   - 화면 전체를 `setState()`로 감싸지 않고, 값이 바뀌는 버튼이나 입력창만 `ValueListenableBuilder` 또는 하위 `StatefulWidget`으로 격리합니다.
3. **무거운 리스트의 지연 로딩 (`ListView.builder`)**:
   - `SingleChildScrollView + Column` 대신 항상 화면에 보이는 아이템만 인스턴스화하는 `ListView.builder` 또는 `CustomScrollView + SliverList`를 사용합니다.

```dart
// ❌ BAD: 리스트 전체를 한 번에 메모리에 올리는 비효율적 구조
SingleChildScrollView(
  child: Column(children: meetups.map((m) => MeetupCard(m)).toList()),
);

// ✅ GOOD: 화면에 보이는 아이템만 빌드하고 메모리 재활용
ListView.builder(
  itemCount: meetups.length,
  itemBuilder: (context, index) => RepaintBoundary(
    child: MeetupCard(meetups[index]),
  ),
);
```

---

## 🛡️ 2. 메모리 누수(Memory Leak) 원천 차단 규칙

컨트롤러, 타이머, 스트림을 사용할 때는 반드시 생명주기 종료 시 자원을 해제해야 합니다:

```dart
@override
void dispose() {
  _textController.dispose();
  _scrollController.dispose();
  _animationController.dispose();
  _streamSubscription?.cancel();
  super.dispose();
}
```

---

## 📱 3. 엄지손가락 조작 영역 (Thumb-Zone) 인체공학

- 유저의 한 손 조작성을 위해, 핵심 액션 버튼(신청하기, 글쓰기, 채팅 시작)은 **화면 하단 1/3 영역(바텀 시트, 하단 고정 플로팅 바)**에 배치합니다.
- 상단 영역은 정보 확인(앱바, 헤더 타이틀, 대표 이미지) 전용으로 활용합니다.

