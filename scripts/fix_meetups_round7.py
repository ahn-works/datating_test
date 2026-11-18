#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Meetup & Coordinates Fix Script (Round 7)
- Area 'host': Fixes missing hostUid and converts members to array for active meetups.
- Area 'coords': Fixes Yeosu 4 items with exact geocoded coordinates.
- Area 'coords-precise': Refines 3 Yeosu meetups to exact park/avenue spots.
- Area 'ghost': Removes ghost test meetup 'meetup_test_1794442447'.
- Area 'dedupe': Removes duplicated seed meetups keeping the newest.
- Area 'all': Runs all of the above.
Usage:
  python scripts/fix_meetups_round7.py --area=all --dry-run
  python scripts/fix_meetups_round7.py --area=all --apply
"""

import argparse
import os
import sys
import time

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import delete_document, list_documents, set_document

HOST_PATCHES = {
    "seed_seed_beer_friday_1117": {
        "hostUid": "test_user_02",
        "host": "연남러너_지훈",
        "hostAvatar": "assets/images/지훈.png",
        "participantIds": ["test_user_02"],
        "members": ["test_user_02"],
        "maxMembers": 4,
        "memberAvatars": ["assets/images/지훈.png"],
    },
    "seed_seed_kpop_karaoke_1117": {
        "hostUid": "test_user_01",
        "host": "망원치즈_민지",
        "hostAvatar": "assets/images/민지.png",
        "participantIds": ["test_user_01"],
        "members": ["test_user_01"],
        "maxMembers": 4,
        "memberAvatars": ["assets/images/민지.png"],
    },
    "seed_seed_running_weekend_1114": {
        "hostUid": "bot_mangwon_runner",
        "host": "망원러너_지안",
        "hostAvatar": "assets/images/지안.png",
        "participantIds": ["bot_mangwon_runner", "test_user_02", "test_user_01"],
        "members": ["bot_mangwon_runner", "test_user_02", "test_user_01"],
        "maxMembers": 4,
        "memberAvatars": [
            "assets/images/지안.png",
            "assets/images/지훈.png",
            "assets/images/민지.png",
        ],
    },
}

COORDS_PATCHES = {
    "IVGd4HF7kv2DLZV4zbNF": {
        "location": "전남 여수시 학동 선소상가 맛집골목",
        "lat": 34.76211,
        "lng": 127.66199,
    },
    "Z2V8YmyZmFIrdTNaypfU": {
        "location": "전남 여수시 웅천동 해변문화공원",
        "lat": 34.74676,
        "lng": 127.68092,
    },
    "meetup_yeosu_azit_boardgame": {
        "location": "전남 여수시 학동 선소상가",
        "lat": 34.76211,
        "lng": 127.66199,
    },
    "meetup_yeosu_lifemate_bike": {
        "location": "전남 여수시 중앙동 여수해양공원",
        "lat": 34.73841,
        "lng": 127.74491,
    },
}

COORDS_PRECISE_PATCHES = {
    "mYoRcZWVFXU6K6FK11cd": {
        "location": "전남 여수시 화장동 성산공원 수변무대",
        "lat": 34.77442,
        "lng": 127.64586,
    },
    "OGfy1UAuJPmhK71HFDAE": {
        "location": "전남 여수시 화장동 무선지구 상가",
        "lat": 34.7618,
        "lng": 127.6575,
    },
    "mnAlUav42KVAtnaXULBw": {
        "location": "전남 여수시 화장동 선소상가 카페거리",
        "lat": 34.7632,
        "lng": 127.6601,
    },
}

GHOST_DOCS = [
    "meetup_test_1794442447",
]


def has_write_credential():
    sa_json = os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON", "").strip() or os.environ.get("FIRESTORE_SERVICE_ACCOUNT_JSON", "").strip()
    sa_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", "").strip()
    token = os.environ.get("FIRESTORE_ACCESS_TOKEN", "").strip()
    return bool(sa_json or sa_path or token)


def run_host_fix(apply=False):
    print("\n--- [Area: host] Patching 3 active meetups without hostUid ---")
    for doc_id, patch in HOST_PATCHES.items():
        print(f"  • Doc ID: {doc_id}")
        print(f"    Payload: {patch}")
        if apply:
            try:
                set_document("meetups", doc_id, patch, merge=True)
                print(f"    [APPLIED] Successfully patched {doc_id}")
            except Exception as e:
                print(f"    [ERROR] Failed to patch {doc_id}: {e}")
        else:
            print("    [DRY-RUN] Will be applied with --apply")


def run_coords_fix(apply=False):
    print("\n--- [Area: coords] Patching 4 Yeosu meetups with exact coordinates ---")
    for doc_id, patch in COORDS_PATCHES.items():
        print(f"  • Doc ID: {doc_id} ({patch['location']})")
        print(f"    Coords: lat={patch['lat']}, lng={patch['lng']}")
        if apply:
            try:
                set_document("meetups", doc_id, patch, merge=True)
                print(f"    [APPLIED] Successfully patched {doc_id}")
            except Exception as e:
                print(f"    [ERROR] Failed to patch {doc_id}: {e}")
        else:
            print("    [DRY-RUN] Will be applied with --apply")


def run_coords_precise_fix(apply=False):
    print("\n--- [Area: coords-precise] Fine-tuning 3 Yeosu meetups to exact park spots ---")
    for doc_id, patch in COORDS_PRECISE_PATCHES.items():
        print(f"  • Doc ID: {doc_id} ({patch['location']})")
        print(f"    Coords: lat={patch['lat']}, lng={patch['lng']}")
        if apply:
            try:
                set_document("meetups", doc_id, patch, merge=True)
                print(f"    [APPLIED] Successfully patched {doc_id}")
            except Exception as e:
                print(f"    [ERROR] Failed to patch {doc_id}: {e}")
        else:
            print("    [DRY-RUN] Will be applied with --apply")


def run_ghost_fix(apply=False):
    print("\n--- [Area: ghost] Deleting ghost test meetups ---")
    for doc_id in GHOST_DOCS:
        print(f"  • Target ghost Doc ID: {doc_id}")
        if apply:
            print("    Waiting 5 seconds before deletion...")
            time.sleep(5)
            try:
                ok = delete_document("meetups", doc_id)
                if ok:
                    print(f"    [APPLIED] Deleted ghost meetup {doc_id}")
                else:
                    print(f"    [WARN] Deletion returned False for {doc_id}")
            except Exception as e:
                print(f"    [ERROR] Failed to delete {doc_id}: {e}")
        else:
            print("    [DRY-RUN] Will be deleted with --apply")


def run_dedupe_fix(apply=False):
    print("\n--- [Area: dedupe] Scanning and deduplicating seed meetups ---")
    try:
        meetups = list_documents("meetups", page_size=100)
    except Exception as e:
        print(f"  [ERROR] Failed to list meetups: {e}")
        return

    groups = {}
    for m in meetups:
        key = m.get("templateId") or m.get("title", "").strip()
        if not key:
            continue
        groups.setdefault(key, []).append(m)

    duplicates_found = 0
    for key, docs in groups.items():
        if len(docs) <= 1:
            continue
        duplicates_found += 1
        docs.sort(key=lambda x: str(x.get("createdAt", "")), reverse=True)
        keep = docs[0]
        remove_list = docs[1:]
        keep_id = keep.get("_id") or keep.get("id")
        print(f"  • Duplicate group: '{key}' (Total: {len(docs)})")
        print(f"    KEEP: {keep_id} (createdAt: {keep.get('createdAt')})")
        for rem in remove_list:
            rem_id = rem.get("_id") or rem.get("id")
            print(f"    REMOVE: {rem_id} (createdAt: {rem.get('createdAt')})")
            if apply:
                try:
                    delete_document("meetups", rem_id)
                    print(f"      [APPLIED] Deleted duplicate {rem_id}")
                except Exception as e:
                    print(f"      [ERROR] Failed to delete {rem_id}: {e}")
            else:
                print("      [DRY-RUN] Will be deleted with --apply")

    if duplicates_found == 0:
        print("  [INFO] No duplicate seed meetups detected.")


def main():
    parser = argparse.ArgumentParser(description="OOMU Meetup & Coordinates Fix Script (Round 7)")
    parser.add_argument(
        "--area",
        choices=["host", "coords", "coords-precise", "ghost", "dedupe", "all"],
        default="all",
        help="Target area to fix",
    )
    parser.add_argument("--dry-run", action="store_true", default=True, help="Preview changes without writing (default)")
    parser.add_argument("--apply", action="store_true", help="Apply changes to Firestore database")
    args = parser.parse_args()

    is_apply = args.apply
    if is_apply and not has_write_credential():
        print("\n⚠️ [NOTICE] Admin Bearer Credential (FIREBASE_SERVICE_ACCOUNT_JSON) not found in environment.")
        print("   Per Round 7 §1 & §5 instructions, switching to DRY-RUN mode safely.\n")
        is_apply = False

    mode_label = "APPLY (LIVE WRITE)" if is_apply else "DRY-RUN (PREVIEW ONLY)"
    print("=" * 60)
    print(f"🔧 OOMU Meetup & Database Fix (Round 7) — Mode: {mode_label}")
    print(f"   Target Area: {args.area}")
    print("=" * 60)

    area = args.area
    if area in ("host", "all"):
        run_host_fix(apply=is_apply)
    if area in ("coords", "all"):
        run_coords_fix(apply=is_apply)
    if area in ("coords-precise", "all"):
        run_coords_precise_fix(apply=is_apply)
    if area in ("ghost", "all"):
        run_ghost_fix(apply=is_apply)
    if area in ("dedupe", "all"):
        run_dedupe_fix(apply=is_apply)

    print("\n" + "=" * 60)
    print(f"✅ Finished execution in {mode_label} mode.")
    print("=" * 60)


if __name__ == "__main__":
    main()
