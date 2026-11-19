#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU Comprehensive Auth & Feed Audit Script
Tests & captures:
1. Live Login Screen (Stage 2)
2. Social Login Options (Kakao, Naver, Google)
3. Phone SMS Verification Modal / Test
4. Signup Screen / Modal
5. Find Email Modal / Screen
6. Reset Password Modal / Screen
7. Updated Home Feed (Verify orange box is GONE, clean photo cover displayed)
8. Updated Category Cafe Screen (Verify Gangnam meetup is filtered out, badge text is clean without widow truncation, bottom content not covered)
"""

import os
import sys
import time
from playwright.sync_api import sync_playwright

ARTIFACT_DIR = r"C:\Users\DT4\.gemini\antigravity\brain\a95242bd-6b0d-40e4-8370-b9993edd36b6"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

def wait_for_flutter(page, timeout=30):
    start = time.time()
    while time.time() - start < timeout:
        try:
            ready = page.evaluate("() => window._flutter && window._flutter.loader && document.querySelector('flt-glass-pane, flutter-view, canvas') !== null")
            if ready:
                time.sleep(2)
                return True
        except:
            pass
        time.sleep(0.5)
    time.sleep(3)
    return True

def run_audit():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        # iPhone 14 Pro Max viewport
        context = browser.new_context(
            viewport={"width": 390, "height": 844},
            device_scale_factor=2.0,
            has_touch=True,
        )
        
        BASE_URL = "http://localhost:8080"
        
        # 1. Login Screen (Stage 2)
        print("[1/8] Capturing Login Screen...")
        page = context.new_page()
        page.goto(f"{BASE_URL}/", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_01_login_stage2.png"))
        
        # 2. Click '회원가입' (Signup)
        print("[2/8] Testing & Capturing Signup Screen...")
        # In LoginScreen Stage 2: '회원가입' link is located under login button
        # Let's click around the signup link (x: 100, y: 380 on 390x844)
        page.mouse.click(105, 382)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_02_signup_screen.png"))
        
        # 3. SMS Phone Verification in Signup
        print("[3/8] Testing & Capturing Phone Verification Modal...")
        # Click on phone verification button or field
        page.mouse.click(195, 280)
        time.sleep(1)
        page.mouse.click(320, 280)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_03_phone_verification.png"))
        page.close()
        
        # 4. Find Email Modal
        print("[4/8] Testing & Capturing Find Email...")
        page = context.new_page()
        page.goto(f"{BASE_URL}/", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(2)
        # Click '이메일 찾기' (approx x: 195, y: 382)
        page.mouse.click(195, 382)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_04_find_email_modal.png"))
        page.close()

        # 5. Reset Password Modal
        print("[5/8] Testing & Capturing Reset Password...")
        page = context.new_page()
        page.goto(f"{BASE_URL}/", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(2)
        # Click '비밀번호 재설정' (approx x: 285, y: 382)
        page.mouse.click(285, 382)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_05_reset_password_modal.png"))
        page.close()

        # 6. Guest Login into Home Feed
        print("[6/8] Testing & Capturing Home Feed (Verifying orange box is GONE)...")
        page = context.new_page()
        page.goto(f"{BASE_URL}/?home=true#/?home=true", wait_until="domcontentloaded")
        wait_for_flutter(page)
        time.sleep(5) # Wait for Firestore items to load
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_06_updated_home_feed.png"))

        # 7. Category Filter Cafe (Verify Gangnam is filtered, badge clean, bottom not covered)
        print("[7/8] Testing & Capturing Category Filter Cafe...")
        # Click '카페·디저트' tab in category bar (around x: 280, y: 112)
        page.mouse.click(280, 112)
        time.sleep(3)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_07_updated_category_cafe.png"))

        # 8. Scroll to bottom to verify FAB & Bottom Nav do not cover content
        print("[8/8] Testing Bottom Scroll & FAB Overlay Clearance...")
        page.mouse.wheel(0, 1500)
        time.sleep(2)
        page.screenshot(path=os.path.join(ARTIFACT_DIR, "audit_08_bottom_clearance.png"))

        browser.close()
        print("All audit screenshots captured successfully!")

if __name__ == "__main__":
    run_audit()
