#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Slack - Pickle AI Realtime Listener & Communicator
- Reads Slack Bot credentials strictly from local environment variables or .env (never stored in DB or git).
- Reads incoming messages from #공지용.
- Filters for instructions from Pickle AI (안심향).
- Posts execution reports directly to Slack.
"""

import os
import sys
import json
import urllib.request
import urllib.parse
from datetime import datetime
from pathlib import Path

def _load_env_file():
    """Loads key-value pairs from .env if present and not in os.environ."""
    env_path = Path(__file__).resolve().parent.parent / ".env"
    if env_path.exists():
        try:
            with open(env_path, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith("#") and "=" in line:
                        k, v = line.split("=", 1)
                        k = k.strip()
                        v = v.strip().strip("'\"")
                        if k not in os.environ:
                            os.environ[k] = v
        except Exception as e:
            print(f"[WARN] Failed to read .env: {e}")

_load_env_file()

def get_slack_config():
    """Retrieves slack configuration strictly from environment variables."""
    token = os.environ.get("SLACK_BOT_TOKEN", "").strip()
    channel = os.environ.get("SLACK_CHANNEL_ID", "C0CHC0S3KEW").strip()
    webhook = os.environ.get("SLACK_WEBHOOK_URL", "").strip()

    if not token and not webhook:
        raise RuntimeError("Neither SLACK_BOT_TOKEN nor SLACK_WEBHOOK_URL is set!")

    return {
        "bot_token": token,
        "channel_id": channel,
        "webhook_url": webhook
    }

def check_channel_messages(limit=10, oldest=None):
    """Fetches the latest messages from #공지용."""
    config = get_slack_config()
    token = config.get("bot_token")
    channel = config.get("channel_id")

    if not token:
        return False, "SLACK_BOT_TOKEN not configured", []

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
    channel = config.get("channel_id")
    webhook_url = config.get("webhook_url")

    # Try Bot API chat.postMessage first
    if token:
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
