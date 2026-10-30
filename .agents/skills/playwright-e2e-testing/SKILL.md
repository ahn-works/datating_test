---
name: playwright-e2e-testing
description: Microsoft Playwright 기반 모바일 뷰포트 E2E 자동화 테스트 및 비주얼 회귀 검증 스킬. 모바일 웹 환경(Pixel 7, iPhone 14) 터치 에뮬레이션, 콘솔 에러 전수 감지, 스크린샷 렌더링 회귀 검사를 수행합니다.
license: MIT
---

# 🎭 Microsoft Playwright 모바일 E2E & 비주얼 회귀 테스트 가이드

본 스킬은 **Microsoft 공식 Playwright(`microsoft/playwright`)** 프레임워크를 기반으로, 모바일 웹 및 배포된 프로덕션 환경에서 실제 유저의 터치 시나리오를 자동 검증하고 시각적 깨짐(Visual Regression)을 사전에 차단하는 E2E 엔지니어링 표준입니다.

---

## 📱 1. 모바일 뷰포트 & 터치 에뮬레이션 (Mobile Emulation)

Playwright의 모바일 디바이스 프리셋(Pixel 7, iPhone 14 Pro)을 사용하여 모바일 전용 UI(바텀 내비게이션, 바텀시트, 플로팅 버튼)가 정상적으로 렌더링되고 터치 가능한지 검증합니다.

```javascript
// playwright.config.ts 예시
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30000,
  use: {
    baseURL: 'https://ahn-works.github.io/datating_test/',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'Android Pixel 7',
      use: { ...devices['Pixel 7'] },
    },
    {
      name: 'iOS iPhone 14',
      use: { ...devices['iPhone 14 Pro'] },
    },
  ],
});
```

---

## 🔍 2. 핵심 E2E 검증 시나리오 4대 수칙

1. **로그인 & 세션 유지 검증**:
   - 카카오 간편 로그인 및 게스트 로그인 후 로컬 스토리지에 토큰이 정상 저장되고 메인 홈 화면으로 리다이렉트되는지 검증합니다.
2. **모임 상세 & 바텀시트 열기 검증**:
   - 모임 카드를 탭했을 때 상세 화면으로 전환되고, '참여 신청' 버튼을 누르면 플로팅 바텀시트가 오버플로우 없이 부드럽게 열리는지 확인합니다.
3. **채팅방 나가기 및 소프트 삭제 검증**:
   - 유저가 채팅방에서 '나가기'를 실행했을 때 해당 유저의 채팅 목록에서 방이 사라지고, 다른 유저의 화면에는 정상 유지되는지 확인합니다.
4. **콘솔 에러(Console Errors) 제로(0) 감사**:
   - 페이지 로딩 및 사용자 인터랙션 중 브라우저 콘솔에 미처리 예외(`TypeError`, `Uncaught Exception`, `404 Not Found`)가 단 1건도 발생하지 않는지 감지합니다.

```javascript
// e2e/smoke.spec.ts 예시
import { test, expect } from '@playwright/test';

test('모바일 홈 화면 콘솔 에러 제로 및 핵심 탭 정상 렌더링', async ({ page }) => {
  const consoleErrors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') consoleErrors.push(msg.text());
  });

  await page.goto('/');
  await page.waitForLoadState('networkidle');

  // 1. 치명적 콘솔 에러가 없어야 함
  expect(consoleErrors).toHaveLength(0);

  // 2. 하단 5대 바텀 내비게이션 탭이 모두 정상 노출되어야 함
  const navTabs = page.locator('.bottom-nav-item');
  await expect(navTabs).toHaveCount(5);
});
```

---

## 📸 3. 비주얼 회귀 테스트 (Screenshot Visual Regression)

화면 코드를 변경한 뒤 이전 스크린샷과 픽셀 단위로 비교하여, 의도치 않은 레이아웃 붕괴나 글자 짤림을 100% 잡아냅니다.

```bash
# Playwright 스냅샷 비교 실행
npx playwright test --update-snapshots
```
