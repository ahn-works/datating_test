# OOMU 딥링크 및 라우트 정책 (`docs/OOMU_DEEPLINKS.md`)

`lib/main.dart`의 초기 라우트 해석(`resolveInitialRouteWidget`)에서 허용하는 쿼리 파라미터와 릴리스/디버그 동작 규격입니다.

## 1. 라우트 및 파라미터 정책 표

| 쿼리 파라미터 | 필수 인자 | 프로덕션(릴리스) 허용 여부 | 릴리스 진입 시 동작 | 비고 |
| :--- | :--- | :---: | :--- | :--- |
| `(없음)` | - | 허용 | 인증 세션 있으면 `OOMUHomeScreen`, 없으면 `LoginScreen` | 기본 진입 |
| `?home=true` | - | 허용 | 게스트 세션(`guest`)으로 초기화 후 `OOMUHomeScreen` | `user=` 파라미터 무시 |
| `?login=true` | - | 허용 | 게스트 세션(`guest`)으로 초기화 후 `LoginScreen` | 로그인 화면 진입 |
| `?detail=true&id=<docId>` | `id` (실제 Firestore 문서 ID) | 허용 (실문서 ID만) | `OOMUDetailScreen(meetup: {'id': docId})` 진입 (`id` 누락·샘플 ID면 `OOMUHomeScreen` 이동) | `sample_01`, `sample_yeosu_01` 등 차단 |
| `?comm_detail=true&id=<docId>` | `id` (실제 Firestore 문서 ID) | 허용 (실문서 ID만) | `CommunityPostDetailScreen(post: {'id': docId})` 진입 (`id` 누락·`test_post`면 `OOMUHomeScreen` 이동) | `post_sample_01`, `test_post` 차단 |
| `?gallery=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | 컴포넌트 갤러리 노출 차단 |
| `?my=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | `user=` 신원 전환 원천 차단 |
| `?profile=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | 샘플 프로필 렌더 차단 |
| `?edit=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | 디버그 전용 |
| `?comm_create=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | 디버그 전용 |
| `?chat=true` / `?chat_room=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | `sample_chat_room_01` 차단 |
| `?discovery=true` / `?fortune=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | 디버그 전용 |
| `?profile_setup=true` / `?my_trips=true` | - | **차단** (`OOMU_DEV_ROUTES` 전용) | 게스트 세션으로 `OOMUHomeScreen` 이동 | 디버그 전용 |
| `?user=<uid\|alias>` | - | **차단 (무시)** | 어떤 경우에도 URL 파라미터로 세션 UID를 전환하지 않음 | 무인증 세션 전환 방지 |
