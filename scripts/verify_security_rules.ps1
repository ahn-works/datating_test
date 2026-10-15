# ==============================================================================
# OOMU 보안 규칙 및 3계층 분배 자동 검증 스크립트 (Windows PowerShell)
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "OOMU 3-Tier Security Rules Verification..." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$hasError = $false

# 1. 프로덕션 소스코드(lib/) 내 R2 S3 Secret Access Key 하드코딩 검사
Write-Host "`n[1/3] Checking hardcoded secrets in production source code (lib/)..." -ForegroundColor Yellow
$libPattern = 'secretAccessKey\s*=\s*[''"][^''"]+[''"]'
$libFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" -File
$libMatches = $libFiles | Select-String -Pattern $libPattern
if ($libMatches) {
    Write-Host "[VIOLATION] Secret Access Key found hardcoded in lib/!" -ForegroundColor Red
    $libMatches | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    $hasError = $true
} else {
    Write-Host "[PASS] No hardcoded secrets found in lib/ (Firestore dynamic load compliant)." -ForegroundColor Green
}

# 2. Git 스테이징 및 리포지토리 내 비인가 미디어 파일 검사 (사진은 R2 전용)
Write-Host "`n[2/3] Checking unauthorized image files in lib/ (Media belongs to R2)..." -ForegroundColor Yellow
$strayImages = Get-ChildItem -Path "lib" -Recurse -Include @("*.jpg", "*.png", "*.jpeg", "*.webp", "*.heic", "*.gif") -File
if ($strayImages) {
    Write-Host "[WARNING] Stray images found in lib/:" -ForegroundColor Yellow
    $strayImages | ForEach-Object { Write-Host "   $($_.FullName)" -ForegroundColor Yellow }
} else {
    Write-Host "[PASS] No unauthorized images in lib/ (Cloudflare R2 compliant)." -ForegroundColor Green
}

# 3. 필수 보안 규칙 파일 존재 여부 검사
Write-Host "`n[3/3] Checking required security rule and guide files..." -ForegroundColor Yellow
$requiredFiles = @(
    ".antigravity/rules/security_distribution_rules.md",
    "docs/SECURITY_AGENT_GUIDE.md",
    "AI_INSTRUCTIONS.md"
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
