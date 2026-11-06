#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

def run():
    print("=== Capturing Final Proofs ===")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15"
        )
        page.goto("http://localhost:8086", wait_until="domcontentloaded")
        time.sleep(5)

        # 1. Login with test account (우리동네_초연)
        print("1. Opening Test Account Modal...")
        page.mouse.click(245, 32) # '🧪 테스트 계정'
        time.sleep(2.5) # Wait for bottom sheet animation

        print("1b. Selecting 초연...")
        page.mouse.click(195, 740) # 4th tile: 초연
        time.sleep(4) # Wait for login & home navigation

        # 2. Open ExploreMapScreen via top app bar map icon at (272, 32)
        print("2. Opening ExploreMapScreen (지도)...")
        page.mouse.click(272, 32)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_final_01_explore_map.png"))
        print("  [OK] Saved audit_final_01_explore_map.png")

        # Go back to Home
        print("2b. Going back to Home...")
        page.mouse.click(24, 44)
        time.sleep(2)

        # 3. Category Tab: '라이프 메이트'
        # On Home screen: Category row is at y=105.
        # Drag leftwards: from (350, 105) to (50, 105)
        print("3. Scrolling category chips...")
        page.mouse.move(350, 105)
        page.mouse.down()
        page.mouse.move(50, 105, steps=15)
        page.mouse.up()
        time.sleep(1.5)
        # Click the revealed '라이프 메이트' chip around (220, 105)
        print("3b. Clicking '라이프 메이트' chip...")
        page.mouse.click(220, 105)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_final_02_lifemate_tab.png"))
        print("  [OK] Saved audit_final_02_lifemate_tab.png")

        # 4. Open My Page -> '내 프로필 보기'
        print("4. Navigating to My Page (MY tab at x=350, y=815)...")
        page.mouse.click(350, 815)
        time.sleep(3)

        # First scroll down on My Page to see interests/hobbies
        print("4b. Scrolling My Page to view interests/hobbies...")
        page.mouse.move(195, 650)
        page.mouse.down()
        page.mouse.move(195, 250, steps=15)
        page.mouse.up()
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_final_03_mypage_interests.png"))
        print("  [OK] Saved audit_final_03_mypage_interests.png")

        # Scroll back up
        page.mouse.move(195, 250)
        page.mouse.down()
        page.mouse.move(195, 650, steps=15)
        page.mouse.up()
        time.sleep(1.5)

        # Click '[👁️ 내 프로필 보기]' at (110, 365)
        print("4c. Clicking '내 프로필 보기' at (110, 365)...")
        page.mouse.click(110, 365)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_final_04_user_profile.png"))
        print("  [OK] Saved audit_final_04_user_profile.png")

        browser.close()
        print("=== Final Proofs Captured Successfully! ===")

if __name__ == "__main__":
    run()
