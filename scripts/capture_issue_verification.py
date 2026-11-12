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

    # 1. Profile detail scrolled down to reveal "관심사 / 취향"
    url_profile = "http://localhost:8086/?profile=true&user=test11#/?profile=true&user=test11"
    print(f"Loading {url_profile}...")
    page.goto(url_profile, wait_until="domcontentloaded")
    time.sleep(6)
    page.mouse.wheel(0, 500)
    time.sleep(2)
    out_profile_bottom = os.path.join(ARTIFACT_DIR, "proof_issue3_profile_detail_bottom.png")
    page.screenshot(path=out_profile_bottom)
    print(f"Saved: {out_profile_bottom}")

    # 2. Community test post detail (showing user's test post with photo and comment)
    url_comm = "http://localhost:8086/?comm_detail=true&test_post=true#/?comm_detail=true&test_post=true"
    print(f"Loading {url_comm}...")
    page.goto(url_comm, wait_until="domcontentloaded")
    time.sleep(6)
    out_comm = os.path.join(ARTIFACT_DIR, "proof_issue1_community_post_image.png")
    page.screenshot(path=out_comm)
    print(f"Saved: {out_comm}")

    browser.close()
print("Verification capture complete!")
