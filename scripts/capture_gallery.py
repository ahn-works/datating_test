import os
import sys
import time
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"
WEB_DIR = r"c:\Users\DT4\Downloads\oomu_app\build\web"
PORT = 8089

class QuietHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)
    def log_message(self, format, *args):
        pass

def start_server():
    server = HTTPServer(('127.0.0.1', PORT), QuietHandler)
    server.serve_forever()

def capture():
    t = threading.Thread(target=start_server, daemon=True)
    t.start()
    time.sleep(1)

    targets = [
        ("gallery_360_scale_10.png", 360, 780, 1.0),
        ("gallery_360_scale_20.png", 360, 780, 2.0),
        ("gallery_390_scale_10.png", 390, 844, 1.0),
        ("gallery_390_scale_20.png", 390, 844, 2.0),
        ("gallery_430_scale_10.png", 430, 932, 1.0),
        ("gallery_430_scale_20.png", 430, 932, 2.0),
    ]

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        for filename, w, h, scale in targets:
            context = browser.new_context(
                viewport={"width": w, "height": h},
                device_scale_factor=1.0,
            )
            page = context.new_page()
            url = f"http://127.0.0.1:{PORT}/datating_test/#/?gallery=true"
            print(f"Loading {url} at {w}x{h} scale={scale}...")
            page.goto(url, wait_until="domcontentloaded")
            time.sleep(5)
            
            # If scale is 2.0, we can adjust flutter text scale or zoom if needed, or check page
            if scale != 1.0:
                page.evaluate(f"document.body.style.zoom = '{scale}'")
                time.sleep(1)

            out_path = os.path.join(ARTIFACT_DIR, filename)
            page.screenshot(path=out_path, full_page=False)
            print(f"[OK] Saved {out_path}")
            context.close()
        browser.close()
    print("All gallery screenshots captured successfully!")

if __name__ == "__main__":
    capture()
