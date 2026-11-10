"""lib/screens 안의 직접 지정 값(색·글자 크기·모서리)의 종류와 횟수를 파일별로 출력한다.

사용법:
  python scripts/check_design_tokens.py              # 현재 수치 출력
  python scripts/check_design_tokens.py --save       # 기준선(scripts/design_token_baseline.json) 저장
  python scripts/check_design_tokens.py --compare    # 기준선과 비교
  python scripts/check_design_tokens.py --file soso_car_home_screen.dart   # 파일별 줄 번호까지
"""
import argparse
import json
import pathlib
import re
import sys
from collections import Counter

ROOT = pathlib.Path(__file__).resolve().parent.parent
SCREENS = ROOT / "lib" / "screens"
BASELINE = ROOT / "scripts" / "design_token_baseline.json"

RE_COLOR = re.compile(r"Color\(\s*0x([0-9A-Fa-f]{8})\s*\)")
RE_FONT = re.compile(r"fontSize:\s*([0-9]+(?:\.[0-9]+)?)")
RE_RADIUS = re.compile(r"BorderRadius\.(?:circular|vertical|horizontal|only|all)?\(?[^)]*?\bcircular\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)|Radius\.circular\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)")


def scan_file(path):
    text = path.read_text(encoding="utf-8", errors="replace")
    colors, fonts, radii = Counter(), Counter(), Counter()
    lines = {"color": [], "font": [], "radius": []}
    for no, line in enumerate(text.splitlines(), 1):
        stripped = line.lstrip()
        if stripped.startswith("//"):
            continue
        for m in RE_COLOR.finditer(line):
            colors[m.group(1).upper()] += 1
            lines["color"].append(no)
        for m in RE_FONT.finditer(line):
            fonts[m.group(1)] += 1
            lines["font"].append(no)
        for m in re.finditer(r"Radius\.circular\(\s*([0-9]+(?:\.[0-9]+)?)\s*\)", line):
            radii[m.group(1)] += 1
            lines["radius"].append(no)
    return colors, fonts, radii, lines


def collect():
    result = {}
    for p in sorted(SCREENS.rglob("*.dart")):
        c, f, r, ln = scan_file(p)
        result[str(p.relative_to(ROOT)).replace("\\", "/")] = {
            "color_kinds": len(c), "color_count": sum(c.values()),
            "font_kinds": len(f), "font_count": sum(f.values()),
            "radius_kinds": len(r), "radius_count": sum(r.values()),
            "_lines": ln,
        }
    return result


def totals(data):
    t = {"color_kinds": set(), "font_kinds": set(), "radius_kinds": set(),
         "color_count": 0, "font_count": 0, "radius_count": 0}
    for p in sorted(SCREENS.rglob("*.dart")):
        c, f, r, _ = scan_file(p)
        t["color_kinds"] |= set(c); t["font_kinds"] |= set(f); t["radius_kinds"] |= set(r)
        t["color_count"] += sum(c.values()); t["font_count"] += sum(f.values()); t["radius_count"] += sum(r.values())
    return {"color_kinds": len(t["color_kinds"]), "color_count": t["color_count"],
            "font_kinds": len(t["font_kinds"]), "font_count": t["font_count"],
            "radius_kinds": len(t["radius_kinds"]), "radius_count": t["radius_count"]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--save", action="store_true")
    ap.add_argument("--compare", action="store_true")
    ap.add_argument("--file")
    a = ap.parse_args()

    data = collect()
    tot = totals(data)

    if a.file:
        key = next((k for k in data if k.endswith(a.file)), None)
        if not key:
            print("파일을 찾을 수 없음:", a.file); sys.exit(1)
        for kind, nums in data[key]["_lines"].items():
            print(f"{kind}: {len(nums)}곳 -> 줄 {sorted(set(nums))[:60]}")
        return

    print(f"{'file':52s} {'색(종/회)':>10s} {'글자(종/회)':>11s} {'반경(종/회)':>11s}")
    for k, v in sorted(data.items(), key=lambda kv: -kv[1]["color_count"]):
        if v["color_count"] + v["font_count"] + v["radius_count"] == 0:
            continue
        print(f"{k:52s} {v['color_kinds']:>4d}/{v['color_count']:<5d} {v['font_kinds']:>5d}/{v['font_count']:<5d} {v['radius_kinds']:>5d}/{v['radius_count']:<5d}")
    print(f"{'TOTAL (lib/screens)':52s} {tot['color_kinds']:>4d}/{tot['color_count']:<5d} {tot['font_kinds']:>5d}/{tot['font_count']:<5d} {tot['radius_kinds']:>5d}/{tot['radius_count']:<5d}")

    slim = {k: {kk: vv for kk, vv in v.items() if kk != "_lines"} for k, v in data.items()}
    if a.save:
        BASELINE.write_text(json.dumps({"total": tot, "files": slim}, ensure_ascii=False, indent=2), encoding="utf-8")
        print("기준선 저장:", BASELINE.relative_to(ROOT))
    if a.compare and BASELINE.exists():
        base = json.loads(BASELINE.read_text(encoding="utf-8"))["total"]
        print("\n기준선 대비:")
        for k in tot:
            print(f"  {k}: {base[k]} -> {tot[k]} ({tot[k]-base[k]:+d})")


if __name__ == "__main__":
    main()

