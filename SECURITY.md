# 🔒 OOMU 단일 보안 지침서 (SECURITY.md)

> **문서 목적**: 본 문서는 OOMU 프로젝트의 **유일한 단일 보안 지침(SSOT)**입니다.  
> 어떠한 경우에도 소스코드, 문서, 테스트, Git 커밋 이력에 개인정보(PII) 및 외부 유료 API 키·시크릿이 노출되지 않도록 엄격히 통제합니다.

---

## 🚨 1. 0-Secret & 0-PII 절대 원칙 (Zero-Tolerance)

### ① 개인 식별 정보 (PII) 소스코드 노출 절대 금지
1. **실제 개인 휴대폰 번호 (`010...`)**:
   - 프로덕션 코드, 테스트 코드, 주석, 문서, 정적 자산 어디에도 하드코딩 금지.
   - 솔라피(SOLAPI) SMS 발신번호를 포함한 모든 전화번호는 Firestore `config/api_keys` (`solapiSenderNumber`)에서 런타임 동적 로드합니다.
   - UI 힌트 및 플레이스홀더는 오직 `010-0000-0000`만 허용합니다.
2. **실제 개인 이메일 (`@naver.com`, `@daum.net`, 개인 `@gmail.com` 등)**:
   - 개인 메일 도메인은 소스코드, 마크다운, HTML 견본에 절대 포함할 수 없습니다.
   - 관리자 판별은 Firestore 유저 문서(`role == 'admin'`) 또는 서비스 전용 도메인(`admin@oomu.app`)으로만 처리합니다.
   - 테스트 계정 이메일은 반드시 `choyeon@test.oomu.app` 등 사내 테스트 도메인만 사용합니다.
   - UI 예시 마스킹은 `oomu****@gmail.com` 공용 플레이스홀더만 사용합니다.
3. **평문 비밀번호 및 크레덴셜**:
   - `password = '...'`, `passwd`, 기본 관리자 암호 등의 평문 기재 절대 금지.

### ② 외부 유료 API 키 & 서비스 크레덴셜 하드코딩 절대 금지
1. **카카오 API 키 (Kakao Developers)**:
   - REST API Key (`kakaoRestApiKey`): Firestore `config/api_keys` 동적 로드.
   - Javascript Key (`kakaoJsApiKey`): Firestore `config/api_keys` 동적 로드 및 런타임 주입.
   - Admin Key (`kakaoAdminKey`): 클라이언트 앱 및 저장소 보관 영구 금지 (유출 시 즉시 폐기).
2. **솔라피 (SOLAPI) SMS 인증**:
   - `solapiApiKey`, `solapiApiSecret`: Firestore `config/api_keys` 런타임 동적 로드.
3. **Cloudflare R2 스토리지**:
   - Account ID, Access Key ID, Secret Access Key: Firestore `config/r2_storage` 런타임 동적 로드.
   - 클라이언트 앱 및 스크립트는 S3 Secret Key를 소스에 직접 담지 않습니다.
4. **Firebase / GCP / Naver API**:
   - 서버 키, 비공개 키(`.json`, `BEGIN PRIVATE KEY`)의 Git 커밋을 원천 차단합니다.
   - 웹 배포 키는 GitHub Secrets(`secrets.KAKAO_JS_API_KEY` 등) 및 환경변수로만 주입합니다.

---

## 📂 2. 자격증명 및 미디어 보관 표준 아키텍처

| 데이터 종류 | 보관 위치 | 로드 시점 및 보안 방식 |
| :--- | :--- | :--- |
| **API 키 (Kakao, Solapi)** | Firestore `config/api_keys` | 앱 구동 시 `SolapiSmsService.initialize()`, `KakaoMapService.ensureKeysLoaded()` 비동기 조회 |
| **Cloudflare R2 자격증명** | Firestore `config/r2_storage` | 앱 기동 시 `r2Storage.initFromFirestore()` 1회 안전 로드 |
| **일반 모임 / 유저 / 채팅** | Firestore 일반 컬렉션 | 보안 규칙(`firestore.rules`)을 통한 읽기/쓰기 권한 제어 |
| **사용자 사진 / 미디어** | Cloudflare R2 버킷 (`oomu-spot`) | AWS SigV4 HMAC-SHA256 Presigned URL 기반 안전 업로드 |

---

## 🛡️ 3. 리포지토리 위생 및 커밋 차단 정책

1. **`.gitignore` 강제 등록 대상**:
   - `.gemini/` (AI 어시스턴트 로컬 캐시, 스킬, 설정)
   - `.env`, `.env.*` (로컬 환경변수 파일)
   - `node_modules/` (Node 패키지)
   - `backups/`, `scratch/` (임시 백업 및 스크래치 파일)
   - `*.pem`, `*.key`, `*serviceAccount*.json` (인증서 및 서비스 계정 키)
2. **미디어 파일 분리**:
   - `lib/` 내 이미지/동영상 파일 직접 커밋 금지 (모든 사용자 미디어는 Cloudflare R2 스토리지 활용).

---

## ⚙️ 4. 이중 자동 검증 파이프라인 (Local + GitHub Actions)

### ① 로컬 사전 검증 (커밋 전 100% 통과 필수)
개발자 및 AI 에이전트는 코드를 커밋하기 전 아래 2개 검증 명령을 반드시 실행해야 합니다:

```powershell
# Windows PowerShell 환경
powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1

# 또는 교차 플랫폼 Python 스캐너
python scripts/verify_deep_security.py
```

### ② GitHub Actions 24/7 자동 감시 스케줄러
* **동작 주기**: 매일 자정 (UTC 00:00 / KST 09:00) 정기 크론 실행 + `main` 브랜치 Push / PR 시 상시 자동 검증.
* **워크플로우**: [`.github/workflows/daily_security_audit.yml`](.github/workflows/daily_security_audit.yml)
* **조치**: 0-Secret 또는 0-PII 규칙 위반 발견 시 즉시 빌드 실패 처리 및 관리자 알림.

---

## 🚨 5. 유출 감지 시 비상 대응 절차 (Incident Response)

만약 1건이라도 개인정보 또는 외부 API 키가 저장소에 노출된 경우:
1. **즉시 키 무효화 및 재발급**: 해당 서비스 제공자 콘솔(카카오, 솔라피, Cloudflare)에서 노출된 키를 즉시 삭제/재발급합니다.
2. **Git 커밋 이력 완전 영구 파기**: 단순 신규 커밋으로 덮지 않고 `git filter-repo` 또는 `BFG Repo-Cleaner`로 히스토리에서 해당 키/정보를 완전 영구 삭제(Purge) 후 `git push --force` 합니다.
3. **Firestore 런타임 갱신**: 신규 발급된 키를 Firestore `config/api_keys` 문서에만 등록하여 서비스를 정상화합니다.
