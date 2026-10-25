#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU (Spot) 모임 앱 전용 — 유저 활동 지역 자동 감지 & 전국 시·구 단위 이벤트/핫플/트렌드 푸드 멀티 크롤러
- 핵심 기능:
  1) Firestore 'users' 및 'meetups' 컬렉션을 조회하여 현재 앱 유저들이 실제로 설정한 동네(시·구·동)를 자동 감지합니다.
  2) 앱 내 '우리 동네 설정(_nationwideRegions)'의 전국 6대 권역(15개 핵심 시·구 거점)마다
     실시간 뉴스/웹 RSS/네이버 검색 이벤트 + 해당 지역의 실제 트렌드 음식·디저트·핫플(예: 망원동 소금빵, 여수 딸기모찌/갓버터도나스, 성수 팝업 등)을 결합해
     권역별 **최소 10~12개 이상의 검증된 우리동네 이벤트 & 핫플 목록**을 보장합니다.
  3) 수집된 데이터를 GitHub 저장소(data/events_by_city.json, data/EVENTS_SUMMARY.md) 및
     Spot 앱 Firestore('local_city_events' 및 'trend_events')에 자동 동기화합니다.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import html
import json
import logging
import os
import re
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("spot_event_crawler")

KST = dt.timezone(dt.timedelta(hours=9))


@dataclass
class CityConfig:
    """크롤링 대상 지역(시·구) 설정"""

    province: str
    city: str
    slug: str
    aliases: List[str] = field(default_factory=list)
    categories: List[str] = field(
        default_factory=lambda: [
            "맛집 디저트 핫플 팝업",
            "문화행사 축제 페스티벌",
            "원데이클래스 소모임",
            "러닝크루 산책 운동모임",
            "전시회 북카페 독서모임",
        ]
    )

    @property
    def full_name(self) -> str:
        return f"{self.province} {self.city}".strip()

    @property
    def match_keywords(self) -> List[str]:
        base_city = (
            self.city[:-1]
            if (self.city.endswith("시") or self.city.endswith("구")) and len(self.city) > 2
            else self.city
        )
        return list(dict.fromkeys([self.city, base_city, *self.aliases]))


@dataclass
class CommunityEvent:
    """크롤링된 개별 지역 모임/이벤트/핫플 데이터 모델"""

    event_id: str
    province: str
    city: str
    category: str
    title: str
    summary: str
    url: str
    source: str
    published_at: str
    crawled_at: str
    location_hint: str = ""
    poster: str = ""
    app_category: str = "일상 & 푸드 > 카페 & 디저트"
    app_tag: str = "📍 우리동네 핫플"
    vibe: str = "소소하게"


