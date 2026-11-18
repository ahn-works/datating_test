#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Trend Events Region Backfill Script (Round 7 - §4-4)
- Backfills 'region' and 'area' fields into 'trend_events' collection.
- Uses REGION_RULES table to map venue/location keywords to provinces/cities.
Usage:
  python scripts/fix_trends_region.py --dry-run
  python scripts/fix_trends_region.py --apply
"""

import argparse
import os
import sys

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import list_documents, set_document

REGION_RULES = [
    ("킨텍스", "경기"),
    ("인스파이어", "인천"),
    ("인천", "인천"),
    ("고척", "서울"),
    ("잠실", "서울"),
    ("올림픽공원", "서울"),
    ("화정체육관", "서울"),
    ("샤롯데", "서울"),
    ("LG아트센터", "서울"),
    ("블루스퀘어", "서울"),
    ("디큐브", "서울"),
    ("피카소소극장", "서울"),
    ("대학로", "서울"),
    ("서울", "서울"),
    ("부산", "부산"),
    ("드림씨어터", "부산"),
    ("사직", "부산"),
    ("광주", "광주"),
    ("울산", "울산"),
    ("대구", "대구"),
    ("제주", "제주"),
    ("전국", "전국"),
    ("멀티플렉스", "전국"),
    ("CGV", "전국"),
    ("메가박스", "전국"),
    ("롯데시네마", "전국"),
]


def derive_region(doc):
    text = f"{doc.get('location', '')} {doc.get('venue', '')} {doc.get('title', '')} {doc.get('area', '')}"
    for keyword, reg in REGION_RULES:
        if keyword in text:
            return reg
    return ""


def has_write_credential():
    sa_json = os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON", "").strip() or os.environ.get("FIRESTORE_SERVICE_ACCOUNT_JSON", "").strip()
    sa_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    token = os.environ.get("FIRESTORE_ACCESS_TOKEN", "").strip()
    return bool(sa_json or sa_path or token)


def main():
    parser = argparse.ArgumentParser(description="OOMU Trend Events Region Backfill")
    parser.add_argument("--dry-run", action="store_true", default=True, help="Preview without writing (default)")
    parser.add_argument("--apply", action="store_true", help="Apply updates to Firestore")
    args = parser.parse_args()

    is_apply = args.apply
    if is_apply and not has_write_credential():
        print("\n⚠️ [NOTICE] Admin Bearer Credential (FIREBASE_SERVICE_ACCOUNT_JSON) not found.")
        print("   Per Round 7 §1 & §5 instructions, switching to DRY-RUN mode safely.\n")
        is_apply = False

    mode_label = "APPLY (LIVE WRITE)" if is_apply else "DRY-RUN (PREVIEW ONLY)"
    print("=" * 60)
    print(f"🌍 OOMU Trend Events Region Backfill — Mode: {mode_label}")
    print("=" * 60)

    try:
        events = list_documents("trend_events", page_size=100)
    except Exception as e:
        print(f"[ERROR] Failed to list trend_events: {e}")
        return

    print(f"Total trend_events found in DB: {len(events)}")
    region_counts = {}

    print("\n" + "-" * 75)
    print(f"{'Doc ID':<22} | {'Region':<6} | {'Location / Venue':<25} | {'Title'}")
    print("-" * 75)

    for item in events:
        doc_id = item.get("_id") or item.get("id", "unknown")
        current_region = item.get("region", "")
        reg = current_region or derive_region(item)
        loc = item.get("location", "")
        title = item.get("title", "")
        title_disp = (title[:18] + "..") if len(title) > 20 else title
        loc_disp = (loc[:22] + "..") if len(loc) > 24 else loc

        region_counts[reg or "(미확인)"] = region_counts.get(reg or "(미확인)", 0) + 1
        print(f"{doc_id:<22} | {reg:<6} | {loc_disp:<25} | {title_disp}")

        if is_apply:
            try:
                set_document("trend_events", doc_id, {"region": reg}, merge=True)
            except Exception as e:
                print(f"  [ERROR] Failed to update {doc_id}: {e}")

    print("-" * 75)
    print("\n📊 Region Distribution Summary:")
    for reg, count in sorted(region_counts.items(), key=lambda x: -x[1]):
        print(f"  • {reg}: {count}건")

    print("\n" + "=" * 60)
    print(f"✅ Finished execution in {mode_label} mode.")
    print("=" * 60)


if __name__ == "__main__":
    main()
