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

        print("Navigating to http://localhost:8086/oomu_app/ ...")
        await page.goto("http://localhost:8086/oomu_app/", wait_until="domcontentloaded")
        await asyncio.sleep(6)

        # Login with quick test button
        await page.mouse.click(245, 32)
        await asyncio.sleep(1.5)
        await page.mouse.click(195, 740)
        await asyncio.sleep(4)

        # Scroll down directly to the Discovery & Trends section
        print("Scrolling to Trends section...")
        await page.mouse.wheel(0, 950)
        await asyncio.sleep(2)

        # Click '전체보기 >' at (340, 832)
        print("Opening '공연·전시와 동네 발견' full sheet by click...")
        await page.mouse.click(340, 832)
        await asyncio.sleep(2.5)

        path_sheet = os.path.join(ARTIFACT_DIR, "audit_verify_discovery_sports_sheet.png")
        await page.screenshot(path=path_sheet)
        print(f"Saved: {path_sheet}")

        # Drag/scroll horizontal filter chips in sheet
        print("Scrolling chips in sheet...")
        await page.mouse.move(300, 240)
        await page.mouse.down()
        await page.mouse.move(50, 240, steps=10)
        await page.mouse.up()
        await asyncio.sleep(1.5)

        path_chips = os.path.join(ARTIFACT_DIR, "audit_verify_sports_and_movies_chips.png")
        await page.screenshot(path=path_chips)
        print(f"Saved: {path_chips}")

        await browser.close()
        print("Done!")

if __name__ == "__main__":
    asyncio.run(main())
