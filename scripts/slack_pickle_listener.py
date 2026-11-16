#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Slack - Pickle AI Realtime Listener & Communicator
- Reads Slack Bot credentials securely from Firestore `app_config/slack`.
- Reads incoming messages from #공지용 (C0CHC0S3KEW).
- Filters for instructions from Pickle AI (안심향) and tracks latest processed timestamp.
- Posts execution reports directly to Slack.
"""

import os
import sys
import json
import urllib.request
import urllib.parse
from datetime import datetime

# Import Firestore Helper
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import scripts.firestore_helper as fh

CHANNEL_ID = "C0CHC0S3KEW" # #공지용

def get_slack_config():
    """Retrieves slack configuration from Firestore app_config/slack."""
    os.environ["FIRESTORE_PROJECT"] = "test-b54fc"
    os.environ["FIRESTORE_WEB_KEY"] = "AIzaSyDWOPC60MA39jq2HAVg6UpKnLB5DalDu7U"
    doc = fh.get_document("app_config", "slack")
    if not doc:
        raise RuntimeError("app_config/slack document not found in Firestore!")
    return doc

def check_channel_messages(limit=10, oldest=None):
    """Fetches the latest messages from #공지용."""
    config = get_slack_config()
    token = config.get("bot_token")
    channel = config.get("channel_id", CHANNEL_ID)

    params = {"channel": channel, "limit": limit}
    if oldest:
        params["oldest"] = str(oldest)

    url = f"https://slack.com/api/conversations.history?{urllib.parse.urlencode(params)}"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            if not data.get("ok"):
                return False, data.get("error"), []
            return True, None, data.get("messages", [])
    except Exception as e:
        return False, str(e), []

def send_message_to_slack(text):
    """Sends a message to #공지용 via bot token (or fallback webhook)."""
    config = get_slack_config()
    token = config.get("bot_token")
    channel = config.get("channel_id", CHANNEL_ID)
    webhook_url = config.get("webhook_url")

    # Try Bot API chat.postMessage first
    try:
        url = "https://slack.com/api/chat.postMessage"
        req = urllib.request.Request(
            url,
            data=json.dumps({"channel": channel, "text": text}).encode("utf-8"),
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            }
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            if data.get("ok"):
                return True, "chat.postMessage success"
    except Exception as e:
        print(f"[WARN] chat.postMessage failed: {e}")

    # Fallback to Webhook
    if webhook_url:
        req = urllib.request.Request(
            webhook_url,
            data=json.dumps({"text": text}).encode("utf-8"),
            headers={"Content-Type": "application/json"}
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            return True, "webhook success"

    return False, "Failed to send message"

if __name__ == "__main__":
    ok, err, msgs = check_channel_messages(limit=5)
    if not ok:
        print(f"[ERROR] Failed to read #공지용: {err}")
    else:
        print(f"[SUCCESS] Retrieved {len(msgs)} messages from #공지용:")
        for m in msgs:
            ts = float(m.get("ts", 0))
            time_str = datetime.fromtimestamp(ts).strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{time_str}] {m.get('user')}: {m.get('text', '')[:100]}")
