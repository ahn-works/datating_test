import sqlite3
import json

db_path = r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb'
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute('SELECT value FROM ItemTable WHERE key = "google.google-antigravity"')
val = cur.fetchone()[0]

obj = json.loads(val)
comments_raw = obj['antigravity-storage']['comments']
cd = json.loads(comments_raw)

for art_key, art_val in cd.get('artifacts', {}).items():
    comments = art_val.get('comments', [])
    if comments:
        print(f'Artifact: {art_key} -> {len(comments)} comments')
        for i, c in enumerate(comments):
            txt = c.get('comment', '')
            layer = c.get('layer', {})
            box = layer.get('boxCoordinates', {})
            point = layer.get('pointCoordinates', {})
            print(f'  [{i+1}] {txt}')
            print(f'      Box: {box}')
            print(f'      Point: {point}')
