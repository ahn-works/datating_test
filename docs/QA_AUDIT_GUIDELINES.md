# 📋 OOMU 전수 품질 검수 지침서 (QA_AUDIT_GUIDELINES.md)

> **목적**: 본 문서는 OOMU 프로젝트의 **유일한 단일 전체 품질 검수 및 QA 지침(SSOT)**입니다.  
> 개발·디자인 전체 지침은 [`AGENTS.md`](AGENTS.md), 보안 지침은 [`SECURITY.md`](SECURITY.md)를 따르며, 모든 기능 구현 및 수정 후 배포 전 검수는 본 문서의 프로토콜과 5단계 자동화 검증을 필수로 준수합니다.

---

## 🧭 1. 검수 3대 핵심 원칙 (Core QA Principles)

1. **실측 캡처 1:1 대조 원칙 (Visual Diff Mandatory & No Superficial Audits)**
   - 대충 코드 몇 줄만 고치고 주관적으로 "완료되었다"고 보고하는 대충 검토 행위를 엄격히 금지합니다.
   - 실제 모바일 뷰포트(390×844 @2x) 환경에서 Playwright로 실측 캡처를 뜨고, 이미지 뷰어로 픽셀·비율·여백·텍스트 말줄임·아이콘을 1:1로 대조하여 갭(Gap)이 0건임을 실측 증거(스크린샷)로 입증해야 합니다.
2. **DB 데이터 실시간 정합성 보장 (Live DB Consistency)**
   - 화면에 노출되는 모든 수치(활동 카운트, 매너온도, 닉네임, 지역, 태그, 포스터)는 하드코딩이 아닌 Firestore/Cloudflare R2의 실제 문서 필드와 1:1 동적 바인딩되어야 합니다.
3. **5단계 자동화 검증 통과 필수 (Pre-Deployment Pipeline)**
   - 보안 스캔(0 Secrets/0 PII) → Dart 구문 검증 → 정적 분석(0 Errors) → 회귀 테스트(100% Pass) → 릴리즈 번들 빌드가 순차적으로 완료되어야 배포를 승인합니다.

---

## 🔍 2. 9대 핵심 기능 전수 검수 프로토콜 (9 Core Audit Protocols)

### [항목 1] 프로필 사진 렌더링 검수
- **검수 목적**: 마이페이지 및 프로필 상세 화면 진입 시 프로필 사진이 깨진 아이콘(`Icons.image_not_supported`)으로 나타나는 결함 방지.
- **검수 대상 파일**:
  - `lib/utils/app_image.dart`
  - `lib/screens/user_profile_screen.dart`
- **검수 방법**:
  1. Cloudflare R2 원격 경로(`profiles/...`) 실패 시 로컬 에셋(`assets/images/초연.png`)으로의 3단 안전 폴백 체인 검증.
  2. `choyeon@test.oomu.app` 계정 진입 시 `http://localhost:8086/?profile=true&user=test11` 경로 실측 캡처.
- **통과 기준**: 상단 원형/히어로 이미지 영역에 에러 아이콘 없이 고화질 프로필 사진이 렌더링될 것.
- **실측 검증 증거**: `proof_01_profile_detail.png` (PASS)

---

### [항목 2] 기본정보·나의 이야기·취향 태그 실데이터 매칭 검수
- **검수 목적**: 프로필 상세와 프로필 수정 화면의 데이터(직업, 한줄소개, MBTI, 음주, 성격, 취향, 흡연, 반려동물)가 Firestore 실제 사용자 문서와 분리되거나 누락되는 문제 차단.
- **검수 대상 위치**:
  - Firestore 컬렉션: `users/LZs5U32GQJMkK77hkmaJupgKzwE2`
  - 화면: `lib/screens/user_profile_screen.dart`, `lib/screens/profile_edit_screen.dart`
