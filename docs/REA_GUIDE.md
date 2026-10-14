# REA 사용 설명서 (AI 에이전트 필독)

> REA(Reverse Engineer Anything, https://github.com/morluto/rea)는 앱/바이너리/웹 동작을 **근거(Evidence)와 함께** 분석하는 MCP 서버입니다.
> 이 프로젝트(OOMU, Flutter 안드로이드 앱)에서는 **우리가 만든 앱의 빌드 산출물 검증, UI/동작 확인, 자체 APK 점검** 용도로 사용합니다.

## 0. 사용 범위 (반드시 준수)
- **우리 소유의 앱, 또는 분석 권한이 있는 대상만** 분석합니다. 타사 앱의 무단 분석/복제는 하지 않습니다 (REA DISCLAIMER 준수).
- 분석은 로컬에서 수행되며, 결과(도구 반환값)만 에이전트에게 전달됩니다.
- 일반 소스 저장소 구조 분석에는 REA를 쓰지 말고 평소 도구(grep, 파일 읽기)를 씁니다.

## 1. 연결 상태
- 등록 위치: `C:\Users\DT4\.gemini\config\mcp_config.json` 의 `rea` 항목 (백업: `mcp_config.json.rea.backup`)
- 스킬: `C:\Users\DT4\.gemini\config\skills\reverse-engineer-anything\SKILL.md` (+ `references/*.md`)
- 설치 명령: `npx -y rea-agents setup --client antigravity --yes` (버전 6.4.0 기준)
- 설정 변경 후에는 **Antigravity를 재시작**해야 REA 도구가 보입니다.
- 도구가 안 보이면: 스킬의 `references/connection-and-recovery.md`를 읽고, `npx -y rea-agents doctor --json`으로 진단합니다. 전체 재설치를 반복하지 마세요.
- 업데이트: `npx rea-agents@latest setup --client antigravity --dry-run` 으로 계획 확인 후 적용.

## 2. 우리 프로젝트(Flutter 안드로이드 앱)에서의 활용 매핑
| 상황 | 사용할 REA 기능 | 필요 조건 |
| --- | --- | --- |
| 빌드된 APK의 Flutter 엔진/Dart 스냅샷 정보 확인 | Flutter apps 분석 (정적 APK 파싱) | 없음 |
| APK 매니페스트(권한, 액티비티), 리소스 확인 | `inspect_android_package`, Android resources | JADX + JDK (Apktool은 리소스용) |
| APK 내부 파일 목록/해시 | `open_binary` / `inspect_artifact` | 없음 |
| 실기기/에뮬레이터 로그, 패키지, 스크린 캡처 | Android devices (ADB) | `adb` 설치 + 기기 연결 |
| 배포된 웹 빌드(`https://ahn-works.github.io/datating_test/`)의 구조/네트워크/스크린샷 | Websites 브라우저 분석 | Chrome 계열 브라우저 |
| 저장된 HAR 네트워크 캡처 분석 | 네트워크 캡처 분석 | HAR 파일 |

현재 이 PC에는 Ghidra/IDA/Hopper/JADX/adb 미설치 상태입니다. 해당 기능이 필요하면 사용자에게 설치 여부를 먼저 물어보세요(REA setup은 이들을 자동 설치하지 않습니다).

## 3. 작업 규칙
1. **REA를 쓸지 판단**: 배포 산출물(APK/웹 빌드)의 실제 동작 증거가 필요할 때만 사용. 소스 코드로 답이 나오면 REA 불필요.
2. **대상 경로 확인**: 사용자가 준 로컬 경로(절대 경로)를 첫 도구에 그대로 전달. 임의로 실행/수정하지 않음.
3. **증거 중심 보고**: 결론에는 REA가 반환한 evidence와 한계(limitations)를 함께 적는다. 추측 금지.
4. **UI 검증 순서(권장)**: (a) GitHub Actions 빌드 성공 확인 → (b) 웹 빌드 브라우저 분석으로 화면/네트워크 확인 → (c) APK가 있으면 Android 정적 분석 → (d) 기기가 있으면 ADB 로그/스크린샷.
5. **Zero-Trace(회사 PC)**: 분석에 쓴 임시 파일(다운로드한 APK, 덤프, 스크래치)은 작업 후 삭제. 저장소에는 분석 결과 요약만 커밋하고 바이너리/덤프는 커밋하지 않는다.
6. **프로젝트 규칙 우선**: UI 코드는 `AI_INSTRUCTIONS.md`의 100% 동적 UI, 반응형, BottomSheet 원칙을 따른다 (REA 결과로 그 원칙을 우회하지 않는다).

## 4. 자주 쓰는 요청 예시
- "배포된 웹 빌드 홈 화면의 위치 선택 / 이미지 로딩 요청이 실패하는지 REA 브라우저 분석으로 확인해줘"
- "빌드된 APK의 권한과 포함된 에셋 목록을 확인해줘"
- "연결된 기기의 logcat에서 앱 크래시 원인을 찾아줘" (adb 필요)

## 5. 참고 문서
- REA README: https://github.com/morluto/rea
- 설치/클라이언트 설정: https://github.com/morluto/rea/blob/main/docs/installation.md
- Android 분석: https://github.com/morluto/rea/blob/main/docs/android-analysis.md
- Flutter 분석: https://github.com/morluto/rea/blob/main/docs/flutter-analysis.md
- ADB 분석: https://github.com/morluto/rea/blob/main/docs/adb-device-analysis.md
