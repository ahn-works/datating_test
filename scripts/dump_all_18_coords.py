import sqlite3
import re
import json

db_path = r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb'
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute('SELECT value FROM ItemTable WHERE key = "google.google-antigravity"')
row = cur.fetchone()
val = row[0]
if isinstance(val, bytes):
    val = val.decode('utf-8', errors='ignore')

matches = list(re.finditer(r'\\*"comment\\*"\s*:\s*\\*"([^\\"]+)\\*"', val))

for i, m in enumerate(matches):
    raw_comment = m.group(1)
    pos = m.start()
    surround = val[max(0, pos-1200):min(len(val), pos+1200)]
    
    # find file
    files = re.findall(r'live_gh_[0-9a-zA-Z_]+\.png', surround)
    file_name = files[0] if files else 'unknown'
    
    # find box coordinates or box/point
    # e.g. "top": ..., "left": ...
    top = re.findall(r'\\*"top\\*"\s*:\s*([0-9\.]+)', surround)
    left = re.findall(r'\\*"left\\*"\s*:\s*([0-9\.]+)', surround)
    width = re.findall(r'\\*"width\\*"\s*:\s*([0-9\.]+)', surround)
    height = re.findall(r'\\*"height\\*"\s*:\s*([0-9\.]+)', surround)

    coords = {}
    if top: coords['top'] = top[0]
    if left: coords['left'] = left[0]
    if width: coords['width'] = width[0]
    if height: coords['height'] = height[0]

    print(f'[{i+1}] 화면: {file_name} | 좌표: {coords}')
    print(f'    지시: {raw_comment}')
    print('='*70)
