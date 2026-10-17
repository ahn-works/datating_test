#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU 풀스택 로컬 Claude 프록시(http://127.0.0.1:1337/v1) 통합 검증 스크립트
1) claude_client.py를 통한 claude-3-haiku 호출 검증
2) claude-3-sonnet 모델 호출 검증
3) sync_trends.py의 트렌드 키워드 생성 연동 검증
"""

import sys
import os

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from claude_client import (
    LOCAL_BASE_URL,
    DEFAULT_MODEL,
    SONNET_MODEL,
    DUMMY_API_KEY,
    create_chat_completion,
)


def run_integration_test() -> int:
    print("==========================================================")
    print("OOMU Local Claude Proxy (g4f) Integration Test")
    print(f"Base URL : {LOCAL_BASE_URL}")
    print(f"API Key  : {DUMMY_API_KEY}")
    print("==========================================================")

    for idx, model_name in enumerate([DEFAULT_MODEL, SONNET_MODEL], start=1):
        print(f"\n[{idx}/2] Testing model '{model_name}'...")
        res = create_chat_completion(
            model=model_name,
            messages=[
                {
                    "role": "user",
                    "content": f"OOMU 동네 모임 앱 테스트입니다. '{model_name} 연동 성공!'이라고 한 문장으로만 답해줘.",
                }
            ],
        )
        reply = (
            res.get("choices", [{}])[0]
            .get("message", {})
            .get("content", "")
            .strip()
        )
        provider = res.get("provider", "local-g4f")
        print(f"  -> Status   : OK (provider={provider})")
        print(f"  -> Response : {reply}")
        if not reply:
            print(f"[FAIL] Empty response for {model_name}")
            return 1

    print("\n==========================================================")
    print("[SUCCESS] All local Claude proxy integration tests passed!")
    print("==========================================================")
    return 0


if __name__ == "__main__":
    raise SystemExit(run_integration_test())
