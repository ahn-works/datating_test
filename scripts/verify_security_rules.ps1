# ==============================================================================
# OOMU 보안 규칙 및 3계층 분배 자동 검증 스크립트 (Windows PowerShell)
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "OOMU 3-Tier Security & PII Leak Rules Verification..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$hasError = $false

# 1. 프로덕션 소스코드(lib/) 내 R2 S3 Secret Access Key 하드코딩 검사
Write-Host "`n[1/6] Checking hardcoded R2/AWS secrets in production source code (lib/)..." -ForegroundColor Yellow
$libSecretPattern = 'secretAccessKey\s*=\s*[''"][^''"]+[''"]'
$libFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" -File
$libSecretMatches = $libFiles | Select-String -Pattern $libSecretPattern
if ($libSecretMatches) {
    Write-Host "[VIOLATION] Secret Access Key found hardcoded in lib/!" -ForegroundColor Red
    $libSecretMatches | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    $hasError = $true
} else {
    Write-Host "[PASS] No hardcoded secrets found in lib/ (Firestore dynamic load compliant)." -ForegroundColor Green
}

# 2. 카카오 API 키 / 어드민 키 하드코딩 검사 (lib/, web/, scripts/)
Write-Host "`n[2/6] Checking hardcoded Kakao API/Admin keys in source files..." -ForegroundColor Yellow
$kakaoKeyPatterns = @(
    '3f91399ac9b6731d96f6d4b9ac13c502',
    '277e860aee05a0dd1504f70ce7ac8e74',
    '831cb7442067257f17f9a5111a281ce5'
)
foreach ($kp in $kakaoKeyPatterns) {
    $matched = Get-ChildItem -Path @("lib", "web", "scripts") -Recurse -Include @("*.dart", "*.html", "*.py", "*.js") -File | Select-String -Pattern $kp
    if ($matched) {
        Write-Host "[VIOLATION] Kakao Key ($kp) found hardcoded in source!" -ForegroundColor Red
        $matched | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
        $hasError = $true
    }
}
if (-not $hasError) {
    Write-Host "[PASS] No hardcoded Kakao API/Admin keys in source code." -ForegroundColor Green
}

# 3. 실제 개인 휴대폰 번호 노출 검사 (lib/ 및 scripts/)
Write-Host "`n[3/6] Checking exposed personal mobile phone numbers (lib/)..." -ForegroundColor Yellow
$realPhoneMatches = $libFiles | Select-String -Pattern '(?<!\d)01059321032(?!\d)|(?<!\d)010-5932-1032(?!\d)'
if ($realPhoneMatches) {
    Write-Host "[VIOLATION] Real personal phone number found in lib/!" -ForegroundColor Red
    $realPhoneMatches | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    $hasError = $true
} else {
    Write-Host "[PASS] No real personal phone numbers in lib/." -ForegroundColor Green
}

# 4. 개인 네이버 이메일 및 하드코딩 비밀번호 노출 검사 (lib/)
Write-Host "`n[4/6] Checking exposed personal email & passwords (lib/)..." -ForegroundColor Yellow
$personalPiiMatches = $libFiles | Select-String -Pattern 'ansimhyang60@naver\.com|test_simhyang99'
if ($personalPiiMatches) {
    Write-Host "[VIOLATION] Personal email or password found in lib/!" -ForegroundColor Red
    $personalPiiMatches | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    $hasError = $true
} else {
    Write-Host "[PASS] No personal email or password in lib/." -ForegroundColor Green
}

# 5. Git 스테이징 및 리포지토리 내 비인가 미디어 파일 검사 (사진은 R2 전용)
Write-Host "`n[5/6] Checking unauthorized image files in lib/ (Media belongs to R2)..." -ForegroundColor Yellow
$strayImages = Get-ChildItem -Path "lib" -Recurse -Include @("*.jpg", "*.png", "*.jpeg", "*.webp", "*.heic", "*.gif") -File
if ($strayImages) {
    Write-Host "[WARNING] Stray images found in lib/:" -ForegroundColor Yellow
    $strayImages | ForEach-Object { Write-Host "   $($_.FullName)" -ForegroundColor Yellow }
} else {
    Write-Host "[PASS] No unauthorized images in lib/ (Cloudflare R2 compliant)." -ForegroundColor Green
}

# 6. 필수 단일 지침서 존재 여부 검사 (SECURITY.md, AGENTS.md)
Write-Host "`n[6/6] Checking required security & master guideline files..." -ForegroundColor Yellow
$requiredFiles = @(
    "SECURITY.md",
    "AGENTS.md"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "[PASS] Required security file exists: $file" -ForegroundColor Green
    } else {
        Write-Host "[MISSING] Required security file not found: $file" -ForegroundColor Red
        $hasError = $true
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
if ($hasError) {
    Write-Host "[FAILED] Security verification failed! Resolve violations before commit." -ForegroundColor Red
    Exit 1
} else {
    Write-Host "[SUCCESS] All security rules passed! Safe to commit and push to GitHub." -ForegroundColor Green
    Exit 0
}