- **검수 방법**:
  1. 프로필 수정 화면에서 흡연 성향('비흡연'), 반려동물('반려동물 있음'), 성격 태그('리액션 요정', '친화력 갑') 선택 후 저장.
  2. Firestore `users/{uid}` 문서에 필드가 정상 저장되는지 Python Admin 스크립트로 확인.
  3. 프로필 상세 화면을 다시 열어 4개 섹션(기본정보, 성격/매력 태그, 나의 이야기, 관심사/취향)에 저장된 값이 1:1 노출되는지 확인.
- **통과 기준**: 수정 화면에서 변경한 모든 필드가 DB에 저장되고, 상세 화면에서 누락 없이 표시될 것.
- **실측 검증 증거**: `proof_01_profile_detail.png`, `proof_03_profile_edit.png` (PASS)

---

### [항목 3] 마이페이지 활동 숫자(배지) 동적 연동 검수
- **검수 목적**: 참여한 모임, 찜한 모임, 내가 쓴 글, 받은 후기 숫자가 더미 고정값(8, 12, null, 23)으로 노출되는 결함 해결.
- **검수 대상 파일**:
  - `lib/screens/my_page_screen.dart`
  - `lib/utils/global_data.dart`
- **검수 방법**:
  1. Firestore 유저 문서에 실제 수치 주입 (`joinedMeetupsCount: 6`, `savedMeetupsCount: 0`, `myPostsCount: 2`, `reviewCount: 3`).
  2. 마이페이지 로드 시 `globalData`와 Firestore 스트림/문서로부터 각각의 카운트를 동적 추출하는지 코드 및 UI 검수.
- **통과 기준**: 4개 메뉴 항목 우측 화살표 옆 숫자가 실제 DB 카운트(`6`, `0`, `2`, `3`)로 정확히 바인딩될 것.
- **실측 검증 증거**: `proof_02_my_page_badges.png` (PASS)

---

### [항목 4 & 6] 채팅 및 커뮤니티 인기 움짤(GIF) 무한 재생 및 첨부 검수
- **검수 목적**:
  - Giphy 스티커/움짤이 이미지 프록시의 강제 압축(`&output=jpg`)으로 인해 움직이지 않고 멈춰있는 결함 해결.
  - 커뮤니티 댓글 입력창에도 움짤 선택 및 댓글 내 움직이는 렌더링 지원.
- **검수 대상 위치**:
  - Firestore 컬렉션: `config/curated_stickers` (100개 스티커 URL)
  - 코드: `lib/utils/app_image.dart`, `lib/services/r2_storage_service.dart`, `lib/screens/community_post_detail_screen.dart`
- **검수 방법**:
  1. `config/curated_stickers`의 모든 스티커 URL에 `&output=gif&n=-1` 옵션 적용.
  2. `curl`로 실제 HTTP 응답 헤더가 `Content-Type: image/gif` 및 바이너리 매직넘버 `GIF89a`를 반환하는지 검증.
  3. 채팅방 및 커뮤니티 댓글 바에서 스티커 픽커 열기 → 스티커 선택 → 전송 후 말풍선 내 렌더링 확인.
- **통과 기준**: 프록시 변환 없이 다중 프레임 GIF가 화면에서 무한 루프로 부드럽게 움직일 것.
- **실측 검증 증거**: `proof_04_chat_room.png`, `proof_05_community_detail.png` (PASS)

---

### [항목 5] 채팅창 동네 핫플 추천 및 검색 검수
- **검수 목적**: 채팅 중 약속 장소를 정할 때 '동네 핫플' 바텀시트가 빈 목록으로 뜨거나 검색이 실패하는 현상 방지.
- **검수 대상 파일**:
  - `lib/screens/chat/chat_modals.dart`
  - `lib/services/kakao_map_service.dart`
- **검수 방법**:
  1. 바텀시트 호출 시 사용자의 현재 동네(여수시 화장동)를 인식하여 8대 검증된 로컬 핫플(성산공원 둘레길, 선소상가 먹자골목 등)이 즉시 로드되는지 확인.
  2. 카테고리 칩('전체', '관광지', '카페', '술집', '빵집') 탭 시 필터링 동작 확인.
  3. 카카오 로컬 API 장애 시에도 안전한 로컬 큐레이션 데이터로 자동 폴백되는지 확인.
