import os
import sys
import time
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
WEB_DIR = r"c:\Users\DT4\Downloads\oomu_app\build\web"
PORT = 8091

class QuietHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)
    def log_message(self, format, *args):
        pass

def start_server():
    server = HTTPServer(('127.0.0.1', PORT), QuietHandler)
    server.serve_forever()

def capture(prefix="home_before"):
    t = threading.Thread(target=start_server, daemon=True)
    t.start()
    time.sleep(1)

    targets = [
        (f"{prefix}_360.png", 360, 780),
        (f"{prefix}_390.png", 390, 844),
        (f"{prefix}_430.png", 430, 932),
    ]

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        for filename, w, h in targets:
            context = browser.new_context(
                viewport={"width": w, "height": h},
                device_scale_factor=1.0,
            )
            page = context.new_page()
            url = f"http://127.0.0.1:{PORT}/datating_test/?home=true#/?home=true"
            print(f"Loading {url} at {w}x{h}...")
            page.goto(url, wait_until="domcontentloaded")
            time.sleep(5)

            out_path = os.path.join(ARTIFACT_DIR, filename)
            page.screenshot(path=out_path, full_page=False)
            print(f"[OK] Saved {out_path}")
            context.close()
        browser.close()
    print("Screenshots captured successfully!")

if __name__ == "__main__":
    prefix = sys.argv[1] if len(sys.argv) > 1 else "home_before"
    capture(prefix)

