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
    url = "http://localhost:8086/?profile=true&user=test11#/?profile=true&user=test11"
    page.goto(url, wait_until="domcontentloaded")
    time.sleep(6)

    # Touch drag up to scroll down
    page.mouse.move(195, 700)
    page.mouse.down()
    page.mouse.move(195, 150, steps=20)
    page.mouse.up()
    time.sleep(2)

    # Do a second drag to scroll all the way to bottom
    page.mouse.move(195, 700)
    page.mouse.down()
    page.mouse.move(195, 200, steps=20)
    page.mouse.up()
    time.sleep(2)

    out_bottom = os.path.join(ARTIFACT_DIR, "proof_issue3_profile_detail_bottom_scrolled.png")
    page.screenshot(path=out_bottom)
    print(f"Saved: {out_bottom}")

    browser.close()
print("Done!")