- **통과 기준**: 검색어가 없어도 즉시 추천 장소 리스트가 노출되고 탭 시 채팅방에 지도 카드가 전송될 것.
- **실측 검증 증거**: 즉시 로드 및 카테고리 필터링 확인 (PASS)

---

### [항목 7] 발견(Discovery) 실시간 포스터 크롤링 및 R2 저장공간 관리 검수
- **검수 목적**:
  - 발견 탭에 실제 크롤링된 트렌드 이벤트(KOPIS 공연, 박스오피스 영화) 대신 기본 와인/음식 사진이 뜨던 문제 해결.
  - 무제한 크롤링으로 인한 Cloudflare R2 스토리지 용량 초과 및 비용 발생 방지.
- **검수 대상 위치**:
  - Firestore 컬렉션: `trend_events` (30개 실시간 크롤링 문서)
  - 코드: `lib/services/discovery_api_service.dart`, `lib/widgets/oomu_discovery_lifestyle_hub.dart`
  - 자동화: `.github/workflows/sync_trends.yml`, `scripts/cleanup_stale_data.py`
- **검수 방법**:
  1. `discovery_api_service.dart`가 Firestore `trend_events` 컬렉션에서 `validUntil` 유효기간 기준 최신 공연/영화 포스터 URL을 로드하는지 확인.
  2. 발견 탭의 '전체추천' 및 '요즘트렌드'에서 실제 포스터(이승윤 고양 콘서트, NCT WISH 등)가 2열 그리드로 렌더링되는지 실측 캡처.
  3. GitHub Actions 스케줄러에서 `cleanup_stale_data.py --days 3`가 실행되어 종료된 이벤트 DB 문서와 연결 끊긴 R2 포스터 파일을 자동 영구 삭제(Purge)하는 로직 확인.
- **통과 기준**: 더미 이미지 없이 실제 크롤링 포스터가 노출되고, 3일 이상 경과된 파일은 R2에서 자동 정리되어 저장공간 0원 유지.
- **실측 검증 증거**: `proof_07_discovery_all_posters.png` (PASS)

---

### [항목 8] 놀거리·운세 인터랙티브 기능 검수
- **검수 목적**: 화면 껍데기만 있고 클릭해도 반응이 없던 '놀거리·운세' 카테고리에 실시간 인터랙션 부여.
- **검수 대상 파일**:
  - `lib/widgets/oomu_discovery_lifestyle_hub.dart`
- **검수 방법**:
  1. 🍀 **오늘의 동네 행운 지수**: 96점 최상 그라데이션 게이지, 행운의 컬러(코랄 핑크), 행운의 장소(로컬 감성 카페), 행운의 시간대(16:00~18:00) 렌더링 검수.
  2. 🔮 **소셜 & 인연 타로 카드**: 3장(연애운, 재물운, 소셜운) 중 카드를 탭했을 때 실시간 뒤집기 애니메이션 및 점수(98점)와 해설 카드가 노출되는지 인터랙션 검수.
  3. ⚖️ **실시간 밸런스 토론 배틀**: A옵션("삼겹살 & 하이볼")과 B옵션("침대 & 마라탕") 탭 시 투표 수 갱신 및 백분율 프로그레스 바 애니메이션 검수.
- **통과 기준**: 탭 즉시 상태 변화가 시각적으로 나타나며 레이아웃 깨짐이 없을 것.
- **실측 검증 증거**: `proof_08_play_and_fortune.png`, `proof_08_play_and_fortune_interactive.png` (PASS)

---

### [항목 9] 커뮤니티 글쓰기 UI 개편 & 댓글/좋아요 무결성 검수
- **검수 목적**:
  - 글쓰기 화면 상단 타이틀 매칭 오류('동네 이야기 쓰기' ❌ → '동네 커뮤니티 글쓰기' ⭕).
  - 카테고리 칩이 세로 1열로 흉하게 나열되던 UI를 세련된 2x2 가로 그리드로 개편.
  - 댓글 작성 시 DB 저장 여부 및 1인 1좋아요(중복 카운트 방지) 무결성 검수.
