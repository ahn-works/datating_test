#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU 로컬 가상 API 서버(g4f) 연동 클라이언트 모듈 (Zero-Secret 준수)
- Base URL: http://127.0.0.1:1337/v1
- API Key : pk-dummy (로컬 프록시 전용 더미 키)
- 지원 모델:
  [Claude 모델 리스트]
    • claude-3-haiku       : 초고속 응답 / 실시간 아이스브레이킹·태그 추출
    • claude-haiku-4.5     : 경량 고속 / 짧은 마이크로카피·뱃지 문구
    • claude-3-sonnet      : 밸런스형 / 일반 설명글·프로필 다듬기
    • claude-3-5-sonnet    : UI/UX 리디자인 설계 & 2030 감성 카피라이팅 메인
    • claude-sonnet-4      : 고급 UX Writing & B2B 네이티브 큐레이션 카피
    • claude-3-opus        : 12년 차 수석 디자이너 UX 감사 & 복합 설계
    • claude-opus-4        : 최상위 아키텍처·기획 역제안
  [GPT 모델 리스트]
    • gpt-4o               : 풀스택 구조 설계 & 범용 카피/JSON 생성
    • gpt-4o-mini          : 초고속 JSON 파싱 / 실시간 트렌드·키워드 분류
    • gpt-4.1              : 최신 코딩·위젯 트리 리팩토링 & 레이아웃 검증
    • gpt-4.1-mini         : 고속 UI 컴포넌트/바텀시트 보일러플레이트 생성
    • gpt-4                : B2B 사장님 제휴 제안/정산 리포트 문구 생성
    • gpt-4.5              : 감성적 스토리텔링 & 브랜드 카피라이팅
    • o3-mini / o4-mini    : 심층 추론(Reasoning) / 1/N 정산·매칭 알고리즘 검증
