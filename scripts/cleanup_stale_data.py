#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Stale Data & Ghost Meetup Cleaner (3-Day Policy)
- Runs daily on GitHub Actions to keep the app database and Cloudflare R2 clean.
- Archives or removes expired meetups and stale trend events older than 3 days.
- Purges unreferenced poster and user images from Cloudflare R2 to maintain $0 storage costs.
"""

import argparse
import os
import re
import subprocess
import sys
from datetime import datetime, timedelta, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from scripts.firestore_helper import delete_document, list_documents, set_document


def cleanup_stale_meetups(days_threshold=3):
    print("==================================================")
    print(f"🧹 Running OOMU Stale Data Cleaner ({days_threshold}-Day Policy)...")
    print("==================================================")

    now = datetime.now(timezone.utc)
    docs = list_documents("meetups", page_size=100)
    print(f"Total meetups in DB: {len(docs)}")

    cleaned_count = 0
    now_iso = now.strftime("%Y-%m-%dT%H:%M:%SZ")

    for doc in docs:
        doc_id = doc.get("_id")
        if not doc_id:
            continue

        is_closed = doc.get("isClosed", False) or doc.get("status") == "closed"
        if is_closed:
            continue

        created_at_raw = doc.get("createdAt") or doc.get("_createTime")
        is_stale = False

        if created_at_raw:
            try:
                clean_time = created_at_raw.replace("Z", "+00:00")
                created_dt = datetime.fromisoformat(clean_time)
                if now - created_dt > timedelta(days=days_threshold):
                    is_stale = True
            except Exception:
                pass

        # Check date string clues
        date_str = str(doc.get("date", ""))
        if "어제" in date_str or "지난" in date_str:
            is_stale = True

        if is_stale:
            print(f"  [ARCHIVE] Meetup '{doc.get('title')}' [ID: {doc_id}] marked closed (age > {days_threshold}d)")
            set_document("meetups", doc_id, {"status": "closed", "isClosed": True, "closedAt": now_iso}, merge=True)
            cleaned_count += 1

    print(f"✅ [SUCCESS] Cleaned/Archived {cleaned_count} stale meetups.")

    # 2. Cleanup expired trend events (공연/축구/영화 중 3일 이상 지난 행사 삭제)
    cleaned_trends = 0
    trends = list_documents("trend_events", page_size=100)
    print(f"\nChecking {len(trends)} trend events for expiration...")
    for t in trends:
        t_id = t.get("_id")
        if not t_id:
            continue
        period = str(t.get("period", ""))
        is_expired = False

        # Period ending format: e.g. "2026.10.15~2026.11.02" or "2026-10-15~2026-11-02"
        if "~" in period:
            end_part = period.split("~")[-1].strip()
            # Match YYYY.MM.DD or YYYY-MM-DD
            m = re.search(r"(\d{4})[.\-](\d{2})[.\-](\d{2})", end_part)
            if m:
                try:
                    end_dt = datetime(int(m.group(1)), int(m.group(2)), int(m.group(3)), 23, 59, 59, tzinfo=timezone.utc)
                    if now - end_dt > timedelta(days=days_threshold):
                        is_expired = True
                except Exception:
                    pass

        if is_expired:
            print(f"  [DELETE] Expired Trend Event '{t.get('title')}' (ended: {period})")
            delete_document("trend_events", t_id)
            cleaned_trends += 1

    print(f"✅ [SUCCESS] Deleted {cleaned_trends} expired trend events.")

    # 3. Cloudflare R2 Orphan Purge Trigger
    print("\n--------------------------------------------------")
    print("🗑️ Triggering Cloudflare R2 Stale & Orphan Purge...")
    try:
        r2_script = os.path.join(os.path.dirname(os.path.abspath(__file__)), "delete_r2_stale_and_duplicates.py")
        if os.path.exists(r2_script):
            subprocess.run([sys.executable, r2_script], check=True)
    except Exception as e:
        print(f"[WARN] Cloudflare R2 purge script notice: {e}")
    print("--------------------------------------------------")

    return cleaned_count + cleaned_trends


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OOMU Data Cleaner")
    parser.add_argument("--days", type=int, default=3, help="Days threshold for staleness (default: 3)")
    args = parser.parse_args()
    cleanup_stale_meetups(days_threshold=args.days)
