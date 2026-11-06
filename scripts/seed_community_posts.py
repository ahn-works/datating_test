#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Seed all Community Posts (Seoul & Yeosu) to Firestore
Enables real-time comment persistence and 1-like-per-user tracking.
"""

import sys
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import set_document

COMMUNITY_POSTS = [
    {
        "id": "post_yeosu_01",
        "category": "동네 토크",
        "tag": "산책로",
        "title": "여수 화장동 성산공원 수변 둘레길 야간 산책 같이 하실 분 계신가요?",
        "content": "성산공원 수변 산책로 저녁에 걸으면 호수 바람도 시원하고 야경도 참 예뻐요. 퇴근 후 가볍게 40분 정도 걷기 운동하실 동네 분들 댓글 남겨주세요!",
        "author": "우리동네_초연",
        "authorAvatar": "https://pub-2e97ef227fa24fa9ad20e502cfa19515.r2.dev/avatars/user_yeosu_01.jpg",
        "location": "전남 여수시 화장동",
        "time": "10분 전",
        "likes": 5,
        "comments": 2,
        "likedUserIds": ["test_user_01", "test_user_02"],
    },
    {
        "id": "post_yeosu_02",
        "category": "맛집/카페",
        "tag": "소금빵",
        "title": "선소상가 골목에 수제 소금빵 새로 나온 카페 가보신 분?",
        "content": "겉바속촉 버터향 가득한 소금빵 나오는 시간 맞춰서 가보려는데 대기 있는지 궁금해요. 다녀오신 분 후기 부탁드려요!",
        "author": "소금빵러버",
        "authorAvatar": "assets/images/시연.png",
        "location": "전남 여수시 학동",
        "time": "35분 전",
        "likes": 8,
        "comments": 3,
        "likedUserIds": ["test_user_03"],
    },
    {
        "id": "post_yeosu_03",
        "category": "동네 토크",
        "tag": "오션뷰",
        "title": "웅천친수공원 주말 노을 보면서 캔맥주 피크닉할 분!",
        "content": "웅천 해변 모래사장에 돗자리 펴고 바닷바람 쐬면서 가볍게 수다 떨어요. 취향 맞는 동네 친구들 환영합니다 ✨",
        "author": "노을사냥꾼",
        "authorAvatar": "assets/images/지훈.png",
        "location": "전남 여수시 웅천동",
        "time": "1시간 전",
        "likes": 12,
        "comments": 4,
        "likedUserIds": [],
    },
    {
        "id": "post_minseo_01",
        "category": "동네 토크",
        "tag": "산책메이트",
        "title": "오늘 저녁 연트럴파크 산책 메이트 구해요!",
        "content": "날씨도 선선한데 퇴근하고 가볍게 경의선숲길 걸으실 분 계실까요? 커피 테이크아웃해서 걷기만 해도 힐링될 것 같아요 😊",
        "author": "민서",
        "authorAvatar": "assets/images/민서.png",
        "location": "서울 마포구 연남동",
        "time": "15분 전",
        "likes": 4,
        "comments": 2,
        "likedUserIds": [],
    },
    {
        "id": "post_01",
        "category": "맛집/카페",
        "tag": "와인",
        "title": "성수동 아지트 비스트로 내추럴 와인 추천",
        "content": "조용하고 감성 넘치는 와인바 발견했어요. 글라스 와인 종류도 많고 음식 페어링도 훌륭합니다. 와인 좋아하시는 분들 꼭 가보세요!",
        "author": "지연",
        "authorAvatar": "assets/images/지연.png",
        "location": "서울 성동구 성수동",
        "time": "1시간 전",
        "likes": 9,
        "comments": 3,
        "likedUserIds": [],
    },
    {
        "id": "post_02",
        "category": "공연/전시",
        "tag": "전시",
        "title": "주말 성수 디뮤지엄 현대미술 전시 같이 갈 동행 찾아요",
        "content": "이번 주말 성수 디뮤지엄 전시 티켓이 2장 있는데 함께 관람하고 근처 카페에서 이야기 나눌 동행 구합니다!",
        "author": "도현",
        "authorAvatar": "assets/images/도현.png",
        "location": "서울 성동구 뚝섬로",
        "time": "2시간 전",
        "likes": 7,
        "comments": 1,
        "likedUserIds": [],
    },
    {
        "id": "post_03",
        "category": "동네 토크",
        "tag": "러닝",
        "title": "망원 한강공원 야간 러닝 5km 코스 추천",
        "content": "망원나들목에서 출발해서 양화대교 찍고 돌아오는 5km 코스가 조명도 밝고 야경도 정말 예쁩니다. 초보 러너분들도 부담없이 뛰기 좋아요!",
        "author": "지훈",
        "authorAvatar": "assets/images/지훈.png",
        "location": "서울 마포구 망원동",
        "time": "3시간 전",
        "likes": 15,
        "comments": 5,
        "likedUserIds": [],
    },
]

def main():
    print(f"Seeding {len(COMMUNITY_POSTS)} community posts to Firestore...")
    for p in COMMUNITY_POSTS:
        pid = p["id"]
        res = set_document("community_posts", pid, p, merge=True)
        print(f"  [OK] Seeded {pid}: {p['title'][:30]}...")
    print("All community posts seeded successfully.")

if __name__ == "__main__":
    main()
