# Cloudflare R2 스토리지 연동 및 보안 가이드

## 1. 개요 및 스토리지 분리 아키텍처
본 프로젝트는 **데이터의 특성에 따른 이원화 스토리지 구조**를 채택하고 있습니다.

- **Firebase Firestore**: 텍스트 데이터 보관 (사용자 프로필 정보, 모임 메타데이터, 실시간 채팅 대화, 매너 온도 등) 및 **보안 자격 증명 안전 보관**
- **Cloudflare R2 (`oomu-spot`)**: 대용량 사진 데이터 전용 스토리지 (프로필 사진, 모임 커버 사진, 대화방 이미지)
- **엄격한 사진 파일 검증**: JPG, PNG, WEBP, HEIC, GIF 등의 순수 이미지 파일만 업로드 허용 (`R2StorageService.isImageFile`)

---

## 2. 보안 원칙: Git 비밀키 노출 방지 (Zero-Secret Policy)
> [!IMPORTANT]
> **Cloudflare R2 S3 API Secret Key 및 개인정보는 GitHub 소스코드에 절대 직접 커밋하지 않습니다.**
> 비밀번호, 암호키 등은 Firebase Firestore의 보안 컬렉션에 암호화/비공개 보관하여 AI 에이전트 및 앱이 안전하게 참조합니다.

### Firebase Firestore 보안 보관 위치
- **컬렉션 (Collection)**: `config`
- **문서 ID (Document ID)**: `r2_storage`
- **보관 필드 (Fields)**:
  ```json
  {
    "bucketName": "oomu-spot",
    "accountId": "81ffd88f0a14642f94a0c4206e160925",
    "accessKeyId": "YOUR_S3_ACCESS_KEY_ID",
    "secretAccessKey": "YOUR_S3_SECRET_ACCESS_KEY",
    "publicBaseUrl": "https://pub-xxxx.r2.dev",
    "updatedAt": "ServerTimestamp"
  }
  ```

---

## 3. Cloudflare R2 버킷 제원
- **Bucket Name**: `oomu-spot`
- **Region**: Asia-Pacific (APAC)
- **Cloudflare Account ID**: `81ffd88f0a14642f94a0c4206e160925`
- **S3 API Endpoint**:
  ```
  https://81ffd88f0a14642f94a0c4206e160925.r2.cloudflarestorage.com/oomu-spot
  ```

---

## 4. 앱 내 R2 자격 증명 등록 및 관리 방법
사용자가 Git에 키를 노출하지 않고도 안전하게 자격 증명을 등록할 수 있도록 앱 내 설정 화면을 지원합니다.

1. 앱 실행 후 우하단 **[MY]** 탭 이동
2. **[설정 및 관리]** 섹션에서 **[Cloudflare R2 스토리지 설정]** 터치
3. 현재 키는 `••••••••` 형태로 마스킹되어 표시됨
4. Cloudflare 대시보드에서 발급받은 **S3 Access Key ID**와 **Secret Access Key** 입력
5. **[Firebase에 안전하게 저장]** 버튼 터치
   - 즉시 Firestore `config/r2_storage` 문서에 비공개 저장
   - 이후 앱 및 에이전트는 Firestore에서 안전하게 키를 동적 로드하여 사용

---

## 5. 업로드 카테고리 및 경로 구조
- **프로필 사진**: `profiles/{timestamp}_{filename}.jpg`
- **모임 커버 사진**: `covers/{timestamp}_{filename}.jpg`
- **대화방 전송 사진**: `chats/{timestamp}_{filename}.jpg`

모든 업로드는 **AWS Signature V4 (HMAC-SHA256)** 서명을 거쳐 Cloudflare R2 S3 엔드포인트로 안전하게 직접 전송됩니다.
