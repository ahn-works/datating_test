# 🔒 OOMU 보안 및 데이터/코드 3계층 분배 규칙 (Security Distribution Rules)

> **규칙 적용 대상:** Antigravity AI 에이전트, 개발자, CI/CD 워크플로우  
> **최우선 준수 원칙:** 본 프로젝트의 모든 작업은 반드시 아래의 **3계층 분배 아키텍처(3-Tier Distribution Architecture)**를 엄격하게 준수해야 하며, 작업 착수 전 및 깃허브 커밋/푸시 전 항시 이 규칙을 읽고 검증해야 합니다.

---

## 🏛️ 제1조 (3계층 분배 아키텍처)

모든 데이터, 자격 증명, 미디어 및 코드는 그 성격에 따라 다음 3개의 저장소로 엄격히 분리되어 관리됩니다.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        OOMU 3-Tier Distribution                        │
├──────────────────┬──────────────────────┬──────────────────────────────┤
│  1. 보안/민감정보  │    2. 사진/미디어      │     3. 소스코드 & 지침       │
│ (Firebase Firestore) │   (Cloudflare R2)    │          (GitHub)            │
├──────────────────┼──────────────────────┼──────────────────────────────┤
│ • R2 S3 API 키   │ • 프로필 사진 (profiles/)│ • Flutter/Dart 소스코드     │
│ • SecretAccessKey│ • 모임 커버 (covers/) │ • UI 위젯 & 상태 관리 로직   │
│ • 개인정보/식별자 │ • 대화 사진 (chats/)  │ • 테스트 코드 & CI/CD       │
│ • 실시간 대화/모임│ • 허용: JPG/PNG/WEBP  │ • 가이드/규칙 문서 (지침)     │
│ (Git 커밋 절대금지)│ (비이미지 파일 차단)   │ (민감정보 0% 제로 시크릿)     │
└──────────────────┴──────────────────────┴──────────────────────────────┘
```

---

## 🔐 제2조 (보안 파일 및 자격 증명 관리 - Firebase Firestore)

1. **보안 파일 및 API 자격 증명의 보관소:**
   - Cloudflare R2 S3 API 자격 증명(`accessKeyId`, `secretAccessKey`, `publicBaseUrl`)은 오직 **Firebase Firestore의 `config/r2_storage` 문서**에만 보관합니다.
   - 외부 공공데이터 및 AI 인증키(KOPIS 공연예술전산망, 한국관광공사 TourAPI, Google Gemini API 키 등)는 오직 **Firebase Firestore의 `config/api_keys` 문서**에만 보관합니다.
   - 사용자 민감 개인정보(전화번호, 계좌번호 등)는 Firestore의 보안 규칙이 적용된 전용 컬렉션에만 저장합니다.
2. **Git 노출 원천 금지 (Zero-Secret Policy):**
   - 소스코드(`lib/**`), 설정 파일, 테스트 코드, 커밋 메시지 등 Git에 커밋되는 어떠한 파일에도 실제 API 비밀키나 비밀번호를 하드코딩해서는 안 됩니다.
   - 코드 상에는 빈 문자열(`""`) 또는 환경변수/Firestore 동적 로딩 호출(`r2Storage.initFromFirestore()`)만 존재해야 합니다.
3. **PC 간 공유 및 동기화 원칙:**
   - 개인 PC, 회사 PC, 모바일 기기 어디서든 `git pull`을 수행한 후 앱을 구동하면, 앱 기동 시 Firestore에서 최신 자격 증명을 실시간 로드하므로 별도의 키 공유나 환경설정 커밋이 일절 불필요합니다.

---

## 🖼️ 제3조 (사진 및 미디어 저장소 관리 - Cloudflare R2)

1. **미디어 전용 버킷 (`oomu-spot`):**
   - 모든 프로필 사진, 모임 커버 이미지, 대화방 공유 사진은 **Cloudflare R2 (`oomu-spot` 버킷)**에만 업로드합니다.
   - 깃허브 저장소에 대용량 사용자 사진이나 런타임 업로드 이미지를 직접 커밋하는 것을 엄격히 금지합니다.
2. **허용 확장자 및 비이미지 파일 차단:**
   - 허용 파일 형식: `jpg`, `jpeg`, `png`, `webp`, `heic`, `gif` (이미지 형식만 허용).
   - `exe`, `sh`, `pdf`, `zip` 등 실행 파일 및 비이미지 파일은 업로드 전 클라이언트 단에서 즉시 차단합니다 (`R2StorageService.isImageFile`).
3. **카테고리별 디렉토리 격리:**
   - 프로필 사진: `profiles/{timestamp}_{filename}`
   - 모임 커버: `covers/{timestamp}_{filename}`
   - 대화방 사진: `chats/{timestamp}_{filename}`
4. **접근 및 열람 프로토콜:**
   - 퍼블릭 도메인 미연동 시: AWS SigV4 HMAC-SHA256 알고리즘 기반 **7일 유효 Presigned GET URL**을 자동 발급하여 안전하게 렌더링합니다.
   - 퍼블릭 CDN 도메인 연동 시: `publicBaseUrl`을 통해 글로벌 엣지 캐싱 가속을 적용합니다.

---

## 💻 제4조 (소스코드, 지침 및 형상 관리 - GitHub)

1. **커밋 대상:**
   - 순수 Flutter/Dart 애플리케이션 소스코드.
   - 디자인, 레이아웃, 상태 관리 및 비즈니스 로직.
   - AI 에이전트 지침서(`AI_INSTRUCTIONS.md`), 보안 규정, 개발 문서.
   - CI/CD 빌드 스크립트 및 단위/위젯 테스트 코드.
2. **사전 검증 의무 (Pre-Commit Verification):**
   - 코드를 수정하고 깃허브에 커밋/푸시하기 전, 반드시 다음 검증을 통과해야 합니다.
     - `git diff`를 통해 실제 토큰, 비밀키, 개인정보가 평문으로 포함되었는지 검사.
     - `scripts/verify_security_rules.ps1` 또는 `scripts/verify_security_rules.sh` 실행하여 보안 위반 여부 확인.
     - `test/r2_storage_test.dart` 및 단위 테스트 통과 확인.
3. **규칙 영속성 및 항상 읽기:**
   - 모든 AI 에이전트는 새로운 작업 지시를 수행할 때마다 본 규칙 파일(`.antigravity/rules/security_distribution_rules.md`)과 `AI_INSTRUCTIONS.md`를 항상 먼저 읽고 작업해야 합니다.
