import asyncio
import os
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

        print("Navigating to http://localhost:8086/ ...")
        await page.goto("http://localhost:8086/", wait_until="domcontentloaded")
        await asyncio.sleep(5)

        # Login with choyeon@test.oomu.app
        print("Logging in with choyeon@test.oomu.app...")
        await page.click('text="이메일로 로그인"')
        await asyncio.sleep(1)

        inputs = await page.query_selector_all('input')
        if len(inputs) >= 2:
            await inputs[0].fill("choyeon@test.oomu.app")
            await inputs[1].fill("test_pass_2026!")
            await asyncio.sleep(0.5)

        await page.click('button:has-text("로그인")')
        await asyncio.sleep(4)

        # 1. Check Community tab comments
        print("Navigating to Community tab...")
        await page.click('text="커뮤니티"')
        await asyncio.sleep(3)

        path_comm = os.path.join(ARTIFACT_DIR, "audit_verify_community_feed.png")
        await page.screenshot(path=path_comm)
        print(f"Saved: {path_comm}")

        # Open post
        print("Opening community post...")
        await page.click('text="여수 화장동 성산공원"')
        await asyncio.sleep(3)

        path_detail = os.path.join(ARTIFACT_DIR, "audit_verify_community_comments.png")
        await page.screenshot(path=path_detail)
        print(f"Saved: {path_detail}")

        # Go back
        await page.click('button:has(svg), [aria-label="Back"], button')
        await asyncio.sleep(1.5)

        # 2. Check Chat tab
        print("Navigating to Chat tab...")
        await page.click('text="채팅"')
        await asyncio.sleep(3)

        path_chat_list = os.path.join(ARTIFACT_DIR, "audit_verify_chat_list.png")
        await page.screenshot(path=path_chat_list)
        print(f"Saved: {path_chat_list}")

        # Click on a chat room
        rooms = await page.query_selector_all('text="모임"')
        if rooms:
            await rooms[0].click()
        else:
            first_item = await page.query_selector('li, [role="button"]')
            if first_item:
                await first_item.click()
        await asyncio.sleep(3)

        path_room = os.path.join(ARTIFACT_DIR, "audit_verify_chat_room.png")
        await page.screenshot(path=path_room)
        print(f"Saved: {path_room}")

        # Click '+' button
        print("Clicking '+' button for Karrot menu...")
        plus_btn = await page.query_selector('[aria-label="대화에 추가하기"]')
        if plus_btn:
            await plus_btn.click()
        else:
            await page.click('button:has-text("+"), [tooltip="대화에 추가하기"]')
        await asyncio.sleep(2)

        path_plus = os.path.join(ARTIFACT_DIR, "audit_verify_chat_karrot_menu.png")
        await page.screenshot(path=path_plus)
        print(f"Saved: {path_plus}")

        await browser.close()
        print("Done!")

if __name__ == "__main__":
    asyncio.run(main())
