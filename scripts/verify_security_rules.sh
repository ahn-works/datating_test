#!/usr/bin/env bash
# ==============================================================================
# OOMU 보안 규칙 및 3계층 분배 자동 검증 스크립트 (Linux / macOS / CI)
# ==============================================================================

set -e

echo "=========================================================="
echo "🔍 OOMU 3계층 보안 규칙 사전 점검 시작..."
echo "=========================================================="

HAS_ERROR=0

# 1. 프로덕션 소스코드(lib/) 내 R2 S3 Secret Access Key 하드코딩 검사
echo ""
echo "[1/3] 프로덕션 소스코드(lib/) 내 비밀키/자격증명 하드코딩 여부 점검..."
if grep -rnE "secretAccessKey\s*=\s*['\"][^'\"]+['\"]" lib/ 2>/dev/null; then
    echo "❌ [위반 감지] 소스코드에 Secret Access Key가 하드코딩되어 있습니다!"
    HAS_ERROR=1
else
    echo "✅ 비밀키 하드코딩 없음 (Firestore 동적 로딩 준수 확인)"
fi

# 2. 비인가 사진/미디어 커밋 여부 점검
echo ""
echo "[2/3] 비인가 사진 파일 점검 (사진은 Cloudflare R2 전용)..."
if find lib/ -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | grep -q .; then
    echo "⚠️ [주의] lib 디렉토리에 직접 포함된 이미지 파일이 있습니다."
else
    echo "✅ lib 내 비인가 이미지 없음 (사진은 Cloudflare R2 업로드 원칙 준수)"
fi

# 3. 필수 보안 규칙 파일 존재 여부 검사
echo ""
echo "[3/3] 필수 보안 규칙 및 지침 파일 검증..."
for file in ".antigravity/rules/security_distribution_rules.md" "docs/SECURITY_AGENT_GUIDE.md" "AI_INSTRUCTIONS.md"; do
    if [ -f "$file" ]; then
        echo "✅ 필수 보안 파일 확인: $file"
    else
        echo "❌ [누락] 필수 보안 파일이 없습니다: $file"
        HAS_ERROR=1
    fi
done

echo ""
echo "=========================================================="
if [ $HAS_ERROR -eq 1 ]; then
    echo "❌ 보안 검증 실패! 위의 위반 사항을 해결한 후 다시 시도하십시오."
    exit 1
else
    echo "🎉 모든 보안 검증 통과! 깃허브에 안전하게 커밋/푸시할 수 있습니다."
    exit 0
fi
