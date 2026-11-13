import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
PORT = 8088
web_dir = os.path.abspath(r"build\web")

print(f"Starting http.server on port {PORT} in {web_dir}...")
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
        page = context.new_page()

        base_url = f"http://localhost:{PORT}/"
        print(f"1. Loading Home from {base_url}...")
        page.goto(base_url, wait_until="domcontentloaded")
        time.sleep(12)

        # Click '둘러보기 (게스트)' if on login/splash
        try:
            guest_btn = page.locator("text=둘러보기")
            if guest_btn.count() > 0:
                print("Clicking 둘러보기 button...")
                guest_btn.first.click()
                time.sleep(4)
            else:
                page.mouse.click(140, 795)
                time.sleep(4)
        except Exception as e:
            print(f"Guest click handled: {e}")

        # Capture 1: Home Screen
        print("Capturing 1. Home Screen...")
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_01_home.png"))

        # Capture 2: Discovery Tab
        print("Capturing 2. Discovery Tab...")
        page.mouse.click(195, 815)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_02_discovery_hub.png"))

        # Scroll Discovery down to see high-res subsidies and restaurants
        page.mouse.wheel(0, 750)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_02_discovery_subsidies.png"))

        # Capture 3: Community Tab
        print("Capturing 3. Community Tab...")
        page.mouse.click(117, 815)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_03_community_feed.png"))

        # Click first community post
        page.mouse.click(200, 240)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_03_community_post_detail.png"))

        # Go back to Meetup list and click first meetup
        print("Capturing 4. Meetup Detail...")
        page.mouse.click(40, 815) # 동네모임
        time.sleep(3)
        page.mouse.click(200, 320) # first meetup
        time.sleep(4)
        page.mouse.wheel(0, 1100) # scroll to map and members
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_04_meetup_detail_map.png"))

        # Capture 5: MY Page
        print("Capturing 5. MY Page...")
        page.mouse.click(350, 815) # MY tab
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_05_mypage.png"))

        # Capture 6: Profile Edit Screen
        print("Capturing 6. Profile Edit Screen...")
        page.mouse.click(315, 148) # 프로필 수정 button
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_06_profile_edit_top.png"))

        # Scroll down in Profile Edit to see section headers and preview banner
        page.mouse.wheel(0, 700)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_06_profile_edit_bottom.png"))

        browser.close()
        print("All audit screenshots captured successfully!")
finally:
    server.terminate()

