# [안티그래비티 4차 수정 지시서 — OOMU 2026-11-16 8e92584 재검수 후속]

대상 저장소: `ahn-works/datating_test`, **main `8e92584`** (2026-11-16 15:58 KST 라이브 배포 완료)
검수 근거: `reports/oomu-recheck-8e92584-2026-11-16.md` (라이브 실클릭 43장 + 실DB GET + 코드 대조, 저장소·DB 쓰기 0건)
판정 요약: 완료 13 · 부분 7 · 미실행 6 · 신규 결함 2 · 미검증 1

> **이미 완료된 것 — 다시 건드리지 마세요 (회귀 금지)**
> Step 0 `app_image.dart`(Base64·covers 정확일치·R2 해소) / 테스트 계정·`482915`·`oomu_phone_pw`·`GzKOBpP14Y` 제거 / 디버그 라우트 `OOMU_DEV_ROUTES` 차단(`main.dart`) / 거리 25km·동네 폴백(`kakao_map_service.dart:363-412`) / 게스트 4동선 로그인 유도 / 커뮤니티 상세 `·` 꼬리·좋아요 트랜잭션·nickname 폴백 / 모임 개설 피커·`maxMembers`·`members` 배열·게스트 게이트·스톡커버 제거 / 커뮤니티·발견 중복 제거 / 공지 스트림·비번찾기·MY 실수치 / `saved_meetups` 토큰·`1/N` 삭제 / `flutter test` CI 게이트.

---

## ■ 0단계 [최우선·보안] 시크릿 이전을 "실제로 되는" 상태로 만든다

**지금 상태**: 클라이언트는 `config/*` 읽기를 지웠는데, 대체 경로인 `app_config/*` 문서가 실DB에 없다(무인증 GET 404: `app_config/kakao`·`public_keys`·`r2_public`·`sms_proxy`). 서버 프록시는 어디에도 구현돼 있지 않다. 그 결과 카카오 로그인·지역검색, R2 업로드, SMS 발송, 네이버 로그인이 **런타임 공백**으로 죽어 있다.

1. `solapi_sms_service.dart:75-82` — `_proxyUrl`을 읽어만 놓고 **send 경로에서 쓰지 않는다**. 프록시가 있으면 `POST $proxyUrl/sms/send`로 보내고 HMAC 서명·API 키를 클라이언트에서 완전히 제거하라.
2. Cloudflare Worker(또는 Functions) 1개로 통합: `/sms/send`, `/r2/sign`, `/naver/token`, `/kakao/local`. 클라이언트에는 **프록시 URL만** 남긴다.
3. 설정 공급 경로를 하나로 확정하라 — (a) `app_config/kakao`·`r2_public`·`sms_proxy`·`public_keys` 문서를 **실DB에 생성**하고 그 사실을 보고하거나, (b) `deploy.yml` `flutter build web`에 `--dart-define`을 주입. 지금은 둘 다 없다.
4. `scripts/firestore_helper.py`는 Admin SDK 코드를 추가했지만 **어떤 워크플로도 `FIREBASE_SERVICE_ACCOUNT_JSON`을 주입하지 않는다**(`grep` 0건). `crawl_events.yml`·`sync_trends.yml`·`oomu_cron_ops.yml`에 secret 주입을 추가하라. 안 하면 규칙 게시 순간 크롤러가 멈춘다.
5. `daily_security_audit.yml`에 ①`firestore.rules` 존재 ②전체 허용 패턴(`allow read, write: if true`) 0건 검사를 추가하라.

## ■ 1단계 [PII] 루트 `users` 문서에서 개인정보 제거

`private/contact`에 쓰기만 추가했고 원본이 남아 있다. 아래를 제거하고 `private/contact`로 옮겨라(마이그레이션 스크립트 + 결과 리포트). **문서 삭제 금지, 필드만 이동.**
- `auth_service.dart:289` `kakaoEmail` / `:512-516` `naverEmail`·`phoneNumber` / `:655`·`:733`·`:761` `phone` / `:983` `phone` / `:989-991` `birthDate`·`detailAddress`
- `login_screen.dart:568` `phone` / `phone_verification_field.dart:231·238` `phone`

## ■ 2단계 [규칙] 게시 전 규칙 보강

- `firestore.rules:284-285` `meetups` update → `resource.data.hostId == request.auth.uid || isAdmin()` 추가(현재 로그인만 하면 남의 모임 수정 가능).
- `:302-304` `community_posts` update → `resource.data.authorId == request.auth.uid || isAdmin()`.
- `:313` `comments` delete → `resource.data.authorId == request.auth.uid || isAdmin()`.
- `phone_verifications`를 client deny로 둘 경우, 전화 인증은 서버(Worker) 검증으로 바꿔야 성립한다(`solapi_sms_service.dart:200-247`가 아직 클라이언트 캐시 비교).

## ■ 3단계 [기능] 새로 발견된 결함 2건

