/**
 * OOMU Server Proxy & Key Isolation Automated Test Suite
 * Tests proxy validation, rate limiting, R2 file guards, and error states.
 */

const assert = require('assert');
const http = require('http');
const app = require('../app');

let server;
let baseUrl;

async function request(path, options = {}) {
  const url = `${baseUrl}${path}`;
  const response = await fetch(url, {
    method: options.method || 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {})
    },
    body: options.body ? JSON.stringify(options.body) : undefined
  });

  const status = response.status;
  let body;
  try {
    body = await response.json();
  } catch (_) {
    body = null;
  }
  return { status, body };
}

async function runTests() {
  console.log('--- Starting OOMU Server Proxy Test Suite ---');
  let passed = 0;
  let failed = 0;

  function test(name, fn) {
    return Promise.resolve()
      .then(fn)
      .then(() => {
        console.log(`[PASS] ${name}`);
        passed++;
      })
      .catch(err => {
        console.error(`[FAIL] ${name}:`, err.message);
        failed++;
      });
  }

  // 1. Health Check
  await test('GET /health returns 200 and status ok', async () => {
    const res = await request('/health');
    assert.strictEqual(res.status, 200);
    assert.strictEqual(res.body.status, 'ok');
    assert.strictEqual(res.body.service, 'oomu-server-proxy');
  });

  // 2. Solapi SMS: Invalid Phone Number
  await test('POST /api/sms/send rejects invalid phone number format', async () => {
    const res = await request('/api/sms/send', {
      method: 'POST',
      body: { phone: '02-123-4567' }
    });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
    assert.ok(res.body.message.includes('010으로 시작하는'));
  });

  // 3. Solapi SMS: Server Credentials Missing
  await test('POST /api/sms/send returns 503 when server keys not set', async () => {
    delete process.env.SOLAPI_API_KEY;
    delete process.env.SOLAPI_API_SECRET;
    const res = await request('/api/sms/send', {
      method: 'POST',
      body: { phone: ['010', '0000', '0000'].join('-') }
    });
    assert.strictEqual(res.status, 503);
    assert.strictEqual(res.body.code, 'SMS_CREDENTIALS_MISSING');
  });

  // 4. Solapi SMS Verify: Missing Params
  await test('POST /api/sms/verify rejects empty phone or code', async () => {
    const res = await request('/api/sms/verify', {
      method: 'POST',
      body: { phone: '', code: '' }
    });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
  });

  // 5. Cloudflare R2: Missing Auth Header
  await test('POST /api/r2/sign-upload rejects unauthenticated request (no bearer)', async () => {
    const res = await request('/api/r2/sign-upload', {
      method: 'POST',
      body: { fileName: 'test.png', category: 'profiles' }
    });
    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.body.success, false);
    assert.ok(res.body.message.includes('로그인이 필요합니다'));
  });

  // 6. Cloudflare R2: Invalid Auth Token
  await test('POST /api/r2/sign-upload rejects invalid auth token', async () => {
    const res = await request('/api/r2/sign-upload', {
      method: 'POST',
      headers: { Authorization: 'Bearer invalid_mock_token' },
      body: { fileName: 'test.png', category: 'profiles' }
    });
    assert.strictEqual(res.status, 401);
    assert.strictEqual(res.body.success, false);
    assert.ok(res.body.message.includes('유효하지 않은 인증 토큰'));
  });

  // 7. Naver OAuth: Missing Code or State
  await test('POST /api/auth/naver rejects missing code or state', async () => {
    const res = await request('/api/auth/naver', {
      method: 'POST',
      body: { code: '' }
    });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
  });

  // 8. Naver OAuth: Missing Server Secret
  await test('POST /api/auth/naver returns 503 when server secret not set', async () => {
    delete process.env.NAVER_CLIENT_SECRET;
    const res = await request('/api/auth/naver', {
      method: 'POST',
      body: { code: 'test_code', state: 'test_state' }
    });
    assert.strictEqual(res.status, 503);
    assert.strictEqual(res.body.code, 'NAVER_SECRET_MISSING');
  });

  // 9. Kakao OAuth: Missing Code
  await test('POST /api/auth/kakao rejects missing code', async () => {
    const res = await request('/api/auth/kakao', {
      method: 'POST',
      body: {}
    });
    assert.strictEqual(res.status, 400);
    assert.strictEqual(res.body.success, false);
  });

  console.log(`\n--- Test Results: ${passed} passed, ${failed} failed ---`);
  if (failed > 0) {
    process.exit(1);
  }
}

// Start temporary test server on random port
server = http.createServer(app);
server.listen(0, async () => {
  const port = server.address().port;
  baseUrl = `http://127.0.0.1:${port}`;
  try {
    await runTests();
  } finally {
    server.close();
  }
});
