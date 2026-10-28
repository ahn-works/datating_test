# 📋 OOMU 08단계 공개 소스 기반 통합 보완 및 실제 실행 검증 결과 보고서 (`docs/UI_POLISH_08_RESULT.md`)

- **작성일**: 2026-10-28
- **기준 리비전**: `c20a202b2ece7c1da9a5dfd47afd5cb165cde801` (07단계 및 4개 화면 마감 변경 보존 상태)
- **단일 디자인 기준**: [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)

---

## 0. 현재 코드 적용 확인 / 실행 검증 여부 / 남은 작업 체크표

| 구분 | 항목 | 코드 적용 확인 | 실행 검증 여부 | 비고 / 남은 작업 |
| :--- | :--- | :---: | :---: | :--- |
| **0. 백업·도구** | 외부 사전 백업(`before_08`) 생성·해시 대조 및 Flutter SDK(`3.47.8`) 준비 | 완료 | **검증 완료** (`testzip()` OK, `hash_mismatch: 0`) | 기존 `before_polish` 백업 함께 보존 |
| **1. 지침 통합** | `docs/OOMU_UI_GUIDE.md` 단일 기준화 및 스킬/규칙 문서 충돌 해소 | 완료 | **검증 완료** (문서 교차 대조) | 안심정산 재도입 금지·유연 줄바꿈 명시 |
| **2. 이모지 보존** | 홈·상세·커뮤니티 제목의 UTF-16 `split('').join('\u2060')` 제거 및 `OomuUiHelpers.formatTitle` 적용 | 완료 | **검증 완료** (`flutter test` + 웹 렌더링 캡처) | 서로게이트 페어·ZWJ·국기 6종 깨짐 0건 |
| **3. 장소·지도·거리** | 미확인 장소의 가짜 홍대입구 좌표(`37.5562, 126.9235`) 및 가짜 `'도보 5분'` 폴백 제거 | 완료 | **검증 완료** (`flutter test` + 웹 렌더링 캡처) | 미확인 시 `'정확한 위치를 확인할 수 없어요'` / `'거리 확인 불가'` 표시 |
| **4. 매너온도 통일** | `manner` / `mannerTemp` (`num`·숫자 `String`·`null`) 단일 파서 및 미확인 `'정보 없음'` 표기 통일 | 완료 | **검증 완료** (`flutter test` + 웹 렌더링 캡처) | 홈·상세·커뮤니티·프로필 동일 값 노출 |
| **5. 댓글 상태 분리** | `_initialDummyComments` 자동 주입 및 `'post_01'` 폴백 제거, 게시글별 댓글·개수 독립화 | 완료 | **검증 완료** (`flutter test` + 웹 렌더링 캡처) | 댓글 0건 시 `'첫 댓글을 남겨보세요'` 노출 |
| **6. 테마·터치·색상** | `main.dart` 공통 테마 연결, 4개 화면 최소 `48×48dp` 터치 영역, `#FF5E36` 정리, 호스트 카드 실데이터화 | 완료 | **검증 완료** (`flutter test` `getSize` + 웹 렌더링) | 모든 주요 조작 위젯 `>= 48×48dp` 실측 통과 |
| **8. 정적·실행 검증** | `flutter analyze`, `flutter test` (33건), `flutter build web`, 360/390/430px 수정 전·후 캡처 | 완료 | **검증 완료** (웹 렌더링 및 위젯 테스트) | **Android 실기기/AVD 실행은 미검증** (Android SDK/AVD 미설치 및 C: 여유 공간 제약) |

---

## 1. 사전 외부 백업 및 무결성 검증 결과

1. **08단계 작업 직전 외부 백업**:
   - **파일 경로**: `C:\Users\DT4\Downloads\oomu_app_backups\oomu_app_before_08_20261028_135421.zip`
   - **용량 / 파일 수**: `235.91 MB` (`247,366,184 bytes`) / `32,535`개 파일
   - **SHA-256**: `66f091f907cf6ad81ca0e18dd888bdaa3b258da960c1832e4d88a275b80d803b`
   - **무결성 검증**: `zipfile.ZipFile.testzip()` 손상 `0건`(`OK`), 임시 폴더 압축 해제 후 핵심 수정 대상 파일 SHA-256 전수 대조 `hash_mismatch: 0`.
2. **기존 마감 백업 보존 확인**:
   - `C:\Users\DT4\Downloads\oomu_app_backups\oomu_app_before_polish_20261028_132950.zip` (`235.90 MB`, 무결성 유지)

