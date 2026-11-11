#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

def test_flows():
    print("=== Testing Specific Flows ===")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15"
        )
        page.goto("http://localhost:8086", wait_until="domcontentloaded")
        time.sleep(4)

        # 1. Login with test account (우리동네_초연)
        print("1. Logging in as 초연...")
        page.mouse.click(245, 32) # '🧪 테스트 계정'
        time.sleep(1.5)
        page.mouse.click(195, 740) # 초연 (choyeon@test.oomu.app)
        time.sleep(3)

        # 2. Open ExploreMapScreen via '지도에서 모임' shortcut at (120, 170)
        print("2. Opening '지도에서 모임'...")
        page.mouse.click(120, 170)
        time.sleep(3.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v4_01_explore_map.png"))
        print("  [OK] Saved audit_v4_01_explore_map.png")

        # Go back to home (x=24, y=44)
        print("2b. Going back to Home...")
        page.mouse.click(24, 44)
        time.sleep(2)

        # 3. Test '라이프 메이트' tab
        print("3. Testing '라이프 메이트' tab...")
        # Drag category bar leftwards: from x=320 to x=80
        page.mouse.move(320, 105)
        page.mouse.down()
        page.mouse.move(80, 105, steps=10)
        page.mouse.up()
        time.sleep(1)
        # Click revealed '라이프 메이트' chip
        page.mouse.click(220, 105)
        time.sleep(2.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v4_02_tab_lifemate.png"))
        print("  [OK] Saved audit_v4_02_tab_lifemate.png")

        # 4. Open My Page -> '내 프로필 보기'
        print("4. Testing My Page and '내 프로필 보기'...")
        page.mouse.click(350, 815) # MY tab
        time.sleep(2)
        # Click '내 프로필 보기' at (200, 365)
        page.mouse.click(200, 365)
        time.sleep(2.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v4_03_user_profile_screen.png"))
        print("  [OK] Saved audit_v4_03_user_profile_screen.png")

        # Go back to My Page (x=24, y=44)
        page.mouse.click(24, 44)
        time.sleep(1.5)
        # Scroll My Page down to reveal Interests & Hobbies
        print("4b. Scrolling My Page to view Interests/Hobbies...")
        page.mouse.move(195, 600)
        page.mouse.down()
        page.mouse.move(195, 200, steps=10)
        page.mouse.up()
        time.sleep(1.5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v4_04_mypage_scrolled.png"))
        print("  [OK] Saved audit_v4_04_mypage_scrolled.png")

        # 5. Open Chat Room and test coral message bubble
        print("5. Testing Chat Room...")
        page.mouse.click(270, 815) # Chat tab
        time.sleep(2)
        page.mouse.click(195, 140) # 1st chat room
        time.sleep(2)
        # Type a message in input box (x=240, y=815)
        page.mouse.click(240, 815)
        time.sleep(0.5)
        page.keyboard.type("안녕하세요 여수 화장동 초연입니다! 반가워요~")
        time.sleep(0.5)
        page.mouse.click(370, 815) # Send button
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_v4_05_chat_room_sent.png"))
        print("  [OK] Saved audit_v4_05_chat_room_sent.png")

        browser.close()
        print("=== Specific Flows Verification Complete! ===")

if __name__ == "__main__":
    test_flows()
