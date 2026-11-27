# 모임 장소 수정안 적용 방법

`meetup_places_fix.json`의 `updates` 9건을 Firestore `meetups/{id}`에 반영한다. 서버 쓰기는 관리자 권한이 필요해서 Firebase 로그인 후 에이전트가 적용한다.

1. 대표: 새 세션에서 "모임 장소 수정안 적용해"라고 말한 뒤, 에이전트가 주는 Firebase 로그인 링크에서 로그인(세션 ID 확인)하고 코드를 붙여 넣는다.
2. 에이전트: 각 항목마다 `firestore_update_document`로 `location`, `lat`, `lng`, `latitude`, `longitude` 다섯 필드만 바꾼다. 다른 필드(참여자, 제목, 사진 등)는 건드리지 않는다.
3. 적용 후 test11 계정으로 REST 조회해 9건 좌표가 바뀌었는지 확인하고, 앱 모임 상세 2~3개에서 지도 마커 위치를 본다.

`keep_unchanged`에 적힌 모임은 바꾸지 않는다(실제 호스트 모임, 테스트 모임).
