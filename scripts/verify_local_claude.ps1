# ==============================================================================
# OOMU 로컬 Claude 가상 API 서버 (http://127.0.0.1:1337/v1) curl 검증 스크립트
# ==============================================================================

$BaseUrl = "http://127.0.0.1:1337/v1"
$ApiKey  = "pk-dummy"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Testing Local g4f Claude API ($BaseUrl)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "`n[1/2] curl Test -> model: claude-3-haiku" -ForegroundColor Yellow
curl.exe --% -s -X POST http://127.0.0.1:1337/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer pk-dummy" -d "{\"model\":\"claude-3-haiku\",\"messages\":[{\"role\":\"user\",\"content\":\"OOMU 앱 연동 테스트입니다. 한국어로 짧게 한 문장 인사해줘.\"}]}"
Write-Host "`n"

Write-Host "[2/2] curl Test -> model: claude-3-sonnet" -ForegroundColor Yellow
curl.exe --% -s -X POST http://127.0.0.1:1337/v1/chat/completions -H "Content-Type: application/json" -H "Authorization: Bearer pk-dummy" -d "{\"model\":\"claude-3-sonnet\",\"messages\":[{\"role\":\"user\",\"content\":\"성수동 카페 모임 아이스브레이킹 질문 1개만 짧게 추천해줘.\"}]}"
Write-Host "`n"
