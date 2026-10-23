#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Executive Daily Business Report & Notion/Telegram Auto-Sync
- Runs daily at 23:59 KST (14:59 UTC).
- Aggregates daily KPI (users, meetups, community posts, reports, chat rooms).
- Automatically syncs to Notion Database (if NOTION_API_KEY & NOTION_DATABASE_ID provided).
- Sends instant Telegram push (if TELEGRAM_BOT_TOKEN & TELEGRAM_CHAT_ID provided).
- Renders rich visual executive dashboard to GitHub Step Summary ($GITHUB_STEP_SUMMARY).
"""

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from firestore_helper import list_documents


def parse_doc_time(val):
    if not val:
        return None
    try:
        clean_time = str(val).replace("Z", "+00:00")
        return datetime.fromisoformat(clean_time)
    except Exception:
        return None


def sync_to_notion(notion_key, database_id, stats):
    """Inserts a new daily KPI row into the founder's Notion database."""
    print("  [NOTION] Syncing to Notion Database...")
    url = "https://api.notion.com/v1/pages"
    headers = {
        "Authorization": f"Bearer {notion_key}",
        "Content-Type": "application/json",
        "Notion-Version": "2022-06-28",
    }

    payload = {
        "parent": {"database_id": database_id},
        "properties": {
            "일자": {
                "title": [{"text": {"content": stats["date_kst"]}}]
            },
            "신규 가입자": {"number": stats["new_users_today"]},
            "누적 가입자": {"number": stats["total_users"]},
            "신규 모임": {"number": stats["new_meetups_today"]},
            "활성 모임": {"number": stats["active_meetups"]},
            "신규 커뮤니티글": {"number": stats["new_posts_today"]},
            "신고 접수": {"number": stats["unresolved_reports"]},
            "상태": {
                "select": {"name": "주의 (신고 검토)" if stats["unresolved_reports"] > 0 else "정상 운영 🟢"}
            },
        },
    }

    req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            print("  [NOTION] ✅ Successfully created daily row in Notion!")
            return True
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode("utf-8")
        print(f"  [NOTION] ⚠️ HTTP {e.code} Error: {err_msg}")
        return False
    except Exception as e:
        print(f"  [NOTION] ⚠️ Error: {e}")
        return False


