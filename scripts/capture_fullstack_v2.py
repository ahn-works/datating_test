import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
PORT = 8088
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

        page = context.new_page()

        # 1. Login Screen
        print("[1/10] Loading Login Screen...")
        page.goto(f"http://localhost:{PORT}/#/", wait_until="domcontentloaded")
        time.sleep(6)
        path1 = os.path.join(ARTIFACT_DIR, "screen_01_login.png")
        page.screenshot(path=path1)
        print(f"[OK] Saved: {path1}")

        # 2. Home Feed (Navigate via ?home=true)
        print("[2/10] Loading Home Feed...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(6)
        path2 = os.path.join(ARTIFACT_DIR, "screen_02_home_feed.png")
        page.screenshot(path=path2)
        print(f"[OK] Saved: {path2}")

        # 3. Category Filter: Click '카페·디저트' chip at (280, 112)
        print("[3/10] Clicking category chip '카페·디저트' at (280, 112)...")
        page.mouse.click(280, 112)
        time.sleep(3)
        path3 = os.path.join(ARTIFACT_DIR, "screen_03_home_filtered_cafe.png")
        page.screenshot(path=path3)
        print(f"[OK] Saved: {path3}")

        # 4. Community Screen (Bottom Navigation Tab 2 at x=120, y=820)
        print("[4/10] Clicking Community tab at (120, 820)...")
        page.mouse.click(120, 820)
        time.sleep(4)
        path4 = os.path.join(ARTIFACT_DIR, "screen_04_community_feed.png")
        page.screenshot(path=path4)
        print(f"[OK] Saved: {path4}")

        # 5. Discovery Section Tab (Bottom Navigation Tab 3 at x=195, y=820)
        print("[5/10] Clicking Discovery Hub tab at (195, 820)...")
        page.mouse.click(195, 820)
        time.sleep(4)
        path5 = os.path.join(ARTIFACT_DIR, "screen_05_discovery_lifestyle_hub.png")
        page.screenshot(path=path5)
        print(f"[OK] Saved: {path5}")

        # 6. Notification Center (Back to Home, then click Bell at x=368, y=35)
        print("[6/10] Loading Notification Center...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        page.mouse.click(368, 35)
        time.sleep(3)
        path6 = os.path.join(ARTIFACT_DIR, "screen_06_notification_center.png")
        page.screenshot(path=path6)
        print(f"[OK] Saved: {path6}")

        # 7. Meetup Host Screen (Back to Home, then click FAB at x=340, y=780)
        print("[7/10] Clicking '+ 모임 열기' FAB at (340, 780)...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        page.mouse.click(340, 780)
        time.sleep(4)
        path7 = os.path.join(ARTIFACT_DIR, "screen_07_meetup_host_form.png")
        page.screenshot(path=path7)
        print(f"[OK] Saved: {path7}")

        # 8. User Profile Preview Screen
        print("[8/10] Loading User Profile Screen...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        # Go to MyPage (x=350, y=820)
        page.mouse.click(350, 820)
        time.sleep(3)
        # Click Profile Avatar/Nickname at (120, 140) to view profile
        page.mouse.click(120, 140)
        time.sleep(3)
        path8 = os.path.join(ARTIFACT_DIR, "screen_08_user_profile_detail.png")
        page.screenshot(path=path8)
        print(f"[OK] Saved: {path8}")

        # 9. Profile Edit Screen (From MyPage, click '프로필 수정' at x=325, y=145)
        print("[9/10] Loading Profile Edit Screen...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        page.mouse.click(350, 820)
        time.sleep(3)
        page.mouse.click(325, 145)
        time.sleep(3)
        path9 = os.path.join(ARTIFACT_DIR, "screen_09_profile_edit.png")
        page.screenshot(path=path9)
        print(f"[OK] Saved: {path9}")

        # 10. Saved Meetups Screen (From MyPage, click '찜한 모임' at x=195, y=345)
        print("[10/10] Loading Saved Meetups Screen...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        page.mouse.click(350, 820)
        time.sleep(3)
        page.mouse.click(195, 345)
        time.sleep(3)
        path10 = os.path.join(ARTIFACT_DIR, "screen_10_saved_meetups.png")
        page.screenshot(path=path10)
        print(f"[OK] Saved: {path10}")

        browser.close()
        print("\n[ALL 10 TARGET SCREENS CAPTURED]")
finally:
    server.terminate()
