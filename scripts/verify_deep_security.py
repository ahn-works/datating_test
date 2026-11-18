#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU 3-Tier Zero-Secret & Zero-PII Deep Security Verification Scanner
Used for local pre-commit checks and daily automated GitHub Actions cron auditing.
"""

import os
import re
import sys
import subprocess

# Paths to exclude completely
EXCLUDED_DIRS = {
    '.git',
    '.github',
    '.gemini',
    '.vscode',
    'build',
    'android/.gradle',
    'android/app/build',
    'node_modules',
    'backups',
    'scratch'
}

EXCLUDED_EXTS = {
    '.png', '.jpg', '.jpeg', '.webp', '.ico',
    '.otf', '.ttf', '.woff', '.woff2',
    '.lock', '.jar', '.gz', '.zip', '.tar'
}

# Safe mock / placeholder exceptions
SAFE_PHONE_ALLOWLIST = {
    '01000000000',
    '010-0000-0000',
    '01012345678',
    '010-1234-5678',
}

SAFE_EMAIL_ALLOWLIST = {
    'admin@oomu.app',
    'test_kakao@oomu.app',
    'cleanId@auth.oomu.app',
    'cleanPhone@oomu.app',
    'choyeon@test.oomu.app',
    'github-actions@github.com',
}

KNOWN_KAKAO_KEYS = [
    ''.join(['3f91399ac9', 'b6731d96f6', 'd4b9ac13c502']),
    ''.join(['277e860aee', '05a0dd1504', 'f70ce7ac8e74']),
    ''.join(['831cb74420', '67257f17f9', 'a5111a281ce5']),
]

def scan_files():
    try:
        raw = subprocess.check_output(['git', 'ls-files', '-z']).decode('utf-8', errors='ignore')
        files = [f for f in raw.split('\0') if f]
    except Exception:
        files = []
        for root, dirs, fnames in os.walk('.'):
            dirs[:] = [d for d in dirs if d not in EXCLUDED_DIRS]
            for fn in fnames:
                files.append(os.path.relpath(os.path.join(root, fn), '.'))
    return files

def run_audit():
    print("=" * 60)
    print("🛡️ OOMU Zero-Secret & Zero-PII Deep Security Audit Scanner")
    print("=" * 60)

    violations = []
    tracked_files = scan_files()

    phone_regex = re.compile(r'(?<!\d)(01[016789][-\s]?\d{3,4}[-\s]?\d{4})(?!\d)')
    email_regex = re.compile(r'\b[A-Za-z0-9._%+-]+@(?:naver\.com|daum\.net|hanmail\.net|nate\.com|gmail\.com)\b', re.IGNORECASE)
    private_key_regex = re.compile(r'-----BEGIN\s+(?:RSA\s+)?PRIVATE\s+KEY-----')
    secret_key_regex = re.compile(r'(?:secretAccessKey|aws_secret_access_key)\s*[:=]\s*[\'"][A-Za-z0-9/+=]{16,}[\'"]')
    solapi_secret_regex = re.compile(r'(?:solapiApiSecret|solapiApiKey)\s*[:=]\s*[\'"][A-Za-z0-9_-]{10,}[\'"]')

    for fpath in tracked_files:
        fpath_norm = fpath.replace('\\', '/')
        if any(fpath_norm.startswith(ex + '/') or fpath_norm == ex for ex in EXCLUDED_DIRS):
            continue
        ext = os.path.splitext(fpath)[1].lower()
        if ext in EXCLUDED_EXTS:
            continue

        if not os.path.exists(fpath):
            continue

        # Skip scanner itself and documentation rules mentioning patterns
        is_security_doc = fpath_norm in {'SECURITY.md', 'scripts/verify_deep_security.py', 'scripts/verify_security_rules.ps1', 'scripts/verify_security_rules.sh'}

        try:
            with open(fpath, 'r', encoding='utf-8', errors='ignore') as fp:
                lines = fp.readlines()
        except Exception:
            continue

        for idx, line in enumerate(lines, 1):
            line_str = line.strip()

            # 1. Private keys
            if private_key_regex.search(line_str):
                violations.append((fpath_norm, idx, "Private Key (PEM) detected", line_str))

            # 2. Known Kakao Keys
            if not is_security_doc:
                for kk in KNOWN_KAKAO_KEYS:
                    if kk in line_str:
                        violations.append((fpath_norm, idx, f"Hardcoded Kakao Key ({kk[:8]}...)", line_str))

            # 3. AWS / R2 Secret Access Key
            if not is_security_doc and secret_key_regex.search(line_str):
                violations.append((fpath_norm, idx, "Hardcoded S3/R2 Secret Access Key", line_str))

            # 4. Solapi Secret
            if not is_security_doc and solapi_secret_regex.search(line_str):
                violations.append((fpath_norm, idx, "Hardcoded Solapi Secret/Key", line_str))

            # 5. Korean Mobile Phone Numbers
            if not is_security_doc:
                for match in phone_regex.finditer(line_str):
                    phone = match.group(1)
                    clean_phone = re.sub(r'[-\s]', '', phone)
                    if phone not in SAFE_PHONE_ALLOWLIST and clean_phone not in SAFE_PHONE_ALLOWLIST:
                        violations.append((fpath_norm, idx, f"Exposed Korean Mobile Phone ({phone})", line_str))

            # 6. Personal Email Addresses (@naver.com, @daum.net, unmasked @gmail.com)
            if not is_security_doc:
                for match in email_regex.finditer(line_str):
                    email = match.group(0).lower()
                    if email in SAFE_EMAIL_ALLOWLIST or 'oomu****@gmail.com' in email or 'oomu<span class="at">****</span>' in line_str:
                        continue
                    violations.append((fpath_norm, idx, f"Exposed Personal Email ({email})", line_str))

    # 7. Stray images in lib/
    stray_lib_images = []
    if os.path.exists('lib'):
        for root, _, files in os.walk('lib'):
            for f in files:
                if f.lower().endswith(('.png', '.jpg', '.jpeg', '.webp', '.gif', '.heic')):
                    stray_lib_images.append(os.path.join(root, f))
    if stray_lib_images:
        for img in stray_lib_images:
            violations.append((img, 0, "Unauthorized image in lib/ (Media must be uploaded to Cloudflare R2)", ""))

    # 8. Check SSOT files existence
    if not os.path.exists('SECURITY.md'):
        violations.append(('SECURITY.md', 0, "Missing required single security specification file", ""))
    if not os.path.exists('AGENTS.md'):
        violations.append(('AGENTS.md', 0, "Missing required single master specification file", ""))

    print(f"\nAudit complete. Scanned {len(tracked_files)} files.")
    if violations:
        print("\n" + "!" * 60)
        print(f"❌ [SECURITY VIOLATIONS DETECTED: {len(violations)}]")
        print("!" * 60)
        for fpath, lnum, msg, content in violations:
            print(f" - {fpath}:{lnum} ➔ {msg}")
            if content:
                print(f"     Code: {content[:100]}")
        print("\nCommit and deployment are BLOCKED until all violations are resolved.")
        sys.exit(1)
    else:
        print("\n✅ [ALL CHECKS PASSED] 0 Secrets, 0 PII, 0 Leaks detected.")
        print("Repository is 100% compliant with OOMU Single Security Standard.")
        sys.exit(0)

if __name__ == "__main__":
    run_audit()
