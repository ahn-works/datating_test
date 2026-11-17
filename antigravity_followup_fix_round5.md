# [안티그래비티 5차 지시서 — OOMU 2026-11-17 fc2dfeb9 배포 복구 + 4차 잔여]

대상 저장소: `ahn-works/datating_test`, **main `fc2dfeb9`** (2026-11-17 08:55 KST 보고분)
검수 근거: `reports/oomu-recheck-fc2dfeb9-2026-11-17.md` (코드 file:line 대조 + CI 로그 + 실DB 무인증 GET + 라이브 번들 대조, 저장소 쓰기 0건)
판정: 완료 5 · 부분 3 · 미실행 9 · 신규 결함 4

> **이미 완료된 것 — 다시 건드리지 마세요 (회귀 금지)**
> 1차 `firestore_time.dart`·`meetup_member_helper.dart`·탭 스켈레톤 / 지도(`web/kakao_map.html` IIFE·Leaflet·`ensureKeysLoaded`) / 게스트 4화면 SSOT / `app_image.dart` Base64·R2 `covers/` / `37c7bf9` P0(테스트 계정·디버그 URL·`482915`·`oomu_phone_pw_`·네이버 clientSecret) / `fbbc97a` 안드로이드 CI / `f2150d0` 프로필 고정 답변 제거 / `fc2dfeb9`의 온보딩 탈출(`profile_setup_screen.dart:484-488`+`main.dart:254·268`)·`profile_options.dart` 목록 SSOT·2열 키-값 행·마이페이지 카드·규칙 권한 3건(`firestore.rules:287-289·307-309·314`) — 이 커밋들의 동작은 유지한 채 그 위에만 수정하세요.

---

## ■ 0단계 [즉시·배포 복구] — 지금 라이브는 `84f3dc40`입니다

**원인(확정)**: 이번 커밋이 `deploy.yml:24-25`에 추가한 `run: flutter analyze`가 `296 issues found`로 exit 1. 296건은 **전부 `info`**(warning 0·error 0)이고, `flutter analyze`는 info도 기본 fatal이라 배포가 멈췄습니다. 그 결과 `deploy.yml` 6~12단계(`flutter test`·web 생성·카카오 주입·build·Deploy to GitHub Pages)가 전부 skipped → gh-pages HEAD는 `b50001e ("deploy: 84f3dc40b57…")` 그대로. 같은 커밋의 `Flutter Android Build` 43983361674는 **success**이므로 컴파일 문제는 아닙니다.

1. `deploy.yml:25`을 `run: flutter analyze --no-fatal-infos`로 바꿔 게이트는 유지하고 info로 죽지 않게 하세요. (`--no-fatal-warnings`까지 걸지 말 것: warning은 계속 실패시켜야 합니다.)
2. lint 소음은 줄이되 **`package:flutter/material.dart` → `material_ui` 전면 마이그레이션은 이번 범위가 아닙니다**(90여 파일 import 교체는 회귀 위험). 필요하면 `analysis_options.yaml`의 `analyzer: errors: deprecated_member_use: ignore` 한 줄까지만.
3. 푸시 전 **로컬에서 `flutter test`를 반드시 먼저 실행**하세요. 이번에 추가된 `test/round4_priority_test.dart` 1번은 실제로 `OOMUHomeScreen`으로 이동하며, 이 테스트는 CI에서 **한 번도 실행된 적이 없습니다**(analyze가 먼저 죽어 test 단계가 skipped). 스켈레톤/셔머 애니메이션 때문에 `pumpAndSettle`이 타임아웃되면 `pump(Duration(...))`으로 바꾸세요.
4. 푸시 후 확인해 보고: 새 `Flutter Web Deploy` run ID **success**, `Deploy to GitHub Pages` 단계 실행, gh-pages HEAD가 새 커밋을 가리킴(`deploy: <sha>` 커밋 메시지), `https://ahn-works.github.io/datating_test/` 200.

## ■ 1단계 [보안] 규칙 게시 **전에** 끝내야 하는 것 (게시는 심향 님이 직접)

지금 실DB는 규칙이 콘솔에 게시되지 않아 **무인증 읽기·쓰기 전면 개방**입니다(실측: `config/api_keys`·`config/r2_storage`(secretAccessKey 평문)·`users` 목록·`users/{uid}/private/contact` 모두 200, 무인증 POST도 200). 규칙을 먼저 게시하면 SMS·카카오·크롤러가 동시에 멈추므로 아래가 선행 조건입니다.

