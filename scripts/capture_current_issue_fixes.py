import os
import sys
import time
import subprocess
from playwright.sync_api import sync_playwright

OUT_DIR = r"C:\Users\developersim\.gemini\antigravity\brain\530b5062-25fa-4820-926b-8dec02c9bf27"

def main():
    print("Capturing live proof screenshots of community post & verification...")
    # Serve build_test on port 8097
    # Ensure junction build_test\datating_test exists
    os.makedirs(r"build_test", exist_ok=True)
    junction_path = os.path.join(r"build_test", "datating_test")
    if not os.path.exists(junction_path):
        subprocess.run(f'cmd /c mklink /J "{junction_path}" "build\\web"', shell=True)

    server = subprocess.Popen([sys.executable, "-m", "http.server", "8097", "--directory", "build_test"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(2)

    try:
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            context = browser.new_context(
                viewport={"width": 393, "height": 852},
                user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
            )
            page = context.new_page()

            # 1. Community Post Create Screen
            print("1. Community Post Create Screen...")
            page1 = context.new_page()
            page1.goto("http://localhost:8097/datating_test/#/?comm_create=true", wait_until="domcontentloaded")
            time.sleep(6)
            page1.screenshot(path=os.path.join(OUT_DIR, "proof_19_comm_create_custom_image.png"))
            page1.close()

            # 2. Community Post Detail Screen
            print("2. Community Post Detail Screen...")
            page2 = context.new_page()
            page2.goto("http://localhost:8097/datating_test/#/?comm_detail=true", wait_until="domcontentloaded")
            time.sleep(6)
            page2.screenshot(path=os.path.join(OUT_DIR, "proof_20_comm_detail_image_rendered.png"))
            page2.close()

            # 3. Profile Setup Screen (Phone Verification Field)
            print("3. Profile Setup Screen...")
            page3 = context.new_page()
            page3.goto("http://localhost:8097/datating_test/#/?profile_setup=true", wait_until="domcontentloaded")
            time.sleep(6)
            page3.screenshot(path=os.path.join(OUT_DIR, "proof_21_profile_setup_phone_field.png"))
            page3.close()

            # 4. Login Screen
            print("4. Login Screen...")
            page4 = context.new_page()
            page4.goto("http://localhost:8097/datating_test/#/?login=true", wait_until="domcontentloaded")
            time.sleep(6)
            page4.screenshot(path=os.path.join(OUT_DIR, "proof_22_login_screen.png"))
            page4.close()

            browser.close()
            print("All proofs captured successfully!")
    finally:
        server.terminate()

if __name__ == "__main__":
    main()
