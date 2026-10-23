#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Firestore Automatic Backup Engine
- Exports key Firestore collections (users, meetups, community_posts, reports, chatRooms) to a compressed JSON archive.
- Retained securely as a GitHub Actions Artifact (free cloud storage).
"""

import gzip
import json
import os
import sys
from datetime import datetime, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import list_documents

TARGET_COLLECTIONS = ["users", "meetups", "community_posts", "reports", "chatRooms", "trend_events"]


def backup_database(output_dir="backups"):
    print("==================================================")
    print("🛡️ Running OOMU Firestore Automatic Backup...")
    print("==================================================")

    os.makedirs(output_dir, exist_ok=True)
    now_str = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    backup_file = os.path.join(output_dir, f"oomu_db_backup_{now_str}.json.gz")

    backup_data = {
        "backupTimestamp": datetime.now(timezone.utc).isoformat(),
        "collections": {},
    }

    total_docs = 0
    for col in TARGET_COLLECTIONS:
        docs = list_documents(col, page_size=100)
        backup_data["collections"][col] = docs
        total_docs += len(docs)
        print(f"  [EXPORT] '{col}': {len(docs)} documents")

    raw_bytes = json.dumps(backup_data, ensure_ascii=False, indent=2).encode("utf-8")
    with gzip.open(backup_file, "wb") as gz:
        gz.write(raw_bytes)

    file_size_kb = os.path.getsize(backup_file) / 1024
    print(f"✅ [SUCCESS] Backup completed: {backup_file} ({file_size_kb:.1f} KB, Total {total_docs} docs)")
    return backup_file


if __name__ == "__main__":
    backup_database()