1. **루트 `users` 문서에서 PII 제거**(복사만 해두고 원본이 남아 있음). 신규/수정 저장 경로는 `private/contact`로 이전하고, 기존 40여 건 이관용 스크립트를 작성해 **`--dry-run` 결과만 보고하세요(실DB 일괄 실행은 심향 님 확인 후 진행, 문서 삭제 절대 금지)**.
   - `lib/services/auth_service.dart:289` `kakaoEmail` / `:512` `naverEmail` / `:516` `phoneNumber` / `:655`·`:733`·`:761`·`:983` `phone` / `:981` `birthDate` / `:988` `detailAddress`
   - `firestore.rules:132-155 isValidUserDoc`에 위 필드가 다시 들어오지 못하도록 `hasOnlyAllowedFields` 또는 명시 거부를 추가.
   - `users` `allow get, list: if true`(`firestore.rules:264`)는 유지하되, 남은 공개 필드가 정말 공개 가능한지 목록으로 보고(`address`는 공개 부적절 — `location`만 공개 권장).
2. **크롤러 Admin SDK를 실제로 되게**: 세 워크플로에 `pip install google-auth requests`를 추가하세요(현재 `boto3` 등만 설치 → `firestore_helper.py:40-61`이 ImportError로 무인증 폴백). 그리고 `FIREBASE_SERVICE_ACCOUNT_JSON`이 비어 있을 때는 **조용히 폴백하지 말고 exit 1**로 알리게 하세요.
3. **`app_config/*` 공급**(여전히 404: `kakao`·`sms_proxy`·`r2_public`): 문서를 실DB에 만들고 그 사실을 보고하거나, `flutter build web`에 `--dart-define`으로 주입. 둘 중 하나는 **실제 값으로** 되어야 SMS·카카오·네이버·R2가 살아납니다.
4. **`scripts/firestore.rules` 정리**: 루트 수정본과 내용이 다릅니다(권한 보강 3건이 빠진 구버전). 삭제하거나 루트로 심볼릭/동기화해서 게시 사고를 막으세요.
5. `daily_security_audit.yml`의 룰 검사 정규식은 `allow read, write: if true` **인접 패턴만** 잡습니다. `allow (get|list|read|write|create|update|delete)\s*:\s*if\s+true` 형태와 `allow get, list: if true`도 검출되게 보강하세요.

## ■ 2단계 [이번 커밋 잔여 정리 — 작은 것]

1. `lib/constants/profile_options.dart`의 라벨 상수 `drinkingLabel`·`smokingLabel`·`petLabel`·`personalityLabel`·`mbtiLabel`·`ageLabel`·`genderLabel`·`hobbiesLabel`이 **정의만 있고 사용처 0**입니다. 4화면 라벨을 이 상수로 실제 치환하거나, 안 쓸 상수는 삭제하세요(둘 중 하나로 끝낼 것).
2. `main.dart:85-101` `?preview=true`가 `우리동네_초연`·29세·IT 기획자 등 **가짜 프로필을 코드에 다시 넣었습니다**. 개발 게이트 안이라도 이전 회차의 "가짜 기본값 제거" 원칙과 충돌하니, 테스트 픽스처(`test/`)로 옮기고 dev 라우트에서는 빈 값 + `미설정` 렌더로 바꾸세요.

## ■ 3단계 [4차 잔여 — 전부 미이행 확인됨]

