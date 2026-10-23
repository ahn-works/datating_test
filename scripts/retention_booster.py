#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Retention Booster & Comeback Reward Engine
- Detects users who have been inactive for >= 3 days.
- Grants free retention bonus hearts / notification to incentivize return.
"""

import sys
from datetime import datetime, timedelta, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import create_document, list_documents, set_document


def run_retention_check(days_inactive=3):
    print("==================================================")
    print("📉 Running OOMU Retention Booster & Comeback Check...")
    print("==================================================")

    now = datetime.now(timezone.utc)
    users = list_documents("users", page_size=100)
    print(f"Checking {len(users)} registered users...")

    boosted_count = 0
    now_iso = now.strftime("%Y-%m-%dT%H:%M:%SZ")

    for u in users:
        uid = u.get("_id")
        if not uid or uid.startswith("seed_") or uid == "admin_user":
            continue

        last_active = u.get("lastLoginAt") or u.get("updatedAt") or u.get("createdAt")
        if not last_active:
            continue

        try:
            clean_time = str(last_active).replace("Z", "+00:00")
            last_dt = datetime.fromisoformat(clean_time)
            if now - last_dt >= timedelta(days=days_inactive):
                last_rewarded = u.get("lastRetentionRewardAt")
                if last_rewarded:
                    clean_rw = str(last_rewarded).replace("Z", "+00:00")
                    rw_dt = datetime.fromisoformat(clean_rw)
                    if now - rw_dt < timedelta(days=7):
                        continue  # Already rewarded within last 7 days

                print(f"  [BOOST] Granting comeback reward to user '{uid}' ({u.get('nickname', '무명')})")
                current_hearts = int(u.get("hearts", 3))
                set_document(
                    "users",
                    uid,
                    {
                        "hearts": current_hearts + 3,
                        "lastRetentionRewardAt": now_iso,
                        "hasUnreadNotification": True,
                    },
                    merge=True,
                )
                create_document(
                    "notifications",
                    {
                        "userId": uid,
                        "title": "💌 컴백 축하 무료 하트 3개 충전!",
                        "body": "오우무에 다시 오신 것을 환영해요! 동네 새로운 모임과 친구들을 둘러보세요.",
                        "type": "retention_reward",
                        "createdAt": now_iso,
                        "isRead": False,
                    },
                )
                boosted_count += 1
        except Exception as e:
            continue

    print(f"✅ [SUCCESS] Granted retention bonus to {boosted_count} dormant users.")
    return boosted_count


if __name__ == "__main__":
    run_retention_check()
