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

        # 1. Login & Splash/Onboarding Screen
        print("[1/10] Capturing Login Screen...")
        page = context.new_page()
        page.goto(f"http://localhost:{PORT}/#/", wait_until="domcontentloaded")
        time.sleep(5)
        path1 = os.path.join(ARTIFACT_DIR, "screen_01_login.png")
        page.screenshot(path=path1)
        print(f"[OK] Saved: {path1}")

        # 2. Home Feed (Navigate via ?home=true)
        print("[2/10] Capturing Home Feed...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(6)
        path2 = os.path.join(ARTIFACT_DIR, "screen_02_home_feed.png")
        page.screenshot(path=path2)
        print(f"[OK] Saved: {path2}")

        # 3. Home Category Filter (Click 러닝 or 카페 chip)
        print("[3/10] Clicking category chip '카페·디저트'...")
        # Category chips are near top: click around x=260, y=140
        page.mouse.click(260, 140)
        time.sleep(2)
        path3 = os.path.join(ARTIFACT_DIR, "screen_03_home_filtered.png")
        page.screenshot(path=path3)
        print(f"[OK] Saved: {path3}")

        # Reset to 전체 chip
        page.mouse.click(40, 140)
        time.sleep(1)

        # 4. Scroll Down to '공연·전시와 동네 발견' Section
        print("[4/10] Scrolling to Discovery Section...")
        page.mouse.move(195, 700)
        page.mouse.down()
        page.mouse.move(195, 200, steps=25)
        page.mouse.up()
        time.sleep(2)
        page.mouse.move(195, 700)
        page.mouse.down()
        page.mouse.move(195, 200, steps=25)
        page.mouse.up()
        time.sleep(2)
        path4 = os.path.join(ARTIFACT_DIR, "screen_04_home_discovery.png")
        page.screenshot(path=path4)
        print(f"[OK] Saved: {path4}")

        # 5. Meetup Detail Screen
        print("[5/10] Capturing Meetup Detail Screen...")
        page.goto(f"http://localhost:{PORT}/?detail=true&id=seed_seed_running_weekend_1114#/?detail=true&id=seed_seed_running_weekend_1114", wait_until="domcontentloaded")
        time.sleep(6)
        path5 = os.path.join(ARTIFACT_DIR, "screen_05_meetup_detail.png")
        page.screenshot(path=path5)
        print(f"[OK] Saved: {path5}")

        # 6. Community Screen (Bottom Navigation Tab 2)
        print("[6/10] Capturing Community Screen...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        # Click bottom nav tab 2 (Community is 4th icon or tab at x=290, y=815)
        page.mouse.click(290, 815)
        time.sleep(3)
        path6 = os.path.join(ARTIFACT_DIR, "screen_06_community_tab.png")
        page.screenshot(path=path6)
        print(f"[OK] Saved: {path6}")

        # 7. Notification Center (Click bell icon at top right x=355, y=55)
        print("[7/10] Capturing Notification Screen...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        page.mouse.click(355, 55)
        time.sleep(3)
        path7 = os.path.join(ARTIFACT_DIR, "screen_07_notification_center.png")
        page.screenshot(path=path7)
        print(f"[OK] Saved: {path7}")

        # 8. MyPage Screen (Bottom Navigation Tab 3 at x=350, y=815)
        print("[8/10] Capturing MyPage Screen...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        page.mouse.click(350, 815)
        time.sleep(3)
        path8 = os.path.join(ARTIFACT_DIR, "screen_08_mypage.png")
        page.screenshot(path=path8)
        print(f"[OK] Saved: {path8}")

        # 9. MyPage Scroll down (to see customer support 4 rows & dividers)
        print("[9/10] Scrolling MyPage to see settings & support...")
        page.mouse.move(195, 650)
        page.mouse.down()
        page.mouse.move(195, 250, steps=20)
        page.mouse.up()
        time.sleep(2)
        path9 = os.path.join(ARTIFACT_DIR, "screen_09_mypage_support_rows.png")
        page.screenshot(path=path9)
        print(f"[OK] Saved: {path9}")

        # 10. Meetup Host / Creation Screen (Click + FAB at center x=195, y=780)
        print("[10/10] Capturing Meetup Host Screen...")
        page.goto(f"http://localhost:{PORT}/?home=true#/?home=true", wait_until="domcontentloaded")
        time.sleep(4)
        page.mouse.click(195, 780)
        time.sleep(3)
        path10 = os.path.join(ARTIFACT_DIR, "screen_10_meetup_host.png")
        page.screenshot(path=path10)
        print(f"[OK] Saved: {path10}")

        browser.close()
        print("\n[ALL 10 SCREENSHOTS CAPTURED SUCCESSFULLY]")
finally:
    server.terminate()
