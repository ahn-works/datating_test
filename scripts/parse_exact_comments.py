import sqlite3
import json

db_path = r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb'
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute('SELECT value FROM ItemTable WHERE key = "google.google-antigravity"')
val = cur.fetchone()[0]

obj = json.loads(val)
comments_raw = obj['antigravity-storage']['comments']
comments_data = json.loads(comments_raw)

all_items = []
for section, content in comments_data.items():
    if isinstance(content, dict):
        for k, v in content.items():
            if isinstance(v, list):
                all_items.extend(v)
            elif isinstance(v, dict) and 'comment' in v:
                all_items.append(v)
    elif isinstance(content, list):
        all_items.extend(content)

print(f'Total comments collected: {len(all_items)}')
for i, c in enumerate(all_items):
    text = c.get('comment', '')
    ari = c.get('ari', {})
    source_uri = ari.get('sourceUri', '')
    file_name = source_uri.split('/')[-1] if source_uri else 'unknown'
    layer = c.get('layer', {})
    box = layer.get('boxCoordinates', {})
    point = layer.get('pointCoordinates', {})
    created_at = c.get('createdAt', '')
    print(f'[{i+1:02d}] 대상: {file_name}')
    print(f'     위치 박스: {box}')
    print(f'     위치 포인트: {point}')
    print(f'     코멘트: {text}')
    print('='*70)
