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

# Notice the escaped quotes: \\"comment\\":\\"([^\\"]+)\\"
matches = re.finditer(r'\\*"comment\\*"\s*:\s*\\*"([^\\"]+)\\*"', val)

results = []
for m in matches:
    raw_comment = m.group(1)
    # Find the nearest sourceUri or image filename before or after
    pos = m.start()
    surround = val[max(0, pos-800):min(len(val), pos+800)]
    
    # search for png filename in surround
    png_matches = re.findall(r'([a-zA-Z0-9_\-\.]+\.png)', surround)
    
    # search for coordinates
    coord_matches = re.findall(r'(\d+\.\d+)', surround)
    
    results.append({
        'comment': raw_comment,
        'files': list(set(png_matches)),
        'surround': surround[:300]
    })

print(f'Total matches: {len(results)}')
for i, r in enumerate(results):
    print(f'=== [{i+1}] ===')
    print('Comment:', r['comment'])
    print('Associated files:', r['files'])
