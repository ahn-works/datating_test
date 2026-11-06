#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

def run():
    print("=== Starting Full OOMU Verification ===")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15"
        )
        page.goto("http://localhost:8086", wait_until="domcontentloaded")
        time.sleep(4)

        # 1. Login with test account (우리동네_초연)
        print("1. Logging in as test user 초연...")
        page.mouse.click(245, 32) # '🧪 테스트 계정' button
        time.sleep(1.5)
        page.mouse.click(195, 740) # 4th tile: 초연 (test11@naver.com)
        time.sleep(3)

        # Capture Home (전체)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_01_home_all.png"))
        print("  [OK] Saved audit_v3_01_home_all.png")

        # 2. Test '취향 아지트' category tab (x=280, y=105)
        print("2. Clicking '취향 아지트' category tab...")
        page.mouse.click(280, 105)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_02_tab_azit.png"))
        print("  [OK] Saved audit_v3_02_tab_azit.png")

        # 3. Test '오늘 번개' category tab (x=155, y=105)
        print("3. Clicking '오늘 번개' category tab...")
        page.mouse.click(155, 105)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_03_tab_lightning.png"))
        print("  [OK] Saved audit_v3_03_tab_lightning.png")

        # 4. Scroll category bar to reach '라이프 메이트'
        # Drag from x=300 to x=100 at y=105
        print("4. Dragging category bar to reveal '라이프 메이트'...")
        page.mouse.move(320, 105)
        page.mouse.down()
        page.mouse.move(80, 105, steps=10)
        page.mouse.up()
        time.sleep(1)
        # Click the revealed chip around x=200, y=105
        page.mouse.click(220, 105)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_04_tab_lifemate.png"))
        print("  [OK] Saved audit_v3_04_tab_lifemate.png")

        # 5. Explore Map Screen (발견 tab: x=195, y=815)
        print("5. Clicking '발견' (Map) tab...")
        page.mouse.click(195, 815)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_05_map_screen.png"))
        print("  [OK] Saved audit_v3_05_map_screen.png")

        # 6. Community Tab (커뮤니티 tab: x=120, y=815)
        print("6. Clicking '커뮤니티' tab...")
        page.mouse.click(120, 815)
        time.sleep(2.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_06_community_feed.png"))
        print("  [OK] Saved audit_v3_06_community_feed.png")

        # Click first post in community feed (around x=195, y=280)
        print("6b. Opening Community Post Detail...")
        page.mouse.click(195, 280)
        time.sleep(2.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_07_community_post_detail.png"))
        print("  [OK] Saved audit_v3_07_community_post_detail.png")

        # 7. Chat Tab (채팅 tab: x=270, y=815)
        # First go back from community detail: top left back button (x=24, y=44)
        print("7. Going back and opening '채팅' tab...")
        page.mouse.click(24, 44)
        time.sleep(1.5)
        page.mouse.click(270, 815) # 채팅 tab
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_08_chat_list.png"))
        print("  [OK] Saved audit_v3_08_chat_list.png")

        # Open first chat room in list (around x=195, y=140)
        print("7b. Opening Chat Room...")
        page.mouse.click(195, 140)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_09_chat_room.png"))
        print("  [OK] Saved audit_v3_09_chat_room.png")

        # Go back from chat room (x=24, y=44)
        page.mouse.click(24, 44)
        time.sleep(1)

        # 8. My Page Tab (MY tab: x=350, y=815)
        print("8. Opening 'MY' tab...")
        page.mouse.click(350, 815)
        time.sleep(2.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_10_mypage.png"))
        print("  [OK] Saved audit_v3_10_mypage.png")

        # Click '내 프로필 보기' button on My Page (around x=195, y=190)
        print("8b. Opening '내 프로필 보기'...")
        page.mouse.click(195, 190)
        time.sleep(2.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v3_11_user_profile.png"))
        print("  [OK] Saved audit_v3_11_user_profile.png")

        browser.close()
        print("=== Full E2E Verification Complete! ===")

if __name__ == "__main__":
    run()
