import sqlite3
import json

db_path = r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb'
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute('SELECT value FROM ItemTable WHERE key = "google.google-antigravity"')
val = cur.fetchone()[0]

obj = json.loads(val)
print('Keys in google.google-antigravity:', list(obj.keys()))

# let's find all keys containing 'comment' or 'annotation'
def search_dict(d, path=""):
    if isinstance(d, dict):
        for k, v in d.items():
            if 'comment' in k.lower() or 'annotation' in k.lower():
                print(f'Match key at {path}.{k}: type={type(v)}')
            search_dict(v, f'{path}.{k}')
    elif isinstance(d, list):
        for i, item in enumerate(d):
            search_dict(item, f'{path}[{i}]')

search_dict(obj)
