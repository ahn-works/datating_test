#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Root Users PII Migration & Inspection Script
- Inspects root 'users' collection documents for legacy PII fields.
- Legacy PII fields: kakaoEmail, naverEmail, phoneNumber, phone, birthDate, detailAddress
- Shows destination: users/{uid}/private/contact
- Default behavior: STRICT DRY-RUN (read-only inspection, zero mutations).
- Mutating execution requires explicit --execute flag (and MUST be confirmed by operator).
- NEVER DELETES ANY DOCUMENTS.
"""

import os
import sys
import json
import argparse
from pathlib import Path

# Add project root and scripts directory to sys.path
SCRIPT_DIR = Path(__file__).resolve().parent
ROOT_DIR = SCRIPT_DIR.parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

try:
    import firestore_helper
except ImportError:
    firestore_helper = None

PII_FIELDS = [
    "kakaoEmail",
    "naverEmail",
    "phoneNumber",
    "phone",
    "birthDate",
    "detailAddress",
]

def scan_and_migrate(execute=False):
    print("=" * 70)
    mode_str = "LIVE EXECUTE" if execute else "STRICT DRY-RUN (Read-Only Inspection)"
    print(f"[*] OOMU Users PII Migration Tool - Mode: {mode_str}")
    print("=" * 70)

    if not firestore_helper:
        print("[ERROR] scripts/firestore_helper.py could not be imported.")
        sys.exit(1)

    print("[*] Fetching users collection from Firestore...")
    users = firestore_helper.list_documents("users", page_size=300)

    if not users:
        print("[!] No users returned or unable to read users collection.")
        return

    total_scanned = len(users)
    users_with_pii = 0
    pii_summary = {field: 0 for field in PII_FIELDS}
    migration_plan = []

    for u in users:
        uid = u.get("id") or u.get("userId") or u.get("docId")
        if not uid:
            continue

        detected_pii = {}
        for f in PII_FIELDS:
            val = u.get(f)
            if val is not None and str(val).strip():
                detected_pii[f] = str(val).strip()
                pii_summary[f] += 1

        if detected_pii:
            users_with_pii += 1
            # Mask sensitive values in output
            masked_plan = {}
            for k, v in detected_pii.items():
                if len(v) > 4:
                    masked_plan[k] = v[:2] + "*" * (len(v) - 4) + v[-2:]
                else:
                    masked_plan[k] = "***"
            migration_plan.append({
                "uid": uid,
                "nickname": u.get("nickname", "unknown"),
                "pii_keys": list(detected_pii.keys()),
                "masked_data": masked_plan,
                "raw_data": detected_pii,
            })

    print(f"[*] Total users scanned: {total_scanned}")
    print(f"[*] Users containing root PII: {users_with_pii}")
    print("[*] Breakdown by PII field:")
    for f, count in pii_summary.items():
        print(f"    - {f:15s}: {count} occurrences")
    print("-" * 70)

    if migration_plan:
        print("[*] Sample migration targets (First 5):")
        for idx, item in enumerate(migration_plan[:5]):
            print(f"  [{idx + 1}] UID: {item['uid']} ({item['nickname']})")
            print(f"      Target: users/{item['uid']}/private/contact")
            print(f"      Fields: {item['pii_keys']}")
            print(f"      Masked: {item['masked_data']}")

    if execute:
        print("\n[!] WARNING: Executing migration to users/{uid}/private/contact...")
        success_count = 0
        for item in migration_plan:
            uid = item["uid"]
            target_data = dict(item["raw_data"])
            ok = firestore_helper.set_document(f"users/{uid}/private", "contact", target_data, merge=True)
            if ok:
                success_count += 1
                print(f"  [SUCCESS] Migrated PII for UID: {uid}")
            else:
                print(f"  [FAIL] Failed to migrate UID: {uid}")
        print(f"[RESULT] Completed live migration: {success_count}/{len(migration_plan)} updated.")
    else:
        print("\n[INFO] Dry-run complete. ZERO records were modified or deleted.")
        print("[INFO] To execute, run with: python scripts/migrate_users_pii_dry_run.py --execute")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OOMU Users Root PII Dry-Run Migration")
    parser.add_argument("--execute", action="store_true", help="Actually execute the migration (writes to private/contact)")
    args = parser.parse_args()

    scan_and_migrate(execute=args.execute)
