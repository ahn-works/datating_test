#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU (Spot) 모임 앱 전용 — 유저 활동 지역 자동 감지 & 전국 시·구 단위 모임/이벤트 멀티 크롤러
- 핵심 기능:
  1) Firestore 'users' 및 'meetups' 컬렉션을 조회하여 현재 앱 유저들이 실제로 설정한 동네(시·구·동)를 자동 감지해 크롤링 대상에 추가합니다.
  2) 앱 내 '우리 동네 설정(_nationwideRegions)'의 전국 6대 권역(서울, 경기/인천, 부산/경상, 대전/충청, 광주/전라, 강원/제주) 주요 거점 도시를 기본 커버합니다.
  3) Google 뉴스/웹 RSS + 네이버 검색 API + 실시간 웹 썸네일 크롤러를 통해 각 지역의 축제·문화행사·소모임·원데이클래스·러닝크루 이벤트를 수집합니다.
  4) 수집된 이벤트를 GitHub 저장소(data/events_by_city.json, data/EVENTS_SUMMARY.md)에 저장할 뿐만 아니라,
     Spot 모임 앱 화면에 즉시 노출되도록 Firestore 'trend_events' 및 'local_city_events' 컬렉션에 포스터 이미지와 함께 자동 동기화합니다.
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

# Windows 터미널 UTF-8 출력 보장
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

    province: str          # 권역/광역자치단체 (예: 서울특별시, 경기도, 전라남도, 부산광역시)
    city: str              # 시·구 명칭 (예: 마포구, 성동구, 성남시, 여수시, 해운대구)
    slug: str              # 파일/DB 저장용 영문 슬러그
    aliases: List[str] = field(default_factory=list)  # 주요 동네/핫플 키워드 (앱 내 _nationwideRegions 연동)
    categories: List[str] = field(
        default_factory=lambda: [
            "문화행사 축제 페스티벌",
            "원데이클래스 소모임",
            "러닝크루 동호회",
            "전시회 팝업스토어 핫플",
            "청년 커뮤니티 모임",
        ]
    )

    @property
    def full_name(self) -> str:
        return f"{self.province} {self.city}".strip()

    @property
    def match_keywords(self) -> List[str]:
        base_city = self.city[:-1] if (self.city.endswith("시") or self.city.endswith("구")) and len(self.city) > 2 else self.city
        return list(dict.fromkeys([self.city, base_city, *self.aliases]))


@dataclass
class CommunityEvent:
    """크롤링된 개별 지역 모임/이벤트 데이터 모델 (Spot 앱 호환 필드 포함)"""

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
    app_category: str = "문화 & 엔터 > 페스티벌 & 공연"
    app_tag: str = "📍 우리동네 행사"
    vibe: str = "놀줄아는"