1. **딥링크가 빈 껍데기를 띄운다** — `main.dart:97` `OOMUDetailScreen(meetup: {'id': docId})`인데 상세 화면에 `collection('meetups').doc(id).get()` 경로가 없다. 실존 id(`IVGd4HF7kv2DLZV4zbNF`)로도 제목 `취향 모임`·`1/4명`이 뜬다. `?comm_detail`도 동일(작성자 `동네주민`). id만 받았을 때 **1회 조회 후 렌더**하도록 고치고, 없으면 '모임을 찾을 수 없어요'를 표시하라.
2. **고객센터 4개 행이 죽어 있다** — `my_page_sub_screens.dart:5-26` `SimpleListScreen`의 `ListTile`에 `onTap`이 없다. FAQ·1:1 문의·이용약관·개인정보 처리방침을 각각 연결하라(약관/개인정보는 `login_screen.dart:305-315`의 본문 재사용). 개인정보 처리방침 본문에 **제3자 제공·위탁·이용자 권리·문의처** 항목을 추가하라.

## ■ 4단계 [P1 잔여] — 판정이 '부분/미실행'인 항목

1. **차단 UID 배선**: `global_data.dart:333-390`의 `blockedUids`·`isTargetBlocked`는 있는데 **호출부 0곳**이다. UI의 `blockUser(닉네임)` 호출(`user_profile_screen.dart:359`, `oomu_chat_room_screen.dart:379`, `ugc_action_sheets.dart:338`)을 `blockUid(uid)`로 바꾸고, 피드·게시글 상세·댓글·모임 목록·상세·프로필에 같은 필터를 적용하라.
2. **발견 탭 하드코딩 제거**: `oomu_discovery_lifestyle_hub.dart:249-290` `_getYouthSubsidies()`의 '최대 240만 원'·'K-패스 30%' 카드, `discovery_api_service.dart:525-562` `_fallbackMovies` 가짜 박스오피스 — **실소스가 없으면 섹션을 숨긴다**. 날씨 기본값 `tempC=17.5`·`pm10=68`(`:235·237`)을 제거하고 실패 시 `oomu_discovery_lifestyle_hub.dart:363`이 "날씨 정보를 불러올 수 없어요"를 표시하게 하라.
3. **인원 표기 잔여**: `home_lightning_section.dart:244` `'${spot['members'] ?? '2/4'} 참여'`(고정 폴백 포함), `oomu_spot_screen.dart:223·793` → `formatMembersLabel(...)` + `'명'`.
4. **홈 목록 마감 배지**: `home_meetup_section.dart:225-231` `statusBadge`에 `MeetupMemberHelper.formatStatusLabel`을 연결하라(현재 '여성 전용'/'오늘 번개'뿐).
5. **`OomuInsets` 실제 적용**: `oomu_tokens.dart:154-163`이 **사용처 0곳**이다. 커뮤니티·발견 목록 마지막 카드가 탭바에 가리고, 홈·찜한 모임에서 FAB가 카드 인원 표기를 덮는다.

## ■ 5단계 [디자인 토큰] 기준선을 올리지 말고 실제로 줄여라

`scripts/design_token_baseline.json`이 109/566·21/511·14/293 → **113/480·20/430·15/228**로 상향 커밋됐다. 그래서 `--compare`가 "변화 0"으로 통과하지만 색 종류는 108→113, 모서리는 14→15종으로 **늘었다**.
- 화면에서 `Color(0x…)` 직접 지정 0건, `fontSize:` 숫자 0건, `BorderRadius.circular(숫자)` 0건으로 만들고(불가피하면 토큰에 이름 추가), 반경은 r8/r12/r16/r24/pill 5단계만.
- UI 이모지 아이콘(발견 카테고리 등) → Material Rounded. 카피 속 이모지는 유지 가능.
- 마친 뒤에 `--save`로 기준선을 **내려서** 갱신하고, `--compare`를 CI 게이트에 연결하라.

## ■ 6단계 [검증·보고]

- 필수: `flutter analyze`(경고 0) · `flutter test` · `check_design_tokens.py --compare` · `flutter build web --release`. **`flutter analyze`는 CI에 단계가 없어 이번 검수에서 확인할 수 없었다** — 워크플로에 단계를 추가하고 로그를 붙여라.
- 보고에 반드시: 수정 파일:라인 / 커밋 SHA / **실제 실행한** 테스트 로그 / 라이브 스크린샷 (a) `app_config` 키 공급 후 카카오 로그인 성공 (b) R2 업로드 사진 실렌더 (c) 딥링크로 실모임·실게시글 표시 (d) 고객센터 4개 링크 동작 (e) 마감 배지가 홈 목록에도 표시 (f) 탭바·FAB에 콘텐츠 안 가림 (g) 토큰 실측 전후 수치.
- **하지 않은 것과 이유**를 따로 적어라. 미실행을 완료로 쓰지 말 것.

> 참고: 규칙 **콘솔 게시**와 시크릿 **재발급**은 안티그래비티가 아니라 심향 님이 직접 한다. 0단계(키 공급·크롤러 서비스 계정)가 끝난 뒤에만 게시해야 한다.
