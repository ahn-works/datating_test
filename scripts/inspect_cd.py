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

for k, v in cd.items():
    print(k, '-> type:', type(v))
    if isinstance(v, dict):
        print('  subkeys count:', len(v.keys()))
        for sk in list(v.keys())[:5]:
            subval = v[sk]
            print('   sub-key:', sk, 'type:', type(subval))
            if isinstance(subval, dict):
                print('      keys:', list(subval.keys()))
                for inner_k, inner_v in subval.items():
                    print('         ', inner_k, '->', str(inner_v)[:150])
            elif isinstance(subval, list):
                print('      len list:', len(subval))
                if subval:
                    print('      item 0:', str(subval[0])[:150])
