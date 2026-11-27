# Firestore 보안 규칙 에뮬레이터 검증 (체크리스트 2번) — 2026-11-27

## 범위와 한계

- 대상: 레포 루트 `firestore.rules` (pc-sync-1127 브랜치, 커밋 0c6f2d3에서 PC 수정본 반영). `scripts/firestore.rules`와 내용이 같다.
- 방법: Firestore 에뮬레이터(v1.19.8, 가짜 프로젝트 `demo-oomu-rules`)에서 비로그인 / 본인 / 타인 / 관리자 계정으로 앱(lib/)이 실제로 보내는 요청 모양을 재현했다. 각 테스트 이름에 근거 코드 위치(`파일:줄`)를 적었다.
- `firestore.rules`는 백엔드 보호구역이라 **수정하지 않았다**. 수정안은 `rules_test/proposed.firestore.rules`에 따로 두었고 **운영에 게시하지 않았다.**
- 운영 Firestore에 실제로 어떤 규칙이 게시돼 있는지는 확인하지 못했다(운영 프로젝트 접근 없음). 게시 후 운영 재검증은 대표님 권한이 필요하다.

## 실행 방법

```bash
cd rules_test
npm ci
npm test                                        # 현재 firestore.rules
RULES_FILE=proposed.firestore.rules npm test    # 수정 제안본
```

Java 21과 Node 22가 필요하다. Branch CI의 `firestore-rules` job이 브랜치 push마다 같은 테스트를 돌린다.

## 결과 (2026-11-27 실행)

| 규칙 | 테스트 | 통과 | 실패 | 결함 기록(todo) |
| --- | --- | --- | --- | --- |
| 현재 `firestore.rules` | 81 | 73 | 0 | 8개 모두 재현됨 |
| 제안본 | 81 | 73 | 0 | 8개 중 7개 해소, 1개 남음 |

`todo` 테스트는 "이렇게 동작해야 한다"는 기대를 적은 것이다. 현재 규칙에서 실패하는 것이 결함의 증거다. node:test는 todo 실패를 전체 실패로 세지 않으므로 CI는 초록색으로 통과한다. 규칙을 고친 뒤 todo 표시를 지워 일반 테스트로 올린다.

### 통과한 주요 보장 (현재 규칙)

- 시크릿 문서(`config/*`, `system_config/*`, `phone_verifications/*`, `app_config/solapi·api_keys·r2_storage·naver·naver_auth`)는 비로그인·로그인·관리자 모두 읽기 거부.
- users 문서에 `phone`·`phoneNumber`·`email`을 넣는 생성과 수정은 거부되고, 관리자 claim 없이 `role: admin`을 쓰는 것도 거부. `private/contact`는 본인만 접근.
- **좋아요(체크리스트 12번)**: 남의 글·댓글 좋아요/취소 허용, 두 사람 연속 좋아요 시 likes=2. 다른 사람 uid 대입, likes 부풀리기(100), 중복 uid, 음수, 좋아요와 본문 동시 수정은 모두 거부. likedUserIds가 없는 예전 글도 좋아요 가능.
- 모임 신청: 본인 pending(1~2명)만 허용, 신청자가 직접 자리 차지·자기 승인 거부. 모임장 승인 트랜잭션(모임 갱신 + 단톡방 생성 + 신청 승인)은 허용.
- 채팅: 참여자만 방·메시지 읽기, arrayContains 목록 조회 허용, 나가기 허용. 다른 사람 내보내기와 일반 참여자의 제목 변경은 거부.
- 비로그인 users 목록 조회는 필터 없이도, `documentId() != 'guest'` 필터를 붙여도 거부됨(가설을 세워 시험했으나 재현 안 됨). 다만 uid를 알면 개별 문서 get은 비로그인도 가능하다.

### 발견한 결함 (백엔드 필요)

