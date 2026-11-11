import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 390, "height": 844})
    print("Navigating to http://127.0.0.1:8086/...")
    page.goto("http://127.0.0.1:8086/", wait_until="domcontentloaded")
    time.sleep(5)
    page.screenshot(path=os.path.join(ARTIFACT_DIR, "root_default_5s.png"))
    time.sleep(4)
    page.screenshot(path=os.path.join(ARTIFACT_DIR, "root_default_9s.png"))
    browser.close()
print("Captured root default!")
