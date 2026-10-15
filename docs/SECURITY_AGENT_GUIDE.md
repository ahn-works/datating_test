# 🛡️ OOMU 보안 규칙 에이전트 가이드 (Security Agent Guide)

본 가이드는 **OOMU (우리 동네 취향 모임)** 프로젝트의 보안 아키텍처와 **Firebase Firestore(보안/텍스트) ⇄ Cloudflare R2(사진) ⇄ GitHub(순수 코드/문서)** 3계층 데이터 분배 규칙을 안전하게 운용하기 위한 가이드입니다.

---

## 1. 3계층 저장소 아키텍처 개요

| 계층 (Tier) | 보관 대상 | 실제 저장소 | 보안 정책 및 접근 제어 |
| :--- | :--- | :--- | :--- |
| **Tier 1: 보안 & 개인정보** | • Cloudflare R2 S3 Access Key / Secret Key<br>• Firebase API / 서비스 토큰<br>• 사용자 민감 개인정보 | **Firebase Firestore**<br>(컬렉션: `config/r2_storage`, `users/*`) | • **Git 커밋 절대 금지 (Zero-Secret Policy)**<br>• 앱 실행 시 Firestore에서 동적 로드<br>• 관리자 전용 쓰기 권한 통제 |
| **Tier 2: 사진 & 미디어** | • 프로필 사진 (`profiles/`)<br>• 모임 커버 사진 (`covers/`)<br>• 실시간 대화 공유 사진 (`chats/`) | **Cloudflare R2**<br>(버킷: `oomu-spot`, APAC) | • JPG/PNG/WEBP 등 이미지만 허용<br>• 비이미지(실행파일/문서) 업로드 차단<br>• AWS SigV4 Presigned GET URL (7일) 조회 |
| **Tier 3: 소스코드 & 문서** | • Flutter/Dart 전체 소스코드<br>• 마크다운 지침, 가이드, 규칙 문서<br>• GitHub Actions CI/CD 워크플로우 | **GitHub Repository**<br>(`ahn-works/datating_test`) | • 민감 자격 증명 0% 포함<br>• 모든 작업 시 사전 보안 검증 통과 필수<br>• 다중 PC 간 원활한 `git pull` 작업 지원 |

---

## 2. Firebase Firestore R2 자격 증명 관리 방법

### 2.1 저장 구조 (`config/r2_storage`)
Firestore 콘솔 또는 앱 내 마이페이지의 [Cloudflare R2 연동 설정]에서 관리됩니다.

```json
{
  "bucketName": "oomu-spot",
  "accountId": "81ffd88f0a14642f94a0c4206e160925",
  "accessKeyId": "YOUR_S3_ACCESS_KEY_ID",
  "secretAccessKey": "YOUR_S3_SECRET_ACCESS_KEY",
  "publicBaseUrl": "https://pub-xxxxxx.r2.dev (선택 사항)",
  "updatedAt": "2026-10-14T..."
}
```

### 2.2 앱 런타임 자동 연동 흐름
1. `lib/main.dart` 구동 시 `Firebase.initializeApp()` 후 `r2Storage.initFromFirestore()` 자동 호출.
2. Firestore에서 자격 증명을 읽어 메모리에 안전하게 캐시.
3. 소스코드나 로컬 디스크에는 일체의 키를 저장하지 않음.
4. UI 표시 시에는 `r2Storage.getMaskedAccessKey()`, `r2Storage.getMaskedSecretKey()`를 통해 중간 마스킹(`••••••••`) 처리.

---

## 3. Cloudflare R2 사진 스토리지 운용 원칙

### 3.1 파일 형식 검증 (Whitelisting)
- 허용 확장자: `jpg`, `jpeg`, `png`, `webp`, `heic`, `gif`
- 매직 바이트(Magic Bytes) 검사 및 확장자 필터링(`R2StorageService.isImageFile`)을 거친 후 업로드.

### 3.2 안전한 이미지 렌더링 파이프라인
모든 화면의 이미지는 `lib/utils/app_image.dart`의 `appImg(path)`를 통해 렌더링됩니다.
- 입력된 경로가 R2 엔드포인트 또는 오브젝트 키인 경우:
  1. `publicBaseUrl`이 등록되어 있으면 초고속 CDN 캐싱 URL로 변환.
  2. 비공개 버킷인 경우 클라이언트에서 AWS SigV4 서명된 **7일 유효 Presigned GET URL** 자동 생성.
  3. 자격 증명 미등록 시 로컬 고화질 에셋으로 안전 폴백(Graceful Fallback)되어 401 오류 및 화면 깨짐 원천 방지.

---

## 4. 커밋 전 보안 자동 검증 (Pre-Commit Verification)

코드를 깃허브에 올리기 전, 반드시 아래 검증 스크립트를 실행하여 비밀키나 민감정보가 포함되지 않았는지 점검합니다.

### Windows (PowerShell):
```powershell
.\scripts\verify_security_rules.ps1
```

### Linux / macOS (Bash):
```bash
./scripts/verify_security_rules.sh
```

### 검증 체크리스트:
- [ ] R2 S3 Secret Access Key가 소스코드에 하드코딩되어 있지 않은가?
- [ ] 대용량 바이너리 사진 파일이 깃허브 스테이징에 추가되지 않았는가?
- [ ] 단위 테스트(`test/r2_storage_test.dart`, `test/security_distribution_test.dart`)가 성공하는가?
- [ ] `.antigravity/rules/security_distribution_rules.md` 지침을 준수하였는가?
