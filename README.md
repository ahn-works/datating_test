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

## 🛠️ 주요 문서
- [AI 지침서 (AI_INSTRUCTIONS.md)](AI_INSTRUCTIONS.md)
- [OOMU 마스터 명세서 (docs/OOMU_MASTER_SPEC.md)](docs/OOMU_MASTER_SPEC.md)
- [Cloudflare R2 연동 가이드 (docs/CLOUDFLARE_R2_SETUP.md)](docs/CLOUDFLARE_R2_SETUP.md)
- [개발 로드맵 (TODO.md)](TODO.md)
