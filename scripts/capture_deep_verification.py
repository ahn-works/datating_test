import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\developersim\.gemini\antigravity\brain\530b5062-25fa-4820-926b-8dec02c9bf27"

PORT = 8095
web_dir = os.path.abspath("build_test")
print(f"Starting server on port {PORT} in {web_dir}...")
server = subprocess.Popen([sys.executable, "-m", "http.server", str(PORT), "--directory", web_dir])

try:
    time.sleep(2)
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            viewport={"width": 390, "height": 844},
            device_scale_factor=2.0,
        )

        base_url = f"http://localhost:{PORT}/datating_test/"
        print(f"1. Loading Home from {base_url}...")
        page.goto(base_url, wait_until="domcontentloaded")
        time.sleep(12)

        # Click '둘러보기 (게스트)'
        print("Clicking 둘러보기 (게스트) at (140, 795)...")
        page.mouse.click(140, 795)
        time.sleep(5)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_10_app_home_clean.png"))

        # 2. Go to Discovery Tab
        print("Clicking 발견 at (195, 815)...")
        page.mouse.click(195, 815)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_11_discovery_hub.png"))

        # Scroll to see new high-res contextual images (subsidies & discounts)
        page.mouse.wheel(0, 700)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_12_discovery_subsidies.png"))

        # 3. Go to Community Tab
        print("Clicking 커뮤니티 at (117, 815)...")
        page.mouse.click(117, 815)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_13_community_feed.png"))

        # Click first community post to verify relative time & comments
        page.mouse.click(200, 240)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_14_community_post_detail.png"))

        # Scroll down in community post detail to see user's comment & heart like
        page.mouse.wheel(0, 600)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_15_community_comments_like.png"))

        # 4. Go to Meetup Detail & Check Map
        print("Clicking 동네모임 at (40, 815)...")
        page.mouse.click(40, 815)
        time.sleep(3)
        # Click first meetup card
        page.mouse.click(200, 320)
        time.sleep(4)
        page.mouse.wheel(0, 1100)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_16_meetup_map_and_actions.png"))

        # 5. Go to MY Page
        print("Clicking MY at (350, 815)...")
        page.mouse.click(350, 815)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_17_mypage_clean.png"))

        # Click '프로필 수정' (approx 315, 148)
        page.mouse.click(315, 148)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_18_profile_edit_screen.png"))

        browser.close()
    print("Full verification captured successfully!")
finally:
    server.terminate()
