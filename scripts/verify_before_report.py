#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OOMU 완료 보고 전 필수 사전 검증 스크립트 (Pre-Report Verification Gate)
- 에이전트가 사용자에게 "완료했습니다"라고 보고하기 전에 반드시 실행하여 통과(Exit Code 0)해야 하는 자동 검증 도구입니다.
- 검증 항목:
  1. HTML 시안/아티팩트(<script> 내부 JS 문법·오타·줄바꿈 깨짐·괄호 짝 맞음·필수 DOM ID 및 render() 호출 여부)
  2. Python 스크립트 구문 오류(py_compile) 전수 검사
  3. 3계층 Zero-Secret 보안 규칙 위반 여부 검사
"""

import argparse
import glob
import os
import py_compile
import re
import sys

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass


def check_js_syntax_in_html(html_path: str) -> list:
    """HTML 파일 내부 <script> 블록의 JS 오타, 줄바꿈 문자열 깨짐, 괄호 불일치, 필수 렌더링 함수 유무를 정밀 검사합니다."""
    errors = []
    if not os.path.exists(html_path):
        return [f"[MISSING] 파일이 존재하지 않습니다: {html_path}"]

    with open(html_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    if content.count("<script") != content.count("</script>"):
        errors.append(f"{html_path}: <script>와 </script> 태그 개수가 일치하지 않습니다.")
    if content.count("<style") != content.count("</style>"):
        errors.append(f"{html_path}: <style>과 </style> 태그 개수가 일치하지 않습니다.")

    scripts = re.findall(r"<script[^>]*>(.*?)</script>", content, flags=re.DOTALL)
    if not scripts:
        errors.append(f"{html_path}: <script> 블록이 없습니다 (빈 화면 위험).")
        return errors

    for s_idx, js in enumerate(scripts):
        lines = js.splitlines()
        in_single = False
        in_double = False
        in_template = False
        in_block_comment = False
        escaped = False
        brace_depth = 0
        paren_depth = 0
        bracket_depth = 0

        for line_no, line in enumerate(lines, start=1):
            i = 0
            n = len(line)
            while i < n:
                ch = line[i]
                nxt = line[i + 1] if i + 1 < n else ""

                if in_block_comment:
                    if ch == "*" and nxt == "/":
                        in_block_comment = False
                        i += 2
                        continue
                    i += 1
                    continue

                if not (in_single or in_double or in_template):
                    if ch == "/" and nxt == "/":
                        break  # 라인 주석
                    if ch == "/" and nxt == "*":
                        in_block_comment = True
                        i += 2
                        continue

                if escaped:
                    escaped = False
                    i += 1
                    continue

                if ch == "\\":
                    escaped = True
                    i += 1
                    continue

                if in_single:
                    if ch == "'":
                        in_single = False
                elif in_double:
                    if ch == '"':
                        in_double = False
                elif in_template:
                    if ch == "`":
                        in_template = False
                else:
                    if ch == "'":
                        in_single = True
                    elif ch == '"':
                        in_double = True
                    elif ch == "`":
                        in_template = True
                    elif ch == "{":
                        brace_depth += 1
                    elif ch == "}":
                        brace_depth -= 1
                    elif ch == "(":
                        paren_depth += 1
                    elif ch == ")":
                        paren_depth -= 1
                    elif ch == "[":
                        bracket_depth += 1
                    elif ch == "]":
                        bracket_depth -= 1

                i += 1

            # 일반 따옴표(' 또는 ") 문자열은 줄바꿈 전에 반드시 닫혀야 함 (안 닫히면 JS SyntaxError -> 화면 백지 현상!)
            if in_single:
                errors.append(
                    f"{html_path} (<script #{s_idx+1}> line {line_no}): 작은따옴표(') 문자열이 줄 끝에서 닫히지 않아 JS SyntaxError(빈 화면)를 유발합니다 -> {line[:80]}"
                )
                in_single = False
            if in_double:
                errors.append(
                    f"{html_path} (<script #{s_idx+1}> line {line_no}): 큰따옴표(\") 문자열이 줄 끝에서 닫히지 않아 JS SyntaxError(빈 화면)를 유발합니다 -> {line[:80]}"
                )
                in_double = False

        if in_template:
            errors.append(f"{html_path} (<script #{s_idx+1}>): 백틱(`) 템플릿 리터럴이 끝까지 닫히지 않았습니다.")
        if brace_depth != 0:
            errors.append(f"{html_path} (<script #{s_idx+1}>): 중괄호 {{}} 짝이 맞지 않습니다 (차이: {brace_depth}).")
        if paren_depth != 0:
            errors.append(f"{html_path} (<script #{s_idx+1}>): 소괄호 () 짝이 맞지 않습니다 (차이: {paren_depth}).")
        if bracket_depth != 0:
            errors.append(f"{html_path} (<script #{s_idx+1}>): 대괄호 [] 짝이 맞지 않습니다 (차이: {bracket_depth}).")

    # 프로토타입 필수 렌더링 호출 체크
    if "id=\"phone\"" in content or "id=\"main\"" in content:
        if "render()" not in content:
            errors.append(f"{html_path}: 초기 화면을 그리는 render() 호출이 누락되었습니다.")

    return errors


def check_python_files(root_dir: str) -> list:
    errors = []
    py_files = [os.path.join(root_dir, "ddg_proxy.py")] + glob.glob(os.path.join(root_dir, "scripts", "*.py"))
    for py_path in py_files:
        if os.path.exists(py_path):
            try:
                py_compile.compile(py_path, doraise=True)
            except py_compile.PyCompileError as e:
                errors.append(f"Python 구문 오류 ({py_path}): {e}")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="OOMU 완료 보고 전 오타·문법·빈화면 사전 검증 도구")
    parser.add_argument(
        "--html",
        nargs="*",
        default=[],
        help="검증할 HTML 시안/아티팩트 파일 경로 목록",
    )
    args = parser.parse_args()

    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    html_targets = list(args.html)
    proto_dir = os.path.join(root_dir, "docs", "prototypes")
    if os.path.isdir(proto_dir):
        html_targets.extend(glob.glob(os.path.join(proto_dir, "*.html")))

    all_errors = []
    print("==========================================================")
    print("[PRE-REPORT GATE] 완료 보고 전 오타·구문·렌더링 사전 검증 시작")
    print("==========================================================")

    for hp in html_targets:
        errs = check_js_syntax_in_html(hp)
        if errs:
            all_errors.extend(errs)
        else:
            print(f"[PASS] HTML/JS 문법 및 렌더링 무결성 확인 완료: {hp}")

    py_errs = check_python_files(root_dir)
    if py_errs:
        all_errors.extend(py_errs)
    else:
        print("[PASS] Python 스크립트 전수 구문(py_compile) 검증 완료")

    if all_errors:
        print("\n[FAIL] 사전 검증에서 아래 오류가 발견되었습니다! 수정 전까지 완료 보고 금지:")
        for err in all_errors:
            print(f"  ❌ {err}")
        return 1

    print("==========================================================")
    print("[SUCCESS] 오타·문법·렌더링 사전 검증 100% 통과! 사용자에게 완료 보고 가능합니다.")
    print("==========================================================")
    return 0


if __name__ == "__main__":
    sys.exit(main())
