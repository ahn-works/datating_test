# 🚀 OOMU 24/7 B2B 무인 운영 & 깃허브 액션 자동화 가이드

본 문서는 OOMU(우리끼리 무드있게)의 **서버 비용 0원 무인 자동화 시스템**의 작동 원리 및 **노션(Notion) / 텔레그램 연동 방법**을 안내합니다.

---

## 📌 1. 자동화 시스템 전체 구성표

| 시간 (한국 시각) | 실행 작업 | 스크립트 | 주요 기능 및 효과 |
| :--- | :--- | :--- | :--- |
| **08:30 KST** | 🗳️ 연애 밸런스 게임 투표 | `scripts/daily_balance_game.py` | 매일 아침 흥미진진한 밸런스 게임 투표 글 자동 등록 (출근길 리텐션) |
| **08:30 KST** | 📉 휴면 유저 컴백 유도 | `scripts/retention_booster.py` | 3일 이상 미접속 회원 탐지 & 무료 하트 3개 충전 알림 지급 |
| **18:00 KST** | 🧊 콜드스타트 번개 모임 생성 | `scripts/seed_meetups.py` | 자연스러운 동네 시드 계정(성수동힙스터 등)으로 요일별 실시간 모임 & 채팅방 개설 |
| **18:00 KST** | 🚨 악성 게시글 모니터링 | `scripts/content_moderator.py` | 조건만남/스폰/도박/불법 홍보 키워드 탐지 시 즉시 블라인드 및 신고 접수 |
| **23:59 KST** | 🧹 유령 모임 & 지난 카풀 청소 | `scripts/cleanup_stale_data.py` | 지난 일정의 모임을 'closed' 처리하여 앱 화면을 항상 신선하게 유지 |
| **23:59 KST** | 📱 대표님 일일 경영 보고서 | `scripts/daily_ops_report.py` | 노션 표에 오늘 가입자, 모임, 신고 건수 자동 기록 & 텔레그램 알림 |
| **일 04:00 KST** | 🛡️ 파이어베이스 DB 자동 백업 | `scripts/backup_firestore.py` | 전체 Firestore 데이터를 JSON.GZ로 압축하여 깃허브 아티팩트에 안전 보관 |

---

## 📓 2. 노션(Notion) 일일 경영 보고서 3분 연동법

대표님의 노션 워크스페이스에 매일 밤 11시 59분 자동으로 보고서 행(Row)이 추가되도록 연동하는 방법입니다.

### 1단계: 노션 API 키 발급
1. [노션 개발자 포털 (My Integrations)](https://www.notion.so/profile/integrations)에 접속합니다.
2. **`+ 새 API 통합(New Integration)`** 클릭:
   * 이름: `OOMU 운영 봇`
   * 관련 워크스페이스 선택 후 **[저장]**
3. 생성된 **`내부 통합 비밀 토큰 (Internal Integration Secret)`** (`secret_...`)을 복사합니다.

### 2단계: 노션 데이터베이스(표) 생성 및 연결
1. 노션에서 새 페이지를 만들고 **`표(Database - Full page)`**를 생성합니다.
2. 표의 컬럼(속성)을 아래와 같이 설정합니다 (이름과 타입이 정확히 일치해야 합니다):
   * **`일자`** (타입: **제목 / Title**)
   * **`신규 가입자`** (타입: **숫자 / Number**)
   * **`누적 가입자`** (타입: **숫자 / Number**)
   * **`신규 모임`** (타입: **숫자 / Number**)
   * **`활성 모임`** (타입: **숫자 / Number**)
   * **`신규 커뮤니티글`** (타입: **숫자 / Number**)
   * **`신고 접수`** (타입: **숫자 / Number**)
   * **`상태`** (타입: **선택 / Select**)
3. 우측 상단 **`··· (설정)`** ➔ **`연결(Connections)`** ➔ **`OOMU 운영 봇`** 추가! (매우 중요 ⭐)
4. 브라우저 주소창의 URL에서 Database ID를 복사합니다:
   * `https://www.notion.so/myworkspace/{DATABASE_ID}?v=...` 에서 32자리 영문/숫자.

### 3단계: 깃허브 시크릿(Secrets)에 등록
1. 깃허브 저장소 `https://github.com/ahn-works/datating_test` 접속
2. **`Settings`** ➔ **`Secrets and variables`** ➔ **`Actions`** 클릭
3. **`New repository secret`** 등록:
   * 이름: `NOTION_API_KEY` / 값: `secret_...`
   * 이름: `NOTION_DATABASE_ID` / 값: `32자리 ID`

> 🎉 **연동 완료!** 이제 매일 밤 11시 59분에 노션 표에 오늘 하루의 성과가 자동으로 차곡차곡 쌓입니다.

---

## 💬 3. 텔레그램(Telegram) 스마트폰 알림 연동 (선택 사항)

1. 텔레그램 앱에서 `@BotFather`를 검색하여 `/newbot`으로 봇 생성 후 **`HTTP API 토큰`**을 받습니다.
2. `@userinfobot`을 검색하여 나의 **`Id (숫자)`**를 확인합니다.
3. 깃허브 Secrets에 등록:
   * `TELEGRAM_BOT_TOKEN`: 봇 토큰
   * `TELEGRAM_CHAT_ID`: 내 유저 ID (숫자)

---

## 🖱️ 4. 깃허브 웹에서 1클릭 수동 테스트 방법

언제든지 필요할 때 즉시 자동화 작업을 1초 만에 실행해볼 수 있습니다.

1. 깃허브 저장소 ➔ **`Actions`** 탭 클릭
2. 좌측 메뉴에서 **`OOMU 24/7 B2B Operations & Cron Automation`** 선택
3. 우측 상단 **`Run workflow`** 버튼 클릭
4. 원하는 작업(전체 실행, 번개 모임 즉시 생성, 투표 즉시 배달, DB 즉시 백업 등) 선택 후 초록색 **[Run workflow]** 클릭!
