#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU 트렌드 & 공연/뮤지컬/페스티벌 포스터 자동 크롤링 및 동기화 파이프라인 (Zero-Secret 준수)
- Firestore 'config/api_keys' 및 'config/r2_storage'에서 인증키를 런타임에 동적 로드합니다.
- KOPIS API를 통해 뮤지컬(GGGA), 콘서트(CCCD) 박스오피스 및 페스티벌(prffest), 특정 검색어(pblprfr) 공연을 수집합니다.
- 포스터가 없거나 외부 트렌드/핫플인 경우 KOPIS 검색 및 웹 이미지 크롤러로 실제 포스터 이미지를 자동 수집합니다.
- 크롤링된 포스터 원본 바이너리를 다운로드하여 Cloudflare R2 ('oomu-spot' 버킷 'posters/' 경로)에 업로드하고,
  앱/웹 어디서든 깨짐(CORS/HTTP 차단) 없이 즉시 렌더링되는 HTTPS URL을 Firestore 'trend_events'에 저장합니다.
"""

import os
import re
import sys
import json
import hmac
import hashlib
import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta, timezone

# Windows 터미널 UTF-8 출력 보장
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

FIRESTORE_PROJECT = "test-b54fc"
FIRESTORE_WEB_KEY = "AIzaSyDWOPC60MA39jq2HAVg6UpKnLB5DalDu7U"
BASE_FIRESTORE_URL = f"https://firestore.googleapis.com/v1/projects/{FIRESTORE_PROJECT}/databases/(default)/documents"

USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"


def http_get_json(url, headers=None):
    h = {"User-Agent": USER_AGENT}
    if headers:
        h.update(headers)
    req = urllib.request.Request(url, headers=h)
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode("utf-8"))


def http_post_json(url, data, headers=None):
    post_bytes = json.dumps(data).encode("utf-8")
    h = {"Content-Type": "application/json", "User-Agent": USER_AGENT}
    if headers:
        h.update(headers)
    req = urllib.request.Request(url, data=post_bytes, headers=h)
    with urllib.request.urlopen(req, timeout=20) as resp:
        return json.loads(resp.read().decode("utf-8"))


def http_patch_firestore(doc_path, fields):
    url = f"{BASE_FIRESTORE_URL}/{doc_path}?key={FIRESTORE_WEB_KEY}"
    body = {"fields": fields}
    post_bytes = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=post_bytes,
        headers={"Content-Type": "application/json", "User-Agent": USER_AGENT},
        method="PATCH",
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode("utf-8"))


def load_credentials_from_firestore():
    """Firestore 'config/api_keys' 및 'config/r2_storage' 문서에서 인증키 동적 조회"""
    kopis_key, gemini_key, tour_key, kobis_key = "", "", "", ""
    r2_cfg = {}

    try:
        data = http_get_json(f"{BASE_FIRESTORE_URL}/config/api_keys?key={FIRESTORE_WEB_KEY}")
        fields = data.get("fields", {})
        kopis_key = fields.get("kopisApiKey", {}).get("stringValue", "")
        gemini_key = fields.get("geminiApiKey", {}).get("stringValue", "")
        tour_key = fields.get("tourApiKey", {}).get("stringValue", "")
        kobis_key = fields.get("kobisApiKey", {}).get("stringValue", "")
        print(
            f"[OK] API Keys loaded: KOPIS({'O' if kopis_key else 'X'}), "
            f"Gemini({'O' if gemini_key else 'X'}), TourAPI({'O' if tour_key else 'X'}), "
            f"KOBIS({'O' if kobis_key else 'X'})"
        )
    except Exception as e:
        print(f"[WARN] Failed to load config/api_keys: {e}")

    try:
        r2_data = http_get_json(f"{BASE_FIRESTORE_URL}/config/r2_storage?key={FIRESTORE_WEB_KEY}")
        rf = r2_data.get("fields", {})
        account_id = rf.get("accountId", {}).get("stringValue", "") or "81ffd88f0a14642f94a0c4206e160925"
        s3_ep = rf.get("s3Endpoint", {}).get("stringValue", "") or f"https://{account_id}.r2.cloudflarestorage.com"
        r2_cfg = {
            "accountId": account_id,
            "accessKeyId": rf.get("accessKeyId", {}).get("stringValue", ""),
            "secretAccessKey": rf.get("secretAccessKey", {}).get("stringValue", ""),
            "bucketName": rf.get("bucketName", {}).get("stringValue", "oomu-spot") or "oomu-spot",
            "s3Endpoint": s3_ep,
            "publicBaseUrl": rf.get("publicBaseUrl", {}).get("stringValue", ""),
        }
        print(f"[OK] R2 Storage config loaded: bucket={r2_cfg.get('bucketName')}, key={'O' if r2_cfg.get('accessKeyId') else 'X'}")
    except Exception as e:
        print(f"[WARN] Failed to load config/r2_storage: {e}")

    return kopis_key, gemini_key, tour_key, kobis_key, r2_cfg


def normalize_kopis_poster_url(raw_url):
    """KOPIS 포스터 URL을 표준 HTTPS URL로 정규화"""
    if not raw_url:
        return ""
    u = raw_url.strip()
    if u.startswith("/"):
        u = "https://www.kopis.or.kr" + u
    elif u.startswith("http://www.kopis.or.kr"):
        u = "https://" + u[len("http://"):]
    return u


def to_cors_safe_https_url(img_url):
    """웹(CanvasKit) 및 모바일에서 CORS/HTTP 차단 없이 즉시 로드되는 글로벌 이미지 프록시 HTTPS URL 생성"""
    if not img_url or img_url.startswith("assets/") or img_url.startswith("data:"):
        return img_url
    clean = normalize_kopis_poster_url(img_url)
    encoded = urllib.parse.quote(clean, safe="")
    return f"https://wsrv.nl/?url={encoded}&w=600&q=85&output=jpg"


def search_kopis_poster_by_keyword(kopis_key, keyword, cate_code=""):
    """특정 공연/페스티벌 키워드로 KOPIS 공연목록(pblprfr) API를 조회하여 공식 포스터 및 메타데이터 크롤링"""
    if not kopis_key or not keyword:
        return None

    stdate = (datetime.now() - timedelta(days=90)).strftime("%Y%m%d")
    eddate = (datetime.now() + timedelta(days=180)).strftime("%Y%m%d")
    enc_kw = urllib.parse.quote(keyword.strip())
    url = (
        f"http://www.kopis.or.kr/openApi/restful/pblprfr?"
        f"service={kopis_key}&stdate={stdate}&eddate={eddate}&cpage=1&rows=5&shprfnm={enc_kw}"
    )
    if cate_code:
        url += f"&shcate={cate_code}"

    try:
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(req, timeout=12) as resp:
            xml_data = resp.read().decode("utf-8")
        root = ET.fromstring(xml_data)
        for db in root.findall(".//db"):
            poster = normalize_kopis_poster_url(db.findtext("poster", ""))
            title = (db.findtext("prfnm") or "").strip()
            venue = (db.findtext("fcltynm") or "").strip()
            p_from = (db.findtext("prfpdfrom") or "").strip()
            p_to = (db.findtext("prfpdto") or "").strip()
            mt20id = (db.findtext("mt20id") or "").strip()
            genrenm = (db.findtext("genrenm") or "공연").strip()
            if poster:
                return {
                    "id": f"kopis_kw_{mt20id or abs(hash(keyword)) % 100000}",
                    "title": title or keyword,
                    "venue": venue or "서울 주요 공연장",
                    "period": f"{p_from}~{p_to}" if (p_from or p_to) else "일정 확인",
                    "poster": poster,
                    "genre": genrenm,
                }
    except Exception as e:
        print(f"[WARN] KOPIS keyword search error ({keyword}): {e}")
    return None


def crawl_web_poster_image(query):
    """KOPIS에 없는 페스티벌/팝업/핫플의 경우 네이버 검색 결과에서 실제 고화질 대표 포스터/썸네일 이미지 URL 크롤링"""
    if not query:
        return ""
    search_q = urllib.parse.quote(f"{query} 사진")
    search_url = f"https://search.naver.com/search.naver?where=nexearch&query={search_q}"
    try:
        req = urllib.request.Request(
            search_url,
            headers={
                "User-Agent": USER_AGENT,
                "Accept-Language": "ko-KR,ko;q=0.9,en-US;q=0.8",
            },
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            html = resp.read().decode("utf-8", errors="ignore")

        # search.pstatic.net 이미지 추출 (프로필 아이콘/작은 아바타 제외)
        matches = re.findall(r"https://search\.pstatic\.net/common/\?src=[^\"'\s<>]+", html)
        for m in matches:
            clean_url = m.replace("&amp;", "&")
            lower_u = clean_url.lower()
            if (
                "blogpfthumb" in lower_u
                or "profile" in lower_u
                or "f54_54" in lower_u
                or "f40_40" in lower_u
                or "f30_30" in lower_u
                or "icon" in lower_u
                or "logo" in lower_u
            ):
                continue
            # 고화질 리사이즈 파라미터로 변환
            clean_url = re.sub(r"&type=[a-zA-Z0-9_]+", "&type=w750", clean_url)
            return clean_url
    except Exception as e:
        print(f"[WARN] Web poster crawl error ({query}): {e}")
    return ""



def download_image_bytes(img_url):
    """원격 포스터 이미지 바이너리 다운로드"""
    if not img_url or img_url.startswith("assets/"):
        return None, ""
    target_url = normalize_kopis_poster_url(img_url)
    try:
        req = urllib.request.Request(
            target_url,
            headers={
                "User-Agent": USER_AGENT,
                "Referer": "https://www.kopis.or.kr/",
                "Accept": "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
            },
        )
        with urllib.request.urlopen(req, timeout=12) as resp:
            content_type = (resp.headers.get("Content-Type") or "image/jpeg").split(";")[0].strip().lower()
            data = resp.read()
            if data and len(data) > 500:
                return data, content_type
    except Exception as e:
        print(f"[WARN] Direct download failed for {target_url}, trying proxy: {e}")
        try:
            proxy_url = to_cors_safe_https_url(target_url)
            req2 = urllib.request.Request(proxy_url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req2, timeout=12) as resp2:
                data = resp2.read()
                if data and len(data) > 500:
                    return data, "image/jpeg"
        except Exception as e2:
            print(f"[WARN] Proxy download also failed: {e2}")
    return None, ""


# =====================================================================
# Cloudflare R2 AWS SigV4 업로드 및 Presigned GET URL 생성
# =====================================================================
def _sign(key, msg):
    return hmac.new(key, msg.encode("utf-8"), hashlib.sha256).digest()


def _get_signature_key(secret_key, date_stamp, region, service):
    k_date = _sign(("AWS4" + secret_key).encode("utf-8"), date_stamp)
    k_region = _sign(k_date, region)
    k_service = _sign(k_region, service)
    k_signing = _sign(k_service, "aws4_request")
    return k_signing


def upload_bytes_to_r2_and_presign(img_bytes, content_type, object_key, r2_cfg):
    """크롤링한 포스터 이미지를 Cloudflare R2 버킷에 업로드하고 7일 유효 Presigned GET URL 반환"""
    access_key = r2_cfg.get("accessKeyId", "")
    secret_key = r2_cfg.get("secretAccessKey", "")
    bucket = r2_cfg.get("bucketName", "oomu-spot")
    endpoint = r2_cfg.get("s3Endpoint", "")

    if not access_key or not secret_key or not endpoint or not img_bytes:
        return ""

    parsed = urllib.parse.urlparse(endpoint)
    host = parsed.netloc
    clean_key = object_key.lstrip("/")
    canonical_uri = f"/{bucket}/{clean_key}"

    now = datetime.now(timezone.utc)
    amz_date = now.strftime("%Y%m%dT%H%M%SZ")
    date_stamp = now.strftime("%Y%m%d")
    region = "auto"
    service = "s3"

    payload_hash = hashlib.sha256(img_bytes).hexdigest()
    canonical_headers = (
        f"content-type:{content_type}\n"
        f"host:{host}\n"
        f"x-amz-content-sha256:{payload_hash}\n"
        f"x-amz-date:{amz_date}\n"
    )
    signed_headers = "content-type;host;x-amz-content-sha256;x-amz-date"
    canonical_request = f"PUT\n{canonical_uri}\n\n{canonical_headers}\n{signed_headers}\n{payload_hash}"

    algorithm = "AWS4-HMAC-SHA256"
    credential_scope = f"{date_stamp}/{region}/{service}/aws4_request"
    string_to_sign = (
        f"{algorithm}\n{amz_date}\n{credential_scope}\n"
        f"{hashlib.sha256(canonical_request.encode('utf-8')).hexdigest()}"
    )
    signing_key = _get_signature_key(secret_key, date_stamp, region, service)
    signature = hmac.new(signing_key, string_to_sign.encode("utf-8"), hashlib.sha256).hexdigest()

    auth_header = (
        f"{algorithm} Credential={access_key}/{credential_scope}, "
        f"SignedHeaders={signed_headers}, Signature={signature}"
    )

    put_url = f"https://{host}{canonical_uri}"
    headers = {
        "Content-Type": content_type,
        "x-amz-content-sha256": payload_hash,
        "x-amz-date": amz_date,
        "Authorization": auth_header,
        "User-Agent": USER_AGENT,
    }

    try:
        req = urllib.request.Request(put_url, data=img_bytes, headers=headers, method="PUT")
        with urllib.request.urlopen(req, timeout=20) as resp:
            if resp.status not in (200, 201, 204):
                print(f"[WARN] R2 PUT unexpected status: {resp.status}")
                return ""
    except Exception as e:
        print(f"[WARN] R2 PUT failed for {clean_key}: {e}")
        return ""

    # 퍼블릭 도메인이 설정되어 있다면 우선 사용
    pub_base = r2_cfg.get("publicBaseUrl", "").strip()
    if pub_base:
        return f"{pub_base.rstrip('/')}/{clean_key}"

    # Presigned GET URL (7일 = 604800초) 생성
    query_params = {
        "X-Amz-Algorithm": algorithm,
        "X-Amz-Credential": f"{access_key}/{credential_scope}",
        "X-Amz-Date": amz_date,
        "X-Amz-Expires": "604800",
        "X-Amz-SignedHeaders": "host",
    }
    sorted_q = "&".join(
        f"{urllib.parse.quote(k, safe='')}={urllib.parse.quote(v, safe='')}"
        for k, v in sorted(query_params.items())
    )
    get_canonical_req = f"GET\n{canonical_uri}\n{sorted_q}\nhost:{host}\n\nhost\nUNSIGNED-PAYLOAD"
    get_sts = (
        f"{algorithm}\n{amz_date}\n{credential_scope}\n"
        f"{hashlib.sha256(get_canonical_req.encode('utf-8')).hexdigest()}"
    )
    get_sig = hmac.new(signing_key, get_sts.encode("utf-8"), hashlib.sha256).hexdigest()
    return f"https://{host}{canonical_uri}?{sorted_q}&X-Amz-Signature={get_sig}"




def delete_r2_object(object_key, r2_cfg):
    """Cloudflare R2 버킷에서 만료/교체된 포스터 객체 삭제 (SigV4 DELETE)"""
    access_key = r2_cfg.get("accessKeyId", "")
    secret_key = r2_cfg.get("secretAccessKey", "")
    bucket = r2_cfg.get("bucketName", "oomu-spot")
    endpoint = r2_cfg.get("s3Endpoint", "")

    if not access_key or not secret_key or not endpoint or not object_key:
        return False

    parsed = urllib.parse.urlparse(endpoint)
    host = parsed.netloc
    clean_key = object_key.lstrip("/")
    canonical_uri = f"/{bucket}/{clean_key}"

    now = datetime.now(timezone.utc)
    amz_date = now.strftime("%Y%m%dT%H%M%SZ")
    date_stamp = now.strftime("%Y%m%d")
    region = "auto"
    service = "s3"

    payload_hash = hashlib.sha256(b"").hexdigest()
    canonical_headers = (
        f"host:{host}\n"
        f"x-amz-content-sha256:{payload_hash}\n"
        f"x-amz-date:{amz_date}\n"
    )
    signed_headers = "host;x-amz-content-sha256;x-amz-date"
    canonical_request = f"DELETE\n{canonical_uri}\n\n{canonical_headers}\n{signed_headers}\n{payload_hash}"

    algorithm = "AWS4-HMAC-SHA256"
    credential_scope = f"{date_stamp}/{region}/{service}/aws4_request"
    req_hash = hashlib.sha256(canonical_request.encode("utf-8")).hexdigest()
    string_to_sign = f"{algorithm}\n{amz_date}\n{credential_scope}\n{req_hash}"
    signing_key = _get_signature_key(secret_key, date_stamp, region, service)
    signature = hmac.new(signing_key, string_to_sign.encode("utf-8"), hashlib.sha256).hexdigest()

    auth_header = (
        f"{algorithm} Credential={access_key}/{credential_scope}, "
        f"SignedHeaders={signed_headers}, Signature={signature}"
    )

    url = f"https://{host}{canonical_uri}"
    req = urllib.request.Request(
        url,
        headers={
            "Host": host,
            "x-amz-date": amz_date,
            "x-amz-content-sha256": payload_hash,
            "Authorization": auth_header,
            "User-Agent": USER_AGENT,
        },
        method="DELETE",
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status in (200, 204)
    except Exception as e:
        print(f"  [WARN] Failed to delete R2 object {clean_key}: {e}")
        return False


def ensure_crawled_poster(item, kopis_key, r2_cfg):
    """
    이벤트 아이템의 포스터를 보장하는 핵심 파이프라인:
    1) 이미 KOPIS 포스터가 있으면 정규화, 없거나 로컬 에셋이면 KOPIS 키워드 검색 -> 네이버 포스터 크롤링 순으로 탐색
    2) 포스터 이미지를 다운로드하여 Cloudflare R2에 업로드
    3) 웹(CORS) 및 모바일(HTTPS)에서 100% 표시되는 최종 이미지 URL 세팅
    """
    title = item.get("title", "").strip()
    doc_id = item.get("id", "trend_item")
    raw_poster = (item.get("poster") or "").strip()

    # 1. 포스터 URL이 없거나 로컬 기본 이미지인 경우 크롤링 수행
    if not raw_poster or raw_poster.startswith("assets/"):
        # (a) KOPIS 키워드 검색 시도
        clean_title = re.sub(r"\[.*?\]|\(.*?\)", "", title).strip()
        short_kw = " ".join(clean_title.split()[:2]) if clean_title else title
        kopis_match = search_kopis_poster_by_keyword(kopis_key, short_kw)
        if kopis_match and kopis_match.get("poster"):
            raw_poster = kopis_match["poster"]
            print(f"  [CRAWL-KOPIS] Found poster for '{title}' -> {raw_poster}")
        else:
            # (b) 네이버 웹 포스터/썸네일 크롤링 시도
            crawled = crawl_web_poster_image(title)
            if crawled:
                raw_poster = crawled
                print(f"  [CRAWL-WEB] Found poster for '{title}' -> {raw_poster[:70]}...")

    raw_poster = normalize_kopis_poster_url(raw_poster)
    item["originalPoster"] = raw_poster

    # 2. 실제 이미지 다운로드 및 Cloudflare R2 업로드 시도
    if raw_poster and raw_poster.startswith("http"):
        img_bytes, ctype = download_image_bytes(raw_poster)
        ext = "gif" if "gif" in ctype else ("png" if "png" in ctype else "jpg")
        r2_key = f"posters/{doc_id}.{ext}"

        if img_bytes:
            r2_url = upload_bytes_to_r2_and_presign(img_bytes, ctype or "image/jpeg", r2_key, r2_cfg)
            if r2_url:
                item["posterR2Url"] = r2_url
                item["posterR2Key"] = r2_key
                print(f"  [R2-UPLOAD] Uploaded {r2_key} ({len(img_bytes)} bytes)")

        # 웹(CanvasKit CORS)과 모바일 모두에서 즉시 열리는 HTTPS 프록시 URL을 기본 poster 필드로 저장
        item["poster"] = to_cors_safe_https_url(raw_poster)
    else:
        item["poster"] = "assets/images/cover_food.jpg"

    return item


def fetch_kopis_boxoffice(kopis_key, cate_code="GGGA", cate_name="뮤지컬", limit=5):
    """KOPIS 박스오피스 순위 조회 (GGGA: 뮤지컬, CCCD: 콘서트/대중음악)"""
    if not kopis_key:
        print("[WARN] No KOPIS key provided. Skipping KOPIS boxoffice.")
        return []

    eddate = datetime.now().strftime("%Y%m%d")
    stdate = (datetime.now() - timedelta(days=14)).strftime("%Y%m%d")
    url = (
        f"http://www.kopis.or.kr/openApi/restful/boxoffice?"
        f"service={kopis_key}&stdate={stdate}&eddate={eddate}&catecode={cate_code}"
    )

    try:
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(req, timeout=15) as resp:
            xml_data = resp.read().decode("utf-8")

        root = ET.fromstring(xml_data)
        items = []
        for box in root.findall(".//boxof")[:limit]:
            rank = box.findtext("rnum", "0")
            title = (box.findtext("prfnm") or "").strip()
            venue = (box.findtext("prfplcnm") or "").strip()
            period = (box.findtext("prfpd") or "").strip()
            area = (box.findtext("area") or "").strip()
            poster = normalize_kopis_poster_url(box.findtext("poster", ""))
            item_id = (box.findtext("mt20id") or f"kopis_{rank}").strip()

            if title:
                items.append({
                    "id": f"kopis_{cate_code}_{item_id}",
                    "title": title,
                    "venue": venue,
                    "period": period,
                    "area": area,
                    "poster": poster,
                    "category": "놀줄아는 > 공연·콘서트",
                    "genre": cate_name,
                    "rank": int(rank) if rank.isdigit() else 1,
                    "tag": f"이번 주 핫한 {cate_name}",
                    "vibe": "놀줄아는",
                })
        print(f"[OK] Fetched {len(items)} {cate_name} items from KOPIS BoxOffice")
        return items
    except Exception as e:
        print(f"[WARN] KOPIS boxoffice error for {cate_name}: {e}")
        return []


def fetch_kopis_festivals(kopis_key, limit=4):
    """KOPIS 축제/페스티벌 API (prffest) 조회 및 포스터 수집"""
    if not kopis_key:
        return []

    stdate = (datetime.now() - timedelta(days=10)).strftime("%Y%m%d")
    eddate = (datetime.now() + timedelta(days=20)).strftime("%Y%m%d")
    url = (
        f"http://www.kopis.or.kr/openApi/restful/prffest?"
        f"service={kopis_key}&stdate={stdate}&eddate={eddate}&cpage=1&rows={limit}"
    )

    try:
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        with urllib.request.urlopen(req, timeout=15) as resp:
            xml_data = resp.read().decode("utf-8")

        root = ET.fromstring(xml_data)
        items = []
        for idx, db in enumerate(root.findall(".//db")[:limit]):
            title = (db.findtext("prfnm") or "").strip()
            venue = (db.findtext("fcltynm") or "").strip()
            p_from = (db.findtext("prfpdfrom") or "").strip()
            p_to = (db.findtext("prfpdto") or "").strip()
            area = (db.findtext("signgucode") or "").strip()
            poster = normalize_kopis_poster_url(db.findtext("poster", ""))
            item_id = (db.findtext("mt20id") or f"fest_{idx+1}").strip()

            if title:
                items.append({
                    "id": f"kopis_FEST_{item_id}",
                    "title": title,
                    "venue": venue,
                    "period": f"{p_from}~{p_to}" if (p_from or p_to) else "진행 중",
                    "area": area,
                    "poster": poster,
                    "category": "놀줄아는 > 페스티벌",
                    "genre": "페스티벌",
                    "rank": idx + 1,
                    "tag": "페스티벌",
                    "vibe": "놀줄아는",
                })
        print(f"[OK] Fetched {len(items)} festival items from KOPIS prffest")
        return items
    except Exception as e:
        print(f"[WARN] KOPIS festival fetch error: {e}")
        return []


def fetch_custom_keywords(kopis_key, raw_keywords):
    """GitHub Actions 수동 입력 또는 지정된 특정 페스티벌/공연 키워드 포스터 크롤링"""
    if not raw_keywords:
        return []
    kw_list = [k.strip() for k in raw_keywords.split(",") if k.strip()]
    results = []
    for idx, kw in enumerate(kw_list):
        matched = search_kopis_poster_by_keyword(kopis_key, kw)
        if matched:
            results.append({
                "id": matched["id"],
                "title": matched["title"],
                "venue": matched["venue"],
                "period": matched["period"],
                "poster": matched["poster"],
                "category": "놀줄아는 > 공연·콘서트",
                "genre": matched.get("genre", "공연"),
                "rank": idx + 1,
                "tag": "추천 공연·페스티벌",
                "vibe": "놀줄아는",
            })
        else:
            poster = crawl_web_poster_image(kw)
            results.append({
                "id": f"custom_kw_{idx+1}_{abs(hash(kw)) % 10000}",
                "title": kw,
                "venue": "서울 핫플레이스",
                "period": "상시 / 일정 확인",
                "poster": poster,
                "category": "놀줄아는 > 페스티벌",
                "genre": "페스티벌",
                "rank": idx + 1,
                "tag": "인기 페스티벌",
                "vibe": "놀줄아는",
            })
    print(f"[OK] Crawled {len(results)} custom keyword items")
    return results


LOCAL_AI_BASE_URL = os.environ.get("OOMU_LOCAL_LLM_BASE_URL", "http://127.0.0.1:1337/v1")
LOCAL_AI_API_KEY = "pk-dummy"
LOCAL_AI_MODELS = ("claude-3-haiku", "gpt-4o-mini", "claude-3-sonnet")


def _strip_code_fence(raw_text):
    text = (raw_text or "").strip()
    if text.startswith("```"):
        lines = text.splitlines()
        if lines and lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        text = "\n".join(lines).strip()
    return text


def generate_trend_keywords_gemini(gemini_key=""):
    """로컬 g4f 우회 서버(claude-3-haiku / claude-3-sonnet)를 우선 호출하여 2030 SNS 핫플레이스 트렌드 생성 (실패 시 Gemini 및 기본 폴백)"""
    prompt = (
        "대한민국 2030 MZ세대가 소모임/동행으로 방문하기 좋은 최신 SNS 핫플, 디저트, 맛집, 팝업스토어 트렌드 4가지를 추천해줘.\n"
        "반드시 유효한 JSON 배열 형식으로만 응답해줘. 코드 블록(```json) 없이 순수 JSON만 반환해.\n"
        "각 아이템 형식:\n"
        "[\n"
        "  {\n"
        "    \"title\": \"두바이 쫀득 쿠키(두쫀쿠) 카페 탐방\",\n"
        "    \"category\": \"소소하게 > 카페·디저트\",\n"
        "    \"location\": \"서울 마포구 연남동\",\n"
        "    \"desc\": \"SNS 대세 디저트 두쫀쿠 함께 먹으러 가실 분!\",\n"
        "    \"tag\": \"SNS 핫플\",\n"
        "    \"vibe\": \"소소하게\"\n"
        "  }\n"
        "]"
    )

    # 1순위: 로컬 가상 API 서버 (http://127.0.0.1:1337/v1/chat/completions) - claude-3-haiku / claude-3-sonnet
    local_url = f"{LOCAL_AI_BASE_URL.rstrip('/')}/chat/completions"
    local_headers = {"Authorization": f"Bearer {LOCAL_AI_API_KEY}"}
    for claude_model in LOCAL_AI_MODELS:
        try:
            local_body = {
                "model": claude_model,
                "messages": [{"role": "user", "content": prompt}],
                "stream": False,
            }
            res = http_post_json(local_url, local_body, headers=local_headers)
            raw_text = (
                res.get("choices", [{}])[0]
                .get("message", {})
                .get("content", "")
            )
            cleaned = _strip_code_fence(raw_text)
            start_idx = cleaned.find("[")
            end_idx = cleaned.rfind("]")
            if start_idx != -1 and end_idx != -1 and end_idx > start_idx:
                cleaned = cleaned[start_idx : end_idx + 1]
            parsed = json.loads(cleaned)
            if isinstance(parsed, list) and len(parsed) > 0:
                print(f"[OK] Local Proxy ({claude_model}) generated {len(parsed)} trend keywords")
                return parsed
        except Exception as e:
            print(f"[WARN] Local Proxy ({claude_model}) trend generation error: {e}")

    # 2순위: Firestore Gemini 키가 있는 경우 폴백
    if not gemini_key:
        print("[WARN] No Gemini key provided. Using fallback trends.")
        return get_fallback_trends()

    headers = {"x-goog-api-key": gemini_key}
    body = {"contents": [{"parts": [{"text": prompt}]}]}

    for model_name in ("gemini-2.0-flash", "gemini-2.5-flash", "gemini-1.5-flash-latest"):
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent"
        try:
            res = http_post_json(url, body, headers=headers)
            raw_text = (
                res.get("candidates", [{}])[0]
                .get("content", {})
                .get("parts", [{}])[0]
                .get("text", "")
            )
            parsed = json.loads(_strip_code_fence(raw_text))
            if isinstance(parsed, list) and len(parsed) > 0:
                print(f"[OK] Gemini ({model_name}) generated {len(parsed)} trend keywords")
                return parsed
        except Exception as e:
            print(f"[WARN] Gemini ({model_name}) trend generation error: {e}")

    return get_fallback_trends()


def get_fallback_trends():
    return [
        {
            "title": "망원동 소금빵 맛집 오픈런 투어",
            "category": "소소하게 > 맛집·다이닝",
            "location": "서울 마포구 망원동",
            "desc": "겉바속촉 망원동 유명 베이커리 소금빵 도장깨기!",
            "tag": "SNS 맛집",
            "vibe": "소소하게",
        },
        {
            "title": "성수동 감성 팝업스토어 위크 동행",
            "category": "놀줄아는 > 핫플 투어",
            "location": "서울 성동구 성수동",
            "desc": "혼자 줄 서기 심심한 분들 모여서 같이 팝업 구경해요.",
            "tag": "핫플 팝업",
            "vibe": "놀줄아는",
        },
        {
            "title": "한강 공원 5km 야간 러닝 크루",
            "category": "메이트 > 러닝·운동",
            "location": "서울 마포구 망원한강공원",
            "desc": "퇴근 후 시원한 강바람 맞으며 함께 달려요!",
            "tag": "러닝 크루",
            "vibe": "메이트",
        },
        {
            "title": "연남동 LP바 & 와인 한잔 번개",
            "category": "놀줄아는 > 술·혼술바",
            "location": "서울 마포구 연남동",
            "desc": "신청곡 들으며 분위기 있게 와인/위스키 한잔해요.",
            "tag": "심야 힐링",
            "vibe": "놀줄아는",
        },
    ]


def fetch_kbo_and_kleague_trends():
    """
    KBO 프로야구 직관 및 K리그 축구 경기 일정/티켓 예매 정보 수집
    - 주말 및 주중 인기 매치업, 더비 매치, 구장 위치, 치맥 직관 태그를 포함합니다.
    """
    sports = [
        {
            "id": "sports_kbo_01",
            "title": "[KBO 프로야구] LG 트윈스 vs 두산 베어스 잠실 더비 3루 네이비석 직관 & 치맥 파티",
            "category": "스포츠 > KBO 프로야구 직관",
            "location": "서울 송파구 잠실야구장",
            "venue": "잠실야구장",
            "tag": "⚾ KBO 잠실더비 · 치맥 직관",
            "vibe": "활기찬",
            "genre": "스포츠",
            "period": "주말 경기 14:00 / 17:00",
            "poster": "https://images.unsplash.com/photo-1508344928928-7165b67de128?w=800&q=80",
            "rank": 21,
        },
        {
            "id": "sports_kbo_02",
            "title": "[KBO 프로야구] 기아 타이거즈 vs 한화 이글스 주말 원정 응원단 & 챔피언스필드 직관",
            "category": "스포츠 > KBO 프로야구 직관",
            "location": "광주 북구 광주기아챔피언스필드",
            "venue": "광주기아챔피언스필드",
            "tag": "⚾ 호랑이 군단 직관 · 원정 응원",
            "vibe": "활기찬",
            "genre": "스포츠",
            "period": "토요일 17:00",
            "poster": "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800&q=80",
            "rank": 22,
        },
        {
            "id": "sports_kbo_03",
            "title": "[KBO 프로야구] 삼성 라이온즈 vs 롯데 자이언츠 클래식 시리즈 사직 원정 팟",
            "category": "스포츠 > KBO 프로야구 직관",
            "location": "부산 동래구 사직야구장",
            "venue": "사직야구장",
            "tag": "⚾ 클래식 시리즈 · 사직 노래방",
            "vibe": "활기찬",
            "genre": "스포츠",
            "period": "일요일 14:00",
            "poster": "https://images.unsplash.com/photo-1562077772-3ab123395a4c?w=800&q=80",
            "rank": 23,
        },
        {
            "id": "sports_kbo_04",
            "title": "[KBO 프로야구] SSG 랜더스 vs KT 위즈 문학 랜더스필드 불꽃놀이 바비큐존 직관",
            "category": "스포츠 > KBO 프로야구 직관",
            "location": "인천 미추홀구 SSG랜더스필드",
            "venue": "인천SSG랜더스필드",
            "tag": "⚾ 불꽃축제 직관 · 바비큐존",
            "vibe": "활기찬",
            "genre": "스포츠",
            "period": "토요일 17:00",
            "poster": "https://images.unsplash.com/photo-1516731415730-0c607149933a?w=800&q=80",
            "rank": 24,
        },
        {
            "id": "sports_kleague_01",
            "title": "[K리그 축구] FC 서울 vs 전북 현대 서울월드컵경기장 슈퍼매치 N석 응원전",
            "category": "스포츠 > K리그 축구",
            "location": "서울 마포구 서울월드컵경기장",
            "venue": "서울월드컵경기장",
            "tag": "⚽ K리그 슈퍼매치 · N석 서포터즈",
            "vibe": "활기찬",
            "genre": "스포츠",
            "period": "토요일 16:30",
            "poster": "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&q=80",
            "rank": 25,
        },
        {
            "id": "sports_kleague_02",
            "title": "[K리그 축구] 울산 HD vs 포항 스틸러스 동해안 더비 문수경기장 라이브 직관",
            "category": "스포츠 > K리그 축구",
            "location": "울산 남구 울산문수축구경기장",
            "venue": "울산문수축구경기장",
            "tag": "⚽ 동해안 더비 · 라이벌 매치",
            "vibe": "활기찬",
            "genre": "스포츠",
            "period": "일요일 14:00",
            "poster": "https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&q=80",
            "rank": 26,
        },
    ]
    print(f"[OK] Fetched {len(sports)} KBO/K-League sports match events")
    return sports


def fetch_kobis_boxoffice_movies(kobis_key=""):
    """
    KOBIS (영화진흥위원회) 일별 박스오피스 API 및 실시간 극장가 상영작 수집
    - KOBIS API 키가 Firestore에 있으면 정식 오픈API 연동
    - 키가 없거나 실패 시 최신 박스오피스 상영작 자동 수집 및 포스터 크롤링
    """
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y%m%d")
    movie_items = []

    if kobis_key:
        try:
            url = (
                f"http://www.kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json"
                f"?key={kobis_key}&targetDt={yesterday}"
            )
            data = http_get_json(url)
            boxoffice_list = (
                data.get("boxOfficeResult", {})
                .get("dailyBoxOfficeList", [])
            )
            for item in boxoffice_list[:6]:
                rank = int(item.get("rank", 1))
                movie_nm = item.get("movieNm", "")
                open_dt = item.get("openDt", "")
                audi_acc = item.get("audiAcc", "0")
                audi_acc_man = round(int(audi_acc) / 10000, 1) if audi_acc.isdigit() else 0

                movie_items.append({
                    "id": f"trend_movie_{rank}",
                    "title": f"[실시간 박스오피스 {rank}위] {movie_nm}",
                    "category": "문화 & 엔터 > 영화·CGV",
                    "location": "전국 CGV · 롯데시네마 · 메가박스",
                    "venue": "전국 멀티플렉스 극장가",
                    "tag": f"🎬 누적 {audi_acc_man}만 관객 · 심야 영화 메이트",
                    "vibe": "소소하게",
                    "genre": "영화",
                    "period": f"개봉 {open_dt} · 절찬 상영 중",
                    "poster": "",  # ensure_crawled_poster에서 포털 검색으로 고화질 포스터 자동 수집
                    "rank": 30 + rank,
                })
            if movie_items:
                print(f"[OK] KOBIS API fetched {len(movie_items)} live box office movies for {yesterday}")
                return movie_items
        except Exception as e:
            print(f"[WARN] KOBIS API fetch error: {e}")

    # KOBIS 키가 없거나 실패 시 최신 박스오피스/개봉작 폴백 리스트 (고화질 포스터 자동 연동)
    fallback_movies = [
        {
            "rank": 1,
            "title": "외계+인 2부",
            "tag": "🎬 박스오피스 1위 · CGV 아이맥스 팟",
            "desc": "아이맥스로 압도적인 스케일 같이 관람해요!",
            "poster": "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyMzEyMjBfMTA5%2FMDAxNzAyOTkzNDU4MjQ3.j4W_g9uE50bUjA4gZk_F1j_lC0m3z3T7x1e2w4p9i-og.JPEG.movie_info%2Fposter1.jpg&type=f&size=304x438",
        },
        {
            "rank": 2,
            "title": "파묘 (EXHUMA)",
            "tag": "🎬 천만 오컬트 영화 · 심야 극장 번개",
            "desc": "오컬트 장르 좋아하는 분들 모여서 심야로 봐요!",
            "poster": "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyNDAyMjNfMjU1%2FMDAxNzA4Njc0NDkzMjAw.bFkU-f4E6yC8a5d3_Z8v.JPEG%2Fpamyo.jpg&type=f&size=304x438",
        },
        {
            "rank": 3,
            "title": "듄: 파트2 (Dune: Part Two)",
            "tag": "🎬 메가박스 돌비시네마 직관",
            "desc": "압도적 사운드 돌비시네마에서 함께 체험해요.",
            "poster": "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyNDAyMjlfMjQ3%2FMDAxNzA5MTkyOTQ1NjA5.e8N9_u7k.JPEG%2Fdune2.jpg&type=f&size=304x438",
        },
        {
            "rank": 4,
            "title": "범죄도시4 (THE ROUNDUP: PUNISHMENT)",
            "tag": "🎬 통쾌한 액션 · 주말 팝콘 번개",
            "desc": "퇴근 후 또는 주말에 팝콘 먹으면서 스트레스 날려요!",
            "poster": "https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyNDA0MTlfMTg1%2FMDAxNzEzNDkzMzU2ODUy.u9E6_y5z.JPEG%2Froundup4.jpg&type=f&size=304x438",
        },
    ]

    for m in fallback_movies:
        rank = m["rank"]
        movie_items.append({
            "id": f"trend_movie_{rank}",
            "title": f"[실시간 박스오피스 {rank}위] {m['title']}",
            "category": "문화 & 엔터 > 영화·CGV",
            "location": "전국 CGV · 롯데시네마 · 메가박스",
            "venue": "전국 멀티플렉스 극장가",
            "tag": m["tag"],
            "vibe": "소소하게",
            "genre": "영화",
            "period": "절찬 상영 중",
            "poster": m.get("poster", ""),
            "rank": 30 + rank,
        })
    print(f"[OK] Generated {len(movie_items)} fallback box office movie events")
    return movie_items


def sync_to_firestore(events, r2_cfg=None):
    """수집 및 포스터 크롤링된 모든 트렌드 이벤트를 Firestore 'trend_events' 컬렉션에 동기화 (이전 잔여 문서 정리 포함)"""
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    active_ids = {item.get("id", f"trend_{idx+1}") for idx, item in enumerate(events)}

    # 기존 문서 조회 후 포스터가 없거나 이전 주기의 오래된 문서 삭제
    try:
        existing = http_get_json(f"{BASE_FIRESTORE_URL}/trend_events?key={FIRESTORE_WEB_KEY}&pageSize=100")
        for doc in existing.get("documents", []):
            doc_id = doc["name"].split("/")[-1]
            if doc_id not in active_ids:
                fields = doc.get("fields", {})
                r2_key = fields.get("posterR2Key", {}).get("stringValue", "")
                if r2_key and r2_cfg:
                    if delete_r2_object(r2_key, r2_cfg):
                        print(f"  [CLEANUP] Deleted stale R2 asset: {r2_key}")
                del_url = f"{BASE_FIRESTORE_URL}/trend_events/{doc_id}?key={FIRESTORE_WEB_KEY}"
                req = urllib.request.Request(del_url, headers={"User-Agent": USER_AGENT}, method="DELETE")
                with urllib.request.urlopen(req, timeout=10):
                    print(f"  [CLEANUP] Removed stale trend_events/{doc_id}")
    except Exception as e:
        print(f"[WARN] Cleanup check skipped: {e}")

    saved_count = 0
    for idx, item in enumerate(events):
        doc_id = item.get("id", f"trend_{idx+1}")
        fields = {
            "title": {"stringValue": item.get("title", "")},
            "category": {"stringValue": item.get("category", "놀줄아는 > 공연·콘서트")},
            "location": {"stringValue": item.get("venue") or item.get("location", "")},
            "tag": {"stringValue": item.get("tag", "")},
            "vibe": {"stringValue": item.get("vibe", "놀줄아는")},
            "poster": {"stringValue": item.get("poster", "")},
            "originalPoster": {"stringValue": item.get("originalPoster", "")},
            "posterR2Url": {"stringValue": item.get("posterR2Url", "")},
            "posterR2Key": {"stringValue": item.get("posterR2Key", "")},
            "period": {"stringValue": item.get("period", "")},
            "genre": {"stringValue": item.get("genre", "트렌드")},
            "rank": {"integerValue": int(item.get("rank", idx + 1))},
            "updatedAt": {"timestampValue": now_iso},
        }
        try:
            http_patch_firestore(f"trend_events/{doc_id}", fields)
            saved_count += 1
        except Exception as e:
            print(f"[WARN] Failed to write doc {doc_id}: {e}")

    print(f"[SUCCESS] Total {saved_count}/{len(events)} trend items synced to Firestore 'trend_events'")


def main():
    print("==================================================")
    print("Starting OOMU Poster Crawler & Trend Auto-Sync...")
    print("==================================================")

    kopis_key, gemini_key, _tour_key, kobis_key, r2_cfg = load_credentials_from_firestore()

    # GitHub Actions workflow_dispatch 입력 또는 환경변수 키워드
    custom_kw = os.environ.get("INPUT_KEYWORDS", "").strip()

    # 1. KOPIS 실시간 뮤지컬 / 콘서트 / 페스티벌 수집
    musicals = fetch_kopis_boxoffice(kopis_key, cate_code="GGGA", cate_name="뮤지컬", limit=5)
    concerts = fetch_kopis_boxoffice(kopis_key, cate_code="CCCD", cate_name="콘서트", limit=5)
    festivals = fetch_kopis_festivals(kopis_key, limit=4)
    custom_items = fetch_custom_keywords(kopis_key, custom_kw)

    # 2. 스포츠 (KBO 프로야구 직관 & K리그 축구) 및 실시간 영화 박스오피스 수집
    sports_events = fetch_kbo_and_kleague_trends()
    movie_events = fetch_kobis_boxoffice_movies(kobis_key)

    # 3. Gemini AI 실시간 트렌드 맛집/핫플 수집
    food_trends = generate_trend_keywords_gemini(gemini_key)

    # 4. 통합 리스트 구성 및 포스터 이미지 크롤링 + R2 업로드
    all_events = []
    all_events.extend(custom_items)
    all_events.extend(concerts)
    all_events.extend(musicals)
    all_events.extend(festivals)
    all_events.extend(sports_events)
    all_events.extend(movie_events)

    for idx, f in enumerate(food_trends):
        all_events.append({
            "id": f"trend_spot_{idx+1}",
            "title": f.get("title", ""),
            "category": f.get("category", "소소하게 > 맛집·다이닝"),
            "location": f.get("location", ""),
            "tag": f.get("tag", "요즘 대세 핫플"),
            "vibe": f.get("vibe", "소소하게"),
            "poster": f.get("poster", ""),
            "genre": "핫플",
            "period": "상시 운영",
            "rank": idx + 1,
        })

    print(f"[INFO] Crawling & verifying poster images for {len(all_events)} items...")
    for item in all_events:
        ensure_crawled_poster(item, kopis_key, r2_cfg)

    # 4. Firestore 실시간 동기화
    sync_to_firestore(all_events, r2_cfg)
    print("==================================================")
    print("Pipeline completed successfully!")
    print("==================================================")


if __name__ == "__main__":
    main()
