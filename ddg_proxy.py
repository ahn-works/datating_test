import os
import sys

# Windows 백그라운드 실행 시 cp949 인코딩 오류 방지
os.environ["PYTHONIOENCODING"] = "utf-8"
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# 유료 인증/크레딧이 필요한 프로바이더를 제외하여 무료 폴백이 즉시 동작하도록 설정
os.environ.setdefault("G4F_IGNORED_PROVIDERS", "Puter,KiloCode,Airforce,G4FSpace")

import g4f
from g4f.api import Api, run_api
from g4f.client import Client
from g4f.providers.any_provider import AnyProvider

# 로컬 프록시 호출 시 사용하는 더미 API Key('pk-dummy' 등)가
# 업스트림 무료 프로바이더에 인증 헤더로 전달되지 않도록 처리
_DUMMY_KEYS = {"pk-dummy", "g4f-local", "dummy", "secret", "sk-dummy"}
_orig_security_call = Api.security.__call__


async def _filtered_security_call(request):
    creds = await _orig_security_call(request)
    if creds is not None and creds.credentials in _DUMMY_KEYS:
        creds.credentials = "secret"
    return creds


Api.security.__call__ = _filtered_security_call

# 1. 설치된 로컬 g4f 서버 지원 Claude 모델 리스트
CLAUDE_PROXY_MODELS = [
    "claude-3-haiku",       # 초고속 응답 / 실시간 아이스브레이킹·태그 추출
    "claude-haiku-4.5",     # 경량 고속 / 짧은 마이크로카피·뱃지 문구
    "claude-3-sonnet",      # 밸런스형 / 일반 설명글·프로필 다듬기
    "claude-3-5-sonnet",    # UI/UX 리디자인 설계 & 2030 감성 카피라이팅 메인
    "claude-3.5-sonnet",    # claude-3-5-sonnet 별칭
    "claude-sonnet-4",      # 고급 UX Writing & B2B 네이티브 큐레이션 카피
    "claude-3-opus",        # 12년 차 수석 디자이너 UX 감사 & 복합 설계
    "claude-opus-4",        # 최상위 아키텍처·기획 역제안
]

# 2. 설치된 로컬 g4f 서버 지원 GPT 모델 리스트
GPT_PROXY_MODELS = [
    "gpt-4o",               # 풀스택 구조 설계 & 범용 멀티모달/카피 생성
    "gpt-4o-mini",          # 초고속 JSON 파싱 / 실시간 데이터·키워드 분류
    "gpt-4.1",              # 최신 코딩·위젯 트리 리팩토링 & 레이아웃 검증
    "gpt-4.1-mini",         # 고속 UI 컴포넌트/바텀시트 보일러플레이트 생성
    "gpt-4.1-nano",         # 초경량 상태 검증
    "gpt-4",                # B2B 사장님 제휴 제안/정산 리포트 문구 생성
    "gpt-4.5",              # 감성적 스토리텔링 & 브랜드 카피라이팅
    "o3-mini",              # 심층 추론(Reasoning) / 1/N 정산·매칭 알고리즘 수식 검증
    "o4-mini",              # 고속 추론 / 보안·예외처리 및 엣지케이스 검증
]

for model_name in CLAUDE_PROXY_MODELS + GPT_PROXY_MODELS:
    AnyProvider.model_map[model_name] = {
        "Yqcloud": "gpt-4",
    }
    if model_name not in AnyProvider.models:
        AnyProvider.models.append(model_name)


def main() -> None:
    # g4f 클라이언트 초기화 확인 및 OpenAI 호환 로컬 API 서버(127.0.0.1:1337) 구동
    _client = Client()
    run_api(bind="127.0.0.1:1337")


if __name__ == "__main__":
    main()
