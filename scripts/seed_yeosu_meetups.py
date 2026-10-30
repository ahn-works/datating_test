# -*- coding: utf-8 -*-
import sys
import os
from datetime import datetime, timezone

sys.path.append(os.path.join(os.path.dirname(__file__)))
from firestore_helper import create_document, list_documents

sys.stdout.reconfigure(encoding='utf-8')

YEOSU_MEETUPS = [
    {
        "title": "주말 여수 화장동 수제 소금빵 & 감성 베이커리 카페 오픈런 🥐",
        "desc": "선소상가 뒤쪽에 새로 생긴 유기농 쌀 소금빵집 오픈런 같이 가실 분! 겉바속촉 빵 털고 2차로 루프탑 카페에서 수다 떨어요 :)",
        "mainCategory": "일상 & 푸드",
        "category": "카페 & 디저트",
        "location": "전남 여수시 화장동 선소상가 카페거리",
        "vibe": "소소하게",
        "tags": ["화장동카페", "소금빵오픈런", "여수디저트", "소소하게", "동네친구"],
        "imageUrl": "assets/images/cover_cafe.jpg",
        "members": "2/4",
        "manner": 42.5,
        "host": "여수빵순이",
        "hostAvatar": "assets/images/kr_female_1.jpg",
        "price": "1/N 안심 정산",
        "transport": "화장동 선소상가 앞 집결",
        "isFemaleOnly": True,
        "date": "이번 주 일요일 오전 11:00",
        "createdAt": datetime.now(timezone.utc),
    },
    {
        "title": "화장동 성산공원 둘레길 가벼운 저녁 5km 런닝 크루 🏃‍♀️",
        "desc": "초보 러너 대환영! 성산공원 호수 둘레길 따라 6분 페이스로 가볍게 달리고 시원한 음료 한잔 마셔요. 오운완 함께해요!",
        "mainCategory": "문화 & 엔터",
        "category": "러닝 & 운동",
        "location": "전남 여수시 화장동 성산공원 수변무대",
        "vibe": "열정적인",
        "tags": ["성산공원", "화장동러닝", "오운완", "둘레길산책", "건강한주말"],
        "imageUrl": "assets/images/cover_running.jpg",
        "members": "3/4",
        "manner": 45.2,
        "host": "성산러너_민우",
        "hostAvatar": "assets/images/kr_male_1.jpg",
        "price": "무료 참여",
        "transport": "성산공원 입구 집결",
        "isFemaleOnly": False,
        "date": "오늘 저녁 7:30",
        "isLightning": True,
        "createdAt": datetime.now(timezone.utc),
    },
    {
        "title": "불금엔 화장동 무선상가 코노 & 시원한 하이볼 한잔 🎤",
        "desc": "한 주 스트레스 코노에서 노래 부르고 하이볼 한잔으로 싹 날려버려요! 과음 없이 편안하고 재밌게 놀 파티원 구합니다.",
        "mainCategory": "문화 & 엔터",
        "category": "불금코노·술",
        "location": "전남 여수시 화장동 무선지구 상가",
        "vibe": "놀줄아는",
        "tags": ["화장동코노", "불금번개", "노래방메이트", "소소한수다", "동네친구"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "members": "2/4",
        "manner": 41.8,
        "host": "화장동코노퀸",
        "hostAvatar": "assets/images/kr_female_2.jpg",
        "price": "1/N 안심 정산",
        "transport": "무선 롯데마트 부근 집결",
        "isFemaleOnly": True,
        "date": "오늘 밤 8:30",
        "isLightning": True,
        "createdAt": datetime.now(timezone.utc),
    },
    {
        "title": "여수 웅천친수공원 바다 캔맥주 소셜 피크닉 & 수다 🍺",
        "desc": "웅천 친수공원 잔디마당에서 바다 노을 보면서 캔맥주 마셔요! 돗자리 챙겨가니 편하게 몸만 오시면 됩니다.",
        "mainCategory": "일상 & 푸드",
        "category": "혼술바동행",
        "location": "전남 여수시 웅천동 해변문화공원",
        "vibe": "소소하게",
        "tags": ["웅천바다", "캔맥주번개", "오션뷰피크닉", "여수노을", "자만추"],
        "imageUrl": "assets/images/cover_wine.jpg",
        "members": "3/4",
        "manner": 43.4,
        "host": "웅천피플_준",
        "hostAvatar": "assets/images/kr_male_2.jpg",
        "price": "1/N 안심 정산",
        "transport": "웅천 친수공원 잔디마당",
        "isFemaleOnly": False,
        "date": "이번 주 토요일 저녁 7:00",
        "createdAt": datetime.now(timezone.utc),
    },
    {
        "title": "여수 학동 선소상가 찐맛집 털기 & 2:2 캐주얼 소셜 다이닝 🥘",
        "desc": "현지인들만 아는 선소 찐 맛집에서 맛있는 저녁 먹고 분위기 좋은 2차 가요! 직장인 2030 동네 찐친 환영합니다.",
        "mainCategory": "일상 & 푸드",
        "category": "맛집털기",
        "location": "전남 여수시 학동 선소상가 맛집골목",
        "vibe": "놀줄아는",
        "tags": ["선소맛집", "2:2미팅", "소셜다이닝", "자만추", "여수친구"],
        "imageUrl": "assets/images/cover_food.jpg",
        "members": "2/4",
        "manner": 44.1,
        "host": "선소미식가",
        "hostAvatar": "assets/images/kr_female_3.jpg",
        "price": "1/N 안심 정산",
        "transport": "학동 선소상가 입구",
        "isFemaleOnly": False,
        "date": "이번 주 금요일 저녁 7:30",
        "createdAt": datetime.now(timezone.utc),
    },
]

print("Seeding Yeosu meetups into Firestore...")
for m in YEOSU_MEETUPS:
    doc = create_document("meetups", m)
    print(f"Created: {m['title']} -> ID: {doc.get('id', 'ok')}")

print("\n[SUCCESS] Yeosu meetups successfully seeded into Firestore!")
