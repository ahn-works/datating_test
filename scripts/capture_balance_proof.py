import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(
        viewport={"width": 390, "height": 844},
        device_scale_factor=2.0,
    )
    url = "http://localhost:8086/?fortune=true#/?fortune=true"
    print(f"Loading {url}...")
    page.goto(url, wait_until="domcontentloaded")
    time.sleep(6)

    # Scroll down to reveal balance battle
    page.mouse.wheel(0, 420)
    time.sleep(2)

    # Tap Option A in balance battle (around x: 100, y: 350 after scroll)
    page.mouse.click(100, 350)
    time.sleep(2)

    out_balance = os.path.join(ARTIFACT_DIR, "proof_08_balance_battle.png")
    page.screenshot(path=out_balance)
    print(f"Saved: {out_balance}")

    browser.close()
print("Done!")
