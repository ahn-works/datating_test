#!/usr/bin/env python3
"""고정된 기능(scripts/feature_freeze.json)의 파일이 바뀌었는지 검사한다.

사용: python3 scripts/check_feature_freeze.py [--base REF] [--head REF] [--registry PATH]
- base 가 없거나 0000… 이면 head 의 직전 커밋과 비교한다.
- 범위 안 커밋 메시지에 [freeze-unlock: 기능 이름] 이 있으면 그 기능만 통과시킨다
  (대표 승인을 받은 경우에만 넣는다. docs/OOMU_풀스택_검사기준.md 5-4).
"""
import argparse
import fnmatch
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True, check=True).stdout


def matches(path, pattern):
    pattern = pattern.strip()
    if pattern.endswith("/"):
        return path.startswith(pattern)
    return path == pattern or fnmatch.fnmatch(path, pattern)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="")
    ap.add_argument("--head", default="HEAD")
    ap.add_argument("--registry", default=str(ROOT / "scripts" / "feature_freeze.json"))
    a = ap.parse_args()

    features = json.loads(Path(a.registry).read_text(encoding="utf-8")).get("features", [])
    if not features:
        print("[PASS] 고정된 기능이 아직 없습니다 (feature_freeze.json 비어 있음).")
        return 0

    base = a.base.strip()
    if not base or set(base) == {"0"}:
        base = f"{a.head}~1"
    try:
        git("rev-parse", "--verify", f"{base}^{{commit}}")
    except subprocess.CalledProcessError:
        print(f"[INFO] 비교 기준 {base} 을(를) 찾을 수 없어 직전 커밋과 비교합니다.")
        base = f"{a.head}~1"
    try:
        changed = [p for p in git("diff", "--name-only", f"{base}..{a.head}").splitlines() if p]
        messages = git("log", "--format=%B", f"{base}..{a.head}")
    except subprocess.CalledProcessError as e:
        print(f"[FAIL] 비교 범위를 읽지 못했습니다 ({base}..{a.head}): {e.stderr.strip()}")
        return 1

    unlocked = {m.strip() for m in re.findall(r"\[freeze-unlock:\s*([^\]]+)\]", messages)}
    violations = []
    for f in features:
        name = f.get("name", "?")
        hits = [p for p in changed if any(matches(p, pat) for pat in f.get("paths", []))]
        if not hits:
            continue
        if name in unlocked:
            print(f"[UNLOCK] '{name}' 고정 해제 표시로 통과: {', '.join(hits)}")
            continue
        violations.append((name, hits))

    if violations:
        for name, hits in violations:
            print(f"[FAIL] 고정된 기능 '{name}'의 파일이 바뀌었습니다: {', '.join(hits)}")
        print("고치려면 대표님 승인 후 커밋 메시지에 [freeze-unlock: 기능 이름]을 넣고, 수정 뒤 다시 A~Z 검사하세요.")
        return 1
    print(f"[PASS] 고정된 기능 {len(features)}개의 파일 변경 없음 (검사 범위 {base}..{a.head}, 바뀐 파일 {len(changed)}개).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