1. **딥링크가 여전히 빈 껍데기**: `?detail=true&id=<id>`는 `OOMUDetailScreen(meetup: {'id': docId})`로 가는데 `lib/screens/oomu_detail_screen.dart`에 Firestore 호출이 **0회**입니다(제목 폴백 `'취향 모임'`, `:50`). id만 받으면 `collection('meetups').doc(id).get()` 1회 후 렌더, 없으면 '모임을 찾을 수 없어요'. `?comm_detail=true&id=`도 같습니다(`community_post_detail_screen.dart:59-87`이 `widget.post`만 사용, 문서 조회 없음).
2. **고객센터 4행 `onTap` 없음**: `my_page_sub_screens.dart:5-26 SimpleListScreen`의 `ListTile`에 `onTap`이 없어 `:436-441`의 FAQ·1:1 문의·이용약관·개인정보 처리방침이 죽어 있습니다. 각각 연결하고, 개인정보 처리방침 본문에 제3자 제공·위탁·이용자 권리·문의처를 넣으세요.
3. **차단 UID 배선 미완**: `blockUid()` 호출이 **0곳**입니다. UI의 `blockUser(닉네임)` 호출을 `blockUid(uid)`로 바꾸고(`user_profile_screen.dart:360`, `oomu_chat_room_screen.dart:379`, `ugc_action_sheets.dart:338`), `blockedUsers`(닉네임) 목록에 uid를 섞어 넣던 `:360`의 버킷 혼동을 정리하세요. 필터는 이미 있는 `isTargetBlocked`(`oomu_home_screen.dart:1885`, `community_post_detail_screen.dart:457·468`, `home_community_section.dart:139`, `oomu_chat_room_screen.dart:672`)를 댓글·모임 목록·상세·MY까지 확대 적용.
4. **발견 탭 하드코딩 제거**: `oomu_discovery_lifestyle_hub.dart:256`(청년월세 240만), `discovery_api_service.dart:525-562`(가짜 박스오피스 5건), 날씨 기본값 `tempC=17.5`·`pm10=68`(`:235-237`) — 실소스가 없으면 **섹션을 숨기고** "날씨 정보를 불러올 수 없어요"를 표시. 숫자를 그럴듯하게 채우지 마세요.
5. **인원·마감 표기**: `home_lightning_section.dart:243-245`의 `'${spot['members'] ?? '2/4'} 참여'` 고정 폴백 제거 + `formatMembersLabel`, `home_meetup_section.dart:225-232` `statusBadge`에 `MeetupMemberHelper.formatStatusLabel`(마감) 연결(지금은 상세·MY 여행만 사용).
6. **`OomuInsets` 실제 적용**: `oomu_tokens.dart:154-163`이 사용처 0곳입니다. 커뮤니티·발견 목록 마지막 카드의 탭바 가림, 홈·찜한 모임의 FAB가 인원 표기를 덮는 문제를 `listBottomWithTabs`/`listBottomWithCta`로 해결.
7. **디자인 토큰은 기준선을 올리지 말고 실제로 줄이세요**: 현재 `--compare`는 `113색/480 · 20폰트/430 · 15모서리/228`에 +0으로 통과합니다(기준선을 현실에 맞춰 올려둔 상태). 화면에서 `Color(0x…)` 직접 지정·`fontSize:` 숫자·`BorderRadius.circular(숫자)`를 0건으로 만들고, 모서리는 `r8/r12/r16/r24/pill` 5단계만. 마친 뒤 `--save`로 기준선을 **내려서** 갱신하고 `--compare`를 CI 게이트로 연결.

## ■ 4단계 [검증·보고 형식 — 이번 회차부터 엄격 적용]

- **로컬 dev-route 스크린샷은 실측으로 인정하지 않습니다.** `scripts/capture_round4_proofs.py`는 `localhost:8092`의 `?setup/?preview/?my` 화면 4장을 `C:\Users\DT4\…`에 저장했을 뿐이고, 저장소에 증빙이 없으며 로그인·실DB·라이브를 하나도 검증하지 않았습니다.
- 보고에 반드시 포함: ①수정 파일:라인 ②커밋 SHA ③**CI run ID와 링크**(analyze·test·deploy 로그) ④**라이브**(`https://ahn-works.github.io/datating_test/`)에서 **로그인 사용자 동선**으로 찍은 스크린샷 — (a) 프로필 등록 건너뛰기 후 홈 진입 (b) 상세 2열 키-값 행 (c) MY 기본정보 카드 (d) 딥링크로 실모임·실게시글 표시 (e) 고객센터 4개 링크 (f) 홈 마감 배지 (g) 탭바·FAB 비겹침 (h) `flutter analyze` 최종 수치.
- **하지 않은 것과 이유를 따로 적으세요.** 미실행을 완료로 쓰지 말 것. 게시·시크릿 재발급은 심향 님이 직접 하십니다.

---

### 참고: 이번 검수에서 확인한 실측값 (그대로 인용 가능)
- `deploy.yml:24-25`, analyze 로그 `296 issues found. (ran in 6.6s)` / `##[error]Process completed with exit code 1.` (run 43983361568, Flutter stable-3.50.0)
- gh-pages HEAD `b50001e` = `deploy: 84f3dc40b57204a3d6ac090360a137ba87dce34f`
- 라이브 `main.dart.js` 4,234,640B: `기본 정보 & 라이프스타일` 0건 / `프로필 등록을 건너뛰시겠어요?` 1건
- 무인증 GET 200: `config/api_keys`, `config/r2_storage`, `users?pageSize=1`, `users/{uid}/private/contact` / 404: `app_config/kakao`·`sms_proxy`·`r2_public`·`slack`
- `check_design_tokens.py --compare`: color 113→113, font 20→20, radius 15→15 (+0)
