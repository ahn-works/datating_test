#!/usr/bin/env python3
"""Refresh verified Naver places for actual member regions and DataLab comparisons.

Run only in GitHub Actions with dedicated Firestore service-account credentials.
No guessed venues, coordinates, popularity, or realtime-search ranking is written.
"""
import datetime as dt
import hashlib
import html
import json
import os
import re
import urllib.parse
import urllib.request

from google.oauth2 import service_account
from google.auth.transport.requests import Request

SCOPE = 'https://www.googleapis.com/auth/datastore'
SOURCE_PLACES = 'Naver Local Search'
SOURCE_TRENDS = 'Naver DataLab Search Trends'
TOPICS = ['카페', '맛집', '공원', '코인노래방']
TREND_GROUPS = [
    {'groupName': '러닝', 'keywords': ['러닝', '러닝화']},
    {'groupName': '원데이클래스', 'keywords': ['원데이클래스', '도자기 클래스']},
    {'groupName': '전시', 'keywords': ['전시회', '미술 전시']},
    {'groupName': '보드게임', 'keywords': ['보드게임', '보드게임 카페']},
    {'groupName': '디저트', 'keywords': ['디저트 카페', '베이커리']},
]


def region_key(region):
    return hashlib.sha256(region.strip().encode('utf-8')).hexdigest()[:24]


def coordinate(raw, lower, upper):
    try:
        value = float(raw)
        if value > upper:
            value /= 10000000
        return value if lower < value < upper else None
    except (ValueError, TypeError):
        return None


def request_json(url, headers, body=None, method=None):
    data = None if body is None else json.dumps(body, ensure_ascii=False).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=20) as response:
        return json.load(response)


def firestore_headers(credentials):
    credentials.refresh(Request())
    return {'Authorization': 'Bearer ' + credentials.token, 'Content-Type': 'application/json'}


def firestore_value(value):
    if isinstance(value, bool):
        return {'booleanValue': value}
    if isinstance(value, int):
        return {'integerValue': str(value)}
    if isinstance(value, float):
        return {'doubleValue': value}
    if isinstance(value, str):
        return {'stringValue': value}
    if isinstance(value, list):
        return {'arrayValue': {'values': [firestore_value(item) for item in value]}}
    if isinstance(value, dict):
        return {'mapValue': {'fields': {key: firestore_value(item) for key, item in value.items()}}}
    raise TypeError('Unsupported Firestore value')


def user_regions(base_url, headers):
    regions = set()
    page_token = ''
    while True:
        params = {'pageSize': '100', 'mask.fieldPaths': 'location'}
        if page_token:
            params['pageToken'] = page_token
        response = request_json(base_url + '/users?' + urllib.parse.urlencode(params), headers)
        for document in response.get('documents', []):
            location = document.get('fields', {}).get('location', {}).get('stringValue', '').strip()
            if location and location != '동네 미설정' and len(location) <= 80:
                regions.add(location)
        page_token = response.get('nextPageToken', '')
        if not page_token:
            return sorted(regions)


def local_places(region, client_id, client_secret):
    headers = {'X-NCP-APIGW-API-KEY-ID': client_id, 'X-NCP-APIGW-API-KEY': client_secret}
    tokens = region.split()
    # Require the municipality and neighborhood when available; avoid same-name villages elsewhere.
    required = tokens[-2:] if len(tokens) >= 2 else tokens
    found = {}
    for topic in TOPICS:
        query = urllib.parse.urlencode({'query': region + ' ' + topic, 'display': 5, 'sort': 'random'})
        result = request_json('https://naverapihub.apigw.ntruss.com/search/v1/local?' + query, headers)
        for item in result.get('items', []):
            address = item.get('roadAddress') or item.get('address') or ''
            if not all(token in address for token in required):
                continue
            lat = coordinate(item.get('mapy'), 30, 45)
            lng = coordinate(item.get('mapx'), 120, 135)
            name = re.sub(r'<[^>]+>', '', html.unescape(item.get('title', ''))).strip()
            if not name or lat is None or lng is None:
                continue
            ident = hashlib.sha256((name + '|' + address).encode('utf-8')).hexdigest()[:16]
            found[ident] = {'id': 'naver_' + ident, 'name': name, 'address': item.get('address', ''),
                            'roadAddress': item.get('roadAddress', ''), 'category': item.get('category', ''),
                            'lat': lat, 'lng': lng, 'region': region, 'source': SOURCE_PLACES}
    return list(found.values())


