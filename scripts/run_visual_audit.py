import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

def run():
    print("=== Visual Audit for Restored Chat & Community ===")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15"
        )
        page.goto("http://localhost:8086", wait_until="domcontentloaded")
        time.sleep(5)

        # 1. Login with 초연 (test11@naver.com)
        print("1. Opening Test Account Modal...")
        page.mouse.click(245, 32)
        time.sleep(2.5)

        print("1b. Selecting 초연...")
        page.mouse.click(195, 740)
        time.sleep(4)

        # 2. Check Community Tab (x=117, y=815)
        print("2. Navigating to Community Tab...")
        page.mouse.click(117, 815)
        time.sleep(3)
        path_comm = os.path.join(ARTIFACT_DIR, "audit_verify_community_feed.png")
        page.screenshot(path=path_comm)
        print(f"  [OK] Saved: {path_comm}")

        # 2b. Open first community post (around y=260)
        print("2b. Opening Community Post Detail...")
        page.mouse.click(195, 260)
        time.sleep(3)
        path_detail = os.path.join(ARTIFACT_DIR, "audit_verify_community_comments.png")
        page.screenshot(path=path_detail)
        print(f"  [OK] Saved: {path_detail}")

        # Go back (x=24, y=44)
        page.mouse.click(24, 44)
        time.sleep(2)

        # 3. Check Chat Tab (x=273, y=815)
        print("3. Navigating to Chat Tab...")
        page.mouse.click(273, 815)
        time.sleep(3)
        path_chat_list = os.path.join(ARTIFACT_DIR, "audit_verify_chat_list.png")
        page.screenshot(path=path_chat_list)
        print(f"  [OK] Saved: {path_chat_list}")

        # 3b. Click on the first chat room (around y=130)
        print("3b. Entering Chat Room...")
        page.mouse.click(195, 130)
        time.sleep(3)
        path_room = os.path.join(ARTIFACT_DIR, "audit_verify_chat_room_clean.png")
        page.screenshot(path=path_room)
        print(f"  [OK] Saved: {path_room}")

        # 3c. Click '+' button beside input bar (x=24, y=818)
        print("3c. Clicking '+' Button for Karrot Menu...")
        page.mouse.click(24, 818)
        time.sleep(2.5)
        path_plus = os.path.join(ARTIFACT_DIR, "audit_verify_chat_karrot_menu.png")
        page.screenshot(path=path_plus)
        print(f"  [OK] Saved: {path_plus}")

        browser.close()
        print("All Visual Verification Finished Successfully!")

if __name__ == "__main__":
    run()
