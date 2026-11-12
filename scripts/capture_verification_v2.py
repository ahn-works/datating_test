import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

screens = [
    ("proof_v2_01_my_trips", "http://localhost:8086/?my_trips=true&user=test11#/?my_trips=true&user=test11"),
    ("proof_v2_02_mypage", "http://localhost:8086/?my=true&user=test11#/?my=true&user=test11"),
    ("proof_v2_03_detail_map", "http://localhost:8086/?detail=true&user=test11#/?detail=true&user=test11"),
    ("proof_v2_05_chat_list_bottom_nav", "http://localhost:8086/?chat=true&user=test11#/?chat=true&user=test11"),
    ("proof_v2_06_discovery_fortune", "http://localhost:8086/?fortune=true#/?fortune=true"),
    ("proof_v2_07_home_concert", "http://localhost:8086/?home=true#/?home=true"),
]

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(
        viewport={"width": 390, "height": 844},
        device_scale_factor=2.0,
    )
    for name, url in screens:
        print(f"Loading {name} at {url}...")
        page.goto(url, wait_until="domcontentloaded")
        time.sleep(5)

        if name == "proof_v2_03_detail_map":
            # Scroll down to show map and remaining seats / manners
            page.mouse.wheel(0, 1100)
            time.sleep(3)

        if name == "proof_v2_07_home_concert":
            # Scroll down to discovery section
            page.mouse.wheel(0, 1000)
            time.sleep(3)

        out_path = os.path.join(ARTIFACT_DIR, f"{name}.png")
        page.screenshot(path=out_path)
        print(f"Saved: {out_path}")

    browser.close()
print("All verification screenshots captured successfully!")
