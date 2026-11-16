import http.server
import socketserver
import threading
import time
from playwright.sync_api import sync_playwright

PORT = 8089
DIRECTORY = 'build/web'

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def start_server():
    try:
        with socketserver.TCPServer(("", PORT), Handler) as httpd:
            print(f"Serving at port {PORT}")
            httpd.serve_forever()
    except Exception as e:
        print("Server error/already running:", e)

server_thread = threading.Thread(target=start_server, daemon=True)
server_thread.start()
time.sleep(1)

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context(viewport={'width': 412, 'height': 892})
    page = context.new_page()
    page.goto(f"http://localhost:{PORT}/")
    print("Waiting for login screen to fully render...")
    time.sleep(8)
    
    # Click guest login button coordinates (x=135, y=850)
    print("Clicking 둘러보기 (게스트) at coordinates (135, 850)...")
    page.mouse.click(135, 850)
    
    # Wait for Home Screen to render
    print("Waiting 10 seconds for home feed to render...")
    time.sleep(10)
    
    screenshot_path = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861\guest_home_feed_no_gray_box.png"
    page.screenshot(path=screenshot_path)
    print("Screenshot saved to", screenshot_path)
    browser.close()
