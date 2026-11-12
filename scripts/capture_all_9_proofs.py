import os
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

screens = [
    ("proof_01_profile_detail", "http://localhost:8086/?profile=true&user=test11#/?profile=true&user=test11"),
    ("proof_02_my_page_badges", "http://localhost:8086/?my=true&user=test11#/?my=true&user=test11"),
    ("proof_03_profile_edit", "http://localhost:8086/?edit=true&user=test11#/?edit=true&user=test11"),
    ("proof_04_chat_room", "http://localhost:8086/?chat_room=true#/?chat_room=true"),
    ("proof_05_community_detail", "http://localhost:8086/?comm_detail=true#/?comm_detail=true"),
    ("proof_06_community_create", "http://localhost:8086/?comm_create=true#/?comm_create=true"),
    ("proof_07_discovery_hub", "http://localhost:8086/?home=true#/?home=true"),
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
        time.sleep(6)

        # For discovery hub, click on the Discovery tab (3rd tab in bottom nav)
        if name == "proof_07_discovery_hub":
            try:
                # Tab 2 in bottom bar (0: 동네모임, 1: 커뮤니티, 2: 발견, 3: 채팅, 4: MY)
                # Let's tap the Discovery icon around x=195, y=815
                page.mouse.click(195, 815)
                time.sleep(4)
                out_path = os.path.join(ARTIFACT_DIR, "proof_07_discovery_all_posters.png")
                page.screenshot(path=out_path)
                print(f"Saved: {out_path}")

                # Now click on "놀거리·운세" category (6th circle in category row, around x=355, y=280)
                page.mouse.click(355, 275)
                time.sleep(3)
                out_fortune = os.path.join(ARTIFACT_DIR, "proof_08_play_and_fortune.png")
                page.screenshot(path=out_fortune)
                print(f"Saved: {out_fortune}")

                # Also tap Tarot Card 1 to flip it (around x=70, y=420)
                page.mouse.click(70, 420)
                time.sleep(1)
                # Also tap Option A in balance battle (around x=150, y=560)
                page.mouse.click(150, 560)
                time.sleep(2)
                out_flipped = os.path.join(ARTIFACT_DIR, "proof_08_play_and_fortune_interactive.png")
                page.screenshot(path=out_flipped)
                print(f"Saved: {out_flipped}")
            except Exception as e:
                print("Discovery click error:", e)

        out_path = os.path.join(ARTIFACT_DIR, f"{name}.png")
        page.screenshot(path=out_path)
        print(f"Saved: {out_path}")

    browser.close()
print("All screenshots captured successfully!")

