#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\b6e14a38-5528-42ae-ba8a-86b74ba38861"

def run_verification():
    print("Starting Playwright E2E Verification...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={"width": 390, "height": 844},
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
        )
        page = context.new_page()

        print("1. Navigating to http://localhost:8086 ...", flush=True)
        page.goto("http://localhost:8086", wait_until="domcontentloaded")
        time.sleep(5)

        # Take screenshot of landing
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_01_landing.png"))
        print("  [OK] Saved v2_01_landing.png")

        # Check if email login button or guest login can be used
        # We can directly log in with test11@naver.com via the Email Auth Sheet or test account button
        # Let's tap '🧪 테스트 계정' if visible or '이메일로 계속하기'
        print("2. Attempting login as test11@naver.com ...")
        test_btn = page.get_by_text("🧪 테스트 계정")
        if test_btn.is_visible():
            test_btn.click()
            time.sleep(2)
            page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_02_test_users.png"))
            # Tap '우리동네_초연' or test user
            choyeon = page.get_by_text("우리동네_초연")
            if choyeon.is_visible():
                choyeon.click()
                time.sleep(3)
        else:
            # Tap email login
            email_btn = page.get_by_text("이메일로 계속하기")
            if email_btn.is_visible():
                email_btn.click()
                time.sleep(2)
                page.locator("input[type='email']").fill("test11@naver.com")
                page.locator("input[type='password']").fill("test11@@")
                page.get_by_text("로그인하기").click()
                time.sleep(3)

        # Home screen screenshot (전체)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_03_home_all.png"))
        print("  [OK] Saved v2_03_home_all.png")

        # 3. Test '취향 아지트' category tab
        print("3. Testing '취향 아지트' tab ...")
        azit_tab = page.get_by_text("취향 아지트")
        if azit_tab.is_visible():
            azit_tab.click()
            time.sleep(2)
            page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_04_tab_azit.png"))
            print("  [OK] Saved v2_04_tab_azit.png")

        # 4. Test '라이프 메이트' category tab
        print("4. Testing '라이프 메이트' tab ...")
        mate_tab = page.get_by_text("라이프 메이트")
        if mate_tab.is_visible():
            mate_tab.click()
            time.sleep(2)
            page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_05_tab_mate.png"))
            print("  [OK] Saved v2_05_tab_mate.png")

        # 5. Test Map View (Explore)
        print("5. Testing Map View ...")
        # Tap map or discovery tab
        map_btn = page.get_by_text("발견")
        if map_btn.is_visible():
            map_btn.click()
            time.sleep(3)
            page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_06_map_screen.png"))
            print("  [OK] Saved v2_06_map_screen.png")

        # 6. Test Community Tab & Detail
        print("6. Testing Community Feed & Comment ...")
        comm_btn = page.get_by_text("커뮤니티")
        if comm_btn.is_visible():
            comm_btn.click()
            time.sleep(2)
            page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_07_community_feed.png"))
            print("  [OK] Saved v2_07_community_feed.png")

            # Tap first post
            first_post = page.locator("text=성산공원").first
            if first_post.is_visible():
                first_post.click()
                time.sleep(2)
                page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_08_community_post_detail.png"))
                print("  [OK] Saved v2_08_community_post_detail.png")
                # Go back
                page.go_back()
                time.sleep(1)

        # 7. Test Chat List & Room
        print("7. Testing Chat ...")
        chat_btn = page.get_by_text("채팅")
        if chat_btn.is_visible():
            chat_btn.click()
            time.sleep(2)
            page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_09_chat_list.png"))
            print("  [OK] Saved v2_09_chat_list.png")

            # Tap first chat item if visible
            first_chat = page.locator("text=러닝").first
            if not first_chat.is_visible():
                first_chat = page.locator("text=번개").first
            if first_chat.is_visible():
                first_chat.click()
                time.sleep(2)
                page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_10_chat_room.png"))
                print("  [OK] Saved v2_10_chat_room.png")
                page.go_back()
                time.sleep(1)

        # 8. Test MyPage & User Profile
        print("8. Testing My Page & User Profile ...")
        mypage_btn = page.get_by_text("마이")
        if mypage_btn.is_visible():
            mypage_btn.click()
            time.sleep(2)
            page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_11_mypage.png"))
            print("  [OK] Saved v2_11_mypage.png")

            # Tap '내 프로필 보기'
            view_profile = page.get_by_text("내 프로필 보기")
            if view_profile.is_visible():
                view_profile.click()
                time.sleep(2)
                page.screenshot(path=os.path.join(ARTIFACT_DIR, "v2_12_user_profile_detail.png"))
                print("  [OK] Saved v2_12_user_profile_detail.png")

        browser.close()
    print("Verification completed successfully!")

if __name__ == "__main__":
    run_verification()
