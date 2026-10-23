#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Content Moderation & Abuse Prevention Engine
- Automatically detects spam, illegal solicitation, and abusive keywords across community posts and meetups.
- Blocks flagged posts immediately and registers incident in 'reports' collection.
"""

import argparse
import re
import sys
from datetime import datetime, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import create_document, list_documents, set_document

FORBIDDEN_KEYWORDS = [
    # Prostitution & illegal solicitation
    r"조건\s*만남",
    r"페이\s*만남",
    r"스\s*폰\s*제안",
    r"애인\s*대행",
    r"고액\s*알바",
    r"출장\s*마사지",
    # Illegal gambling & spam
    r"사설\s*토토",
    r"바카라",
    r"카지노",
    r"코인\s*리딩",
    r"수익\s*보장",
    # External contact scam / evasion
    r"텔레그램\s*아이디",
    r"텔레\s*문의",
    r"라인\s*아이디",
    r"카톡\s*아이디\s*[:：]\s*\w+",
]

COMPILED_PATTERNS = [re.compile(p, re.IGNORECASE) for p in FORBIDDEN_KEYWORDS]


def scan_content_text(text):
    if not text:
        return []
    matches = []
    for p in COMPILED_PATTERNS:
        m = p.search(text)
        if m:
            matches.append(m.group(0))
    return matches


def moderate_all():
    print("==================================================")
    print("🚨 Running OOMU Content Moderation Watchdog...")
    print("==================================================")

    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    flagged_count = 0

    # 1. Check Community Posts
    posts = list_documents("community_posts", page_size=100)
    print(f"Scanning {len(posts)} community posts...")
    for p in posts:
        doc_id = p.get("_id")
        if not doc_id or p.get("isBlocked", False):
            continue

        raw_text = f"{p.get('title', '')} {p.get('content', '')}"
        violations = scan_content_text(raw_text)
        if violations:
            print(f"  [BLOCKED] Community Post '{doc_id}' matched forbidden: {violations}")
            set_document(
                "community_posts",
                doc_id,
                {
                    "isBlocked": True,
                    "status": "flagged",
                    "flaggedReasons": violations,
                    "moderatedAt": now_iso,
                },
                merge=True,
            )
            # Create a report entry
            create_document(
                "reports",
                {
                    "targetType": "community_post",
                    "targetId": doc_id,
                    "title": p.get("title", ""),
                    "reason": f"자동 감지 (금칙어 위반: {', '.join(violations)})",
                    "author": p.get("author", "알수없음"),
                    "status": "auto_blocked",
                    "createdAt": now_iso,
                },
            )
            flagged_count += 1

    # 2. Check Meetups
    meetups = list_documents("meetups", page_size=100)
    print(f"Scanning {len(meetups)} meetups...")
    for m in meetups:
        doc_id = m.get("_id")
        if not doc_id or m.get("isBlocked", False):
            continue

        raw_text = f"{m.get('title', '')} {m.get('description', '')}"
        violations = scan_content_text(raw_text)
        if violations:
            print(f"  [BLOCKED] Meetup '{doc_id}' matched forbidden: {violations}")
            set_document(
                "meetups",
                doc_id,
                {
                    "isBlocked": True,
                    "status": "flagged",
                    "flaggedReasons": violations,
                    "moderatedAt": now_iso,
                },
                merge=True,
            )
            create_document(
                "reports",
                {
                    "targetType": "meetup",
                    "targetId": doc_id,
                    "title": m.get("title", ""),
                    "reason": f"자동 감지 (금칙어 위반: {', '.join(violations)})",
                    "author": m.get("host", "알수없음"),
                    "status": "auto_blocked",
                    "createdAt": now_iso,
                },
            )
            flagged_count += 1

    print(f"✅ [SUCCESS] Moderation completed. Flagged {flagged_count} malicious items.")
    return flagged_count


if __name__ == "__main__":
    moderate_all()
