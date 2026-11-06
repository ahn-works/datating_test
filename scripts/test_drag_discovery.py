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
        await asyncio.sleep(2)
        await page.mouse.click(195, 740)
        await asyncio.sleep(4)

        # Vertical drag to scroll up feed (touch drag)
        print("Vertical dragging to reveal Trends...")
        await page.mouse.move(200, 700)
        await page.mouse.down()
        await page.mouse.move(200, 200, steps=20)
        await page.mouse.up()
        await asyncio.sleep(1.5)

        await page.mouse.move(200, 700)
        await page.mouse.down()
        await page.mouse.move(200, 300, steps=20)
        await page.mouse.up()
        await asyncio.sleep(2)

        path_trends = os.path.join(ARTIFACT_DIR, "audit_verify_home_discovery_scrolled.png")
        await page.screenshot(path=path_trends)
        print(f"Saved: {path_trends}")

        # Now horizontal drag on trend chips (approx y=420)
        print("Horizontal dragging trend filter chips...")
        await page.mouse.move(350, 420)
        await page.mouse.down()
        await page.mouse.move(50, 420, steps=15)
        await page.mouse.up()
        await asyncio.sleep(2)

        path_chips = os.path.join(ARTIFACT_DIR, "audit_verify_sports_and_movies_chips.png")
        await page.screenshot(path=path_chips)
        print(f"Saved: {path_chips}")

        await browser.close()
        print("Done!")

if __name__ == "__main__":
    asyncio.run(main())
