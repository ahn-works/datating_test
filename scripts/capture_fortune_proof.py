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

    # Save clean fortune view
    out_fortune = os.path.join(ARTIFACT_DIR, "proof_08_play_and_fortune.png")
    page.screenshot(path=out_fortune)
    print(f"Saved: {out_fortune}")

    # Flip Tarot Card 1 (around x: 70, y: 560)
    page.mouse.click(70, 560)
    time.sleep(1)

    # Tap Balance Battle option A (around x: 120, y: 720)
    page.mouse.click(120, 720)
    time.sleep(1)

    out_interactive = os.path.join(ARTIFACT_DIR, "proof_08_play_and_fortune_interactive.png")
    page.screenshot(path=out_interactive)
    print(f"Saved: {out_interactive}")

    browser.close()
print("Done!")