# Spot 모임 앱(_nationwideRegions)의 전국 6대 권역 주요 유저 거점 리스트
DEFAULT_SPOT_CITIES: List[CityConfig] = [
    # 1. 서울권 (앱 기본 진입 및 최대 밀집 권역)
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
        aliases=["강남구", "신사동", "역삼동", "송파구", "잠실동", "잠실", "용산구", "한남동", "이태원동", "여의도동", "을지로", "익선동", "건대"],
    ),
    # 2. 경기 / 인천권
    CityConfig(
        province="경기도",
        city="성남시",
        slug="gyeonggi_seongnam",
        aliases=["분당", "판교", "판교동", "정자동", "서현", "위례", "분당구"],
    ),
    CityConfig(
        province="경기도",
        city="수원시",
        slug="gyeonggi_suwon",
        aliases=["영통", "광교", "광교동", "인계동", "행궁동", "수원화성", "팔달구"],
    ),
    CityConfig(
        province="경기도",
        city="고양시",
        slug="gyeonggi_goyang",
        aliases=["일산", "일산동구", "장항동", "일산호수공원", "정발산", "킨텍스"],
    ),
    CityConfig(
        province="경기도",
        city="용인·하남·안양",
        slug="gyeonggi_yongin_hanam",
        aliases=["용인시", "수지구", "풍덕천동", "기흥", "하남시", "미사동", "안양시", "평촌동", "부천시"],
    ),
    CityConfig(
        province="인천광역시",
        city="연수구·부평",
        slug="incheon_yeonsu",
        aliases=["인천", "송도", "송도동", "연수구", "부평", "구월동"],
    ),
    # 3. 부산 / 경상권
    CityConfig(
        province="부산광역시",
        city="해운대·부산진·수영",
        slug="busan_main",
        aliases=["부산", "해운대", "해운대구", "우동", "전포동", "서면", "광안리", "광안동", "수영구"],
    ),
    CityConfig(
        province="대구·울산·경남",
        city="대구·울산·창원",
        slug="gyeongsang_main",
        aliases=["대구", "수성구", "범어동", "동성로", "울산", "삼산동", "창원시", "상남동"],
    ),
    # 4. 대전 / 충청권
    CityConfig(
        province="대전·세종·충청",
        city="대전·세종·천안·청주",
        slug="chungcheong_main",
        aliases=["대전", "유성구", "봉명동", "둔산동", "세종시", "나성동", "천안시", "불당동", "청주시", "성안동"],
    ),
    # 5. 광주 / 전라권 (여수·순천·광양·목포·전주·광주)
    CityConfig(
        province="전라남도",
        city="여수시",
        slug="jeonnam_yeosu",
        aliases=["여수", "학동", "웅천동", "웅천", "여서동", "문수동", "이순신광장", "돌산읍", "교동"],
    ),
    CityConfig(
        province="전라남도",
        city="순천·광양·목포",
        slug="jeonnam_suncheon_mokpo",
        aliases=["순천시", "순천", "조례동", "신대지구", "연향동", "광양시", "중마동", "목포시", "하당동", "평화광장", "나주시", "빛가람동"],
    ),
    CityConfig(
        province="광주·전북",
        city="광주·전주시",
        slug="gwangju_jeonju",
        aliases=["광주", "상무동", "동명동", "수완동", "봉선동", "전주시", "전주", "효자동", "송천동", "객사", "익산시", "군산시"],
    ),
    # 6. 강원 / 제주권
    CityConfig(
        province="강원·제주",
        city="강릉·춘천·제주시",
        slug="gangwon_jeju",
        aliases=["강릉시", "강릉", "춘천시", "춘천", "속초시", "제주시", "제주", "노형동", "연동", "서귀포시", "중문동"],
    ),
]


def clean_html_text(raw: str) -> str:
    """HTML 태그 및 불필요한 공백 제거"""
    if not raw:
        return ""
    unescaped = html.unescape(raw)
    no_tags = re.sub(r"<[^>]+>", " ", unescaped)
    return re.sub(r"\s+", " ", no_tags).strip()


def make_event_id(city: str, title: str, url: str) -> str:
    """중복 방지를 위한 고유 해시 ID 생성"""
    normalized = f"{city}|{re.sub(r'[^가-힣a-zA-Z0-9]', '', title.lower())}|{url.strip()}"
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()[:16]


def is_relevant_to_city(city_cfg: CityConfig, title: str, summary: str) -> bool:
    """수집된 게시글이 해당 지역 또는 주요 생활권과 실제로 관련 있는지 검증"""
    combined = f"{title} {summary}"
    return any(keyword in combined for keyword in city_cfg.match_keywords)