- **검수 대상 파일**:
  - `lib/screens/community_post_create_screen.dart`
  - `lib/screens/community_post_detail_screen.dart`
- **검수 방법**:
  1. 글쓰기 화면 진입 시 헤더 타이틀이 '동네 커뮤니티 글쓰기'로 표시되는지 확인.
  2. 4대 카테고리(일상·수다, 공연·핫플, 맛집·카페, 동네질문)가 2행 2열 대칭 그리드로 줄바꿈 없이 정갈하게 배치되는지 확인.
  3. 상세 화면에서 좋아요 버튼 연타 시 `likedUserIds` Set 검증을 통해 1개 계정당 1회만 카운트(+1 / -1 토글)되는지 검증.
- **통과 기준**: 카테고리 2x2 대칭 배치, 줄바꿈 0건, 좋아요 중복 집계 0건.
- **실측 검증 증거**: `proof_06_community_create.png` (PASS)

---

## 🚀 3. 배포 전 필수 5단계 자동화 검증 파이프라인 (표준 매뉴얼)

모든 코드 작업 완료 후 배포 전 반드시 아래 5단계를 순차적으로 실행하여 전 항목 통과를 입증해야 합니다.

```
[1단계: Playwright 실측 캡처 대조]
  └─ python scripts/capture_all_9_proofs.py

[2단계: 제로-시크릿 보안 스캐너 (7/7 PASS)]
  └─ powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1

[3단계: Dart 구문 검증 & 정적 분석 (0 Errors)]
  └─ python scripts/verify_dart_syntax.py
  └─ flutter analyze

[4단계: 단위 및 위젯 회귀 테스트 (100% PASS)]
  └─ flutter test

[5단계: 릴리즈 빌드 & GitHub 최신 동기화]
  └─ flutter build web --release
  └─ git add -A && git commit -m "..."
  └─ git pull --rebase origin main && git push origin main
```

---

## 📋 4. 일일 배포 QA 체크리스트 (양식)

| No | 체크 항목 | 검수 방법 | 확인 결과 (Y/N) |
|:---:|---|---|:---:|
| 1 | 프로필 및 피드 썸네일이 깨짐 없이 표시되는가? | Playwright 실측 캡처 | [ ] |
| 2 | 마이페이지의 참여/찜/글/후기 숫자가 실제 DB와 일치하는가? | Firestore 실데이터 대조 | [ ] |
| 3 | 프로필 수정 시 변경된 항목이 즉시 상세 화면에 반영되는가? | 수정 후 재진입 확인 | [ ] |
| 4 | 채팅 및 커뮤니티에서 움짤(GIF)이 부드럽게 움직이는가? | 다중 프레임 재생 확인 | [ ] |
| 5 | 채팅 동네 핫플 바텀시트가 즉시 로드되고 카테고리 필터가 작동하는가? | 바텀시트 터치 확인 | [ ] |
| 6 | 발견 탭의 공연/영화 포스터가 실제 크롤링 이미지인가? | 트렌드 피드 대조 | [ ] |
| 7 | 타로 카드 뒤집기 및 밸런스 배틀 투표 인터랙션이 동작하는가? | 터치 인터랙션 확인 | [ ] |
| 8 | 커뮤니티 글쓰기 카테고리가 2x2 가로 그리드로 정갈하게 정렬되었는가? | 화면 캡처 대조 | [ ] |
| 9 | 좋아요 클릭 시 1인 1회만 카운트(중복 방지)되는가? | 연타 토글 테스트 | [ ] |
| 10 | 보안 스크립트(`verify_security_rules.ps1`) 결과가 7/7 PASS인가? | 콘솔 실행 확인 | [ ] |
| 11 | `flutter test` 회귀 테스트가 100% 통과했는가? | 82/82 통과 확인 | [ ] |
| 12 | 브라우저 캐시 무효화 안내(Ctrl+F5)를 사용자에게 전달했는가? | 안내 배포 확인 | [ ] |
