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

        await page.goto("http://localhost:8086/oomu_app/", wait_until="domcontentloaded")
        await asyncio.sleep(6)

        # Login with quick test button
        await page.mouse.click(245, 32)
        await asyncio.sleep(1.5)
        await page.mouse.click(195, 740)
        await asyncio.sleep(4)

        # Scroll down 1200px so Trends section is in the middle of viewport
        print("Scrolling home feed to trends section...")
        await page.mouse.wheel(0, 1200)
        await asyncio.sleep(2)

        path_trends = os.path.join(ARTIFACT_DIR, "audit_verify_home_trends_centered.png")
        await page.screenshot(path=path_trends)
        print(f"Saved: {path_trends}")

        # Drag horizontal chips from right to left to show ⚾ 스포츠 and 🎬 영화
        print("Dragging chips to show sports and movies...")
        await page.mouse.move(340, 500)
        await page.mouse.down()
        await page.mouse.move(40, 500, steps=10)
        await page.mouse.up()
        await asyncio.sleep(2)

        path_sports_chips = os.path.join(ARTIFACT_DIR, "audit_verify_home_sports_chips_scrolled.png")
        await page.screenshot(path=path_sports_chips)
        print(f"Saved: {path_sports_chips}")

        await browser.close()
        print("Finished!")

if __name__ == "__main__":
    asyncio.run(main())
