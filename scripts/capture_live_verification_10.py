import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\developersim\.gemini\antigravity\brain\530b5062-25fa-4820-926b-8dec02c9bf27"

PORT = 8092
web_dir = os.path.abspath("build_test")
print(f"Starting http.server on port {PORT} in {web_dir}...")
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
        print(f"1. Capturing Mobile Home from {base_url}...")
        page.goto(base_url, wait_until="domcontentloaded")
        time.sleep(14)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_01_home_mobile.png"))

        print("2. Capturing Discovery Lifestyle Hub...")
        page.mouse.click(195, 810)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_02_discovery_hub.png"))

        page.mouse.wheel(0, 800)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_03_discovery_subsidies.png"))

        print("3. Capturing Community Feed...")
        page.mouse.click(117, 810)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_04_community_feed.png"))

        print("4. Capturing MyPage...")
        page.mouse.click(350, 810)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "proof_05_mypage.png"))

        browser.close()
    print("All screenshots captured successfully!")
finally:
    server.terminate()
