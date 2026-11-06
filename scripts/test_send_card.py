import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

def run():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15"
        )
        page.goto("http://localhost:8086", wait_until="domcontentloaded")
        time.sleep(5)

        # Login as 초연
        page.mouse.click(245, 32)
        time.sleep(2.5)
        page.mouse.click(195, 740)
        time.sleep(4)

        # Go to Chat tab
        page.mouse.click(273, 815)
        time.sleep(3)

        # Open chat room
        page.mouse.click(195, 130)
        time.sleep(3)

        # Click '+' button
        page.mouse.click(24, 818)
        time.sleep(2)

        # Click '안심 귀가' (x=144, y=740)
        print("Clicking '안심 귀가' button...")
        page.mouse.click(144, 740)
        time.sleep(3)

        path_sent_card = os.path.join(ARTIFACT_DIR, "audit_verify_chat_card_rendered.png")
        page.screenshot(path=path_sent_card)
        print(f"Saved: {path_sent_card}")

        browser.close()

if __name__ == "__main__":
    run()

