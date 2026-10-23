#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Cold-Start Neighborhood Meetup Generator (Seed Personas - Option B)
- Creates realistic, vibrant neighborhood meetups and interactive chat rooms in Firestore.
- Solves the cold-start problem so new users never land on an empty screen.
- Seeds have realistic Korean personas, diverse interests, and authentic timing.
"""

import argparse
import random
import sys
from datetime import datetime, timedelta, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import create_document, list_documents, set_document

# Authentic seed personas
SEED_PERSONAS = [
    {
        "host": "성수동힙스터",
        "avatar": "assets/images/kr_female_1.jpg",
        "manner": 43.8,
        "default_loc": "서울 성동구 성수동 카페거리",
    },
    {
        "host": "망원러너_민우",
        "avatar": "assets/images/kr_male_1.jpg",
        "manner": 46.5,
        "default_loc": "서울 마포구 망원한강공원",
    },
    {
        "host": "퇴근후맥주_준",
        "avatar": "assets/images/kr_male_2.jpg",
        "manner": 42.4,
        "default_loc": "서울 중구 을지로3가역",
    },
    {
        "host": "디저트탐험대",
        "avatar": "assets/images/kr_female_2.jpg",
        "manner": 44.2,
        "default_loc": "서울 마포구 연남동 경의선숲길",
    },
    {
        "host": "보드게임장인",
        "avatar": "assets/images/kr_male_3.jpg",
        "manner": 47.1,
        "default_loc": "서울 강남구 강남역 11번 출구",
    },
    {
        "host": "주말캠퍼_지은",
        "avatar": "assets/images/kr_female_3.jpg",
        "manner": 45.0,
        "default_loc": "서울 송파구 잠실한강공원",
    },
    {
        "host": "코노마스터_수빈",
        "avatar": "assets/images/kr_female_4.jpg",
        "manner": 41.8,
        "default_loc": "서울 마포구 합정역 부근",
    },
]

# High-engagement meetup templates
MEETUP_TEMPLATES = [
    {
        "template_id": "seed_beer_friday",
        "title": "퇴근 후 가볍게 을지로 노포 & 수제 맥주 한잔 🍺",
        "desc": "한 주 동안 고생 많으셨습니다! 가볍게 을지로에서 시원한 생맥주와 먹태 먹으면서 소소하게 수다 떨어요. 과음X 편한 분위기!",
        "mainCategory": "일상 & 푸드",
        "category": "술 & 혼술바",
        "location": "서울 중구 을지로3가역 4번 출구",
        "vibe": "놀줄아는",
        "tags": ["퇴근길한잔", "을지로노포", "수제맥주", "소소한수다", "소셜다이닝"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "memberCount": "4명",
        "members": "2/4",
        "genderLimit": "성별 무관",
        "ageLimit": "20대~30대",
        "price": "N빵",
        "transport": "각자 이동",
        "isFemaleOnly": False,
        "target_days": [2, 3, 4],  # Wed, Thu, Fri
        "date_str": "이번주 금요일 저녁 7시 30분",
    },
    {
        "template_id": "seed_running_weekend",
        "title": "주말 아침 망원 한강공원 가벼운 5km 런닝 크루 🏃",
        "desc": "초보 러너도 대환영입니다! 6분 30초 페이스로 천천히 강바람 맞으며 뛰고, 끝나고 시원한 아아 한잔 마셔요.",
        "mainCategory": "문화 & 엔터",
        "category": "러닝 & 피트니스",
        "location": "서울 마포구 망원한강공원 입구",
        "vibe": "열정적인",
        "tags": ["한강러닝", "5km런", "오운완", "러닝크루", "건강한주말"],
        "imageUrl": "assets/images/cover_running.jpg",
        "memberCount": "4명",
        "members": "3/4",
        "genderLimit": "성별 무관",
        "ageLimit": "20대~30대",
        "price": "무료",
        "transport": "망원역 집결 후 이동",
        "isFemaleOnly": False,
        "target_days": [4, 5, 6],  # Fri, Sat, Sun
        "date_str": "이번주 일요일 오전 9시",
    },
    {
        "template_id": "seed_cafe_seongsu",
        "title": "성수동 신상 에스프레소 바 & 감성 베이글 투어 ☕🥯",
        "desc": "성수동 요즘 핫한 베이커리 카페 같이 갈 분 구해요! 사진도 서로 찍어주고 커피 향 즐기면서 여유로운 주말 보내요.",
        "mainCategory": "일상 & 푸드",
        "category": "카페 & 디저트",
        "location": "서울 성동구 성수역 3번 출구",
        "vibe": "소소하게",
        "tags": ["성수동카페", "베이글맛집", "감성카페", "주말힐링", "카페투어"],
        "imageUrl": "assets/images/cover_cafe.jpg",
        "memberCount": "4명",
        "members": "2/4",
        "genderLimit": "성별 무관",
        "ageLimit": "20대~30대",
        "price": "각자 결제",
        "transport": "성수역 집결",
        "isFemaleOnly": False,
        "target_days": [3, 4, 5],  # Thu, Fri, Sat
        "date_str": "이번주 토요일 오후 2시",
    },
    {
        "template_id": "seed_food_malatang",
        "title": "주말 엽떡+마라탕+꿔바로우 털러 가실 파티원 🔥",
        "desc": "혼자서는 다 못 시키는 조합! 마라탕 매운맛 좋아하는 분들과 푸짐하게 시켜서 먹부림 부려봐요 😋",
        "mainCategory": "일상 & 푸드",
        "category": "동네 맛집 & 소셜 다이닝",
        "location": "서울 마포구 홍대입구역 9번 출구",
        "vibe": "소소하게",
        "tags": ["마라탕파티", "엽떡", "홍대맛집", "소셜다이닝", "먹스타그램"],
        "imageUrl": "assets/images/cover_food.jpg",
        "memberCount": "4명",
        "members": "2/4",
        "genderLimit": "여성 전용",
        "ageLimit": "20대~30대",
        "price": "N빵",
        "transport": "각자 이동",
        "isFemaleOnly": True,
        "target_days": [3, 4, 5],
        "date_str": "이번주 토요일 저녁 6시",
    },
    {
        "template_id": "seed_boardgame_gangnam",
        "title": "강남역 보드게임 카페에서 스플렌더 & 카탄 한판 🎲",
        "desc": "룰 몰라도 친절하게 설명해 드립니다! 주말에 가볍게 머리 식히고 웃으면서 게임할 분들 환영해요.",
        "mainCategory": "문화 & 엔터",
        "category": "보드게임 & e스포츠",
        "location": "서울 강남구 강남역 11번 출구 레드버튼 앞",
        "vibe": "놀줄아는",
        "tags": ["보드게임", "스플렌더", "강남모임", "주말취미", "게임동호회"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "memberCount": "4명",
        "members": "2/4",
        "genderLimit": "성별 무관",
        "ageLimit": "20대~30대",
        "price": "이용료 각자",
        "transport": "강남역 집결",
        "isFemaleOnly": False,
        "target_days": [5, 6, 0],
        "date_str": "이번주 일요일 오후 3시",
    },
    {
        "template_id": "seed_kpop_karaoke",
        "title": "불금 스트레스 확 날리는 코인노래방 메이트 구함 🎤",
        "desc": "혼코노도 좋지만 가끔은 신나게 같이 떼창하고 지를 사람! 음치박치 환영, 스트레스 해소가 목적입니다 😆",
        "mainCategory": "문화 & 엔터",
        "category": "음악 & 노래방",
        "location": "서울 마포구 합정역 3번 출구 수노래연습장",
        "vibe": "놀줄아는",
        "tags": ["코인노래방", "불금코노", "스트레스해소", "노래방메이트", "합정"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "memberCount": "4명",
        "members": "2/4",
        "genderLimit": "여성 전용",
        "ageLimit": "20대~30대",
        "price": "N빵",
        "transport": "각자 이동",
        "isFemaleOnly": True,
        "target_days": [3, 4],
        "date_str": "오늘 저녁 8시",
    },
]


def seed_meetups_job(force=False, max_active=6):
    print("==================================================")
    print("🚀 Running OOMU Cold-Start Meetup Generator...")
    print("==================================================")

    now = datetime.now(timezone(timedelta(hours=9)))  # KST
    current_weekday = now.weekday()  # Mon=0, Tue=1, Wed=2, Thu=3, Fri=4, Sat=5, Sun=6
    print(f"Current KST Time: {now.strftime('%Y-%m-%d %H:%M:%S')} (Weekday: {current_weekday})")

    existing_docs = list_documents("meetups", page_size=100)
    active_meetups = [d for d in existing_docs if d.get("status", "active") != "closed" and not d.get("isClosed", False)]
    print(f"Current Active Meetups in DB: {len(active_meetups)}")

    if len(active_meetups) >= max_active and not force:
        print(f"[INFO] Sufficient active meetups ({len(active_meetups)}>={max_active}). Skipping new seed generation.")
        return 0

    # Filter templates matching today or general
    candidates = [t for t in MEETUP_TEMPLATES if current_weekday in t["target_days"]]
    if not candidates:
        candidates = MEETUP_TEMPLATES

    # Choose a template that isn't already active by title
    existing_titles = {d.get("title", "") for d in active_meetups}
    fresh_candidates = [c for c in candidates if c["title"] not in existing_titles]

    if not fresh_candidates:
        if force:
            fresh_candidates = candidates
        else:
            print("[INFO] All eligible template meetups are already active. No duplicates created.")
            return 0

    template = random.choice(fresh_candidates)
    persona = random.choice(SEED_PERSONAS)

    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    doc_id = f"seed_{template['template_id']}_{now.strftime('%m%d')}"

    meetup_payload = {
        "title": template["title"],
        "description": template["desc"],
        "location": template["location"],
        "category": template["category"],
        "mainCategory": template["mainCategory"],
        "vibe": template["vibe"],
        "tags": template["tags"],
        "memberCount": template["memberCount"],
        "genderLimit": template["genderLimit"],
        "ageLimit": template["ageLimit"],
        "host": persona["host"],
        "hostAvatar": persona["avatar"],
        "imageUrl": template["imageUrl"],
        "photos": [template["imageUrl"]],
        "members": template["members"],
        "manner": persona["manner"],
        "price": template["price"],
        "transport": template["transport"],
        "isFemaleOnly": template["isFemaleOnly"],
        "date": template["date_str"],
        "createdAt": now_iso,
        "isSeed": True,
        "status": "active",
        "isClosed": False,
    }

    # Save to meetups
    saved_doc = set_document("meetups", doc_id, meetup_payload, merge=True)
    print(f"✅ [SUCCESS] Created Seed Meetup: '{template['title']}' (Host: {persona['host']}) [ID: {doc_id}]")

    # Initialize associated chat room
    try:
        room_payload = {
            "id": doc_id,
            "title": template["title"],
            "lastMessage": f"안녕하세요! {persona['host']}입니다. {template['title']} 모임 대화방입니다. 참여를 환영해요! 🎉",
            "lastMessageTime": "방금",
            "time": "방금",
            "members": 2,
            "imageUrl": template["imageUrl"],
            "isGroup": True,
            "updatedAt": now_iso,
            "isSeed": True,
        }
        set_document("chatRooms", doc_id, room_payload, merge=True)
        print(f"💬 [SUCCESS] Initialized Chat Room: chatRooms/{doc_id}")
    except Exception as e:
        print(f"[WARN] Chat room init warning: {e}")

    return 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OOMU Meetup Seeder")
    parser.add_argument("--force", action="store_true", help="Force generate even if threshold reached")
    args = parser.parse_args()
    seed_meetups_job(force=args.force)