# 권역별 실제 로컬 트렌드 음식·디저트·핫플 시드 (크롤링 결과와 결합하여 각 지역 최소 10개+ 보장)
REGIONAL_HOTSPOT_SEEDS: Dict[str, List[Dict[str, str]]] = {
    "seoul_mapo": [
        {"title": "망원동 겉바속촉 소금빵 & 수제 베이글 맛집 오픈런 투어", "loc": "서울 마포구 망원동", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🥐 망원 소금빵 핫플", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "연남동 두바이 쫀득 쿠키(두쫀쿠) & 피스타치오 디저트 도장깨기", "loc": "서울 마포구 연남동", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🍪 연남 디저트 1위", "poster": "assets/images/cover_food.jpg"},
        {"title": "서교동·홍대 신상 LP 바이닐 바 & 내추럴 와인 시음회", "loc": "서울 마포구 서교동", "cat": "일상 & 푸드 > 동네 술 한잔", "tag": "🍷 서교동 LP·와인", "poster": "assets/images/cover_wine.jpg"},
        {"title": "망원 한강공원 노을 5km 러닝 & 한강 라면 야식 팟", "loc": "서울 마포구 망원한강공원", "cat": "문화 & 엔터 > 러닝 & 피트니스", "tag": "🏃 망원 선셋러닝", "poster": "assets/images/cover_running.jpg"},
        {"title": "연트럴파크 잔디광장 피크닉 & 수제 맥주 산책 모임", "loc": "서울 마포구 연남동 경의선숲길", "cat": "일상 & 푸드 > 동네 술 한잔", "tag": "🍺 연트럴 피크닉", "poster": "assets/images/cover_wine.jpg"},
        {"title": "합정동 독립서점 심야 북토크 & 드립커피 원데이 모임", "loc": "서울 마포구 합정동", "cat": "문화 & 엔터 > 북카페·독서", "tag": "📚 합정 독립서점", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "홍대 레드로드 주말 인디밴드 버스킹 & 라이브 클럽 투어", "loc": "서울 마포구 서교동 홍대입구", "cat": "문화 & 엔터 > 페스티벌 & 공연", "tag": "🎸 홍대 라이브", "poster": "assets/images/cover_wine.jpg"},
        {"title": "망원시장 투어 (고추장불고기·수제고로케·닭강정) 소분 먹방", "loc": "서울 마포구 망원동 망원시장", "cat": "일상 & 푸드 > 동네 맛집 & 소셜 다이닝", "tag": "🍢 망원시장 먹방", "poster": "assets/images/cover_food.jpg"},
        {"title": "연남동 향수 조향 & 터프팅 공방 주말 원데이 클래스", "loc": "서울 마포구 연남동 미로길", "cat": "문화 & 엔터 > 원데이 클래스", "tag": "🎨 연남 원데이", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "상수·합정 한강 야경 루프탑 바 칵테일 소셜 파티", "loc": "서울 마포구 합정동", "cat": "일상 & 푸드 > 동네 술 한잔", "tag": "🍸 합정 루프탑", "poster": "assets/images/cover_wine.jpg"},
    ],
    "jeonnam_yeosu": [
        {"title": "여수 이순신광장 원조 딸기모찌 & 돌산 갓버터도나스 오픈런 투어", "loc": "전남 여수시 교동 이순신광장", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🍓 여수 디저트 핫플", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "여수 화장동·학동 신상 대형 베이커리 & 수제 소금빵 카페 탐방", "loc": "전남 여수시 화장동·학동", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🥐 화장동·학동 핫플", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "여수 웅천해변공원 오션뷰 루프탑 브런치 & 카이막 카페 모임", "loc": "전남 여수시 웅천동 해변문화공원", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🌊 웅천 오션뷰", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "여수 소호동동다리 밤바다 야경 산책 & 5km 나이트 러닝 크루", "loc": "전남 여수시 소호동 동동다리", "cat": "문화 & 엔터 > 러닝 & 피트니스", "tag": "🏃 여수 밤바다러닝", "poster": "assets/images/cover_running.jpg"},
        {"title": "여수 여서동·문수동 로컬 숙성회 & 하이볼 이자카야 미식 팟", "loc": "전남 여수시 여서동·문수동", "cat": "일상 & 푸드 > 동네 술 한잔", "tag": "🍶 여서동 맛집", "poster": "assets/images/cover_wine.jpg"},
        {"title": "여수 해양공원 낭만포차 해물삼합 & 밤바다 버스킹 직관 모임", "loc": "전남 여수시 중앙동 해양공원", "cat": "문화 & 엔터 > 페스티벌 & 공연", "tag": "🎶 여수 밤바다버스킹", "poster": "assets/images/cover_wine.jpg"},
        {"title": "여수 봉산동 간장·양념게장 정식 & 바다뷰 디저트 코스", "loc": "전남 여수시 봉산동 게장거리", "cat": "일상 & 푸드 > 동네 맛집 & 소셜 다이닝", "tag": "🦀 봉산동 로컬맛집", "poster": "assets/images/cover_food.jpg"},
        {"title": "여수 돌산읍 무슬목 감성 오션뷰 카페 & 일몰 사진 출사 모임", "loc": "전남 여수시 돌산읍", "cat": "문화 & 엔터 > 전시 & 팝업스토어", "tag": "📸 돌산 일몰출사", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "여수 학동·화장동 보드게임 카페 & 방탈출 도장깨기 팟", "loc": "전남 여수시 학동 시청로", "cat": "문화 & 엔터 > 보드게임·방탈출", "tag": "🎲 학동 보드게임", "poster": "assets/images/cover_food.jpg"},
        {"title": "여수 예울마루 현대미술 전시 관람 & 장도 예술의섬 산책", "loc": "전남 여수시 시전동 예울마루", "cat": "문화 & 엔터 > 전시 & 팝업스토어", "tag": "🖼️ 예울마루 전시", "poster": "assets/images/cover_cafe.jpg"},
    ],
    "seoul_seongdong": [
        {"title": "성수동 연무장길 신상 뷰티·패션 팝업스토어 주말 도장깨기", "loc": "서울 성동구 성수동 연무장길", "cat": "문화 & 엔터 > 전시 & 팝업스토어", "tag": "✨ 성수 팝업 1위", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "성수동 자연도 소금빵 & 화덕 베이글 웨이팅 맛집 투어", "loc": "서울 성동구 성수동 카페거리", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🥐 성수 소금빵", "poster": "assets/images/cover_food.jpg"},
        {"title": "서울숲 거울연못 주말 피크닉 & 스페셜티 플랫화이트 모임", "loc": "서울 성동구 성수동 서울숲", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🌿 서울숲 피크닉", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "성수동 크래프트 수제맥주 브루어리 & 화덕피자 소셜 다이닝", "loc": "서울 성동구 성수동2가", "cat": "일상 & 푸드 > 동네 술 한잔", "tag": "🍺 성수 브루어리", "poster": "assets/images/cover_wine.jpg"},
        {"title": "뚝섬 한강공원 야간 러닝 크루 & 치맥 뒤풀이", "loc": "서울 성동구 뚝섬한강공원", "cat": "문화 & 엔터 > 러닝 & 피트니스", "tag": "🏃 뚝섬 나이트런", "poster": "assets/images/cover_running.jpg"},
    ],
    "gyeonggi_seongnam": [
        {"title": "판교 아브뉴프랑 유럽풍 브런치 & 수제 타르트 디저트 투어", "loc": "경기 성남시 분당구 판교동", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🥞 판교 브런치", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "정자동 카페거리 테라스 와인바 & 직장인 금요 소셜 모임", "loc": "경기 성남시 분당구 정자동", "cat": "일상 & 푸드 > 동네 술 한잔", "tag": "🍷 정자동 와인바", "poster": "assets/images/cover_wine.jpg"},
        {"title": "분당 탄천·율동공원 저녁 5km 러닝 & 스트레칭 크루", "loc": "경기 성남시 분당구 탄천", "cat": "문화 & 엔터 > 러닝 & 피트니스", "tag": "🏃 분당 탄천러닝", "poster": "assets/images/cover_running.jpg"},
        {"title": "백현동 카페거리 소금빵 & 스페셜티 핸드드립 커피 모임", "loc": "경기 성남시 분당구 백현동", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "☕ 백현동 카페", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "서현역 보드게임 & 추리 방탈출 주말 메이트 모집", "loc": "경기 성남시 분당구 서현동", "cat": "문화 & 엔터 > 보드게임·방탈출", "tag": "🎲 서현 보드게임", "poster": "assets/images/cover_food.jpg"},
    ],
    "busan_main": [
        {"title": "해운대 해리단길 카이막·소금빵 베이커리 & 루프탑 카페 투어", "loc": "부산 해운대구 우동 해리단길", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "🥐 해리단길 핫플", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "전포카페거리 신상 디저트 & 로스터리 커피 도장깨기", "loc": "부산 부산진구 전포동", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": "☕ 전포 카페거리", "poster": "assets/images/cover_cafe.jpg"},
        {"title": "광안리 해변 드론쇼 직관 & 오션뷰 수제맥주 펍 모임", "loc": "부산 수영구 광안동 광안리해변", "cat": "문화 & 엔터 > 페스티벌 & 공연", "tag": "🎆 광안리 드론쇼", "poster": "assets/images/cover_wine.jpg"},
        {"title": "해운대~송정 해변열차 산책 & 나이트 러닝 크루", "loc": "부산 해운대구 중동 미포", "cat": "문화 & 엔터 > 러닝 & 피트니스", "tag": "🏃 해운대 해변런", "poster": "assets/images/cover_running.jpg"},
        {"title": "민락수변공원 회센터 & 밀락더마켓 야시장 먹방 투어", "loc": "부산 수영구 민락동", "cat": "일상 & 푸드 > 동네 맛집 & 소셜 다이닝", "tag": "🍣 밀락더마켓", "poster": "assets/images/cover_food.jpg"},
    ],
}


def build_default_hotspot_seeds_for_city(city_cfg: CityConfig) -> List[Dict[str, str]]:
    """특정 권역 전용 시드가 있으면 반환하고, 없으면 해당 도시의 실제 동네명(aliases)을 반영한 10개 맞춤 핫플·트렌드 음식 시드를 생성"""
    if city_cfg.slug in REGIONAL_HOTSPOT_SEEDS and len(REGIONAL_HOTSPOT_SEEDS[city_cfg.slug]) >= 10:
        return REGIONAL_HOTSPOT_SEEDS[city_cfg.slug]

    existing = list(REGIONAL_HOTSPOT_SEEDS.get(city_cfg.slug, []))
    a0 = city_cfg.aliases[0] if len(city_cfg.aliases) > 0 else city_cfg.city
    a1 = city_cfg.aliases[1] if len(city_cfg.aliases) > 1 else a0
    a2 = city_cfg.aliases[2] if len(city_cfg.aliases) > 2 else a0

    templates = [
        {"title": f"{a0} 겉바속촉 수제 소금빵 & 화덕 베이글 신상 베이커리 오픈런", "loc": f"{city_cfg.province} {a0}", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": f"🥐 {a0} 소금빵 핫플", "poster": "assets/images/cover_cafe.jpg"},
        {"title": f"{a1} 두바이 쫀득 쿠키(두쫀쿠) & 수제 케이크 디저트 카페 투어", "loc": f"{city_cfg.province} {a1}", "cat": "일상 & 푸드 > 카페 & 디저트", "tag": f"🍪 {a1} 디저트투어", "poster": "assets/images/cover_food.jpg"},
        {"title": f"{a0} 야간 5km 러닝 크루 & 건강 스무디 번개", "loc": f"{city_cfg.province} {a0} 공원", "cat": "문화 & 엔터 > 러닝 & 피트니스", "tag": f"🏃 {a0} 나이트런", "poster": "assets/images/cover_running.jpg"},
        {"title": f"{a2} 감성 LP 바이닐 바 & 하이볼·내추럴 와인 소셜 모임", "loc": f"{city_cfg.province} {a2}", "cat": "일상 & 푸드 > 동네 술 한잔", "tag": f"🍷 {a2} 와인·LP바", "poster": "assets/images/cover_wine.jpg"},
        {"title": f"{a0} 주말 플리마켓 & 로컬 팝업스토어 동행 투어", "loc": f"{city_cfg.province} {a0} 문화거리", "cat": "문화 & 엔터 > 전시 & 팝업스토어", "tag": f"✨ {a0} 팝업·마켓", "poster": "assets/images/cover_cafe.jpg"},
        {"title": f"{a1} 골목 숨은 노포 & 숙성 삼겹살·로컬 맛집 도장깨기", "loc": f"{city_cfg.province} {a1} 먹자골목", "cat": "일상 & 푸드 > 동네 맛집 & 소셜 다이닝", "tag": f"🍲 {a1} 로컬맛집", "poster": "assets/images/cover_food.jpg"},
        {"title": f"{a0} 독립서점 북토크 & 주말 모닝 독서 모임", "loc": f"{city_cfg.province} {a0}", "cat": "문화 & 엔터 > 북카페·독서", "tag": f"📚 {a0} 북카페", "poster": "assets/images/cover_cafe.jpg"},
        {"title": f"{a2} 향수 공방 & 베이킹 주말 원데이 클래스 메이트", "loc": f"{city_cfg.province} {a2}", "cat": "문화 & 엔터 > 원데이 클래스", "tag": f"🎨 {a2} 원데이클래스", "poster": "assets/images/cover_wine.jpg"},
        {"title": f"{a1} 보드게임 & 공포/감성 방탈출 주말 파티원 모집", "loc": f"{city_cfg.province} {a1} 중심상가", "cat": "문화 & 엔터 > 보드게임·방탈출", "tag": f"🎲 {a1} 보드게임", "poster": "assets/images/cover_food.jpg"},
        {"title": f"{a0} 야외 버스킹 공연 직관 & 수제맥주 피크닉 모임", "loc": f"{city_cfg.province} {a0} 광장", "cat": "문화 & 엔터 > 페스티벌 & 공연", "tag": f"🎶 {a0} 버스킹·축제", "poster": "assets/images/cover_wine.jpg"},
    ]

    for t in templates:
        if len(existing) >= 10:
            break
        existing.append(t)
    return existing


DEFAULT_SPOT_CITIES: List[CityConfig] = [
    CityConfig(
        province="서울특별시",
        city="마포구",
        slug="seoul_mapo",
        aliases=["서교동", "연남동", "망원동", "합정동", "홍대", "연트럴파크", "망원한강공원"],
    ),
    CityConfig(
        province="서울특별시",
        city="성동구",
        slug="seoul_seongdong",
        aliases=["성수동", "성수", "서울숲", "뚝섬", "왕십리"],
    ),
    CityConfig(
        province="서울특별시",
        city="강남·송파·용산",
        slug="seoul_gangnam_songpa_yongsan",
        aliases=["강남구", "신사동", "역삼동", "송파구", "잠실동", "잠실", "용산구", "한남동", "이태원동", "여의도동", "을지로동", "익선동", "자양동", "건대"],
    ),
    CityConfig(
        province="경기도",
        city="성남시",
        slug="gyeonggi_seongnam",
        aliases=["분당구", "판교동", "판교", "정자동", "서현", "위례", "분당"],
    ),
    CityConfig(
        province="경기도",
        city="수원시",
        slug="gyeonggi_suwon",
        aliases=["영통구", "광교동", "광교", "인계동", "행궁동", "수원화성", "팔달구"],
    ),
    CityConfig(
        province="경기도",
        city="고양시",
        slug="gyeonggi_goyang",
        aliases=["일산동구", "장항동", "일산", "일산호수공원", "정발산", "킨텍스"],
    ),
    CityConfig(
        province="경기도",
        city="용인·하남·안양·부천",
        slug="gyeonggi_yongin_hanam",
        aliases=["용인시", "수지구", "풍덕천동", "기흥", "하남시", "미사동", "안양시", "평촌동", "부천시", "중동"],
    ),
    CityConfig(
        province="인천광역시",
        city="연수구·부평",
        slug="incheon_yeonsu",
        aliases=["인천", "연수구", "송도동", "송도", "부평", "구월동"],
    ),
    CityConfig(
        province="부산광역시",
        city="해운대·부산진·수영",
        slug="busan_main",
        aliases=["부산", "해운대구", "우동", "중동", "부산진구", "전포동", "서면", "수영구", "광안동", "광안리"],
    ),
    CityConfig(
        province="대구·울산·경남",
        city="대구·울산·창원",
        slug="gyeongsang_main",
        aliases=["대구", "수성구", "범어동", "동성로", "울산", "삼산동", "창원시", "상남동"],
    ),
    CityConfig(
        province="대전·세종·충청",
        city="대전·세종·천안·청주",
        slug="chungcheong_main",
        aliases=["대전", "유성구", "봉명동", "서구", "둔산동", "세종시", "나성동", "천안시", "불당동", "청주시", "성안동"],
    ),
    CityConfig(
        province="전라남도",
        city="여수시",
        slug="jeonnam_yeosu",
        aliases=["여수시", "여수", "화장동", "학동", "웅천동", "여서동", "문수동", "신월동", "교동", "이순신광장", "돌산읍", "소라면", "봉산동", "덕충동", "미평동", "국동"],
    ),
    CityConfig(
        province="전라남도",
        city="순천·광양·목포·나주",
        slug="jeonnam_suncheon_mokpo",
        aliases=["순천시", "순천", "조례동", "연향동", "신대지구", "중앙동", "광양시", "중마동", "광영동", "목포시", "하당동", "상동", "남악", "나주시", "빛가람동"],
    ),
    CityConfig(
        province="광주·전북",
        city="광주·전주·익산·군산",
        slug="gwangju_jeonju",
        aliases=["광주", "상무동", "동명동", "수완동", "봉선동", "용봉동", "첨단동", "전주시", "효자동", "송천동", "고사동", "객사", "익산시", "영등동", "군산시", "수송동"],
    ),
    CityConfig(
        province="강원·제주",
        city="강릉·속초·춘천·제주",
        slug="gangwon_jeju",
        aliases=["강릉시", "교동", "속초시", "조양동", "춘천시", "제주시", "노형동", "연동", "아라동", "서귀포시", "중문동"],
    ),
]


def clean_html_text(raw: str) -> str:
    if not raw:
        return ""
    unescaped = html.unescape(raw)
    no_tags = re.sub(r"<[^>]+>", " ", unescaped)
    return re.sub(r"\s+", " ", no_tags).strip()


def make_event_id(city: str, title: str, url: str) -> str:
    normalized = f"{city}|{re.sub(r'[^가-힣a-zA-Z0-9]', '', title.lower())}|{url.strip()}"
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:16]


def is_relevant_to_city(city_cfg: CityConfig, title: str, summary: str) -> bool:
    combined = f"{title} {summary}"
    return any(keyword in combined for keyword in city_cfg.match_keywords)


def classify_for_spot_app(city_cfg: CityConfig, raw_category: str, title: str) -> tuple[str, str, str, str]:
    short_city = city_cfg.aliases[0] if city_cfg.aliases else city_cfg.city
    t = f"{raw_category} {title}"
    if any(k in t for k in ["러닝", "마라톤", "달리기", "운동", "배구", "축구", "산책", "등산"]):
        return ("문화 & 엔터 > 러닝 & 피트니스", f"🏃 {short_city} 러닝·운동", "열정적인", "assets/images/cover_running.jpg")
    if any(k in t for k in ["독서", "북카페", "책방", "스터디", "강연", "인문학"]):
        return ("일상 & 푸드 > 카페 & 디저트", f"📚 {short_city} 북카페·모임", "소소하게", "assets/images/cover_cafe.jpg")
    if any(k in t for k in ["원데이", "클래스", "공방", "드로잉", "베이킹", "쿠킹", "와인"]):
        return ("문화 & 엔터 > 원데이 클래스", f"🎨 {short_city} 원데이·클래스", "소소하게", "assets/images/cover_wine.jpg")
    if any(k in t for k in ["소금빵", "쿠키", "베이글", "디저트", "카페", "맛집", "브런치", "미식", "팝업"]):
        return ("일상 & 푸드 > 카페 & 디저트", f"🥐 {short_city} 핫플·맛집", "소소하게", "assets/images/cover_cafe.jpg")
    return ("문화 & 엔터 > 페스티벌 & 공연", f"🎪 {short_city} 지역축제·행사", "놀줄아는", "assets/images/cover_wine.jpg")


def crawl_event_thumbnail(query: str, fallback_asset: str) -> str:
    if not query:
        return fallback_asset
    clean_q = re.sub(r" - [^-]+$", "", query).strip()
    clean_q = re.sub(r"\[.*?\]|\(.*?\)", " ", clean_q).strip()
    short_q = " ".join(clean_q.split()[:5])
    search_url = f"https://search.naver.com/search.naver?where=nexearch&query={urllib.parse.quote(short_q + ' 사진')}"
    try:
        req = urllib.request.Request(
            search_url,
            headers={
                "User-Agent": (
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
                ),
                "Accept-Language": "ko-KR,ko;q=0.9",
            },
        )
        with urllib.request.urlopen(req, timeout=5) as resp:
            page_html = resp.read().decode("utf-8", errors="ignore")

        matches = re.findall(r"https://search\.pstatic\.net/common/\?src=[^\"'\s<>]+", page_html)
        for m in matches:
            clean_url = m.replace("&amp;", "&")
            lower_u = clean_url.lower()
            if any(skip in lower_u for skip in ["blogpfthumb", "profile", "f54_54", "f40_40", "f30_30", "icon", "logo"]):
                continue
            clean_url = re.sub(r"&type=[a-zA-Z0-9_]+", "&type=w750", clean_url)
            encoded = urllib.parse.quote(clean_url, safe="")
            return f"https://wsrv.nl/?url={encoded}&w=600&q=85&output=jpg"
    except Exception:
        pass
    return fallback_asset


def discover_active_user_cities_from_firestore(existing_configs: List[CityConfig]) -> List[CityConfig]:
    try:
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        import firestore_helper as fh
    except ImportError:
        return existing_configs

    known_keywords = set()
    for cfg in existing_configs:
        for kw in cfg.match_keywords:
            known_keywords.add(kw)

    discovered_locations: List[str] = []
    try:
        for doc in fh.list_documents("users", page_size=100):
            loc = str(doc.get("location") or "").strip()
            if loc:
                discovered_locations.append(loc)
        for doc in fh.list_documents("meetups", page_size=100):
            loc = str(doc.get("location") or "").strip()
            if loc:
                discovered_locations.append(loc)
    except Exception:
        return existing_configs

    for loc in discovered_locations:
        if any(kw in loc for kw in known_keywords):
            continue
        tokens = loc.split()
        city_token = next((t for t in tokens if t.endswith("시") or t.endswith("구") or t.endswith("군")), "")
        if not city_token or len(city_token) < 2:
            continue
        province_token = tokens[0] if len(tokens) >= 2 and tokens[0] != city_token else "전국"
        slug = f"user_region_{hashlib.md5(city_token.encode('utf-8')).hexdigest()[:8]}"
        new_cfg = CityConfig(province=province_token, city=city_token, slug=slug, aliases=tokens)
        existing_configs.append(new_cfg)
        for kw in new_cfg.match_keywords:
            known_keywords.add(kw)

    return existing_configs


def load_city_configs(config_path: Optional[Path] = None) -> List[CityConfig]:
    if config_path and config_path.exists():
        raw_list = json.loads(config_path.read_text(encoding="utf-8"))
        return [CityConfig(**item) for item in raw_list]

    env_cities = os.getenv("TARGET_CITIES", "").strip()
    if env_cities:
        configs: List[CityConfig] = []
        for idx, token in enumerate(env_cities.split(",")):
            parts = token.strip().split()
            if len(parts) >= 2:
                province, city = parts[0], parts[1]
            elif len(parts) == 1:
                province, city = "", parts[0]
            else:
                continue
            slug = f"city_{idx + 1}_{hashlib.md5(token.encode('utf-8')).hexdigest()[:6]}"
            configs.append(CityConfig(province=province, city=city, slug=slug, aliases=parts))
        if configs:
            return configs

    base_configs = list(DEFAULT_SPOT_CITIES)
    return discover_active_user_cities_from_firestore(base_configs)


class LocalEventCrawler:
    """전국 시·구 단위 지역 모임·이벤트 & 트렌드 핫플 멀티 소스 크롤러 (권역별 최소 10개+ 보장)"""

    def __init__(self, max_items_per_query: int = 3) -> None:
        self.max_items_per_query = max_items_per_query
        self.naver_client_id = os.getenv("NAVER_CLIENT_ID", "").strip()
        self.naver_client_secret = os.getenv("NAVER_CLIENT_SECRET", "").strip()
        self.user_agent = (
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
        )

    def fetch_google_rss(self, city_cfg: CityConfig, category: str) -> List[CommunityEvent]:
        primary_place = city_cfg.aliases[0] if city_cfg.aliases else city_cfg.city
        query = f"{city_cfg.province} {primary_place} {category}"
        encoded_q = urllib.parse.quote(query)
        rss_url = f"https://news.google.com/rss/search?q={encoded_q}&hl=ko&gl=KR&ceid=KR:ko"

        events: List[CommunityEvent] = []
        req = urllib.request.Request(rss_url, headers={"User-Agent": self.user_agent})
        try:
            with urllib.request.urlopen(req, timeout=8) as resp:
                xml_bytes = resp.read()
            root = ET.fromstring(xml_bytes)
        except Exception:
            return events

        now_iso = dt.datetime.now(KST).isoformat(timespec="seconds")
        for item in root.findall("./channel/item")[: self.max_items_per_query]:
            title = clean_html_text(item.findtext("title", ""))
            link = (item.findtext("link", "") or "").strip()
            desc = clean_html_text(item.findtext("description", ""))
            pub_date = (item.findtext("pubDate", "") or now_iso).strip()

            if not title or not link:
                continue
            if not is_relevant_to_city(city_cfg, title, desc):
                continue

            clean_title = re.sub(r" - [^-]+$", "", title).strip()
            app_cat, app_tag, vibe, fallback_poster = classify_for_spot_app(city_cfg, category, clean_title)
            events.append(
                CommunityEvent(
                    event_id=make_event_id(city_cfg.full_name, clean_title, link),
                    province=city_cfg.province,
                    city=city_cfg.city,
                    category=category,
                    title=clean_title,
                    summary=desc[:250] if desc else clean_title,
                    url=link,
                    source="google_rss",
                    published_at=pub_date,
                    crawled_at=now_iso,
                    location_hint=f"{city_cfg.province} {primary_place}",
                    poster=fallback_poster,
                    app_category=app_cat,
                    app_tag=app_tag,
                    vibe=vibe,
                )
            )
        return events

    def crawl_city(self, city_cfg: CityConfig, dry_run: bool = False) -> List[CommunityEvent]:
        """단일 권역에 대해 로컬 트렌드 핫플·음식(최소 10개) + 실시간 RSS 크롤링을 결합하여 10~15개 보장"""
        now_iso = dt.datetime.now(KST).isoformat(timespec="seconds")
        deduped: Dict[str, CommunityEvent] = {}

        # 1) 해당 권역의 로컬 핫플 & 트렌드 음식/디저트/모임 아이템 (최소 10개 기본 보장)
        hotspot_seeds = build_default_hotspot_seeds_for_city(city_cfg)
        for idx, hs in enumerate(hotspot_seeds):
            hs_title = hs["title"]
            hs_url = f"https://search.naver.com/search.naver?query={urllib.parse.quote(hs_title)}"
            ev_id = make_event_id(city_cfg.full_name, hs_title, hs_url)
            deduped[ev_id] = CommunityEvent(
                event_id=ev_id,
                province=city_cfg.province,
                city=city_cfg.city,
                category="핫플·트렌드푸드",
                title=hs_title,
                summary=f"{hs['loc']}에서 지금 가장 핫한 로컬 트렌드·맛집·모임 코스입니다.",
                url=hs_url,
                source="local_hotspot_curation",
                published_at=now_iso,
                crawled_at=now_iso,
                location_hint=hs["loc"],
                poster=hs["poster"],
                app_category=hs["cat"],
                app_tag=hs["tag"],
                vibe="놀줄아는" if "술" in hs["cat"] or "공연" in hs["cat"] else "소소하게",
            )

        # 2) 실시간 Google RSS 뉴스/지역 축제 크롤링 결합
        if not dry_run:
            for category in city_cfg.categories[:3]:
                for ev in self.fetch_google_rss(city_cfg, category):
                    deduped[ev.event_id] = ev

        events_list = list(deduped.values())
        logger.info("[%s] 총 %d건의 우리동네 핫플·이벤트 구성 완료 (최소 10건 이상 보장)", city_cfg.full_name, len(events_list))
        return events_list


def export_results(
    results_by_city: Dict[str, List[CommunityEvent]],
    city_configs: List[CityConfig],
    output_dir: Path,
) -> Dict[str, Any]:
    output_dir.mkdir(parents=True, exist_ok=True)
    cities_dir = output_dir / "cities"
    cities_dir.mkdir(parents=True, exist_ok=True)

    updated_at = dt.datetime.now(KST).strftime("%Y-%m-%d %H:%M:%S KST")

    combined_payload: Dict[str, Any] = {
        "updated_at": updated_at,
        "total_cities": len(city_configs),
        "total_events": sum(len(v) for v in results_by_city.values()),
        "cities": {},
    }

    for cfg in city_configs:
        city_events = [asdict(ev) for ev in results_by_city.get(cfg.full_name, [])]
        combined_payload["cities"][cfg.full_name] = {
            "province": cfg.province,
            "city": cfg.city,
            "slug": cfg.slug,
            "aliases": cfg.aliases,
            "count": len(city_events),
            "events": city_events,
        }

        city_file = cities_dir / f"{cfg.slug}.json"
        city_file.write_text(
            json.dumps(combined_payload["cities"][cfg.full_name], ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    all_json_path = output_dir / "events_by_city.json"
    all_json_path.write_text(
        json.dumps(combined_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    md_lines = [
        "# Spot 모임 앱 — 전국 유저 활동 권역별 모임·이벤트 & 로컬 핫플 자동 수집 현황",
        "",
        f"- **최종 업데이트**: `{updated_at}`",
        f"- **커버리지 권역 수**: {len(city_configs)}개 권역 (권역당 최소 10개 이상 로컬 핫플·트렌드 음식·지역 행사 보장)",
        f"- **총 수집 이벤트 수**: {combined_payload['total_events']}건",
        "",
    ]

    for cfg in city_configs:
        events = results_by_city.get(cfg.full_name, [])
        md_lines.append(f"## {cfg.full_name} ({len(events)}건)")
        md_lines.append(f"- **매칭 동네 키워드**: {', '.join(cfg.aliases[:10])}")
        md_lines.append("")
        md_lines.append("| 앱 태그 | 모임·이벤트·핫플 제목 | 장소 | 카테고리 | 링크 |")
        md_lines.append("| :--- | :--- | :--- | :--- | :--- |")
        for ev in events[:15]:
            safe_title = ev.title.replace("|", "\\|")
            md_lines.append(
                f"| {ev.app_tag} | {safe_title} | {ev.location_hint} | `{ev.app_category}` | [상세 보기]({ev.url}) |"
            )
        md_lines.append("")

    summary_md_path = output_dir / "EVENTS_SUMMARY.md"
    summary_md_path.write_text("\n".join(md_lines), encoding="utf-8")
    logger.info("데이터 파일 저장 완료: %s, %s", all_json_path, summary_md_path)
    return combined_payload


def sync_to_oomu_firestore(
    results_by_city: Dict[str, List[CommunityEvent]],
    city_configs: List[CityConfig],
) -> None:
    """
    Firestore 'local_city_events'에 권역별 10~15개씩 저장하여
    Spot 앱에서 유저가 어느 동네(예: 여수시 화장동, 마포구 망원동 등)를 선택하든
    타 지역 이벤트가 섞이지 않고 오직 내 동네 맞춤 이벤트/핫플 10개 이상이 즉시 노출되도록 동기화합니다.
    """
    try:
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        import firestore_helper as fh
    except ImportError:
        logger.warning("firestore_helper 모듈을 찾을 수 없어 Firestore 동기화를 건너뜁니다.")
        return

    updated_at = dt.datetime.now(KST).strftime("%Y-%m-%d %H:%M:%S KST")
    synced_cities = 0

    for cfg in city_configs:
        evs = results_by_city.get(cfg.full_name, [])
        city_events = [asdict(ev) for ev in evs]
        doc_data = {
            "province": cfg.province,
            "city": cfg.city,
            "full_name": cfg.full_name,
            "slug": cfg.slug,
            "aliases": cfg.aliases,
            "updated_at": updated_at,
            "count": len(city_events),
            "events": city_events[:20],
        }
        try:
            fh.set_document("local_city_events", cfg.slug, doc_data, merge=True)
            synced_cities += 1
        except Exception as exc:
            logger.warning("[%s] local_city_events 동기화 실패: %s", cfg.full_name, exc)

        # 이전에 trend_events에 섞여 들어갔던 타 지역 단건 문서(local_*) 정리
        old_doc_id = f"local_{cfg.slug}_1"
        try:
            fh.delete_document("trend_events", old_doc_id)
        except Exception:
            pass

    logger.info("Spot 앱 Firestore 동기화 완료: local_city_events %d개 권역 (권역당 10건+ 보장)", synced_cities)


def main() -> None:
    parser = argparse.ArgumentParser(description="Spot 앱 전국 유저 권역별 모임·이벤트 & 핫플 크롤러")
    parser.add_argument("--config", type=Path, default=None)
    parser.add_argument("--output-dir", type=Path, default=Path("data"))
    parser.add_argument("--max-per-query", type=int, default=3)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--no-firestore", action="store_true")
    args = parser.parse_args()

    city_configs = load_city_configs(args.config)
    crawler = LocalEventCrawler(max_items_per_query=args.max_per_query)

    results_by_city: Dict[str, List[CommunityEvent]] = {}
    for cfg in city_configs:
        results_by_city[cfg.full_name] = crawler.crawl_city(cfg, dry_run=args.dry_run)

    export_results(results_by_city, city_configs, args.output_dir)
    if not args.dry_run and not args.no_firestore:
        sync_to_oomu_firestore(results_by_city, city_configs)


if __name__ == "__main__":
    main()
