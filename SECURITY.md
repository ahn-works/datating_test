# 🔒 OOMU 단일 보안 지침서 (SECURITY.md)

> **목적**: 본 문서는 OOMU 프로젝트의 **유일한 단일 보안 지침(SSOT)**입니다.  
> 어떠한 경우에도 소스코드, 문서, Git 커밋 이력에 개인정보(PII) 및 외부 유료 API 키가 노출되지 않도록 강제합니다.

---

## 🚨 1. 0-Secret & 0-PII 절대 원칙

1. **개인 식별 정보(PII) 소스코드 노출 절대 금지**
   - **실제 개인 휴대폰 번호 (`010...`)**: 소스코드, 테스트 코드, 주석, 문서에 하드코딩 절대 금지.
     - 솔라피(SOLAPI) SMS 발신번호를 포함한 모든 전화번호는 Firestore `config/api_keys` (`solapiSenderNumber`)에서 런타임 동적 로드합니다.
   - **실제 개인 이메일 (`@naver.com`, `@daum.net`, 개인 `@gmail.com` 등)**: 절대 하드코딩 금지.
     - 관리자 권한 확인은 Firestore 유저 문서(`role == 'admin'`) 또는 서비스 전용 도메인(`admin@oomu.app`)으로만 판별합니다.
     - 로그인/UI 예시 마스킹은 반드시 `oomu****@gmail.com` 등 공용 플레이스홀더를 사용합니다.
   - **실제/개인 비밀번호**: 어떠한 형태의 평문 비밀번호(`passwd`, `password = '...'`)도 소스에 커밋하지 않습니다.

2. **외부 유료 API 키 & 서비스 크레덴셜 하드코딩 금지**
   - **카카오 API 키 (Kakao Developers)**:
     - REST API Key (`kakaoRestApiKey`): Firestore `config/api_keys` 동적 로드.
     - Javascript Key (`kakaoJsApiKey`): Firestore `config/api_keys` 동적 로드 및 웹 뷰 런타임 전달.
     - Admin Key (`kakaoAdminKey`): 클라이언트 앱 소스코드 및 저장소에 **절대 보관 금지** (완전 삭제).
   - **솔라피 (SOLAPI) SMS**:
     - `solapiApiKey`, `solapiApiSecret`: Firestore `config/api_keys`에서 런타임 동적 로드.
   - **Cloudflare R2 스토리지**:
     - Account ID, Access Key ID, Secret Access Key: Firestore `config/r2_storage`에서 런타임 동적 로드.
   - **Firebase Web API Key**:
     - 파이썬/배포 스크립트에 하드코딩 금지. 필요 시 환경 변수(`FIRESTORE_WEB_KEY`)로 주입.

---

## 📂 2. 데이터 보관 및 런타임 로드 표준

| 데이터 종류 | 보관 위치 | 로드 시점 및 방식 |
| :--- | :--- | :--- |
| **API 키 (Kakao, Solapi)** | Firestore `config/api_keys` | `SolapiSmsService.initialize()`, `KakaoMapService.ensureKeysLoaded()` |
| **Cloudflare R2 자격증명** | Firestore `config/r2_storage` | `r2Storage.initFromFirestore()` (앱 기동 시 1회) |
| **일반 텍스트 / 모임 / 유저** | Firestore 일반 컬렉션 | 서비스 계층을 통한 비동기 쿼리 |
| **사진 / 미디어 파일** | Cloudflare R2 버킷 (`oomu-spot`) | AWS SigV4 HMAC-SHA256 Presigned URL 업로드/조회 |

---

## 🛡️ 3. Git 및 리포지토리 위생 규칙

1. **커밋 금지 파일 (`.gitignore`)**:
   - `.gemini/` (글로벌 스킬, 캐시, 개인 설정)
   - `.env`, `.env.*` (환경변수 파일)
   - `node_modules/` (Node 패키지)
   - `backups/`, `scratch/` (임시 백업 및 스크래치 파일)
   - `*serviceAccount*.json`, `*.key.json` (GCP/Firebase 서비스 계정 키)
2. **미디어 파일**:
   - `lib/` 및 Git 저장소에 대용량 이미지/사진 파일 무단 커밋 금지 (모든 이미지는 Cloudflare R2 스토리지에 업로드).

---

## 🛠️ 4. 필수 자동 검증 절차 (커밋 전 100% 통과 필수)

에이전트는 코드를 수정하거나 커밋하기 전 반드시 다음 검증 스크립트를 실행하여 0건의 위반 사항을 확인해야 합니다:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify_security_rules.ps1
```

- **검증 항목**:
  1. `lib/` 내 R2 S3 Secret Access Key 하드코딩 부재
  2. `lib/`, `web/`, `scripts/` 내 카카오 API/어드민 키 하드코딩 부재
  3. `lib/` 내 실제 개인 휴대폰 번호 부재
  4. `lib/` 내 개인 네이버/다음 이메일 및 비밀번호 부재
  5. `lib/` 내 비인가 미디어 파일 부재
  6. 필수 지침서(`SECURITY.md`, `AGENTS.md`) 존재 여부
