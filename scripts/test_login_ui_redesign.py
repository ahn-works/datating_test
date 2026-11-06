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

        # 1. Open App (opens LoginScreen by default for unauthenticated session)
        await page.goto("http://localhost:8086/oomu_app/", wait_until="domcontentloaded")
        await asyncio.sleep(5)

        # 2. Capture Initial Login Tab Screen
        path_login = os.path.join(ARTIFACT_DIR, "audit_verify_login_screen_intro.png")
        await page.screenshot(path=path_login)
        print(f"[OK] Saved Login Tab: {path_login}")

        # 3. Click '회원가입' Tab (around x=280, y=260)
        # Let's inspect coordinates: The tab bar is roughly at y=250-270.
        # Left tab (로그인) is ~x=100. Right tab (회원가입) is ~x=290.
        await page.mouse.click(290, 260)
        await asyncio.sleep(1.5)

        path_signup = os.path.join(ARTIFACT_DIR, "audit_verify_signup_tab.png")
        await page.screenshot(path=path_signup)
        print(f"[OK] Saved SignUp Tab: {path_signup}")

        # 4. Click '휴대폰 번호로 회원가입' button (around x=195, y=410)
        await page.mouse.click(195, 410)
        await asyncio.sleep(1.5)

        path_sms_modal = os.path.join(ARTIFACT_DIR, "audit_verify_phone_modal_from_login.png")
        await page.screenshot(path=path_sms_modal)
        print(f"[OK] Saved Phone SMS Modal: {path_sms_modal}")

        await browser.close()
        print("Done!")

if __name__ == "__main__":
    asyncio.run(main())

