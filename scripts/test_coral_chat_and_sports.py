import asyncio
import os
import sys
from playwright.async_api import async_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15"
        )
        page = await context.new_page()

        print("Navigating to http://localhost:8086/oomu_app/ ...")
        await page.goto("http://localhost:8086/oomu_app/", wait_until="domcontentloaded")
        await asyncio.sleep(6)

        # Login using Quick Test Account Button (top right)
        print("Clicking Quick Test Account button...")
        await page.mouse.click(245, 32)
        await asyncio.sleep(1.5)

        # Select test user (초연)
        print("Selecting user 초연...")
        await page.mouse.click(195, 740)
        await asyncio.sleep(4)

        # 1. Home Screen - Scroll to Discovery & Sports filter
        print("Verifying Home Screen Discovery & Sports filter...")
        # Scroll down
        await page.mouse.wheel(0, 700)
        await asyncio.sleep(2)

        path_home = os.path.join(ARTIFACT_DIR, "audit_verify_home_discovery_filters.png")
        await page.screenshot(path=path_home)
        print(f"Saved: {path_home}")

        # 2. Chat List Tab (Tab index 4: x=273, y=815)
        print("Navigating to Chat tab...")
        await page.mouse.click(273, 815)
        await asyncio.sleep(3)

        path_chat_list = os.path.join(ARTIFACT_DIR, "audit_verify_chat_list_coral.png")
        await page.screenshot(path=path_chat_list)
        print(f"Saved: {path_chat_list}")

        # 3. Enter First Chat Room (click around x=195, y=140)
        print("Entering Chat Room...")
        await page.mouse.click(195, 140)
        await asyncio.sleep(3)

        path_chat_room = os.path.join(ARTIFACT_DIR, "audit_verify_chat_room_coral.png")
        await page.screenshot(path=path_chat_room)
        print(f"Saved: {path_chat_room}")

        # 4. Click '+' button on chat room (bottom left near input, approx x=32, y=816)
        print("Clicking '+' Karrot Drawer button...")
        await page.mouse.click(32, 816)
        await asyncio.sleep(2)

        path_chat_plus = os.path.join(ARTIFACT_DIR, "audit_verify_chat_karrot_menu_coral.png")
        await page.screenshot(path=path_chat_plus)
        print(f"Saved: {path_chat_plus}")

        await browser.close()
        print("Visual verification complete!")

if __name__ == "__main__":
    asyncio.run(main())
