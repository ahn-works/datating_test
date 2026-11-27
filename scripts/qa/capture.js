// 검수용 화면 캡처 (Playwright). 한 번에 10개 화면 x 폭 3개를 찍는다.
// 사용: ACCTS=<계정 JSON> [DETAIL_ID=<실제 모임 문서ID>] [ONLY=host,meetup] node scripts/qa/capture.js <url> <출력폴더> <접두어> [계정번호=0]
// DETAIL_ID: 홈 카드는 서버에 없는 지역 봇 모임이라 상세가 '찾을 수 없어요'로 뜬다 → 딥링크로 실제 모임 상세를 연다.
// 계정 JSON 형식: [{"email":"...","password":"..."}] (비밀번호는 레포에 넣지 않는다)
const { chromium } = require('playwright');
const fs = require('fs');
const [url, out, prefix, idx = '0'] = process.argv.slice(2);
const acct = JSON.parse(fs.readFileSync(process.env.ACCTS))[Number(idx)];
// [이름, 탭 x비율, 추가 동작, 찍은 뒤 뒤로가기]
const SCREENS = [
  ['home', 0.1, []], ['home_scroll', 0.1, [['wheel', 900]]],
  ['community', 0.3, []], ['post', 0.3, [['tap', 0.5, 215]]],
  ['discover', 0.5, []], ['discover_scroll', 0.5, [['wheel', 1400]]],
  ['chat', 0.7, []], ['my', 0.9, []],
  // 모임 개설(우하단 '모임 열기' → 카테고리 카드까지 스크롤)
  ['host', 0.1, [['tap', 0.82, 742], ['wheel', 120]], true],
];
const ONLY = process.env.ONLY ? process.env.ONLY.split(',') : null;
(async () => {
  fs.mkdirSync(out, { recursive: true });
  const b = await chromium.launch();
  for (const w of [360, 390, 430]) {
    const ctx = await b.newContext({ viewport: { width: w, height: 844 }, deviceScaleFactor: 1, locale: 'ko-KR', isMobile: true, hasTouch: true });
    const p = await ctx.newPage();
    await p.goto(url, { waitUntil: 'load', timeout: 60000 });
    await p.waitForTimeout(9000);
    await p.mouse.click(w / 2, 296); await p.keyboard.type(acct.email, { delay: 15 });
    await p.mouse.click(w / 2 - 15, 356); await p.keyboard.type(acct.password, { delay: 15 });
    await p.mouse.click(w / 2, 425); await p.waitForTimeout(10000);
    for (const [name, tabX, acts, back] of SCREENS) {
      if (ONLY && !ONLY.includes(name)) continue;
      await p.mouse.click(w * tabX, 812); await p.waitForTimeout(4500);
      for (const a of acts) {
        if (a[0] === 'wheel') { await p.mouse.move(w / 2, 420); await p.mouse.wheel(0, a[1]); }
        else await p.mouse.click(w * a[1], a[2]);
        await p.waitForTimeout(3500);
      }
      await p.screenshot({ path: `${out}/${prefix}_${w}_${name}.png` });
      if (name === 'post' || back) { await p.goBack().catch(() => {}); await p.waitForTimeout(1500); }
    }
    // 모임 상세(딥링크): 위쪽 정보칸, 아래쪽 모임 소개 두 장
    if (process.env.DETAIL_ID && (!ONLY || ONLY.includes('meetup'))) {
      await p.goto(`${url}?detail=true&id=${encodeURIComponent(process.env.DETAIL_ID)}`, { waitUntil: 'load', timeout: 60000 });
      await p.waitForTimeout(12000);
      await p.mouse.move(w / 2, 420); await p.mouse.wheel(0, 380); await p.waitForTimeout(2500);
      await p.screenshot({ path: `${out}/${prefix}_${w}_meetup.png` });
      await p.mouse.wheel(0, 300); await p.waitForTimeout(2500);
      await p.screenshot({ path: `${out}/${prefix}_${w}_meetup_intro.png` });
    }
    await ctx.close();
  }
  await b.close();
})().catch(e => { console.error('ERR', e.message); process.exit(1); });