---

## 2. 핵심 원인별 코드 수정 내역

### [1] UI 문서 및 스킬 지침 단일화
- **수정 파일**:
  - [`docs/OOMU_UI_GUIDE.md`](file:///c:/Users/DT4/Downloads/oomu_app/docs/OOMU_UI_GUIDE.md)
  - [`.agents/skills/frontend-design/SKILL.md`](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/frontend-design/SKILL.md)
  - [`.agents/skills/figma-mobile-tokens/SKILL.md`](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/figma-mobile-tokens/SKILL.md)
  - [`.agents/skills/karrot-hyperlocal-feed/SKILL.md`](file:///c:/Users/DT4/Downloads/oomu_app/.agents/skills/karrot-hyperlocal-feed/SKILL.md)
  - [`.antigravity/rules/ui_ux_design_rules.md`](file:///c:/Users/DT4/Downloads/oomu_app/.antigravity/rules/ui_ux_design_rules.md)
- **내용**:
  - 브랜드 강조색 `#F25767` 및 중립 배경 `#FAF6F7` 단일화(옛 주황 `#FF5E36`/`#FF6B4A` 폐기).
  - Flutter에 존재하지 않는 `wordBreak: WordBreak.keepAll` 및 서로게이트 페어를 깨뜨리는 `split('').join('\u2060')` 금지 명시.
  - 사용자 요청으로 제거된 `'1/N 안심 정산'` 배지 및 커뮤니티 상세 `'모임 개설'` 배너 재도입 금지 명시.

### [2] 제목 이모지 깨짐 원인 제거
- **원인**: Dart `String.split('')`는 UTF-16 code unit 단위로 문자열을 분해하므로 `🎲`, `🥯`, `🏃‍♀️`, `👩🏽‍🤝‍👩🏻`, `👨‍👩‍👧‍👦`, `🇰🇷` 등의 서로게이트 페어 및 ZWJ 시퀀스 사이에 `\u2060`이 삽입되어 `` 형태로 깨짐.
- **수정 파일**:
  - [`lib/utils/oomu_ui_helpers.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart) (`OomuUiHelpers.formatTitle`)
  - [`lib/screens/soso_car_home_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_home_screen.dart)
  - [`lib/screens/soso_car_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_detail_screen.dart)
  - [`lib/screens/community_post_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_detail_screen.dart)
- **결과**: 기존 `\u2060` 오염 문자를 제거하고 서로게이트 페어·ZWJ·국기 시퀀스를 원형 그대로 보존.

### [3] 장소·지도·거리 불일치 수정
- **원인**:
  - `soso_car_detail_screen.dart`에서 초기 좌표를 홍대입구역(`37.5562, 126.9235`)으로 하드코딩하고, 키워드 검색 실패 시에도 홍대 지도를 그대로 표시함.
  - `kakao_map_service.dart`에서 위치 권한/좌표 확인 실패 시 `'내 위치에서 도보 5분 (약 350m)'`라는 가짜 문구를 반환함.
- **수정 파일**:
  - [`lib/services/kakao_map_service.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/services/kakao_map_service.dart) (`resolveVerifiedPlace`, `getDistanceTextFromCurrent`)
  - [`lib/screens/soso_car_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_detail_screen.dart)
  - [`lib/screens/soso_car_host_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_host_screen.dart)
  - [`lib/widgets/kakao_map_view_stub.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/widgets/kakao_map_view_stub.dart)
- **결과**:
  - 모임 생성 시 선택된 실제 좌표(`lat`, `lng`)를 함께 저장하고, 상세 화면에서 유효 좌표를 최우선 사용.
  - 좌표 미확인 장소는 가짜 홍대 지도를 숨기고 `'정확한 위치를 확인할 수 없어요'` 안내 카드와 `'거리 확인 불가'`를 표시.

### [4] 호스트 매너온도 단일화
- **수정 파일**:
  - [`lib/utils/oomu_ui_helpers.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/utils/oomu_ui_helpers.dart) (`parseMannerTemp`, `formatMannerTemp`)
  - [`lib/screens/soso_car_home_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_home_screen.dart)
  - [`lib/screens/soso_car_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_detail_screen.dart)
  - [`lib/screens/community_post_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_detail_screen.dart)
  - [`lib/screens/user_profile_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/user_profile_screen.dart)
- **결과**: `manner`와 `mannerTemp`(`num`, 숫자 `String`, `null`)를 동일하게 파싱하며, 값이 없을 때 임의의 `36.5°C`/`38.5°C`/`41.2°C`로 덮어쓰지 않고 `'정보 없음'` / `'매너온도 정보 없음'`으로 일관되게 표시.

### [5] 커뮤니티 댓글 내용·개수·저장 상태 분리
- **원인**: `community_post_detail_screen.dart`에서 모든 게시글의 초기 댓글을 동일한 `_initialDummyComments`로 채우고, Firestore에 댓글이 없을 때 자동으로 더미 댓글을 업로드했으며, `id`가 없을 때 `'post_01'`로 폴백하여 서로 다른 게시글이 같은 댓글을 공유함.
- **수정 파일**:
  - [`lib/screens/community_post_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_detail_screen.dart)
  - [`lib/screens/soso_car_home_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_home_screen.dart)
- **결과**:
  - `_initialDummyComments` 및 자동 업로드 로직, `'post_01'` 폴백을 완전 제거.
  - 각 게시글은 자신의 `commentList` 또는 고유 `post['id']` 하위 컬렉션만 읽으며, 댓글이 없으면 `'첫 댓글을 남겨보세요'` 빈 상태를 노출.
  - 상단 인터랙션 바(`댓글 N`), 댓글 섹션 헤더(`댓글 N`), 실제 댓글 리스트 개수, 커뮤니티 목록 카드 댓글 수를 단일 상태로 동기화.

### [6] 공통 테마 연결·터치 영역 48dp 보장·호스트 카드 실데이터화
- **수정 파일**:
  - [`lib/main.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/main.dart) (`theme: OomuUiHelpers.buildTheme()`, 인증/초기화 코드 미변경)
  - [`lib/screens/soso_car_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_detail_screen.dart)
  - [`lib/screens/soso_car_home_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/soso_car_home_screen.dart)
  - [`lib/screens/my_page_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/my_page_screen.dart)
  - [`lib/screens/community_post_detail_screen.dart`](file:///c:/Users/DT4/Downloads/oomu_app/lib/screens/community_post_detail_screen.dart)
- **결과**:
  - 홈 블럭/목록 토글(`minWidth: 52, minHeight: 48`), 서브태그 칩/더보기(`minWidth: 48, minHeight: 48`), MY 내 프로필 보기/프로필 수정(`minimumSize: Size.fromHeight(48)`), MY 성향 수정 버튼(`minWidth: 48, minHeight: 48`), 커뮤니티 게시글 좋아요/댓글 좋아요/전송 버튼(`48×48dp`), 상세 길찾기/프로필 보기/찜/참여 신청 버튼(`>= 48dp`) 모두 최소 `48×48dp` 터치 타깃 충족.
  - 홈·상세·MY·커뮤니티 4개 활성 화면의 장식성 레거시 주황(`#FF5E36`)을 브랜드 로즈 코랄(`#F25767`) 및 웜 서피스로 정리.
  - 상세 호스트 카드에서 `isHostVerified`가 확인된 경우에만 `'PASS 본인인증 호스트'`를 표시하고, `praiseTags`/`hostTags`가 비어 있으면 하드코딩 칭찬 태그를 숨김.

---

## 3. 정적 분석 및 단위·위젯 테스트 실행 결과

1. **정적 분석 (`flutter analyze`)**:
   - 실행 명령: `C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat analyze --no-fatal-infos --no-fatal-warnings`
   - 결과: **Exit code 0** (컴파일 에러·타입 오류 0건, 수정 파일 내 경고 0건)
2. **전체 테스트 스위트 (`flutter test`)**:
   - 실행 명령: `C:\Users\DT4\Downloads\oomu_dev_tools\flutter\bin\flutter.bat test`
   - 결과: **총 33개 테스트 전수 통과 (`00:07 +33: All tests passed!`)**
   - 신규 검증 스위트 ([`test/oomu_08_verification_test.dart`](file:///c:/Users/DT4/Downloads/oomu_app/test/oomu_08_verification_test.dart)):
     - `[2]` 6종 복합 이모지(`'카탄 한판 🎲'`, `'커피 ☕🥯'`, `'한강 러닝 🏃‍♀️'`, `'함께해요 👩🏽‍🤝‍👩🏻'`, `'가족 👨‍👩‍👧‍👦'`, `'대한민국 🇰🇷'`) 보존 및 렌더링 검증 통과
     - `[3]` 검증된 장소 좌표 반환 및 미확인 장소 `'정확한 위치를 확인할 수 없어요'` / `'거리 확인 불가'` 표시 검증 통과
     - `[4]` `manner`/`mannerTemp`(`num`, `String`, `null`) 파싱 및 상세·프로필 매너온도 일치 검증 통과
     - `[5]` 서로 다른 게시글 A/B 댓글 격리, 빈 댓글 안내, 댓글 작성 시 카운트 동기화 검증 통과
     - `[6]` MY 내 프로필 보기(`UserProfileScreen`) vs 프로필 수정(`ProfileEditScreen`) 분리 및 4개 화면 주요 조작 버튼 `>= 48×48dp` 크기 실측 통과
     - `[8]` `360×800`, `390×844`, `430×932` 화면 크기 × 글자 확대 `1.0`, `1.3`, `2.0` 조합에서 4개 화면 `RenderFlex overflow` **0건** 검증 통과

---

## 4. 실제 렌더링 화면 수정 전(`before_08`) · 수정 후(`after_08`) 캡처 비교

> **촬영 환경**: 로컬 Flutter Web 빌드(`CanvasKit` + Chrome Headless CDP + SwiftShader WebGL), 동일한 시드 데이터 및 뷰포트(`360×800`, `390×844`, `430×932`, `deviceScaleFactor: 2`).
> **저장 경로**: `C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861\screenshots_08\`

| 화면 구분 | 해상도 | 수정 전 (`before_08`) | 수정 후 (`after_08`) | 주요 시각적 변화 확인 |
| :--- | :---: | :--- | :--- | :--- |
| **1. 모임 상세 (검증된 장소)** | `360×800`<br>`390×844`<br>`430×932` | `before_08_detail_360x800.png`<br>`before_08_detail_390x844.png`<br>`before_08_detail_430x932.png` | `after_08_detail_360x800.png`<br>`after_08_detail_390x844.png`<br>`after_08_detail_430x932.png` | 제목의 `🎲`, `☕🥯`, `🏃‍♀️` 이모지가 `` 깨짐 없이 정상 표시되고, 하드코딩 칭찬 태그가 제거되어 호스트 카드가 깔끔하게 정돈됨 |
| **2. 모임 상세 (미확인 장소)** | `390×844` | `before_08_detail_unknown_390x844.png` | `after_08_detail_unknown_390x844.png` | 복합 ZWJ·국기 이모지(`👩🏽‍🤝‍👩🏻`, `👨‍👩‍👧‍👦`, `🇰🇷`) 정상 표시, 가짜 홍대 지도 대신 위치 미확인 안내 카드와 `'거리 확인 불가'` 표시 |
| **3. 홈 화면** | `360×800`<br>`390×844`<br>`430×932` | `before_08_home_360x800.png`<br>`before_08_home_390x844.png`<br>`before_08_home_430x932.png` | `after_08_home_360x800.png`<br>`after_08_home_390x844.png`<br>`after_08_home_430x932.png` | 카드 제목의 `🔥`, `☕📚` 이모지 복구, 블럭/목록 토글 48dp 터치 영역 확보, 레거시 주황 제거 및 코랄 톤 통일 |
| **4. MY 화면** | `360×800`<br>`390×844`<br>`430×932` | `before_08_my_360x800.png`<br>`before_08_my_390x844.png`<br>`before_08_my_430x932.png` | `after_08_my_360x800.png`<br>`after_08_my_390x844.png`<br>`after_08_my_430x932.png` | `내 프로필 보기`와 `프로필 수정` 버튼이 360px에서도 줄바꿈·잘림 없이 1:1 대칭(`48dp`)으로 정렬됨 |
| **5. 커뮤니티 상세 (게시글 A / B)** | `360×800`<br>`390×844`<br>`430×932` | `before_08_community_a_360x800.png`<br>`before_08_community_a_390x844.png`<br>`before_08_community_a_430x932.png`<br>`before_08_community_b_390x844.png` | `after_08_community_a_360x800.png`<br>`after_08_community_a_390x844.png`<br>`after_08_community_a_430x932.png`<br>`after_08_community_b_390x844.png` | 수정 전에는 새 게시글 A/B 모두에 가짜 댓글 2개(`댓글 2`)가 잘못 노출되고 제목 이모지가 깨졌으나, 수정 후 이모지가 정상 표시되고 `'댓글 0'` 및 `'첫 댓글을 남겨보세요'` 빈 상태가 정확히 표시됨 |

