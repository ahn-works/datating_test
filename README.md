# OOMU (우리 동네 취향 모임 / Spot10)

## 📌 프로젝트 개요 및 아키텍처
본 프로젝트는 **데이터 특성에 따른 이원화 스토리지 아키텍처**를 채택하고 있습니다.

1. **Firebase Firestore (텍스트 / 보안 / 실시간 데이터)**
   - 모임 정보, 사용자 프로필, 실시간 대화방 메시지, 매너 온도 관리
   - **R2 S3 API 보안 자격 증명 안전 보관 (`config/r2_storage`)**
2. **Cloudflare R2 (`oomu-spot`) (고성능 대용량 사진 스토리지)**
   - 프로필 사진, 모임 커버 사진, 대화방 공유 사진 전용
   - AWS SigV4 HMAC-SHA256 기반 직접 업로드 및 Presigned URL 자동 생성

---

## 🔒 보안 원칙 및 PC 간 작업 연계 (Zero-Secret Policy)
> **개인정보 및 Cloudflare R2 S3 Secret Access Key는 GitHub에 커밋하지 않습니다.**

- 모든 R2 자격 증명은 **Firebase Firestore (`config/r2_storage`)**에 안전하게 등록되어 있습니다.
- 앱 실행 시(`lib/main.dart` ➡️ `r2Storage.initFromFirestore()`) Firestore에서 자동으로 최신 자격 증명을 동적 로드합니다.
- 따라서 **개인 PC, 회사 PC, 모바일 기기 어디서든 `git pull`만 받으면 별도의 API 키 수동 입력 없이 즉시 연동**됩니다.

---

## 🛠️ 프로젝트 단일 지침서 (SSOT)
- **[OOMU 단일 전체 지침서 (AGENTS.md)](AGENTS.md)**: 전체 설계, 아키텍처, 60-30-10 디자인 시스템, 세션 정합성
- **[OOMU 단일 보안 지침서 (SECURITY.md)](SECURITY.md)**: 0-Secret & 0-PII 보안 원칙, 외부 API 키 관리, 자동 사전 검증 표준