def send_telegram_alert(bot_token, chat_id, message):
    """Sends a Telegram push alert to the founder's smartphone."""
    print("  [TELEGRAM] Sending push alert...")
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    payload = {
        "chat_id": chat_id,
        "text": message,
        "parse_mode": "Markdown",
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            print("  [TELEGRAM] ✅ Push notification delivered!")
            return True
    except Exception as e:
        print(f"  [TELEGRAM] ⚠️ Error sending message: {e}")
        return False


def generate_daily_report():
    print("==================================================")
    print("📱 Running OOMU Executive Daily Business Report...")
    print("==================================================")

    now_kst = datetime.now(timezone(timedelta(hours=9)))
    date_str = now_kst.strftime("%Y-%m-%d")
    today_start = datetime(now_kst.year, now_kst.month, now_kst.day, 0, 0, 0, tzinfo=timezone(timedelta(hours=9)))
    today_start_utc = today_start.astimezone(timezone.utc)

    # 1. Fetch & Analyze Users
    users = list_documents("users", page_size=100)
    total_users = len(users)
    new_users_today = 0
    for u in users:
        t = parse_doc_time(u.get("createdAt") or u.get("_createTime"))
        if t and t >= today_start_utc:
            new_users_today += 1

    # 2. Fetch & Analyze Meetups
    meetups = list_documents("meetups", page_size=100)
    total_meetups = len(meetups)
    active_meetups = 0
    new_meetups_today = 0
    for m in meetups:
        if m.get("status") != "closed" and not m.get("isClosed", False):
            active_meetups += 1
        t = parse_doc_time(m.get("createdAt") or m.get("_createTime"))
        if t and t >= today_start_utc:
            new_meetups_today += 1

    # 3. Fetch & Analyze Community Posts
    posts = list_documents("community_posts", page_size=100)
    total_posts = len(posts)
    new_posts_today = 0
    for p in posts:
        t = parse_doc_time(p.get("createdAt") or p.get("_createTime"))
        if t and t >= today_start_utc:
            new_posts_today += 1

    # 4. Fetch & Analyze Reports
    reports = list_documents("reports", page_size=100)
    total_reports = len(reports)
    unresolved_reports = 0
    for r in reports:
        if r.get("status") != "resolved":
            unresolved_reports += 1

    stats = {
        "date_kst": date_str,
        "total_users": total_users,
        "new_users_today": new_users_today,
        "total_meetups": total_meetups,
        "active_meetups": active_meetups,
        "new_meetups_today": new_meetups_today,
        "total_posts": total_posts,
        "new_posts_today": new_posts_today,
        "total_reports": total_reports,
        "unresolved_reports": unresolved_reports,
    }

    # Generate Markdown Summary
    report_md = f"""# 📊 OOMU 일일 운영 리포트 ({date_str})

> **기준 시각**: {now_kst.strftime("%Y-%m-%d %H:%M:%S")} (KST)
> **서비스 상태**: {"🚨 신고 검토 필요" if unresolved_reports > 0 else "🟢 정상 운영 중"}

### 📈 핵심 지표 요약 (KPI)

| 지표명 | 오늘 실적 | 누적 지표 | 상태 |
| :--- | :---: | :---: | :---: |
| 👥 **회원 가입** | **+{new_users_today}명** | 총 {total_users}명 | {"🔥 성장세" if new_users_today > 0 else "보통"} |
| 🍻 **동네 모임** | **+{new_meetups_today}건** | 활성 {active_meetups}개 (총 {total_meetups}건) | {"🟢 활성화" if active_meetups >= 3 else "⚠️ 모임 추가 권장"} |
| 💬 **커뮤니티 글** | **+{new_posts_today}건** | 총 {total_posts}건 | {"👍 활발" if new_posts_today > 0 else "보통"} |
| 🛡️ **신고/어뷰징** | **{unresolved_reports}건** | 누적 {total_reports}건 | {"🚨 즉시 조치" if unresolved_reports > 0 else "안전 🛡️"} |

---
"""

    print(report_md)

    # Write to GitHub Step Summary if running in GitHub Actions
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path and os.path.exists(os.path.dirname(summary_path)):
        try:
            with open(summary_path, "a", encoding="utf-8") as f:
                f.write(report_md)
            print("✅ [GITHUB] Wrote report to GITHUB_STEP_SUMMARY")
        except Exception as e:
            print(f"[WARN] Failed to write step summary: {e}")

    # Sync to Notion if configured
    notion_key = os.environ.get("NOTION_API_KEY", "").strip()
    notion_db_id = os.environ.get("NOTION_DATABASE_ID", "").strip()
    if notion_key and notion_db_id:
        sync_to_notion(notion_key, notion_db_id, stats)
    else:
        print("💡 [NOTION] NOTION_API_KEY 또는 NOTION_DATABASE_ID가 설정되지 않아 노션 동기화는 건너뜁니다.")
        print("   (GitHub Secrets에 키를 등록하시면 매일 밤 노션 표에 자동 기록됩니다!)")

    # Send Telegram push if configured
    tg_token = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
    tg_chat = os.environ.get("TELEGRAM_CHAT_ID", "").strip()
    if tg_token and tg_chat:
        tg_text = (
            f"📊 *[OOMU] 일일 경영 리포트 ({date_str})*\n\n"
            f"• 신규 가입자: *+{new_users_today}명* (누적 {total_users}명)\n"
            f"• 활성 모임: *{active_meetups}개* (신규 +{new_meetups_today}개)\n"
            f"• 커뮤니티 글: *+{new_posts_today}개*\n"
            f"• 미해결 신고: *{unresolved_reports}건*\n\n"
            f"오늘도 수고 많으셨습니다! 👏"
        )
        send_telegram_alert(tg_token, tg_chat, tg_text)

    return stats


if __name__ == "__main__":
    generate_daily_report()
