// 검수용 화면 캡처 (Playwright). 한 번에 8개 화면 x 폭 3개를 찍는다.
// 사용: ACCTS=<계정 JSON> node scripts/qa/capture.js <url> <출력폴더> <접두어> [계정번호=0]
// 계정 JSON 형식: [{"email":"...","password":"..."}] (비밀번호는 레포에 넣지 않는다)
const { chromium } = require('playwright');
const fs = require('fs');
const [url, out, prefix, idx = '0'] = process.argv.slice(2);
const acct = JSON.parse(fs.readFileSync(process.env.ACCTS))[Number(idx)];
// [이름, 탭 x비율, 추가 동작]
const SCREENS = [
  ['home', 0.1, []], ['home_scroll', 0.1, [['wheel', 900]]],
  ['community', 0.3, []], ['post', 0.3, [['tap', 0.5, 215]]],
  ['discover', 0.5, []], ['discover_scroll', 0.5, [['wheel', 1400]]],
  ['chat', 0.7, []], ['my', 0.9, []],
];
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
    for (const [name, tabX, acts] of SCREENS) {
      await p.mouse.click(w * tabX, 812); await p.waitForTimeout(4500);
      for (const a of acts) {
        if (a[0] === 'wheel') { await p.mouse.move(w / 2, 420); await p.mouse.wheel(0, a[1]); }
        else await p.mouse.click(w * a[1], a[2]);
        await p.waitForTimeout(3500);
      }
      await p.screenshot({ path: `${out}/${prefix}_${w}_${name}.png` });
      if (name === 'post') { await p.goBack().catch(() => {}); await p.waitForTimeout(1500); }
    }
    await ctx.close();
  }
  await b.close();
})().catch(e => { console.error('ERR', e.message); process.exit(1); });
