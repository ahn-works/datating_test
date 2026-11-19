import sqlite3
import re
import json

db_path = r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb'
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute('SELECT value FROM ItemTable WHERE key = "google.google-antigravity"')
val = cur.fetchone()[0]
if isinstance(val, bytes):
    val = val.decode('utf-8', errors='ignore')

idx = 0
found = 0
seen = set()
while True:
    idx = val.find('comment', idx)
    if idx == -1: break
    
    start = val.rfind('{\\"id\\"', 0, idx)
    if start != -1:
        chunk = val[start:start+1800]
        m = re.search(r'\\*"comment\\*"\s*:\s*\\*"([^\\"]+)\\"', chunk)
        if m:
            c_text = m.group(1)
            if c_text not in seen:
                seen.add(c_text)
                f_m = re.search(r'(live_gh_[0-9a-zA-Z_]+\.png)', chunk)
                f_name = f_m.group(1) if f_m else 'unknown'
                
                # find coords inside layer
                # "boxCoordinates":{"topLeft":{"x":...,"y":...},"bottomRight":{"x":...,"y":...}}
                coords = re.findall(r'[xXyY]":([0-9\.]+)', chunk)
                print(f'[{found+1}] File: {f_name}')
                print(f'    Comment: {c_text}')
                print(f'    Coords (x,y): {coords}')
                print('-'*60)
                found += 1
    idx += 7

print('Total unique comments found:', found)
