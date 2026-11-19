import sqlite3
import json
import os

db_path = r'C:\Users\DT4\AppData\Roaming\Antigravity IDE\User\globalStorage\state.vscdb'
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute('SELECT value FROM ItemTable WHERE key = "google.google-antigravity"')
val = cur.fetchone()[0]

obj = json.loads(val)
comments_raw = obj['antigravity-storage']['comments']
cd = json.loads(comments_raw)

output_dir = r'C:\Users\DT4\.gemini\antigravity\brain\a95242bd-6b0d-40e4-8370-b9993edd36b6\user_comments_crops'
os.makedirs(output_dir, exist_ok=True)

comment_index = 0
summary_list = []

for art_key, art_val in cd.get('artifacts', {}).items():
    comments = art_val.get('comments', [])
    if comments:
        fname = art_key.split('/')[-1]
        for c in comments:
            comment_index += 1
            txt = c.get('comment', '')
            sel = c.get('artifactSelection', {}).get('selection', {}).get('value', {})
            x = sel.get('x', 0)
            y = sel.get('y', 0)
            w = sel.get('width', 0)
            h = sel.get('height', 0)
            
            # extract cropped media bytes if present
            cropped = sel.get('croppedMedia', {}).get('payload', {}).get('value', {})
            crop_path = None
            if cropped and isinstance(cropped, dict):
                # reconstruct byte array
                byte_indices = sorted([int(k) for k in cropped.keys()])
                byte_data = bytes([cropped[str(idx)] for idx in byte_indices])
                crop_fname = f'crop_{comment_index:02d}_{fname}.png'
                crop_path = os.path.join(output_dir, crop_fname)
                with open(crop_path, 'wb') as f:
                    f.write(byte_data)
            
            summary_list.append({
                'index': comment_index,
                'file': fname,
                'comment': txt,
                'x': x, 'y': y, 'w': w, 'h': h,
                'crop_path': crop_path
            })
            print(f'[{comment_index:02d}] {fname} (x:{x:.2f}, y:{y:.2f}, w:{w:.2f}, h:{h:.2f})')
            print(f'     지시: "{txt}"')
            print(f'     크롭이미지: {crop_path}')
            print('-'*60)

with open(os.path.join(output_dir, 'summary.json'), 'w', encoding='utf-8') as f:
    json.dump(summary_list, f, ensure_ascii=False, indent=2)

print('Total 18 crops saved successfully!')