def classify_for_spot_app(city_cfg: CityConfig, raw_category: str, title: str) -> tuple[str, str, str, str]:
    """
    크롤링된 이벤트를 Spot 앱의 카테고리/태그/바이브/기본 커버 이미지로 매핑
    반환: (app_category, app_tag, vibe, fallback_poster)
    """
    short_city = city_cfg.aliases[0] if city_cfg.aliases else city_cfg.city
    t = f"{raw_category} {title}"
    if any(k in t for k in ["러닝", "마라톤", "달리기", "운동", "배구", "축구", "산책", "등산"]):
        return (
            "문화 & 엔터 > 러닝 & 피트니스",
            f"🏃 {short_city} 러닝·운동",
            "열정적인",
            "assets/images/cover_running.jpg",
        )
    if any(k in t for k in ["독서", "북카페", "책방", "스터디", "강연", "인문학"]):
        return (
            "일상 & 푸드 > 카페 & 디저트",
            f"📚 {short_city} 북카페·모임",
            "소소하게",
            "assets/images/cover_cafe.jpg",
        )
    if any(k in t for k in ["원데이", "클래스", "공방", "드로잉", "베이킹", "쿠킹", "와인"]):
        return (
            "문화 & 엔터 > 원데이 클래스",
            f"🎨 {short_city} 원데이·클래스",
            "소소하게",
            "assets/images/cover_wine.jpg",
        )
    if any(k in t for k in ["팝업", "전시", "미술관", "박람회", "플리마켓", "야장", "미식", "맛집"]):
        return (
            "문화 & 엔터 > 전시 & 팝업스토어",
            f"✨ {short_city} 핫플·팝업",
            "놀줄아는",
            "assets/images/cover_food.jpg",
        )
    return (
        "문화 & 엔터 > 페스티벌 & 공연",
        f"🎪 {short_city} 지역축제·행사",
        "놀줄아는",
        "assets/images/cover_wine.jpg",
    )


def crawl_event_thumbnail(query: str, fallback_asset: str) -> str:
    """네이버 검색에서 이벤트 대표 썸네일/포스터 이미지를 추출하고 CORS-safe HTTPS URL로 변환"""
    if not query:
        return fallback_asset
    clean_q = re.sub(r" - [^-]+$", "", query).strip()
    clean_q = re.sub(r"\[.*?\]|\(.*?\)", " ", clean_q).strip()
    short_q = " ".join(clean_q.split()[:5])
    search_url = f"https://search.naver.com/search.naver?where=nexearch&query={urllib.parse.quote(short_q + ' 포스터 행사')}"
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
        with urllib.request.urlopen(req, timeout=6) as resp:
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
    """
    Firestore 'users' 및 'meetups' 컬렉션에서 실제 유저들이 설정한 동네(location)를 읽어와
    기본 권역에 없는 새로운 시·구가 있으면 자동으로 크롤링 대상에 추가합니다.
    """
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
    except Exception as exc:
        logger.warning("Firestore 유저 지역 조회 중 경고 (기본 전국 권역으로 진행): %s", exc)
        return existing_configs

    added = 0
    for loc in discovered_locations:
        if any(kw in loc for kw in known_keywords):
            continue
        # 예: "충청북도 충주시 연수동" 또는 "포항시 북구" 등에서 시/구 추출
        tokens = loc.split()
        city_token = next((t for t in tokens if t.endswith("시") or t.endswith("구") or t.endswith("군")), "")
        if not city_token or len(city_token) < 2:
            continue
        province_token = tokens[0] if len(tokens) >= 2 and tokens[0] != city_token else "전국"
        slug = f"user_region_{hashlib.md5(city_token.encode('utf-8')).hexdigest()[:8]}"
        new_cfg = CityConfig(
            province=province_token,
            city=city_token,
            slug=slug,
            aliases=tokens,
        )
        existing_configs.append(new_cfg)
        for kw in new_cfg.match_keywords:
            known_keywords.add(kw)
        added += 1

    if added > 0:
        logger.info("Firestore 활성 유저 거주지 기반 신규 지역 %d곳 자동 추가 완료", added)
    return existing_configs


