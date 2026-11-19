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
        fname = art_key.split('/')[-1]
        for i, c in enumerate(comments):
            txt = c.get('comment', '')
            print(f'[{fname}] {txt}')
            print('  All keys in comment obj:', list(c.keys()))
            for k in c.keys():
                if k not in ['comment', 'ari', 'id', 'cascadeId']:
                    print(f'    {k}: {c[k]}')
            print('-'*50)