def data_lab(client_id, client_secret):
    today = dt.date.today()
    start = today - dt.timedelta(days=21)
    headers = {'X-NCP-APIGW-API-KEY-ID': client_id, 'X-NCP-APIGW-API-KEY': client_secret,
               'Content-Type': 'application/json'}
    result = request_json('https://naverapihub.apigw.ntruss.com/search-trend/v1/search', headers, {
        'startDate': start.isoformat(), 'endDate': today.isoformat(), 'timeUnit': 'week',
        'keywordGroups': TREND_GROUPS, 'device': 'mo', 'ages': ['3', '4', '5', '6', '7', '8'],
    }, method='POST')
    items = []
    for row in result.get('results', []):
        series = row.get('data') or []
        if not series:
            continue
        latest = float(series[-1].get('ratio', 0))
        previous = float(series[-2].get('ratio', 0)) if len(series) > 1 else None
        items.append({'keyword': row.get('title', ''), 'category': '선정 키워드 비교',
                      'ratio': round(latest, 1), 'previousRatio': round(previous, 1) if previous is not None else 0,
                      'change': '관심도 ' + str(round(latest))})
    items.sort(key=lambda item: item['ratio'], reverse=True)
    for index, item in enumerate(items):
        item['rank'] = index + 1
    return items


def write_doc(base_url, path, data, headers):
    fields = {key: firestore_value(value) for key, value in data.items()}
    request_json(base_url + '/' + path, headers, {'fields': fields}, method='PATCH')


def main():
    account_json = os.environ.get('FIREBASE_SERVICE_ACCOUNT_JSON', '')
    client_id = os.environ.get('NAVER_API_HUB_CLIENT_ID') or os.environ.get('NAVER_MAP_CLIENT_ID', '')
    client_secret = os.environ.get('NAVER_API_HUB_CLIENT_SECRET') or os.environ.get('NAVER_MAP_CLIENT_SECRET', '')
    if not account_json or not client_id or not client_secret:
        raise SystemExit('Required GitHub Actions secrets are missing; no data was written.')
    account = json.loads(account_json)
    credentials = service_account.Credentials.from_service_account_info(account, scopes=[SCOPE])
    base = 'https://firestore.googleapis.com/v1/projects/' + account['project_id'] + '/databases/(default)/documents'
    headers = firestore_headers(credentials)
    regions = user_regions(base, headers)
    if not regions:
        raise SystemExit('No registered member regions found; no data was written.')
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    completed = 0
    for region in regions:
        places = local_places(region, client_id, client_secret)
        if not places:
            continue
        write_doc(base, 'naver_region_places/' + region_key(region),
                  {'region': region, 'source': SOURCE_PLACES, 'places': places, 'updatedAt': now}, headers)
        completed += 1
    if not completed:
        raise SystemExit('Naver returned no verified places; existing data was kept.')
    trends = data_lab(client_id, client_secret)
    if trends:
        write_doc(base, 'app_config/naver_trends',
                  {'source': SOURCE_TRENDS, 'scope': '선정 키워드의 19~49세 모바일 상대 관심도',
                   'items': trends, 'updatedAt': now}, headers)
    print('Updated verified Naver places for ' + str(completed) + ' regions; DataLab groups: ' + str(len(trends)))


if __name__ == '__main__':
    main()
