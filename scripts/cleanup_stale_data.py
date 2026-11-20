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
from scripts.firestore_helper import PROJECT_ID, delete_document, get_access_token, list_documents
import requests


def sync_auth_users_to_firestore():
    """Firebase Authentication에 없는 고아 users/{uid} 문서를 자동 정리한다 (봇은 bots/로 분리 유지)."""
    print("\n🔄 Syncing Firebase Authentication <-> Firestore users...")
    token = get_access_token()
    if not token:
        print("[SKIP] No service account token; skipping Auth <-> Firestore user sync.")
        return 0

    auth_uids = set()
    next_page = None
    url = f"https://identitytoolkit.googleapis.com/v1/projects/{PROJECT_ID}/accounts:query"
    while True:
        payload = {"returnUserInfo": False, "limit": "500"}
        if next_page:
            payload["nextPageToken"] = next_page
        resp = requests.post(
            url,
            headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
            json=payload,
            timeout=15,
        )
        if resp.status_code != 200:
            print(f"[WARN] Identity Toolkit query failed ({resp.status_code}): skipping user sync.")
            return 0
        data = resp.json()
        for u in data.get("userInfo", []):
            if u.get("localId"):
                auth_uids.add(u["localId"])
        next_page = data.get("nextPageToken")
        if not next_page:
            break

    removed = 0
    for doc in list_documents("users", page_size=200):
        uid = doc.get("_id")
        if not uid or doc.get("isBot") is True:
            continue
        if uid not in auth_uids:
            print(f"  [DELETE] Orphaned user doc not in Auth: users/{uid}")
            delete_document("users", uid)
            removed += 1
    print(f"✅ [SUCCESS] Auth sync complete (Auth: {len(auth_uids)}, Removed orphaned users: {removed}).")
    return removed


def cleanup_stale_meetups(days_threshold=3):
    print("==================================================")
    print(f"🧹 Running OOMU Stale Data Cleaner ({days_threshold}-Day Policy)...")
    print("==================================================")

    now = datetime.now(timezone.utc)
    docs = list_documents("meetups", page_size=100)
    print(f"Total meetups in DB: {len(docs)}")

    cleaned_count = 0

    for doc in docs:
        doc_id = doc.get("_id")
        if not doc_id:
            continue

        is_closed = doc.get("isClosed", False) or doc.get("status") == "closed"
        created_at_raw = doc.get("createdAt") or doc.get("_createTime")
        is_stale = bool(is_closed)

        if not is_stale and created_at_raw:
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
            print(f"  [DELETE] Closed/Expired Meetup '{doc.get('title')}' [ID: {doc_id}]")
            delete_document("meetups", doc_id)
            cleaned_count += 1

    print(f"✅ [SUCCESS] Deleted {cleaned_count} closed/expired meetups.")

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

    sync_auth_users_to_firestore()
    return cleaned_count + cleaned_trends


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OOMU Data Cleaner")
    parser.add_argument("--days", type=int, default=3, help="Days threshold for staleness (default: 3)")
    args = parser.parse_args()
    cleanup_stale_meetups(days_threshold=args.days)
