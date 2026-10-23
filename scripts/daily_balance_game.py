#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Daily Romance & Social Balance Game Generator
- Posts engaging daily dilemma polls to 'community_posts' at 08:30 KST every morning.
- Drives viral comments, healthy debates, and user retention.
- Zero-duplicate check ensures only 1 fresh poll per day.
"""

import argparse
import sys
from datetime import datetime, timedelta, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import get_document, list_documents, set_document

BALANCE_GAMES = [
    {
        "title": "🦐 [오늘의 밸런스] 깻잎 떼어주기 vs 새우 까주기",
        "question": "내 애인이 내 절친에게 해줄 때 더 용납할 수 없는 것은?",
        "optionA": "A. 깻잎 두 장 붙은 거 젓가락으로 떼어주기",
        "optionB": "B. 뜨거운 새우 손으로 까서 앞접시에 놔주기",
        "tag": "깻잎논쟁",
    },
    {
        "title": "💳 [연애 토크] 첫 데이트 비용, 여러분의 기준은?",
        "question": "첫 만남 계산할 때 가장 자연스러운 방식은?",
        "optionA": "A. 첫 만남은 깔끔하게 무조건 5:5 더치페이",
        "optionB": "B. 밥 산 사람이 있으면 커피는 상대가 사는 센스",
        "tag": "데이트비용",
    },
    {
        "title": "🍻 [이성친구 논쟁] 애인과 남사친/여사친의 단둘이 술자리",
        "question": "여러분이라면 어디까지 이해해 줄 수 있나요?",
        "optionA": "A. 밤 10시 전 귀가하고 연락 잘 되면 이해 가능",
        "optionB": "B. 아무리 오래된 친구라도 단둘이 밤 술자리는 절대 불가!",
        "tag": "남사친여사친",
    },
    {
        "title": "📱 [연락 스타일] 연애할 때 더 선호하는 연락 빈도는?",
        "question": "나와 더 잘 맞는 연애 연락 스타일은?",
        "optionA": "A. 일상 틈틈이 실시간 카톡 & 사소한 사진 공유형",
        "optionB": "B. 낮엔 각자 할 일 집중하고 퇴근 후 밤에 통화 몰아서 하는 형",
        "tag": "연락스타일",
    },
    {
        "title": "🏖️ [주말 데이트] 이번 주말 더 끌리는 데이트 코스는?",
        "question": "돌아오는 주말, 둘 중 딱 하나만 골라야 한다면?",
        "optionA": "A. 성수/홍대 핫플 팝업스토어 & 신상 맛집 웨이팅 정복",
        "optionB": "B. 동네 한적한 숲길 산책 & 조용한 북카페 힐링",
        "tag": "주말데이트",
    },
    {
        "title": "🎁 [기념일] 100일 기념일 선물, 어떤 게 더 감동인가요?",
        "question": "연인에게 받았을 때 더 기억에 남는 선물은?",
        "optionA": "A. 내가 평소 갖고 싶다고 흘려 말했던 브랜드 선물",
        "optionB": "B. 진심 어린 손편지와 하루 종일 직접 기획한 서프라이즈 코스",
        "tag": "기념일선물",
    },
    {
        "title": "🚗 [드라이브] 데이트 이동할 때 더 좋은 방식은?",
        "question": "연인과의 주말 데이트 이동 수단 선호도는?",
        "optionA": "A. 편안하고 오붓하게 음악 들으며 차로 드라이브",
        "optionB": "B. 주차 걱정 없이 지하철/걸어 다니며 골목길 구경",
        "tag": "데이트이동",
    },
    {
        "title": "🥘 [식성 케미] 연인과 더 안 맞을 때 힘든 것은?",
        "question": "음식 취향에서 더 치명적인 차이는?",
        "optionA": "A. 매운맛/마라탕 극호 vs 완전 맵찔이",
        "optionB": "B. 맛집 줄 서기 즐기는 미식가 vs 배만 차면 아무거나형",
        "tag": "식성케미",
    },
    {
        "title": "🏠 [데이트 성향] 비 오는 날 최고의 데이트는?",
        "question": "창밖에 비가 주룩주룩 내릴 때 더 하고 싶은 것은?",
        "optionA": "A. 집에서 맛있는 배달음식 먹으며 넷플릭스 몰아보기",
        "optionB": "B. 감성 LP바나 창가 뷰 카페에서 빗소리 들으며 커피 한잔",
        "tag": "비오는날",
    },
    {
        "title": "✈️ [여행 스타일] 연인과 첫 해외여행 갈 때 나의 스타일은?",
        "question": "여행 계획 짤 때 나는 어느 쪽에 가깝나요?",
        "optionA": "A. 분 단위 엑셀 일정표 & 맛집 예약 필수 극 J",
        "optionB": "B. 항공권/숙소만 잡고 발길 닿는 대로 즐기는 즉흥 P",
        "tag": "여행스타일",
    },
]


def post_daily_balance_game(force=False):
    print("==================================================")
    print("🗳️ Running OOMU Daily Balance Game Poster...")
    print("==================================================")

    now = datetime.now(timezone(timedelta(hours=9)))  # KST
    today_str = now.strftime("%Y%m%d")
    post_id = f"balance_poll_{today_str}"

    # Check if today's balance game already exists
    if not force:
        existing = get_document("community_posts", post_id)
        if existing:
            print(f"[INFO] Today's balance poll already posted: '{existing.get('title')}'. Skipping.")
            return 0

    # Pick game based on day-of-year mod length
    day_of_year = now.timetuple().tm_yday
    game_idx = day_of_year % len(BALANCE_GAMES)
    game = BALANCE_GAMES[game_idx]

    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    content_text = (
        f"{game['question']}\n\n"
        f"1️⃣ {game['optionA']}\n"
        f"2️⃣ {game['optionB']}\n\n"
        f"💬 여러분의 선택과 그 이유는 무엇인가요? 댓글로 자유롭게 남겨주세요!"
    )

    post_payload = {
        "id": post_id,
        "category": "동네 토크",
        "tag": "밸런스게임",
        "title": game["title"],
        "content": content_text,
        "author": "오우무 에디터 💌",
        "authorAvatar": "assets/images/kr_female_1.jpg",
        "location": "서울 전체",
        "time": "오늘의 투표",
        "manner": 48.5,
        "likedUserIds": [],
        "likes": 0,
        "isLiked": False,
        "comments": 0,
        "pollOptions": [game["optionA"], game["optionB"]],
        "pollVotes": {"A": 0, "B": 0},
        "isPoll": True,
        "createdAt": now_iso,
        "relatedMeetup": {
            "title": f"{game['tag']} 토크 번개",
            "location": "서울 전체",
            "category": "일상 & 푸드 > 카페 & 디저트",
            "poster": "assets/images/cover_cafe.jpg",
        },
    }

    set_document("community_posts", post_id, post_payload, merge=True)
    print(f"✅ [SUCCESS] Posted Balance Game to community_posts/{post_id}:")
    print(f"   Title: {game['title']}")
    print(f"   Tag: #{game['tag']}")
    return 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OOMU Daily Balance Game")
    parser.add_argument("--force", action="store_true", help="Force post even if already exists")
    args = parser.parse_args()
    post_daily_balance_game(force=args.force)