| # | 등급 | 내용 | 근거 | 제안본 |
| --- | --- | --- | --- | --- |
| R1 | 높음 | **탈퇴해도 공개 프로필이 남음.** `users` delete가 관리자 전용인데 앱은 본인 문서를 지우고 실패를 `catch`로 숨긴 뒤 Auth 계정만 삭제한다. 스토어 계정 삭제 요건(체크리스트 11번)과도 관련 | `lib/services/auth_service.dart:199` | 본인 삭제 허용 → 해소 |
| R2 | 중간 | **매너온도 위조.** 본인이 `mannerTemp`를 아무 값으로 바꿀 수 있음 | users update 필드 제한 없음 | 생성 시 36.5 고정, 수정 금지(관리자 제외) → 해소 |
| R3 | 중간 | **인증 배지 위조.** 본인이 `isVerified`·`isPhoneVerified`를 직접 켤 수 있음. 앱이 지금 클라이언트에서 이 값을 쓰기 때문에 규칙만 잠그면 가입이 막힌다 | `lib/widgets/phone_verification_field.dart:225`, `lib/services/auth_service.dart:400` | **미해결.** 체크리스트 1·3번(서버 배포, OTP 서버 검증) 이후 서버가 쓰도록 옮기고 잠근다 |
| R4 | 중간 | **글·댓글 사칭.** create가 `authorId == 나 OR userId == 나`라서 `userId`만 내 것으로 두고 `authorId`에 다른 회원을 넣으면 통과 | community_posts / comments create | 있는 작성자 필드는 모두 본인이어야 함 → 해소 |
| R5 | 중간 | **채팅 메시지 사칭.** 같은 OR 구조라 `senderId`에 다른 참여자를 넣고 보낼 수 있음 | messages create | `senderId == 나` 필수 → 해소 |
| R6 | 중간 (기능 고장) | **단톡방 투표·일정·응원·프로필교환 카드에 다른 참여자가 응답하면 저장 실패.** messages update가 보낸 사람 전용이라 "변경을 저장하지 못했어요"가 뜬다 | `lib/screens/chat/chat_system_cards.dart:318,550,1064,1349,1489` → `lib/services/chat_repository.dart:206` | 참여자는 응답 필드만 수정 허용 → 해소 |
| R7 | 중간 | **알림 사칭·피싱.** 로그인만 하면 아무 회원에게 아무 제목·본문의 알림을 만들 수 있음 | notifications create | 모임 신청/결정 알림만, 신청서·모임장 관계 확인 → 해소 |
| R8 | 높음 (개인정보) | **신고 내용 전체 공개.** 로그인만 하면 모든 신고(신고자 닉네임, 대상, 사유)를 읽을 수 있음. 앱은 reports를 읽지 않는다 | reports read | 관리자만 열람 → 해소 |

### 현재 동작으로만 기록한 것 (대표 결정 필요, 결함으로 세지 않음)

- 거절된 신청자는 같은 모임에 다시 신청할 수 없다(update 규칙이 pending에서만 허용).
- 신청자는 자기 신청을 취소(삭제)할 수 없다(삭제는 관리자 전용). 앱에 취소 버튼이 생기면 규칙도 바꿔야 한다.

### 규칙으로는 못 막는 것 (프론트+백엔드 구조 변경 필요)

- 공개 users 문서에 `blockedUsers`(차단한 닉네임 목록, `lib/utils/global_data.dart:644`)와 `kakaoId`(`lib/services/auth_service.dart:402`)가 저장된다. users get이 공개라 글쓴이 uid만 알면 누구나 읽는다. Firestore 규칙은 필드 단위로 숨길 수 없으므로 `user_states/{uid}` 또는 `users/{uid}/private/*`로 옮겨야 한다.
- `secret_after` 카드의 `secretChoices`는 공유 메시지 문서에 저장돼 같은 방 참여자 모두가 읽을 수 있다. "비밀 선택"이라는 이름과 맞지 않는다.
- 앱이 `config/kakao_auth`에 쓰기를 시도한다(`lib/services/auth_service.dart:151`). 규칙이 막고 있어 피해는 없지만 매번 거부 오류가 난다.

## 제안본 적용 시 주의

- 제안본 R2는 생성 시 `mannerTemp == 36.5`만 허용한다. `OOMU_DEV_ACCOUNTS` 빌드 플래그의 테스트 계정(38.5)은 관리자 claim이 없으면 가입이 거부된다.
- 제안본 R6은 응답 필드(`voters`, `attendees`, `cheers`, `acceptedMembers`, `status`, `secretChoices`, `submittedAt`) 수정만 허용한다. 참여자가 다른 사람의 응답을 덮어쓰는 것까지는 막지 못한다.
- 제안본 R7은 앱이 보내는 알림 2종(`meetup_request`, `meetup_decision`)만 허용한다. 알림 종류가 늘면 규칙에도 추가해야 한다.
- 게시는 `firestore.rules`에 반영 → `cd rules_test && npm test` 통과 확인 → `firebase deploy --only firestore:rules` 순서로 한다. 게시 뒤 운영에서 2계정으로 다시 확인한다(체크리스트 2번 "운영에서 재검증").
