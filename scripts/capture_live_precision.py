import os
import sys
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
BASE_URL = "https://ahn-works.github.io/datating_test"

def wait_for_flutter(page, max_wait=20):
    for i in range(max_wait):
        time.sleep(1)
        splash_hidden = page.evaluate('''() => {
            const splash = document.getElementById('oomu-loading-splash');
            return !splash || splash.style.display === 'none' || splash.style.opacity === '0' || getComputedStyle(splash).display === 'none';
        }''')
        has_canvas = page.evaluate('''() => {
            return !!document.querySelector('canvas, flt-glass-pane, flutter-view');
        }''')
        if has_canvas and splash_hidden:
            time.sleep(2)
            return True
    return False

def run():
    print(f"=== Capturing All Live Screens from GitHub Pages: {BASE_URL} ===")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 390, "height": 844},
            device_scale_factor=2.0,
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        )

        # 1. Login Screen
        print("[1/10] Screen 01: Login")
        page = context.new_page()
        page.goto(f"{BASE_URL}/#/", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_01_login.png"))
        page.close()

        # 2. Home Feed
        print("[2/10] Screen 02: Home Feed")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_02_home_feed.png"))
        
        # 3. Category Filter ('카페·디저트' at 280, 112)
        print("[3/10] Screen 03: Category Filter Cafe")
        page.mouse.click(280, 112)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_03_category_cafe.png"))
        page.close()

        # 4. Discovery Hub (Home -> Drag Scroll)
        print("[4/10] Screen 04: Discovery Hub")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(3)
        page.mouse.move(195, 700)
        page.mouse.down()
        page.mouse.move(195, 200, steps=25)
        page.mouse.up()
        time.sleep(2)
        page.mouse.move(195, 700)
        page.mouse.down()
        page.mouse.move(195, 200, steps=25)
        page.mouse.up()
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_04_discovery_hub.png"))
        page.close()

        # 5. Meetup Detail
        print("[5/10] Screen 05: Meetup Detail")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?detail=true&id=seed_seed_running_weekend_1114#/?detail=true&id=seed_seed_running_weekend_1114", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_05_meetup_detail.png"))
        page.close()

        # 6. Community Feed (Bottom nav tab 2 at 120, 820)
        print("[6/10] Screen 06: Community")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(3)
        page.mouse.click(120, 820)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_06_community_feed.png"))
        page.close()

        # 7. Notification Center (Bell at 368, 35)
        print("[7/10] Screen 07: Notification Center")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(3)
        page.mouse.click(368, 35)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_07_notification_center.png"))
        page.close()

        # 8. Meetup Host Form (FAB at 340, 780)
        print("[8/10] Screen 08: Meetup Host Form")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(3)
        page.mouse.click(340, 780)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_08_meetup_host.png"))
        page.close()

        # 9. MyPage (Tab 5 at 350, 820)
        print("[9/10] Screen 09: MyPage")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(3)
        page.mouse.click(350, 820)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_09_mypage.png"))

        # 10. Saved Meetups (From MyPage, click '찜한 모임' at 195, 345)
        print("[10/10] Screen 10: Saved Meetups")
        page.mouse.click(195, 345)
        time.sleep(4)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "live_gh_10_saved_meetups.png"))
        page.close()

        browser.close()
        print("\n=== All 10 screens captured from GitHub Pages! ===")

if __name__ == "__main__":
    run()
