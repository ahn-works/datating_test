#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Update and enrich all Firestore meetups with accurate tags, description, mainCategory, lat, lng.
Ensures zero empty results for '오늘 번개', '취향 아지트', '라이프 메이트', and '공연·핫플'.
"""

import sys
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import set_document, list_documents

UPDATES = {
    # 1. Yeosu Dining & Social
    "IVGd4HF7kv2DLZV4zbNF": {
        "title": "여수 학동 선소상가 찐맛집 털기 & 2:2 캐주얼 소셜 다이닝 🥘",
        "location": "전남 여수시 학동 선소상가 맛집골목",
        "lat": 35.1540,
        "lng": 127.6530,
        "mainCategory": "일상 & 푸드",
        "category": "동네 맛집 & 소셜 다이닝",
        "tags": ["선소상가", "맛집", "소셜다이닝", "핫플", "동네맛집", "캐주얼", "취향 아지트", "공연·핫플"],
        "description": "학동 선소상가 맛집골목에서 맛있는 저녁 먹으며 편하게 수다 떨어요! 2030 동네 친구 환영합니다.",
        "date": "이번 주 금요일 7시",
    },
    # 2. Yeosu Lightning Karaoke & Highball
    "OGfy1UAuJPmhK71HFDAE": {
        "title": "불금엔 화장동 무선상가 코노 & 시원한 하이볼 한잔 🎤",
        "location": "전남 여수시 화장동 무선지구 상가",
        "lat": 35.1610,
        "lng": 127.6580,
        "mainCategory": "문화 & 엔터",
        "category": "오늘 번개",
        "tags": ["오늘 번개", "오늘번개", "번개", "하이볼", "코노", "노래방", "무선상가", "불금"],
        "description": "퇴근 후 무선상가에서 시원하게 하이볼 한잔하고 코노에서 스트레스 풀어요! 당일 번개 모임입니다.",
        "isLightning": True,
        "date": "오늘 저녁 8시",
    },
    # 3. Yeosu Woongcheon Picnic
    "Z2V8YmyZmFIrdTNaypfU": {
        "title": "여수 웅천친수공원 바다 캔맥주 소셜 피크닉 & 수다 🍺",
        "location": "전남 여수시 웅천동 해변문화공원",
        "lat": 35.1480,
        "lng": 127.6620,
        "mainCategory": "문화 & 엔터",
        "category": "취향 아지트",
        "tags": ["취향 아지트", "공연·핫플", "핫플", "바다", "피크닉", "캔맥주", "웅천친수공원", "소셜", "야경"],
        "description": "웅천 바다 노을을 바라보며 시원한 캔맥주 피크닉 즐겨요. 바닷바람 쐬면서 가볍게 힐링해요!",
        "date": "이번 주말 6시",
    },
    # 4. Yeosu Running Mate
    "mYoRcZWVFXU6K6FK11cd": {
        "title": "화장동 성산공원 둘레길 가벼운 저녁 5km 런닝 크루 🏃‍♀️",
        "location": "전남 여수시 화장동 성산공원 수변무대",
        "lat": 35.1630,
        "lng": 127.6540,
        "mainCategory": "액티비티 & 스포츠",
        "category": "라이프 메이트",
        "tags": ["라이프 메이트", "러닝·운동", "운동", "러닝", "런닝", "동네산책", "성산공원", "둘레길", "메이트", "헬스"],
        "description": "성산공원 호수 둘레길 따라 천천히 5km 페이스 6분대로 달립니다. 초보 러너도 대환영!",
        "date": "오늘 저녁 8시반",
    },
    # 5. Yeosu Cafe & Salt Bread
    "mnAlUav42KVAtnaXULBw": {
        "title": "주말 여수 화장동 수제 소금빵 & 감성 베이커리 카페 오픈런 🥐",
        "location": "전남 여수시 화장동 선소상가 카페거리",
        "lat": 35.1590,
        "lng": 127.6560,
        "mainCategory": "체험 & 취미",
        "category": "취향 아지트",
        "tags": ["취향 아지트", "카페·디저트", "베이커리", "소금빵", "카페", "디저트", "아지트", "오픈런", "커피"],
        "description": "화장동에 새로 생긴 감성 베이커리에서 갓 구운 소금빵과 스페셜티 커피 함께 즐겨요!",
        "date": "이번 주 토요일 11시",
    },
    # 6. Seoul Seongsu Natural Wine
    "meetup_seongsu_wine_01": {
        "title": "성수동 아지트 비스트로 내추럴 와인 & 소셜 토크 🍷",
        "location": "서울 성동구 성수동 카페거리",
        "lat": 37.5445,
        "lng": 127.0560,
        "mainCategory": "체험 & 취미",
        "category": "취향 아지트",
        "tags": ["취향 아지트", "와인", "소셜", "아지트", "성수", "핫플", "내추럴와인", "소셜토크", "공연·핫플"],
        "description": "성수동 골목 숨은 아지트 비스트로에서 편안하게 글라스 와인 마시며 이야기 나눠요.",
        "date": "이번 주 금요일 7시반",
    },
    # 7. Seoul Mangwon Running
    "seed_seed_running_weekend_1031": {
        "title": "주말 아침 망원 한강공원 가벼운 5km 런닝 크루 🏃",
        "location": "서울 마포구 망원한강공원 입구",
        "lat": 37.5520,
        "lng": 126.8960,
        "mainCategory": "액티비티 & 스포츠",
        "category": "라이프 메이트",
        "tags": ["라이프 메이트", "러닝·운동", "운동", "러닝", "런닝", "한강", "망원", "메이트", "동네산책"],
        "description": "주말 상쾌한 아침 공기 마시며 망원 한강공원 가볍게 뛰어요!",
        "date": "이번 주 토요일 아침 9시",
    },
    # 8. Yeosu Boardgame Azit
    "meetup_yeosu_azit_boardgame": {
        "title": "여수 학동 보드게임 & 방탈출 취향 아지트 모임 🎲",
        "location": "전남 여수시 학동 선소상가",
        "lat": 35.1550,
        "lng": 127.6520,
        "mainCategory": "게임 & 오락",
        "category": "취향 아지트",
        "tags": ["취향 아지트", "보드게임·방탈출", "보드게임", "방탈출", "게임", "아지트"],
        "description": "스플렌더, 카탄 등 입문용 보드게임부터 전략 게임까지 편하게 즐겨요!",
        "host": "보드게임장인",
        "hostAvatar": "assets/images/정재.png",
        "hostUid": "test_user_02",
        "mannerTemp": 44.5,
        "currentMembers": 2,
        "maxMembers": 4,
        "members": "2/4",
        "date": "이번 주 토요일 4시",
        "status": "recruiting",
    },
    # 9. Seoul Hongdae Lightning
    "meetup_seoul_lightning_hongdae": {
        "title": "홍대입구 9번출구 불금 회식 & 코노 즉석 번개 🎤",
        "location": "서울 마포구 홍대입구역 9번 출구",
        "lat": 37.5568,
        "lng": 126.9238,
        "mainCategory": "문화 & 엔터",
        "category": "오늘 번개",
        "tags": ["오늘 번개", "오늘번개", "번개", "홍대", "코노", "하이볼", "불금"],
        "description": "홍대 9번출구에서 모여 가볍게 1차 치맥하고 코노에서 불금 달려요!",
        "isLightning": True,
        "host": "홍대힙스터",
        "hostAvatar": "assets/images/도현.png",
        "hostUid": "test_user_01",
        "mannerTemp": 43.0,
        "currentMembers": 2,
        "maxMembers": 4,
        "members": "2/4",
        "date": "오늘 저녁 7시반",
        "status": "recruiting",
    },
}

def main():
    print(f"Updating {len(UPDATES)} meetups in Firestore...")
    for doc_id, data in UPDATES.items():
        res = set_document("meetups", doc_id, data, merge=True)
        print(f"  [OK] Updated {doc_id}: {data['title'][:30]}...")
    print("All meetups successfully updated with rich tags and coordinates.")

if __name__ == "__main__":
    main()
