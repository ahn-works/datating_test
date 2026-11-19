import sqlite3
import json

db_paths = [
    r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\workspaceStorage\46f414b55cac6904825ab6e09a4d46eb\state.vscdb',
    r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb',
]

for db_path in db_paths:
    print('Checking:', db_path)
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('SELECT key, value FROM ItemTable')
    for k, v in cur.fetchall():
        if isinstance(v, bytes):
            v_str = v.decode('utf-8', errors='ignore')
        else:
            v_str = str(v)
        
        for kw in ['문제구만', '가리잖아', '강남역', '모집 마감']:
            if kw in v_str:
                print(f'FOUND [{kw}] in key: {k}')
                idx = v_str.find(kw)
                print(v_str[max(0, idx-100):min(len(v_str), idx+300)])
                print('='*50)