def load_city_configs(config_path: Optional[Path] = None) -> List[CityConfig]:
    """외부 설정 파일, 환경변수(TARGET_CITIES), 또는 Spot 앱 전국 권역 + Firestore 활성 유저 지역 로드"""
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
    """전국 시·구 단위 지역 모임 및 이벤트 멀티 소스 크롤러"""

    def __init__(self, max_items_per_query: int = 3) -> None:
        self.max_items_per_query = max_items_per_query
        self.naver_client_id = os.getenv("NAVER_CLIENT_ID", "").strip()
        self.naver_client_secret = os.getenv("NAVER_CLIENT_SECRET", "").strip()
        self.user_agent = (
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
        )

    def fetch_google_rss(self, city_cfg: CityConfig, category: str) -> List[CommunityEvent]:
        """Google 뉴스/웹 RSS를 통해 해당 지역의 모임·행사 정보 수집 (무설치/무키 기본 동작)"""
        primary_place = city_cfg.aliases[0] if city_cfg.aliases else city_cfg.city
        query = f"{city_cfg.province} {primary_place} {category}"
        encoded_q = urllib.parse.quote(query)
        rss_url = f"https://news.google.com/rss/search?q={encoded_q}&hl=ko&gl=KR&ceid=KR:ko"

        events: List[CommunityEvent] = []
        req = urllib.request.Request(rss_url, headers={"User-Agent": self.user_agent})
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                xml_bytes = resp.read()
        except Exception as exc:
            logger.warning("[%s] Google RSS 요청 실패 (%s): %s", city_cfg.full_name, category, exc)
            return events

        try:
            root = ET.fromstring(xml_bytes)
        except ET.ParseError as exc:
            logger.warning("[%s] RSS XML 파싱 오류: %s", city_cfg.full_name, exc)
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

            app_cat, app_tag, vibe, fallback_poster = classify_for_spot_app(city_cfg, category, title)
            events.append(
                CommunityEvent(
                    event_id=make_event_id(city_cfg.full_name, title, link),
                    province=city_cfg.province,
                    city=city_cfg.city,
                    category=category,
                    title=title,
                    summary=desc[:250] if desc else title,
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

    def fetch_naver_search(
        self,
        city_cfg: CityConfig,
        category: str,
        search_type: str = "cafearticle",
    ) -> List[CommunityEvent]:
        """네이버 오픈 API(카페글/블로그/뉴스)를 통해 동네 소모임·동호회 모집글 수집"""
        if not (self.naver_client_id and self.naver_client_secret):
            return []

        primary_place = city_cfg.aliases[0] if city_cfg.aliases else city_cfg.city
        query = urllib.parse.quote(f"{city_cfg.province} {primary_place} {category}")
        api_url = (
            f"https://openapi.naver.com/v1/search/{search_type}.json"
            f"?query={query}&display={self.max_items_per_query}&sort=date"
        )
        req = urllib.request.Request(
            api_url,
            headers={
                "X-Naver-Client-Id": self.naver_client_id,
                "X-Naver-Client-Secret": self.naver_client_secret,
                "User-Agent": self.user_agent,
            },
        )
        events: List[CommunityEvent] = []
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
        except Exception as exc:
            logger.warning(
                "[%s] 네이버 API(%s) 호출 실패: %s",
                city_cfg.full_name,
                search_type,
                exc,
            )
            return events

        now_iso = dt.datetime.now(KST).isoformat(timespec="seconds")
        for item in payload.get("items", []):
            title = clean_html_text(item.get("title", ""))
            link = (item.get("originallink") or item.get("link") or "").strip()
            desc = clean_html_text(item.get("description", ""))
            postdate = item.get("postdate") or item.get("pubDate") or now_iso

            if not title or not link:
                continue
            if not is_relevant_to_city(city_cfg, title, desc):
                continue

            app_cat, app_tag, vibe, fallback_poster = classify_for_spot_app(city_cfg, category, title)
            events.append(
                CommunityEvent(
                    event_id=make_event_id(city_cfg.full_name, title, link),
                    province=city_cfg.province,
                    city=city_cfg.city,
                    category=category,
                    title=title,
                    summary=desc[:250],
                    url=link,
                    source=f"naver_{search_type}",
                    published_at=str(postdate),
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
        """단일 권역/도시에 대해 모임·이벤트 카테고리 크롤링 및 대표 썸네일 보강"""
        if dry_run:
            now_iso = dt.datetime.now(KST).isoformat(timespec="seconds")
            sample_title = f"[{city_cfg.city}] 주말 지역 청년 소모임 & 네트워킹 데이"
            sample_url = f"https://example.com/events/{city_cfg.slug}/1"
            return [
                CommunityEvent(
                    event_id=make_event_id(city_cfg.full_name, sample_title, sample_url),
                    province=city_cfg.province,
                    city=city_cfg.city,
                    category="소모임 동호회",
                    title=sample_title,
                    summary=f"{city_cfg.full_name}에서 열리는 지역 주민·청년 커뮤니티 정기 모임입니다.",
                    url=sample_url,
                    source="dry_run_sample",
                    published_at=now_iso,
                    crawled_at=now_iso,
                    location_hint=city_cfg.full_name,
                    poster="assets/images/cover_cafe.jpg",
                )
            ]

        deduped: Dict[str, CommunityEvent] = {}
        for category in city_cfg.categories:
            for ev in self.fetch_google_rss(city_cfg, category):
                deduped[ev.event_id] = ev

            for search_type in ("cafearticle", "blog", "news"):
                for ev in self.fetch_naver_search(city_cfg, category, search_type=search_type):
                    deduped[ev.event_id] = ev

        events_list = list(deduped.values())
        # 상위 대표 이벤트 2건은 실제 웹 포스터/썸네일 이미지 자동 추출
        for ev in events_list[:2]:
            ev.poster = crawl_event_thumbnail(ev.title, ev.poster)

        logger.info("[%s] 총 %d건의 고유 모임/이벤트 수집 완료", city_cfg.full_name, len(events_list))
        return events_list


def export_results(
    results_by_city: Dict[str, List[CommunityEvent]],
    city_configs: List[CityConfig],
    output_dir: Path,
) -> Dict[str, Any]:
    """수집된 데이터를 시별 JSON 파일과 통합 JSON, GitHub 마크다운 요약본으로 저장"""
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
        "# Spot 모임 앱 — 전국 유저 활동 권역별 모임·이벤트 자동 수집 현황",
        "",
        f"- **최종 업데이트**: `{updated_at}`",
        f"- **커버리지 권역 수**: {len(city_configs)}개 권역 (서울·경기·인천·부산·경상·대전·충청·광주·전라·강원·제주 + 활성 유저 지역)",
        f"- **총 수집 이벤트 수**: {combined_payload['total_events']}건",
        "",
    ]

    for cfg in city_configs:
        events = results_by_city.get(cfg.full_name, [])
        md_lines.append(f"## {cfg.full_name} ({len(events)}건)")
        md_lines.append(f"- **주요 동네 키워드**: {', '.join(cfg.aliases[:8])}")
        md_lines.append("")
        if not events:
            md_lines.append("_새로 수집된 모임/이벤트가 없습니다._")
            md_lines.append("")
            continue

        md_lines.append("| 앱 태그 | 모임·이벤트 제목 | 카테고리 | 발행/수집 시각 | 링크 |")
        md_lines.append("| :--- | :--- | :--- | :--- | :--- |")
        for ev in events:
            safe_title = ev.title.replace("|", "\\|")
            md_lines.append(
                f"| {ev.app_tag} | {safe_title} | `{ev.app_category}` | {ev.published_at} | [원문 보기]({ev.url}) |"
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
    1) Firestore 'local_city_events' 컬렉션에 권역별 전체 이벤트 동기화
    2) Spot 앱 홈 화면('실시간 공연·뮤지컬 & 우리동네 이벤트')에서 즉시 보이도록
       권역별 대표 이벤트를 'trend_events' 컬렉션에도 직접 동기화!
    """
    try:
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        import firestore_helper as fh
    except ImportError:
        logger.warning("firestore_helper 모듈을 찾을 수 없어 Firestore 동기화를 건너뜁니다.")
        return

    updated_at = dt.datetime.now(KST).strftime("%Y-%m-%d %H:%M:%S KST")
    synced_cities = 0
    synced_trends = 0
    base_rank = 20

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
            "events": city_events[:25],
        }
        try:
            fh.set_document("local_city_events", cfg.slug, doc_data, merge=True)
            synced_cities += 1
        except Exception as exc:
            logger.warning("[%s] local_city_events 동기화 실패: %s", cfg.full_name, exc)

        # 각 권역의 상위 대표 이벤트 1~2건을 Spot 앱 홈 피드의 'trend_events' 컬렉션에 직접 등록
        for idx, ev in enumerate(evs[:1]):
            base_rank += 1
            clean_title = re.sub(r" - [^-]+$", "", ev.title).strip()
            trend_doc_id = f"local_{cfg.slug}_{idx + 1}"
            trend_doc = {
                "id": trend_doc_id,
                "title": clean_title,
                "venue": ev.location_hint,
                "location": ev.location_hint,
                "province": cfg.province,
                "city": cfg.city,
                "regionAliases": cfg.aliases,
                "period": "실시간 지역 소식 · 상시",
                "poster": ev.poster or "assets/images/cover_food.jpg",
                "category": ev.app_category,
                "genre": "우리동네",
                "tag": ev.app_tag,
                "vibe": ev.vibe,
                "rank": base_rank,
                "summary": ev.summary,
                "sourceUrl": ev.url,
                "isLocalCrawled": True,
                "updatedAt": updated_at,
            }
            try:
                fh.set_document("trend_events", trend_doc_id, trend_doc, merge=True)
                synced_trends += 1
            except Exception as exc:
                logger.warning("[%s] trend_events 동기화 실패: %s", trend_doc_id, exc)

    logger.info(
        "Spot 앱 Firestore 동기화 완료: local_city_events %d개 권역, trend_events %d개 대표 지역 이벤트 등록",
        synced_cities,
        synced_trends,
    )


def notify_app_webhook(results_by_city: Dict[str, List[CommunityEvent]]) -> None:
    """모임 앱 백엔드 웹훅(APP_WEBHOOK_URL)이 설정된 경우 최신 크롤링 데이터를 POST 전송"""
    webhook_url = os.getenv("APP_WEBHOOK_URL", "").strip()
    if not webhook_url:
        return

    payload = {
        "synced_at": dt.datetime.now(KST).isoformat(timespec="seconds"),
        "data": {
            city: [asdict(ev) for ev in events]
            for city, events in results_by_city.items()
        },
    }
    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            logger.info("모임 앱 웹훅 동기화 성공 (HTTP %s)", resp.status)
    except Exception as exc:
        logger.warning("모임 앱 웹훅 전송 실패: %s", exc)


def main() -> None:
    parser = argparse.ArgumentParser(description="Spot 앱 전국 유저 권역별 모임·이벤트 크롤러")
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help="크롤링 대상 지역 설정 JSON 파일 경로 (미지정 시 앱 전국 6대 권역 + Firestore 활성 유저 지역 자동 감지)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("data"),
        help="크롤링 결과 JSON 및 마크다운 저장 폴더 (기본값: data/)",
    )
    parser.add_argument(
        "--max-per-query",
        type=int,
        default=3,
        help="권역·카테고리별 최대 수집 건수 (기본값: 3)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="네트워크 요청 없이 로컬 샘플 데이터로 파이프라인 및 출력 파일 구조 검증",
    )
    parser.add_argument(
        "--no-firestore",
        action="store_true",
        help="Firestore DB 자동 동기화 생략",
    )
    args = parser.parse_args()

    city_configs = load_city_configs(args.config)
    crawler = LocalEventCrawler(max_items_per_query=args.max_per_query)

    results_by_city: Dict[str, List[CommunityEvent]] = {}
    for cfg in city_configs:
        results_by_city[cfg.full_name] = crawler.crawl_city(cfg, dry_run=args.dry_run)

    export_results(results_by_city, city_configs, args.output_dir)
    if not args.dry_run:
        if not args.no_firestore:
            sync_to_oomu_firestore(results_by_city, city_configs)
        notify_app_webhook(results_by_city)


if __name__ == "__main__":
    main()
