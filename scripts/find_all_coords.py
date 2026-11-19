import sqlite3
import re

db_path = r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb'
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute('SELECT value FROM ItemTable WHERE key = "google.google-antigravity"')
val = cur.fetchone()[0]
if isinstance(val, bytes):
    val = val.decode('utf-8', errors='ignore')

targets = [
    '삭제해',
    '온도는 어디갔음',
    '이거 UI 전문디자이너',
    '이거 UI도 디자이너',
    '모든 매너온도 폰트크기',
    '디자이너 규칙에 맞게',
    '여기도 디자인수정',
    '너무 촘촘해서 답답해',
    '모집중 강조하되',
    '모든 모임에 UI를',
    '디자인 수정',
    '제발 UI좀 수정하고 처음에 매너온도는',
    '없애 프로필 수정'
]

for t in targets:
    idx = val.find(t)
    if idx != -1:
        sur = val[idx-1000:idx+1000]
        # find top, left, width, height
        top = re.findall(r'\\*"top\\*"\s*:\s*([0-9\.]+)', sur)
        left = re.findall(r'\\*"left\\*"\s*:\s*([0-9\.]+)', sur)
        width = re.findall(r'\\*"width\\*"\s*:\s*([0-9\.]+)', sur)
        height = re.findall(r'\\*"height\\*"\s*:\s*([0-9\.]+)', sur)
        files = re.findall(r'live_gh_[0-9a-zA-Z_]+\.png', sur)
        fname = files[0] if files else 'unknown'
        print(f'[{t[:15]}] in {fname} -> top:{top[:1]} left:{left[:1]} w:{width[:1]} h:{height[:1]}')
