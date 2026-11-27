#!/usr/bin/env python3
"""수정 전(A)·후(B) 캡처를 폭별 한 장으로 합친다. 검수자는 이 이미지 3장만 보면 된다.
사용: python3 scripts/qa/contact_sheet.py <폴더> <전접두어> <후접두어>"""
import sys, glob, os
from PIL import Image
d, a, b = sys.argv[1:4]
names = sorted({os.path.basename(f).split('_', 2)[2] for f in glob.glob(f'{d}/{a}_*_*.png')})
for w in (360, 390, 430):
    cols = []
    for n in names:
        pa, pb = f'{d}/{a}_{w}_{n}', f'{d}/{b}_{w}_{n}'
        if os.path.exists(pa) and os.path.exists(pb):
            A, B = Image.open(pa), Image.open(pb)
            c = Image.new('RGB', (A.width + B.width + 6, A.height), 'red'); c.paste(A, (0, 0)); c.paste(B, (A.width + 6, 0)); cols.append(c)
    if not cols: continue
    # 4개씩 두 줄(왼쪽=수정 전, 오른쪽=수정 후)
    half = (len(cols) + 1) // 2
    for k, part in enumerate((cols[:half], cols[half:])):
        if not part: continue
        W = sum(c.width for c in part) + 10 * (len(part) - 1)
        sheet = Image.new('RGB', (W, part[0].height), 'white'); x = 0
        for c in part: sheet.paste(c, (x, 0)); x += c.width + 10
        sheet.save(f'{d}/sheet_{w}_{k + 1}.png')
print('done')
