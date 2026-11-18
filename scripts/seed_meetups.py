#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Cold-Start Neighborhood Meetup Generator (Seed Personas - Round 7)
- Creates realistic, vibrant neighborhood meetups and interactive chat rooms in Firestore.
- Fixed document IDs (seed_{template_id}) to prevent duplicates.
- Strict 1:1 persona UID mapping with real accounts (test_user_01~03, bot_*).
- Explicit lat/lng coordinates for Seoul and Yeosu locations.
"""

import argparse
import random
import re
import sys
from datetime import datetime, timedelta, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import list_documents, set_document

# Authentic seed personas mapped 1:1 to real users documents
SEED_PERSONAS = [
    {
        "uid": "test_user_03",
        "host": "성수와인_지연",
        "avatar": "assets/images/지연.png",
        "manner": 43.8,
        "default_loc": "서울 성동구 성수동 카페거리",
    },
    {
        "uid": "bot_mangwon_runner",
        "host": "망원러너_지안",
        "avatar": "assets/images/지안.png",
        "manner": 46.5,
        "default_loc": "서울 마포구 망원한강공원",
    },
    {
        "uid": "test_user_02",
        "host": "연남러너_지훈",
        "avatar": "assets/images/지훈.png",
        "manner": 42.4,
        "default_loc": "서울 중구 을지로3가역",
    },
    {
        "uid": "test_user_01",
        "host": "망원치즈_민지",
        "avatar": "assets/images/민지.png",
        "manner": 44.2,
        "default_loc": "서울 마포구 연남동 경의선숲길",
    },
    {
        "uid": "minji",
        "host": "망원치즈_민지",
        "avatar": "assets/images/민지.png",
        "manner": 45.0,
        "default_loc": "서울 송파구 잠실한강공원",
    },
    {
        "uid": "bot_yeosu_bakery",
        "host": "여수빵순이_주아",
        "avatar": "assets/images/주아.png",
        "manner": 44.5,
        "default_loc": "전남 여수시 화장동 선소상가 카페거리",
    },
    {
        "uid": "bot_yeosu_running",
        "host": "성산러너_지훈",
        "avatar": "assets/images/지훈.png",
        "manner": 45.2,
        "default_loc": "전남 여수시 화장동 성산공원",
    },
    {
        "uid": "bot_yeosu_ungcheon",
        "host": "웅천피플_지안",
        "avatar": "assets/images/지안.png",
        "manner": 43.4,
        "default_loc": "전남 여수시 웅천동 해변문화공원",
    },
]

# High-engagement meetup templates with fixed persona mapping & verified lat/lng
MEETUP_TEMPLATES = [
    {
        "template_id": "seed_beer_friday",
        "persona_uid": "test_user_02",
        "title": "퇴근 후 가볍게 을지로 노포 & 수제 맥주 한잔",
        "desc": "한 주 동안 고생 많으셨습니다! 가볍게 을지로에서 시원한 생맥주와 먹태 먹으면서 소소하게 수다 떨어요. 과음X 편한 분위기!",
        "mainCategory": "일상 & 푸드",
        "category": "술 & 혼술바",
        "location": "서울 중구 을지로3가역 4번 출구",
        "lat": 37.5662,
        "lng": 126.9919,
        "vibe": "놀줄아는",
        "tags": ["퇴근길한잔", "을지로노포", "수제맥주", "소소한수다", "소셜다이닝"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "memberCount": "4명",
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
        "persona_uid": "bot_mangwon_runner",
        "title": "주말 아침 망원 한강공원 가벼운 5km 런닝 크루",
        "desc": "초보 러너도 대환영입니다! 6분 30초 페이스로 천천히 강바람 맞으며 뛰고, 끝나고 시원한 아아 한잔 마셔요.",
        "mainCategory": "문화 & 엔터",
        "category": "러닝 & 피트니스",
        "location": "서울 마포구 망원한강공원 입구",
        "lat": 37.5539,
        "lng": 126.8978,
        "vibe": "열정적인",
        "tags": ["한강러닝", "5km런", "오운완", "러닝크루", "건강한주말"],
        "imageUrl": "assets/images/cover_running.jpg",
        "memberCount": "4명",
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
        "persona_uid": "test_user_03",
        "title": "성수동 신상 에스프레소 바 & 감성 베이글 투어",
        "desc": "성수동 요즘 핫한 베이커리 카페 같이 갈 분 구해요! 사진도 서로 찍어주고 커피 향 즐기면서 여유로운 주말 보내요.",
        "mainCategory": "일상 & 푸드",
        "category": "카페 & 디저트",
        "location": "서울 성동구 성수역 3번 출구",
        "lat": 37.5445,
        "lng": 127.0560,
        "vibe": "소소하게",
        "tags": ["성수동카페", "베이글맛집", "감성카페", "주말힐링", "카페투어"],
        "imageUrl": "assets/images/cover_cafe.jpg",
        "memberCount": "4명",
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
        "persona_uid": "minji",
        "title": "주말 엽떡+마라탕+꿔바로우 털러 가실 파티원",
        "desc": "혼자서는 다 못 시키는 조합! 마라탕 매운맛 좋아하는 분들과 푸짐하게 시켜서 먹부림 부려봐요.",
        "mainCategory": "일상 & 푸드",
        "category": "동네 맛집 & 소셜 다이닝",
        "location": "서울 마포구 홍대입구역 9번 출구",
        "lat": 37.5575,
        "lng": 126.9244,
        "vibe": "소소하게",
        "tags": ["마라탕파티", "엽떡", "홍대맛집", "소셜다이닝", "먹스타그램"],
        "imageUrl": "assets/images/cover_food.jpg",
        "memberCount": "4명",
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
        "persona_uid": "test_user_01",
        "title": "강남역 보드게임 카페에서 스플렌더 & 카탄 한판",
        "desc": "룰 몰라도 친절하게 설명해 드립니다! 주말에 가볍게 머리 식히고 웃으면서 게임할 분들 환영해요.",
        "mainCategory": "문화 & 엔터",
        "category": "보드게임 & e스포츠",
        "location": "서울 강남구 강남역 11번 출구 레드버튼 앞",
        "lat": 37.4981,
        "lng": 127.0276,
        "vibe": "놀줄아는",
        "tags": ["보드게임", "스플렌더", "강남모임", "주말취미", "게임동호회"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "memberCount": "4명",
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
        "persona_uid": "test_user_02",
        "title": "불금 스트레스 확 날리는 코인노래방 메이트 구함",
        "desc": "혼코노도 좋지만 가끔은 신나게 같이 떼창하고 지를 사람! 음치박치 환영, 스트레스 해소가 목적입니다.",
        "mainCategory": "문화 & 엔터",
        "category": "음악 & 노래방",
        "location": "서울 마포구 합정역 3번 출구 수노래연습장",
        "lat": 37.5492,
        "lng": 126.9137,
        "vibe": "놀줄아는",
        "tags": ["코인노래방", "불금코노", "스트레스해소", "노래방메이트", "합정"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "memberCount": "4명",
        "genderLimit": "여성 전용",
        "ageLimit": "20대~30대",
        "price": "N빵",
        "transport": "각자 이동",
        "isFemaleOnly": True,
        "target_days": [3, 4],
        "date_str": "오늘 저녁 8시",
    },
    {
        "template_id": "seed_yeosu_bakery",
        "persona_uid": "bot_yeosu_bakery",
        "title": "선소상가 소금빵 오픈런 & 바다 뷰 베이커리 카페 투어",
        "desc": "선소상가에 새로 생긴 핫한 베이커리 카페 같이 가요! 여수 바다 보면서 소금빵에 아메리카노 한잔 어때요?",
        "mainCategory": "일상 & 푸드",
        "category": "카페 & 디저트",
        "location": "전남 여수시 학동 선소상가 맛집골목",
        "lat": 34.76211,
        "lng": 127.66199,
        "vibe": "소소하게",
        "tags": ["소금빵", "선소상가", "여수카페", "바다뷰", "디저트"],
        "imageUrl": "assets/images/cover_cafe.jpg",
        "memberCount": "4명",
        "genderLimit": "성별 무관",
        "ageLimit": "20대~30대",
        "price": "각자 결제",
        "transport": "각자 이동",
        "isFemaleOnly": False,
        "target_days": [4, 5, 6],
        "date_str": "이번주 토요일 오후 2시",
    },
    {
        "template_id": "seed_yeosu_running",
        "persona_uid": "bot_yeosu_running",
        "title": "화장동 성산공원 수변무대 가벼운 야간 런닝 크루",
        "desc": "성산공원 호수 둘레길 같이 뛰실 분 구해요! 천천히 4km 뛰고 벤치에서 스트레칭하며 수다 떨어요.",
        "mainCategory": "문화 & 엔터",
        "category": "러닝 & 피트니스",
        "location": "전남 여수시 화장동 성산공원 수변무대",
        "lat": 34.77442,
        "lng": 127.64586,
        "vibe": "열정적인",
        "tags": ["성산공원", "야간러닝", "오운완", "여수러닝", "둘레길"],
        "imageUrl": "assets/images/cover_running.jpg",
        "memberCount": "4명",
        "genderLimit": "성별 무관",
        "ageLimit": "20대~30대",
        "price": "무료",
        "transport": "수변무대 앞 집결",
        "isFemaleOnly": False,
        "target_days": [1, 2, 3, 4],
        "date_str": "평일 저녁 8시",
    },
    {
        "template_id": "seed_yeosu_ungcheon",
        "persona_uid": "bot_yeosu_ungcheon",
        "title": "웅천 해변문화공원 피크닉 & 힐링 산책",
        "desc": "웅천 바닷바람 맞으며 가볍게 산책하고 잔디밭에서 담소 나눠요. 편한 옷차림으로 오세요!",
        "mainCategory": "문화 & 엔터",
        "category": "산책 & 힐링",
        "location": "전남 여수시 웅천동 해변문화공원",
        "lat": 34.74676,
        "lng": 127.68092,
        "vibe": "힐링하는",
        "tags": ["웅천", "해변공원", "피크닉", "바다산책", "힐링"],
        "imageUrl": "assets/images/cover_running.jpg",
        "memberCount": "4명",
        "genderLimit": "성별 무관",
        "ageLimit": "20대~30대",
        "price": "무료",
        "transport": "해변공원 입구 집결",
        "isFemaleOnly": False,
        "target_days": [5, 6, 0],
        "date_str": "이번주 일요일 오후 4시",
    },
]


def seed_meetups_job(force=False, max_active=8):
    print("==================================================")
    print("🚀 Running OOMU Cold-Start Meetup Generator (Round 7)...")
    print("==================================================")

    now = datetime.now(timezone(timedelta(hours=9)))  # KST
    current_weekday = now.weekday()
    print(f"Current KST Time: {now.strftime('%Y-%m-%d %H:%M:%S')} (Weekday: {current_weekday})")

    existing_docs = list_documents("meetups", page_size=100)
    active_meetups = [d for d in existing_docs if d.get("status", "active") != "closed" and not d.get("isClosed", False)]
    print(f"Current Active Meetups in DB: {len(active_meetups)}")

    if len(active_meetups) >= max_active and not force:
        print(f"[INFO] Sufficient active meetups ({len(active_meetups)}>={max_active}). Skipping new seed generation.")
        return 0

    candidates = [t for t in MEETUP_TEMPLATES if current_weekday in t["target_days"]]
    if not candidates:
        candidates = MEETUP_TEMPLATES

    existing_templates = {d.get("templateId", "") for d in active_meetups}
    fresh_candidates = [c for c in candidates if c["template_id"] not in existing_templates]

    if not fresh_candidates:
        if force:
            fresh_candidates = candidates
        else:
            print("[INFO] All eligible template meetups are already active. No duplicates created.")
            return 0

    template = random.choice(fresh_candidates)
    target_persona_uid = template.get("persona_uid")
    persona = next((p for p in SEED_PERSONAS if p["uid"] == target_persona_uid), None)
    if not persona:
        persona = SEED_PERSONAS[0]

    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    doc_id = f"seed_{template['template_id']}"

    deadline_dt = now + timedelta(days=6)
    deadline_iso = deadline_dt.strftime("%Y-%m-%dT%H:%M:%SZ")

    raw_max_members = template.get("memberCount", "4명")
    parsed_max_members = int(re.sub(r"[^0-9]", "", raw_max_members) or 4)

    meetup_payload = {
        "title": template["title"],
        "description": template["desc"],
        "location": template["location"],
        "lat": template.get("lat"),
        "lng": template.get("lng"),
        "category": template["category"],
        "mainCategory": template["mainCategory"],
        "vibe": template["vibe"],
        "tags": template["tags"],
        "memberCount": template["memberCount"],
        "maxMembers": parsed_max_members,
        "genderLimit": template["genderLimit"],
        "ageLimit": template["ageLimit"],
        "host": persona["host"],
        "hostUid": persona["uid"],
        "hostAvatar": persona["avatar"],
        "imageUrl": template["imageUrl"],
        "photos": [template["imageUrl"]],
        "members": [persona["uid"]],
        "participantIds": [persona["uid"]],
        "memberAvatars": [persona["avatar"]],
        "deadline": deadline_iso,
        "deadlineLabel": "모집 마감 D-1",
        "closedByHost": False,
        "templateId": template["template_id"],
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

    try:
        set_document("meetups", doc_id, meetup_payload, merge=True)
        print(f"✅ [SUCCESS] Created Seed Meetup: '{template['title']}' (Host: {persona['host']}) [ID: {doc_id}]")
    except Exception as e:
        print(f"[ERROR] Failed to save seed meetup: {e}")
        return 0

    try:
        room_payload = {
            "id": doc_id,
            "meetupId": doc_id,
            "title": template["title"],
            "hostUid": persona["uid"],
            "lastMessage": f"안녕하세요! {persona['host']}입니다. {template['title']} 모임 대화방입니다. 참여를 환영해요! 🎉",
            "lastMessageTime": "방금",
            "time": "방금",
            "members": 1,
            "participants": [persona["uid"]],
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
    parser = argparse.ArgumentParser(description="OOMU Meetup Seeder (Round 7)")
    parser.add_argument("--force", action="store_true", help="Force generate even if threshold reached")
    args = parser.parse_args()
    seed_meetups_job(force=args.force)
