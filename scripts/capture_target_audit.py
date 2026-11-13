import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
PORT = 8089
web_dir = os.path.abspath(r"build\web")

server = subprocess.Popen([sys.executable, "-m", "http.server", str(PORT), "--directory", web_dir])

try:
    time.sleep(2)
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 390, "height": 844},
            device_scale_factor=2.0,
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        )

        base_url = f"http://localhost:{PORT}/"

        # 1. MY Page directly from fresh tab
        page1 = context.new_page()
        page1.goto(base_url, wait_until="domcontentloaded")
        time.sleep(12)
        # click guest
        try:
            page1.mouse.click(140, 795)
            time.sleep(4)
        except:
            pass

        # Click MY tab (x=350, y=815)
        print("Clicking MY Tab...")
        page1.mouse.click(350, 815)
        time.sleep(4)
        page1.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_target_01_mypage.png"))

        # Click '프로필 수정' (approx 315, 140)
        print("Clicking Profile Edit...")
        page1.mouse.click(315, 140)
        time.sleep(4)
        page1.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_target_02_profile_edit_top.png"))

        # Scroll down in Profile Edit to see Personality & Bio & Preview banner
        page1.mouse.wheel(0, 600)
        time.sleep(2)
        page1.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_target_02_profile_edit_mid.png"))

        page1.mouse.wheel(0, 600)
        time.sleep(2)
        page1.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_target_02_profile_edit_preview_btn.png"))
        page1.close()

        # 2. Meetup Detail (from Home, click first card)
        page2 = context.new_page()
        page2.goto(base_url, wait_until="domcontentloaded")
        time.sleep(10)
        page2.mouse.click(140, 795) # guest
        time.sleep(4)
        print("Clicking first meetup card...")
        page2.mouse.click(200, 320)
        time.sleep(4)
        # Scroll to map & member avatars
        page2.mouse.wheel(0, 1100)
        time.sleep(3)
        page2.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_target_03_meetup_detail_map.png"))
        page2.close()

        # 3. Discovery Subsidies & Food Cards
        page3 = context.new_page()
        page3.goto(base_url, wait_until="domcontentloaded")
        time.sleep(10)
        page3.mouse.click(140, 795) # guest
        time.sleep(4)
        # Click Discovery Tab (195, 815)
        page3.mouse.click(195, 815)
        time.sleep(4)
        # Click '청년지원금' chip (approx x=245, y=390)
        print("Clicking 청년지원금 chip...")
        page3.mouse.click(245, 390)
        time.sleep(3)
        page3.mouse.wheel(0, 400)
        time.sleep(2)
        page3.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_target_04_discovery_subsidies.png"))

        # Click '날씨·맛집' chip (approx x=120, y=390)
        print("Clicking 날씨·맛집 chip...")
        page3.mouse.click(120, 390)
        time.sleep(3)
        page3.mouse.wheel(0, 400)
        time.sleep(2)
        page3.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_target_04_discovery_restaurants.png"))
        page3.close()

        browser.close()
        print("Target audit completed successfully!")
finally:
    server.terminate()

