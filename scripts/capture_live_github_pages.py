import os
import sys
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
BASE_URL = "https://ahn-works.github.io/datating_test"

def wait_for_flutter(page, max_wait=15):
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
            print(f"  [Ready] in {i+1}s")
            time.sleep(2)  # Extra buffer for canvas paint
            return True
    return False

def run():
    print(f"Starting Live GitHub Pages Capture from: {BASE_URL}")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 390, "height": 844},
            device_scale_factor=2.0,
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        )
        page = context.new_page()

        # 1. Login Screen
        print("\n[1/10] Capturing Login Screen...")
        page.goto(f"{BASE_URL}/", wait_until="domcontentloaded")
        wait_for_flutter(page, 20)
        time.sleep(3)
        path1 = os.path.join(ARTIFACT_DIR, "live_gh_01_login.png")
        page.screenshot(path=path1)
        print(f"  -> Saved: {path1}")

        # 2. Home Feed (Navigate via ?home=true)
        print("\n[2/10] Capturing Home Feed...")
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page, 20)
        time.sleep(4)
        path2 = os.path.join(ARTIFACT_DIR, "live_gh_02_home_feed.png")
        page.screenshot(path=path2)
        print(f"  -> Saved: {path2}")

        # 3. Category Filter: Click '카페·디저트' chip at (280, 112)
        print("\n[3/10] Capturing Category Filter ('카페·디저트')...")
        page.mouse.click(280, 112)
        time.sleep(3)
        path3 = os.path.join(ARTIFACT_DIR, "live_gh_03_category_cafe.png")
        page.screenshot(path=path3)
        print(f"  -> Saved: {path3}")

        # 4. Scroll Down: Discovery & Lifestyle Hub
        print("\n[4/10] Capturing Home Discovery & Lifestyle Hub...")
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page, 15)
        time.sleep(3)
        # Scroll down
        page.mouse.wheel(0, 1200)
        time.sleep(3)
        path4 = os.path.join(ARTIFACT_DIR, "live_gh_04_discovery_hub.png")
        page.screenshot(path=path4)
        print(f"  -> Saved: {path4}")

        # 5. Meetup Detail: Click the first meetup card at (195, 300)
        print("\n[5/10] Capturing Meetup Detail Screen...")
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page, 15)
        time.sleep(3)
        page.mouse.click(195, 300)
        time.sleep(4)
        path5 = os.path.join(ARTIFACT_DIR, "live_gh_05_meetup_detail.png")
        page.screenshot(path=path5)
        print(f"  -> Saved: {path5}")

        # 6. Community Screen (Bottom Navigation Tab 2 at x=120, y=820)
        print("\n[6/10] Capturing Community Feed...")
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page, 15)
        time.sleep(3)
        page.mouse.click(120, 820)
        time.sleep(4)
        path6 = os.path.join(ARTIFACT_DIR, "live_gh_06_community_feed.png")
        page.screenshot(path=path6)
        print(f"  -> Saved: {path6}")

        # 7. Notification Center (Bell at x=368, y=35)
        print("\n[7/10] Capturing Notification Center...")
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page, 15)
        time.sleep(3)
        page.mouse.click(368, 35)
        time.sleep(3)
        path7 = os.path.join(ARTIFACT_DIR, "live_gh_07_notification_center.png")
        page.screenshot(path=path7)
        print(f"  -> Saved: {path7}")

        # 8. Meetup Host Form Screen (FAB '+' at x=340, y=780)
        print("\n[8/10] Capturing Meetup Host Screen...")
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page, 15)
        time.sleep(3)
        page.mouse.click(340, 780)
        time.sleep(4)
        path8 = os.path.join(ARTIFACT_DIR, "live_gh_08_meetup_host.png")
        page.screenshot(path=path8)
        print(f"  -> Saved: {path8}")

        # 9. MyPage (Bottom Nav Tab 4 at x=350, y=820)
        print("\n[9/10] Capturing MyPage Screen...")
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page, 15)
        time.sleep(3)
        page.mouse.click(350, 820)
        time.sleep(4)
        path9 = os.path.join(ARTIFACT_DIR, "live_gh_09_mypage.png")
        page.screenshot(path=path9)
        print(f"  -> Saved: {path9}")

        # 10. Saved Meetups (From MyPage, click '찜한 모임' at x=195, y=345)
        print("\n[10/10] Capturing Saved Meetups Screen...")
        page.mouse.click(195, 345)
        time.sleep(3)
        path10 = os.path.join(ARTIFACT_DIR, "live_gh_10_saved_meetups.png")
        page.screenshot(path=path10)
        print(f"  -> Saved: {path10}")

        browser.close()
        print("\n[SUCCESS] All 10 Live GitHub Pages screens captured successfully!")

if __name__ == "__main__":
    run()
