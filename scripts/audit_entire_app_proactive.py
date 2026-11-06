import asyncio
import os
from playwright.async_api import async_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

async def capture_all():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15"
        )
        page = await context.new_page()

        print("[START] 1. Intro & Login Screen...")
        await page.goto("http://localhost:8086/oomu_app/", wait_until="domcontentloaded")
        await asyncio.sleep(5)
        p1 = os.path.join(ARTIFACT_DIR, "audit_screen_01_login_tab.png")
        await page.screenshot(path=p1)
        print(f"[OK] 1. Login Tab: {p1}")

        # 1-B: Signup Tab (Click '회원가입' tab at x=280, y=315)
        print("[STEP] 1b. Switching to Signup Tab...")
        await page.mouse.click(280, 315)
        await asyncio.sleep(1.5)
        p1b = os.path.join(ARTIFACT_DIR, "audit_screen_01b_signup_tab.png")
        await page.screenshot(path=p1b)
        print(f"[OK] 1b. SignUp Tab: {p1b}")

        # 1-C: Solapi SMS Phone Modal (Click '휴대폰 번호로 회원가입' at x=195, y=415)
        print("[STEP] 1c. Opening Solapi Phone Modal...")
        await page.mouse.click(195, 415)
        await asyncio.sleep(2)
        p1c = os.path.join(ARTIFACT_DIR, "audit_screen_01c_phone_modal.png")
        await page.screenshot(path=p1c)
        print(f"[OK] 1c. Solapi Phone Modal: {p1c}")

        # Close phone modal by clicking backdrop at x=50, y=100
        await page.mouse.click(50, 100)
        await asyncio.sleep(1.5)

        # 2. Enter via Test User (Click '🧪 테스트 계정' -> 초연 계정)
        print("[STEP] 2. Logging in as Choyeon (여수시 화장동)...")
        await page.mouse.click(245, 32)
        await asyncio.sleep(1.5)
        # Click Choyeon tile at (195, 740)
        await page.mouse.click(195, 740)
        await asyncio.sleep(5)

        # Screen 2: Home Feed (Meetups)
        p2 = os.path.join(ARTIFACT_DIR, "audit_screen_02_home_feed.png")
        await page.screenshot(path=p2)
        print(f"[OK] 2. Home Feed: {p2}")

        # Screen 2-B: Home Feed Trends Section (Scroll down)
        print("[STEP] 2b. Scrolling to Trends & Sports/Cinema...")
        await page.mouse.move(200, 700)
        await page.mouse.down()
        await page.mouse.move(200, 220, steps=25)
        await page.mouse.up()
        await asyncio.sleep(2)
        p2b = os.path.join(ARTIFACT_DIR, "audit_screen_02b_home_trends.png")
        await page.screenshot(path=p2b)
        print(f"[OK] 2b. Home Trends: {p2b}")

        # Scroll back up to top
        await page.mouse.move(200, 220)
        await page.mouse.down()
        await page.mouse.move(200, 700, steps=25)
        await page.mouse.up()
        await asyncio.sleep(2)

        # 3. Meetup Detail (Click first meetup card at x=195, y=340)
        print("[STEP] 3. Opening Meetup Detail...")
        await page.mouse.click(195, 340)
        await asyncio.sleep(3)
        p3 = os.path.join(ARTIFACT_DIR, "audit_screen_03_meetup_detail.png")
        await page.screenshot(path=p3)
        print(f"[OK] 3. Meetup Detail: {p3}")

        # Return to Home (Back button center is at x=28, y=27)
        print("[STEP] Returning to Home...")
        await page.mouse.click(28, 27)
        await asyncio.sleep(2)

        # 4. Community Feed (Bottom Nav Tab 1: x=117, y=815)
        print("[STEP] 4. Navigating to Community Feed...")
        await page.mouse.click(117, 815)
        await asyncio.sleep(3)
        p4 = os.path.join(ARTIFACT_DIR, "audit_screen_04_community_feed.png")
        await page.screenshot(path=p4)
        print(f"[OK] 4. Community Feed: {p4}")

        # 5. Community Post Detail (Click first post in list at x=195, y=260)
        print("[STEP] 5. Opening Community Post Detail...")
        await page.mouse.click(195, 260)
        await asyncio.sleep(3)
        p5 = os.path.join(ARTIFACT_DIR, "audit_screen_05_community_detail.png")
        await page.screenshot(path=p5)
        print(f"[OK] 5. Community Detail: {p5}")

        # Return to Community Feed (AppBar Back button at x=24, y=28)
        print("[STEP] Returning to Community Feed...")
        await page.mouse.click(24, 28)
        await asyncio.sleep(2)

        # 6. Discover Tab (Bottom Nav Tab 2: x=195, y=815)
        print("[STEP] 6. Navigating to Discover Tab...")
        await page.mouse.click(195, 815)
        await asyncio.sleep(3)
        p6 = os.path.join(ARTIFACT_DIR, "audit_screen_06_discover_feed.png")
        await page.screenshot(path=p6)
        print(f"[OK] 6. Discover Feed: {p6}")

        # 7. Chat List Tab (Bottom Nav Tab 3: x=273, y=815)
        print("[STEP] 7. Navigating to Chat List...")
        await page.mouse.click(273, 815)
        await asyncio.sleep(3)
        p7 = os.path.join(ARTIFACT_DIR, "audit_screen_07_chat_list.png")
        await page.screenshot(path=p7)
        print(f"[OK] 7. Chat List: {p7}")

        # 8. Chat Room Detail (Click first chat room at x=195, y=170)
        print("[STEP] 8. Opening Chat Room...")
        await page.mouse.click(195, 170)
        await asyncio.sleep(3)
        p8 = os.path.join(ARTIFACT_DIR, "audit_screen_08_chat_room.png")
        await page.screenshot(path=p8)
        print(f"[OK] 8. Chat Room: {p8}")

        # 8-B. Chat Room Tool Drawer (Click '+' button at x=32, y=818)
        print("[STEP] 8b. Opening Chat '+' Tool Drawer...")
        await page.mouse.click(32, 818)
        await asyncio.sleep(2)
        p8b = os.path.join(ARTIFACT_DIR, "audit_screen_08b_chat_drawer.png")
        await page.screenshot(path=p8b)
        print(f"[OK] 8b. Chat Drawer: {p8b}")

        # Close drawer with backdrop click at (195, 200)
        await page.mouse.click(195, 200)
        await asyncio.sleep(1.5)

        # Return to Chat List (AppBar Back button at x=24, y=28)
        print("[STEP] Returning to Chat List...")
        await page.mouse.click(24, 28)
        await asyncio.sleep(2)

        # 9. My Page Tab (Bottom Nav Tab 4: x=351, y=815)
        print("[STEP] 9. Navigating to My Page...")
        await page.mouse.click(351, 815)
        await asyncio.sleep(3)
        p9 = os.path.join(ARTIFACT_DIR, "audit_screen_09_my_page.png")
        await page.screenshot(path=p9)
        print(f"[OK] 9. My Page: {p9}")

        await browser.close()
        print("\n==========================================")
        print("🎉 ALL 11 AUDIT SCREENSHOTS COMPLETED!")
        print("==========================================")

if __name__ == "__main__":
    asyncio.run(capture_all())
