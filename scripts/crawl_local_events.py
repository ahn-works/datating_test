#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
전국 시(City) 단위 지역 모임·커뮤니티 이벤트 멀티 크롤러 및 자동화 스크립트
- 대상 지역: 경기도 고양시, 경기도 성남시, 경기도 수원시, 경기도 용인시, 전라남도 여수시 등 '~시' 단위 확장 구조
- 수집 채널:
  1) Google 뉴스/웹 RSS 피드 (API 키 없이 기본 동작)
  2) 네이버 검색 오픈 API (블로그·카페·뉴스·웹문서 - 소모임/동호회/지역행사 특화)
  3) 지자체/공공데이터포털 문화행사 API (선택 연동)
- 출력 결과:
  1) data/events_by_city.json (전체 시별 통합 JSON - 앱 백엔드/클라이언트 연동용)
  2) data/cities/<city_slug>.json (개별 시 단위 분할 JSON)
  3) data/EVENTS_SUMMARY.md (GitHub 저장소에서 바로 확인 가능한 시별 마크다운 표)
- 부가 연동:
  1) OOMU Firestore DB ('local_city_events' 컬렉션) 자동 동기화 (무서버/무키 기본 연동)
  2) 모임 앱 백엔드 웹훅(APP_WEBHOOK_URL) POST 동기화
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
logger = logging.getLogger("city_event_crawler")

KST = dt.timezone(dt.timedelta(hours=9))


@dataclass
class CityConfig:
    """'~시' 단위 크롤링 대상 지역 설정"""

    province: str          # 광역자치단체 (예: 경기도, 전라남도)
    city: str              # 기초자치단체 '~시' (예: 고양시, 성남시, 여수시)
    slug: str              # 파일 저장용 영문 슬러그
    aliases: List[str] = field(default_factory=list)  # 구/주요 생활권 키워드 (노이즈 필터링 보강용)
    categories: List[str] = field(
        default_factory=lambda: [
            "소모임 동호회",
            "원데이클래스 모임",
            "러닝크루 운동모임",
            "독서모임 스터디",
            "문화행사 축제",
            "청년 커뮤니티 행사",
        ]
    )

    @property
    def full_name(self) -> str:
        return f"{self.province} {self.city}".strip()

    @property
    def match_keywords(self) -> List[str]:
        base_city = self.city[:-1] if self.city.endswith("시") and len(self.city) > 2 else self.city
        return list(dict.fromkeys([self.city, base_city, *self.aliases]))


@dataclass
class CommunityEvent:
    """크롤링된 개별 지역 모임/이벤트 데이터 모델"""

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


