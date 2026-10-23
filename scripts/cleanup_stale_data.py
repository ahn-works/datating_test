#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Stale Data & Ghost Meetup Cleaner
- Runs daily at midnight (KST 00:00 / UTC 15:00) to keep the app database clean.
- Archives expired meetups by marking 'status: closed' and 'isClosed: true'.
- Removes outdated mock documents so users only see fresh, active events.
"""

import argparse
import sys
from datetime import datetime, timedelta, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import list_documents, set_document


def cleanup_stale_meetups(days_threshold=7):
    print("==================================================")
    print("🧹 Running OOMU Stale Data & Ghost Meetup Cleaner...")
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
                # Handle ISO 8601 string
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
    return cleaned_count


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OOMU Data Cleaner")
    parser.add_argument("--days", type=int, default=7, help="Days threshold for staleness")
    args = parser.parse_args()
    cleanup_stale_meetups(days_threshold=args.days)
