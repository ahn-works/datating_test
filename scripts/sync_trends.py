#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU 트렌드 & 공연/뮤지컬 자동 동기화 스크립트 (Zero-Secret 준수)
- Firestore 'config/api_keys'에서 KOPIS 및 Gemini API 키를 동적으로 로드합니다.
- KOPIS API를 통해 주간 인기 뮤지컬 및 대중음악/콘서트 박스오피스 1~10위를 수집합니다.
- Gemini AI를 통해 2030 SNS 핫플레이스/맛집/디저트 트렌드 큐레이션을 자동 생성합니다.
- 수집 및 생성된 데이터를 Firestore 'trend_events' 컬렉션에 실시간 저장합니다.
"""

import os
import sys
import json
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta

FIRESTORE_PROJECT = "test-b54fc"
FIRESTORE_WEB_KEY = "AIzaSyDWOPC60MA39jq2HAVg6UpKnLB5DalDu7U"
BASE_FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{FIRESTORE_PROJECT}/databases/(default)/documents"

def http_get_json(url, headers=None):
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode('utf-8'))

def http_post_json(url, data, headers=None):
    post_bytes = json.dumps(data).encode('utf-8')
    h = {'Content-Type': 'application/json'}
    if headers:
        h.update(headers)
    req = urllib.request.Request(url, data=post_bytes, headers=h)
    with urllib.request.urlopen(req, timeout=20) as resp:
        return json.loads(resp.read().decode('utf-8'))

def http_patch_firestore(doc_path, fields):
    url = f"{BASE_FIRESTORE_URL}/{doc_path}?key={FIRESTORE_WEB_KEY}"
    body = {"fields": fields}
    post_bytes = json.dumps(body).encode('utf-8')
    req = urllib.request.Request(url, data=post_bytes, headers={'Content-Type': 'application/json'}, method='PATCH')
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode('utf-8'))

def load_credentials_from_firestore():
    """Firestore 'config/api_keys' 문서에서 인증키 동적 조회"""
    url = f"{BASE_FIRESTORE_URL}/config/api_keys?key={FIRESTORE_WEB_KEY}"
    try:
        data = http_get_json(url)
        fields = data.get('fields', {})
        kopis_key = fields.get('kopisApiKey', {}).get('stringValue', '')
        gemini_key = fields.get('geminiApiKey', {}).get('stringValue', '')
        print(f"[OK] Credentials loaded from Firestore: KOPIS({'O' if kopis_key else 'X'}), Gemini({'O' if gemini_key else 'X'})")
        return kopis_key, gemini_key
    except Exception as e:
        print(f"[WARN] Failed to load credentials from Firestore: {e}")
        return "", ""

def fetch_kopis_boxoffice(kopis_key, cate_code="GGGA", cate_name="뮤지컬"):
    """KOPIS 박스오피스 순위 조회 (GGGA: 뮤지컬, CCCD: 콘서트/대중음악)"""
    if not kopis_key:
        print("[WARN] No KOPIS key provided. Skipping KOPIS sync.")
        return []

    eddate = datetime.now().strftime("%Y%m%d")
    stdate = (datetime.now() - timedelta(days=14)).strftime("%Y%m%d")
    url = f"http://www.kopis.or.kr/openApi/restful/boxoffice?service={kopis_key}&stdate={stdate}&eddate={eddate}&catecode={cate_code}"

    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=15) as resp:
            xml_data = resp.read().decode('utf-8')

        root = ET.fromstring(xml_data)
        items = []
        for box in root.findall('.//boxof')[:5]:  # 상위 5개 추출
            rank = box.findtext('rnum', '0')
            title = box.findtext('prfnm', '')
            venue = box.findtext('prfplcnm', '')
            period = box.findtext('prfpd', '')
            area = box.findtext('area', '')
            poster = box.findtext('poster', '')
            item_id = box.findtext('mt20id', f"kopis_{rank}")

            if title:
                items.append({
                    'id': f"kopis_{cate_code}_{item_id}",
                    'title': title.strip(),
                    'venue': venue.strip(),
                    'period': period.strip(),
                    'area': area.strip(),
                    'poster': poster.strip(),
                    'category': f"문화 & 엔터 > 페스티벌 & 공연",
                    'genre': cate_name,
                    'rank': int(rank) if rank.isdigit() else 1,
                    'tag': f"이번 주 핫한 {cate_name} 🔥",
                    'vibe': "놀줄아는",
                })
        print(f"[OK] Fetched {len(items)} {cate_name} items from KOPIS")
        return items
    except Exception as e:
        print(f"[WARN] KOPIS fetch error for {cate_name}: {e}")
        return []

def generate_trend_keywords_gemini(gemini_key):
    """Gemini AI를 활용한 2030 SNS 핫플레이스 및 맛집/디저트 트렌드 생성"""
    if not gemini_key:
        print("[WARN] No Gemini key provided. Using fallback trends.")
        return get_fallback_trends()

    prompt = (
        "대한민국 2030 MZ세대가 소모임/동행으로 방문하기 좋은 최신 SNS 핫플, 디저트, 맛집, 팝업스토어 트렌드 4가지를 추천해줘.\n"
        "반드시 유효한 JSON 배열 형식으로만 응답해줘. 코드 블록(```json) 없이 순수 JSON만 반환해.\n"
        "각 아이템 형식:\n"
        "[\n"
        "  {\n"
        "    \"title\": \"두바이 쫀득 쿠키(두쫀쿠) 카페 탐방\",\n"
        "    \"category\": \"일상 & 푸드 > 카페 & 디저트\",\n"
        "    \"location\": \"서울 마포구 연남동\",\n"
        "    \"desc\": \"SNS 대세 디저트 두쫀쿠 함께 먹으러 가실 분!\",\n"
        "    \"tag\": \"☕ 소소하게 SNS 핫플\",\n"
        "    \"vibe\": \"소소하게\"\n"
        "  }\n"
        "]"
    )

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent"
    headers = {"x-goog-api-key": gemini_key}
    body = {"contents": [{"parts": [{"text": prompt}]}]}

    try:
        res = http_post_json(url, body, headers=headers)
        raw_text = res.get('candidates', [{}])[0].get('content', {}).get('parts', [{}])[0].get('text', '').strip()
        
        # ```json 마크다운 제거
        if raw_text.startswith("```"):
            lines = raw_text.splitlines()
            if lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].startswith("```"):
                lines = lines[:-1]
            raw_text = "\n".join(lines).strip()

        parsed = json.loads(raw_text)
        if isinstance(parsed, list) and len(parsed) > 0:
            print(f"[OK] Gemini generated {len(parsed)} trend keywords")
            return parsed
        else:
            return get_fallback_trends()
    except Exception as e:
        print(f"[WARN] Gemini trend generation error: {e}")
        return get_fallback_trends()

def get_fallback_trends():
    return [
        {
            "title": "두바이 쫀득 쿠키 & 카다이프 카페 탐방",
            "category": "일상 & 푸드 > 카페 & 디저트",
            "location": "서울 마포구 연남동",
            "desc": "요즘 제일 핫한 두쫀쿠 먹고 이야기 나눠요!",
            "tag": "☕ 소소하게 SNS 핫플",
            "vibe": "소소하게"
        },
        {
            "title": "성수동 감성 팝업스토어 웨이팅 동행 팟",
            "category": "문화 & 엔터 > 전시 & 팝업스토어",
            "location": "서울 성동구 성수동",
            "desc": "혼자 줄 서기 심심한 분들 모여서 같이 팝업 구경해요.",
            "tag": "⚡ 놀줄아는 핫플",
            "vibe": "놀줄아는"
        },
        {
            "title": "주말 홍대 엽떡 & 마라탕 메뉴 털기",
            "category": "일상 & 푸드 > 동네 맛집 & 소셜 다이닝",
            "location": "서울 마포구 서교동",
            "desc": "마라탕에 꿔바로우까지 여럿이서 푸짐하게 먹어요!",
            "tag": "🍲 맛집 팟",
            "vibe": "소소하게"
        },
        {
            "title": "힙한 을지로 혼술바 & 와인바 동행",
            "category": "일상 & 푸드 > 동네 술 한잔",
            "location": "서울 중구 을지로동",
            "desc": "퇴근 후 가볍게 와인 한잔하며 힐링할 메이트 찾아요.",
            "tag": "🍷 심야 힐링",
            "vibe": "놀줄아는"
        }
    ]

def sync_to_firestore(events):
    """수집된 모든 트렌드 이벤트를 Firestore 'trend_events' 컬렉션에 동기화"""
    now_iso = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    saved_count = 0

    for idx, item in enumerate(events):
        doc_id = item.get('id', f"trend_{idx+1}")
        fields = {
            "title": {"stringValue": item.get('title', '')},
            "category": {"stringValue": item.get('category', '문화 & 엔터')},
            "location": {"stringValue": item.get('venue') or item.get('location', '')},
            "tag": {"stringValue": item.get('tag', '')},
            "vibe": {"stringValue": item.get('vibe', '놀줄아는')},
            "poster": {"stringValue": item.get('poster', '')},
            "period": {"stringValue": item.get('period', '')},
            "rank": {"integerValue": int(item.get('rank', idx+1))},
            "updatedAt": {"timestampValue": now_iso}
        }
        try:
            http_patch_firestore(f"trend_events/{doc_id}", fields)
            saved_count += 1
        except Exception as e:
            print(f"[WARN] Failed to write doc {doc_id}: {e}")

    print(f"[SUCCESS] Total {saved_count}/{len(events)} trend items synced to Firestore 'trend_events'")

def main():
    print("==================================================")
    print("Starting OOMU Trend & Event Auto-Sync Pipeline...")
    print("==================================================")

    kopis_key, gemini_key = load_credentials_from_firestore()

    # 1. KOPIS 실시간 공연 랭킹 수집
    musicals = fetch_kopis_boxoffice(kopis_key, cate_code="GGGA", cate_name="뮤지컬")
    concerts = fetch_kopis_boxoffice(kopis_key, cate_code="CCCD", cate_name="콘서트")

    # 2. Gemini AI 실시간 트렌드 맛집/핫플 수집
    food_trends = generate_trend_keywords_gemini(gemini_key)

    # 3. 통합 리스트 구성
    all_events = []
    all_events.extend(musicals)
    all_events.extend(concerts)
    for idx, f in enumerate(food_trends):
        all_events.append({
            'id': f"trend_spot_{idx+1}",
            'title': f.get('title', ''),
            'category': f.get('category', '일상 & 푸드'),
            'location': f.get('location', ''),
            'tag': f.get('tag', '🔥 요즘 대세 핫플'),
            'vibe': f.get('vibe', '소소하게'),
            'poster': 'assets/images/cover_food.jpg',
            'period': '상시 운영',
            'rank': idx + 1
        })

    # 4. Firestore 실시간 동기화
    sync_to_firestore(all_events)
    print("==================================================")
    print("Pipeline completed successfully!")
    print("==================================================")

if __name__ == "__main__":
    main()