DEFAULT_CITIES: List[CityConfig] = [
    CityConfig(
        province="경기도",
        city="고양시",
        slug="gyeonggi_goyang",
        aliases=["일산", "일산동구", "일산서구", "덕양구", "호수공원", "정발산", "화정"],
    ),
    CityConfig(
        province="경기도",
        city="성남시",
        slug="gyeonggi_seongnam",
        aliases=["분당", "판교", "수정구", "중원구", "분당구", "정자", "서현", "위례"],
    ),
    CityConfig(
        province="경기도",
        city="수원시",
        slug="gyeonggi_suwon",
        aliases=["영통", "광교", "인계동", "행궁동", "장안구", "권선구", "팔달구"],
    ),
    CityConfig(
        province="경기도",
        city="용인시",
        slug="gyeonggi_yongin",
        aliases=["수지", "기흥", "처인구", "죽전", "동백", "보정동"],
    ),
    CityConfig(
        province="전라남도",
        city="여수시",
        slug="jeonnam_yeosu",
        aliases=["여수", "웅천", "여서동", "학동", "소호동", "돌산", "이순신광장"],
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
    """수집된 게시글이 해당 '~시' 또는 주요 생활권과 실제로 관련 있는지 검증"""
    combined = f"{title} {summary}"
    return any(keyword in combined for keyword in city_cfg.match_keywords)


def load_city_configs(config_path: Optional[Path] = None) -> List[CityConfig]:
    """외부 JSON 설정 파일 또는 환경변수(TARGET_CITIES)에서 대상 '~시' 목록 로드"""
    if config_path and config_path.exists():
        raw_list = json.loads(config_path.read_text(encoding="utf-8"))
        return [CityConfig(**item) for item in raw_list]

    env_cities = os.getenv("TARGET_CITIES", "").strip()
    if env_cities:
        # 형식 예시: "경기도 고양시,경기도 성남시,전라남도 여수시"
        configs: List[CityConfig] = []
        for idx, token in enumerate(env_cities.split(",")):
            parts = token.strip().split()
            if len(parts) >= 2:
                province, city = parts[0], parts[1]
            elif len(parts) == 1:
                province, city = "", parts[0]
            else:
                continue
            slug = f"city_{idx + 1}_{re.sub(r'[^a-zA-Z0-9]', '', city)}"
            configs.append(CityConfig(province=province, city=city, slug=slug))
        if configs:
            return configs

    return DEFAULT_CITIES


class LocalEventCrawler:
    """시(City) 단위 지역 모임 및 이벤트 멀티 소스 크롤러"""

    def __init__(self, max_items_per_query: int = 5) -> None:
        self.max_items_per_query = max_items_per_query
        self.naver_client_id = os.getenv("NAVER_CLIENT_ID", "").strip()
        self.naver_client_secret = os.getenv("NAVER_CLIENT_SECRET", "").strip()
        self.user_agent = (
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
        )

    def fetch_google_rss(self, city_cfg: CityConfig, category: str) -> List[CommunityEvent]:
        """Google 뉴스/웹 RSS를 통해 해당 시의 모임·행사 정보 수집 (무설치/무키 기본 동작)"""
        query = f"{city_cfg.full_name} {category}"
        encoded_q = urllib.parse.quote(query)
        rss_url = f"https://news.google.com/rss/search?q={encoded_q}&hl=ko&gl=KR&ceid=KR:ko"

        events: List[CommunityEvent] = []
        req = urllib.request.Request(rss_url, headers={"User-Agent": self.user_agent})
        try:
            with urllib.request.urlopen(req, timeout=12) as resp:
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
                    location_hint=city_cfg.full_name,
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

        query = urllib.parse.quote(f"{city_cfg.full_name} {category}")
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
                    location_hint=city_cfg.full_name,
                )
            )
        return events

    def crawl_city(self, city_cfg: CityConfig, dry_run: bool = False) -> List[CommunityEvent]:
        """단일 '~시'에 대해 모든 모임 카테고리 크롤링 및 중복 제거"""
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
                )
            ]

        deduped: Dict[str, CommunityEvent] = {}
        for category in city_cfg.categories:
            for ev in self.fetch_google_rss(city_cfg, category):
                deduped[ev.event_id] = ev

            for search_type in ("cafearticle", "blog", "news"):
                for ev in self.fetch_naver_search(city_cfg, category, search_type=search_type):
                    deduped[ev.event_id] = ev

        logger.info("[%s] 총 %d건의 고유 모임/이벤트 수집 완료", city_cfg.full_name, len(deduped))
        return list(deduped.values())


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

    # 1. 통합 JSON 저장 (data/events_by_city.json)
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
            "count": len(city_events),
            "events": city_events,
        }

        # 2. 개별 시 단위 JSON 저장 (앱에서 특정 시 데이터만 가볍게 호출할 때 사용)
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

    # 3. GitHub 저장소용 마크다운 요약 리포트 생성 (data/EVENTS_SUMMARY.md)
    md_lines = [
        "# 지역별(시 단위) 커뮤니티 모임 및 이벤트 자동 수집 현황",
        "",
        f"- **최종 업데이트**: `{updated_at}`",
        f"- **모니터링 대상 도시**: {', '.join(cfg.full_name for cfg in city_configs)}",
        f"- **총 수집 이벤트 수**: {combined_payload['total_events']}건",
        "",
    ]

    for cfg in city_configs:
        events = results_by_city.get(cfg.full_name, [])
        md_lines.append(f"## {cfg.full_name} ({len(events)}건)")
        md_lines.append("")
        if not events:
            md_lines.append("_새로 수집된 모임/이벤트가 없습니다._")
            md_lines.append("")
            continue

        md_lines.append("| 카테고리 | 모임·이벤트 제목 | 출처 | 발행/수집 시각 | 링크 |")
        md_lines.append("| :--- | :--- | :--- | :--- | :--- |")
        for ev in events:
            safe_title = ev.title.replace("|", "\\|")
            md_lines.append(
                f"| {ev.category} | {safe_title} | `{ev.source}` | {ev.published_at} | [원문 보기]({ev.url}) |"
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
    """OOMU Firestore 백엔드('local_city_events' 컬렉션)에 시별 최신 모임·이벤트 자동 반영"""
    try:
        import firestore_helper as fh
    except ImportError:
        try:
            sys.path.insert(0, str(Path(__file__).resolve().parent))
            import firestore_helper as fh
        except ImportError:
            logger.warning("firestore_helper 모듈을 찾을 수 없어 Firestore 동기화를 건너뜁니다.")
            return

    updated_at = dt.datetime.now(KST).strftime("%Y-%m-%d %H:%M:%S KST")
    synced_cities = 0
    for cfg in city_configs:
        city_events = [asdict(ev) for ev in results_by_city.get(cfg.full_name, [])]
        doc_data = {
            "province": cfg.province,
            "city": cfg.city,
            "full_name": cfg.full_name,
            "slug": cfg.slug,
            "updated_at": updated_at,
            "count": len(city_events),
            "events": city_events[:25],  # 문서 크기 최적화를 위해 최신 25건 유지
        }
        try:
            fh.set_document("local_city_events", cfg.slug, doc_data, merge=True)
            synced_cities += 1
        except Exception as exc:
            logger.warning("[%s] Firestore 동기화 실패: %s", cfg.full_name, exc)

    logger.info("OOMU Firestore (local_city_events) %d개 도시 동기화 완료", synced_cities)


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
    parser = argparse.ArgumentParser(description="시(City) 단위 지역 모임·이벤트 크롤러")
    parser.add_argument(
        "--config",
        type=Path,
        default=None,
        help="크롤링 대상 시(City) 설정 JSON 파일 경로 (미지정 시 기본 시 목록 사용)",
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
        default=5,
        help="도시·카테고리별 최대 수집 건수 (기본값: 5)",
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