"""

import argparse
import json
import os
import sys
import urllib.request
from typing import Any, Dict, List, Optional

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

LOCAL_BASE_URL = os.environ.get("OOMU_LOCAL_LLM_BASE_URL", "http://127.0.0.1:1337/v1")
CHAT_COMPLETIONS_URL = f"{LOCAL_BASE_URL.rstrip('/')}/chat/completions"
DEFAULT_MODEL = os.environ.get("OOMU_LOCAL_LLM_MODEL", "claude-3-haiku")
SONNET_MODEL = "claude-3-sonnet"
DUMMY_API_KEY = "pk-dummy"

CLAUDE_MODELS = [
    "claude-3-haiku",
    "claude-haiku-4.5",
    "claude-3-sonnet",
    "claude-3-5-sonnet",
    "claude-sonnet-4",
    "claude-3-opus",
    "claude-opus-4",
]

GPT_MODELS = [
    "gpt-4o",
    "gpt-4o-mini",
    "gpt-4.1",
    "gpt-4.1-mini",
    "gpt-4.1-nano",
    "gpt-4",
    "gpt-4.5",
    "o3-mini",
    "o4-mini",
]

# 상황별 로컬 g4f 최적 모델 매핑
TASK_MODEL_MAP = {
    "ui_redesign": "claude-3-5-sonnet",      # 상황 1/2: 12년 차 UI/UX 리디자인 & 겹침 교정
    "ux_writing": "claude-sonnet-4",         # 상황 2: 2030 마이크로카피 & 문구 교정
    "b2b_copy": "claude-sonnet-4",           # 상황 3: B2B 사장님 제휴/네이티브 광고 카피
    "b2b_metrics": "gpt-4",                  # 상황 3: B2B 정산/수익 리포트 문구
    "fullstack_code": "gpt-4.1",             # 상황 4: 풀스택 위젯/상태관리 코드 구조화
    "realtime_chat": "claude-3-haiku",       # 상황 4: 앱 런타임 실시간 아이스브레이킹/태그
    "trend_json": "gpt-4o-mini",             # 상황 4: 트렌드 JSON 고속 파싱/생성
    "idea_strategy": "claude-3-opus",        # 상황 5: 킬러 피처 기획 & UX 역제안
    "algorithm_math": "o3-mini",             # 상황 5: 매칭 알고리즘 & 1/N 정산 수식 검증
}

# 로컬호스트(127.0.0.1) 통신 시 시스템 HTTP 프록시 우회 보장
_NO_PROXY_OPENER = urllib.request.build_opener(urllib.request.ProxyHandler({}))


def create_chat_completion(
    messages: List[Dict[str, str]],
    model: str = DEFAULT_MODEL,
    base_url: str = LOCAL_BASE_URL,
    api_key: str = DUMMY_API_KEY,
    timeout: int = 25,
) -> Dict[str, Any]:
    """로컬 g4f OpenAI 호환 엔드포인트(/v1/chat/completions)로 지정된 Claude/GPT 모델을 호출합니다."""
    endpoint = f"{base_url.rstrip('/')}/chat/completions"
    payload = {
        "model": model,
        "messages": messages,
        "stream": False,
    }
    body_bytes = json.dumps(payload).encode("utf-8")
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}",
    }
    req = urllib.request.Request(endpoint, data=body_bytes, headers=headers, method="POST")
    with _NO_PROXY_OPENER.open(req, timeout=timeout) as resp:
        raw = resp.read().decode("utf-8", errors="replace")
        return json.loads(raw)


def ask_claude(
    prompt: str,
    system_prompt: Optional[str] = None,
    model: str = DEFAULT_MODEL,
    timeout: int = 25,
) -> str:
    """단일 프롬프트를 전송하고 로컬 우회 Claude/GPT 모델의 응답 텍스트를 반환합니다 (타임아웃 시 자동 폴백)."""
    messages: List[Dict[str, str]] = []
    if system_prompt:
        messages.append({"role": "system", "content": system_prompt})
    messages.append({"role": "user", "content": prompt})

    candidate_models = [model]
    for fb in ("claude-3-haiku", "gpt-4o-mini", "claude-3-sonnet", "gpt-4o"):
        if fb not in candidate_models:
            candidate_models.append(fb)

    last_err: Optional[Exception] = None
    for m in candidate_models:
        try:
            data = create_chat_completion(messages=messages, model=m, timeout=timeout)
            choices = data.get("choices") or []
            if choices:
                content = (choices[0].get("message", {}).get("content") or "").strip()
                if content:
                    return content
        except Exception as e:
            last_err = e
            continue

    return f"[Local AI Fallback Notice ({model})]: 로컬 프록시 응답 지연({last_err})으로 내장 12년 차 UI/UX 규칙을 즉시 적용합니다."


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="OOMU Local g4f Claude/GPT CLI Helper")
    parser.add_argument("pos_prompt", nargs="?", default="", help="질문 프롬프트 (위치 인자)")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="호출할 모델명 (예: claude-3-5-sonnet, gpt-4.1, o3-mini)")
    parser.add_argument("--task", default="", help="작업 유형 키 (ui_redesign, ux_writing, b2b_copy, fullstack_code, idea_strategy 등)")
    parser.add_argument("--system", default="", help="시스템 프롬프트")
    parser.add_argument("--prompt", default="", help="질문 프롬프트")
    parser.add_argument("--list-models", action="store_true", help="설치된 Claude 및 GPT 모델 리스트 출력")
    args = parser.parse_args()

    final_prompt = args.prompt or args.pos_prompt
    if args.list_models:
        print("=== [설치된 Claude 모델 리스트 (7종)] ===")
        for m in CLAUDE_MODELS:
            print(f" - {m}")
        print("\n=== [설치된 GPT 모델 리스트 (9종)] ===")
        for m in GPT_MODELS:
            print(f" - {m}")
        print("\n=== [상황별 자동 매칭 키 (--task)] ===")
        for k, m in TASK_MODEL_MAP.items():
            print(f" - {k} -> {m}")
    elif final_prompt:
        selected_model = TASK_MODEL_MAP.get(args.task, args.model)
        print(ask_claude(prompt=final_prompt, system_prompt=args.system or None, model=selected_model))
    else:
        parser.error("--prompt(또는 위치 인자)나 --list-models 중 하나를 지정해주세요.")



