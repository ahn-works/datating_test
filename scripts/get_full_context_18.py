import sqlite3
import re

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
    surround = val[max(0, pos-1500):min(len(val), pos+1500)]
    files = re.findall(r'live_gh_[0-9a-zA-Z_]+\.png', surround)
    file_name = files[0] if files else 'unknown'
    print(f'[{i+1}] {file_name}: {raw_comment}')
    # print nearest textSelection or context
    texts = re.findall(r'\\*"textSelection\\*"\s*:\s*\\*"([^\\"]+)\\*"', surround)
    if texts: print('    textSelection:', texts)
    coords = re.findall(r'\\*"boxCoordinates\\*"\s*:\s*\{([^}]+)\}', surround)
    if coords: print('    boxCoords:', coords)
