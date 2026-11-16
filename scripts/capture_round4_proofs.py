import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
PORT = 8092
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

        # 1. Profile Setup Escape Screen
        print("[1/4] Loading Profile Setup screen...")
        page1 = context.new_page()
        page1.goto(f"http://localhost:{PORT}/datating_test/?setup=true#/?setup=true", wait_until="domcontentloaded")
        time.sleep(6)

        path1 = os.path.join(ARTIFACT_DIR, "round4_01_profile_setup_escape.png")
        page1.screenshot(path=path1)
        print(f"[OK] Saved: {path1}")

        # 2. Tap '나중에 하기' to open exit confirmation dialog
        print("[2/4] Clicking '나중에 하기' to show exit dialog...")
        page1.mouse.click(335, 36)
        time.sleep(2)

        path2 = os.path.join(ARTIFACT_DIR, "round4_02_profile_exit_dialog.png")
        page1.screenshot(path=path2)
        print(f"[OK] Saved: {path2}")
        page1.close()

        # 3. User Profile Detail Screen with 2-column Key-Value rows
        print("[3/4] Loading User Profile Preview screen...")
        page2 = context.new_page()
        page2.goto(f"http://localhost:{PORT}/datating_test/?preview=true#/?preview=true", wait_until="domcontentloaded")
        time.sleep(6)

        # Scroll down to reveal Basic Info 2-column rows
        page2.mouse.move(195, 700)
        page2.mouse.down()
        page2.mouse.move(195, 250, steps=20)
        page2.mouse.up()
        time.sleep(2)

        path3 = os.path.join(ARTIFACT_DIR, "round4_03_profile_detail_qa_labels.png")
        page2.screenshot(path=path3)
        print(f"[OK] Saved: {path3}")
        page2.close()

        # 4. MyPage Screen with Lifestyle & Basic Info Card
        print("[4/4] Loading MyPage screen...")
        page3 = context.new_page()
        page3.goto(f"http://localhost:{PORT}/datating_test/?my=true#/?my=true", wait_until="domcontentloaded")
        time.sleep(6)

        # Scroll down slightly to see basic info card
        page3.mouse.move(195, 600)
        page3.mouse.down()
        page3.mouse.move(195, 300, steps=20)
        page3.mouse.up()
        time.sleep(2)

        path4 = os.path.join(ARTIFACT_DIR, "round4_04_mypage_profile_section.png")
        page3.screenshot(path=path4)
        print(f"[OK] Saved: {path4}")
        page3.close()

        browser.close()
        print("[ALL SCREENSHOTS CAPTURED SUCCESSFULLY]")
finally:
    server.terminate()
