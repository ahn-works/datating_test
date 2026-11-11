import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

screens = [
    ("new_design_01_home", "http://localhost:8086/?home=true#/?home=true"),
    ("new_design_02_detail", "http://localhost:8086/?detail=true#/?detail=true"),
    ("new_design_03_community", "http://localhost:8086/?comm_detail=true#/?comm_detail=true"),
    ("new_design_04_chat_room", "http://localhost:8086/?chat_room=true#/?chat_room=true"),
    ("new_design_05_my", "http://localhost:8086/?my=true#/?my=true"),
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
        out_path = os.path.join(ARTIFACT_DIR, f"{name}.png")
        page.screenshot(path=out_path)
        print(f"Saved: {out_path}")
    browser.close()
print("Done!")

