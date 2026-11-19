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

# Unescape JSON string
# Let's find all annotation objects
pattern = re.compile(r'\{\\"id\\":\\"[^\\"]+\\",\\"cascadeId\\":\\"[^\\"]+\\",\\"ari\\":\{[^}]+\\},\\"layer\\":\{[^}]+\\},\\"comment\\":\\"([^\\"]+)\\"')

matches = pattern.finditer(val)
items = []
for m in matches:
    full_str = m.group(0)
    comment = m.group(1)
    # clean escapes
    clean_json = full_str.replace('\\"', '"').replace('\\\\', '\\') + '}'
    try:
        parsed = json.loads(clean_json)
        items.append(parsed)
    except:
        items.append({'comment': comment, 'raw': clean_json})

print('Parsed annotation count:', len(items))
for i, it in enumerate(items):
    c = it.get('comment', '')
    ari = it.get('ari', {})
    src = ari.get('sourceUri', '')
    layer = it.get('layer', {})
    print(f'[{i+1}] File: {src.split("/")[-1]}')
    print(f'    Comment: {c}')
    print(f'    Layer details: {layer}')
    print('-'*50)
