const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK if not already initialized
if (admin.apps.length === 0) {
  try {
    admin.initializeApp();
  } catch (e) {
    console.warn('[ServerProxy] Firebase Admin init notice:', e.message);
  }
}

const ADMIN_EMAILS = (process.env.ADMIN_EMAILS || '').split(',').map(s => s.trim().toLowerCase()).filter(Boolean);

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Helper: Get Firestore instance safely
function getDb() {
  return admin.firestore();
}

// -------------------------------------------------------------
// 0. Health Check
// -------------------------------------------------------------
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'oomu-server-proxy', timestamp: new Date().toISOString() });
});

// -------------------------------------------------------------
// 1. Solapi SMS Proxy: /api/sms/send
// -------------------------------------------------------------
app.post('/api/sms/send', async (req, res) => {
  try {
    const rawPhone = (req.body.phone || '').toString().trim();
    const cleanPhone = rawPhone.replace(/[^0-9]/g, '');

    // Phone format validation (010xxxxxxxx)
    if (!cleanPhone.startsWith('010') || cleanPhone.length < 10 || cleanPhone.length > 11) {
      return res.status(400).json({ success: false, message: '010으로 시작하는 올바른 휴대폰 번호를 입력해 주세요.' });
    }

    const db = getDb();
    const verificationRef = db.collection('phone_verifications').doc(cleanPhone);
    const existingSnap = await verificationRef.get().catch(() => null);

    const now = Date.now();
    if (existingSnap && existingSnap.exists) {
      const data = existingSnap.data();
      // Rate limiting: At least 30 seconds between sends
      if (data.lastSentAt && now - data.lastSentAt < 30000) {
        const waitSec = Math.ceil((30000 - (now - data.lastSentAt)) / 1000);
        return res.status(429).json({ success: false, message: `${waitSec}초 후 다시 요청할 수 있습니다.` });
      }

      // Daily attempt limit: max 10 sends per 24 hours
      if (data.dayStart && now - data.dayStart < 86400000 && (data.sendsToday || 0) >= 10) {
        return res.status(429).json({ success: false, message: '일일 인증번호 요청 한도(10회)를 초과했습니다. 내일 다시 시도해 주세요.' });
      }
    }

    // Generate secure 6-digit OTP
    const otp = crypto.randomInt(100000, 999999).toString();
    const salt = crypto.randomBytes(16).toString('hex');
    const hashedCode = crypto.createHash('sha256').update(otp + salt).digest('hex');

    const dayStart = existingSnap && existingSnap.exists && (now - (existingSnap.data().dayStart || 0) < 86400000)
      ? existingSnap.data().dayStart
      : now;
    const sendsToday = existingSnap && existingSnap.exists && (now - (existingSnap.data().dayStart || 0) < 86400000)
      ? (existingSnap.data().sendsToday || 0) + 1
      : 1;

    // Save hashed OTP with 3-minute expiry to Firestore
    await verificationRef.set({
      phone: cleanPhone,
      hashedCode,
      salt,
      expiresAt: now + 180000, // 3 minutes
      attempts: 0,
      lastSentAt: now,
      dayStart,
      sendsToday,
      verified: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true }).catch(e => console.warn('[ServerProxy] OTP persist failed:', e.message));

    // Retrieve server-side credentials
    let apiKey = process.env.SOLAPI_API_KEY || '';
    let apiSecret = process.env.SOLAPI_API_SECRET || '';
    let senderNumber = process.env.SOLAPI_SENDER_NUMBER || '';
    let kakaoPfId = process.env.SOLAPI_KAKAO_PFID || '';
    let kakaoTemplateId = process.env.SOLAPI_KAKAO_TEMPLATE_ID || '';

    // Load from Firestore app_config/solapi if not set in env
    if (!apiKey || !apiSecret || !senderNumber || !kakaoPfId) {
      try {
        const solapiDoc = await db.collection('app_config').doc('solapi').get();
        if (solapiDoc.exists) {
          const cfg = solapiDoc.data();
          apiKey = apiKey || cfg.solapiApiKey || '';
          apiSecret = apiSecret || cfg.solapiApiSecret || '';
          senderNumber = senderNumber || cfg.solapiSenderNumber || '';
          kakaoPfId = kakaoPfId || cfg.solapiKakaoPfId || '';
          kakaoTemplateId = kakaoTemplateId || cfg.solapiKakaoTemplateId || '';
        }
      } catch (e) {
        console.warn('[ServerProxy] Firestore solapi config read notice:', e.message);
      }
    }

    if (!apiKey || !apiSecret || !senderNumber) {
      // In testing/dev environments without server keys configured:
      return res.status(503).json({
        success: false,
        message: '서버에 SMS 발송 키가 설정되지 않았습니다. 관리자에게 문의하세요.',
        code: 'SMS_CREDENTIALS_MISSING'
      });
    }

    // Build Solapi Messages v4 HMAC-SHA256 signature
    const dateStr = new Date().toISOString();
    const solapiSalt = Date.now().toString() + crypto.randomInt(1000, 9999).toString();
    const hmac = crypto.createHmac('sha256', apiSecret);
    hmac.update(dateStr + solapiSalt);
    const signature = hmac.digest('hex');
    const authHeader = `HMAC-SHA256 apiKey=${apiKey}, date=${dateStr}, salt=${solapiSalt}, signature=${signature}`;

    const messageText = `[OOMU] 동네 취향 모임 ✨\n\n반가워요, 이웃님! \n우무(OOMU) 인증번호입니다.\n\n🔐 인증번호 : [${otp}]\n⏱️ 유효시간 : 3분 이내\n\n🙅 타인에게 절대 노출 금지!`;

    const kakaoPfId = process.env.SOLAPI_KAKAO_PFID || '';
    const kakaoTemplateId = process.env.SOLAPI_KAKAO_TEMPLATE_ID || '';

    const messagePayload = {
      to: cleanPhone,
      from: senderNumber,
      text: messageText
    };

    if (kakaoPfId && kakaoTemplateId) {
      messagePayload.kakaoOptions = {
        pfId: kakaoPfId,
        templateId: kakaoTemplateId,
        variables: {
          '#{인증번호}': otp
        },
        disableSms: false
      };
    }

    const solapiRes = await fetch('https://api.solapi.com/messages/v4/send', {
      method: 'POST',
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: messagePayload
      })
    });

    if (!solapiRes.ok) {
      const errText = await solapiRes.text();
      console.error('[ServerProxy] Solapi send error:', solapiRes.status, errText);
      return res.status(502).json({ success: false, message: 'SMS 발송사 응답 오류가 발생했습니다.' });
    }

    return res.json({ success: true, message: '인증번호가 발송되었습니다.', expiresIn: 180 });
  } catch (err) {
    console.error('[ServerProxy] /api/sms/send error:', err);
    return res.status(500).json({ success: false, message: '서버 내부 오류가 발생했습니다.' });
  }
});

// -------------------------------------------------------------
// 2. Solapi SMS Proxy: /api/sms/verify
// -------------------------------------------------------------
app.post('/api/sms/verify', async (req, res) => {
  try {
    const rawPhone = (req.body.phone || '').toString().trim();
    const cleanPhone = rawPhone.replace(/[^0-9]/g, '');
    const code = (req.body.code || '').toString().trim();

    if (!cleanPhone || !code) {
      return res.status(400).json({ success: false, message: '전화번호와 인증번호를 입력해 주세요.' });
    }

    const db = getDb();
    const verificationRef = db.collection('phone_verifications').doc(cleanPhone);
    const snap = await verificationRef.get();

    if (!snap.exists) {
      return res.status(400).json({ success: false, message: '인증 요청 내역이 없습니다. 인증번호를 다시 요청해 주세요.' });
    }

    const data = snap.data();
    const now = Date.now();

    // Check expiry
    if (now > (data.expiresAt || 0)) {
      return res.status(400).json({ success: false, message: '인증번호 유효시간(3분)이 만료되었습니다. 다시 요청해 주세요.' });
    }

    // Check attempt limit
    if ((data.attempts || 0) >= 5) {
      return res.status(400).json({ success: false, message: '인증 실패 횟수(5회)를 초과했습니다. 다시 요청해 주세요.' });
    }

    // Validate hash
    const inputHash = crypto.createHash('sha256').update(code + (data.salt || '')).digest('hex');
    if (inputHash !== data.hashedCode) {
      await verificationRef.update({
        attempts: admin.firestore.FieldValue.increment(1)
      });
      return res.status(400).json({ success: false, message: '인증번호가 일치하지 않습니다.' });
    }

    // Mark as verified
    await verificationRef.update({
      verified: true,
      verifiedAt: now,
      hashedCode: admin.firestore.FieldValue.delete(), // Consume OTP
      salt: admin.firestore.FieldValue.delete()
    });

    return res.json({ success: true, verified: true, message: '휴대폰 본인인증이 완료되었습니다.' });
  } catch (err) {
    console.error('[ServerProxy] /api/sms/verify error:', err);
    return res.status(500).json({ success: false, message: '서버 내부 오류가 발생했습니다.' });
  }
});

// -------------------------------------------------------------
// 3. Cloudflare R2 Presigned Upload Proxy: /api/r2/sign-upload
// -------------------------------------------------------------
app.post('/api/r2/sign-upload', async (req, res) => {
  try {
    // 1. Verify user authentication (Firebase Auth Bearer token)
    const authHeader = req.headers.authorization || '';
    if (!authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: '로그인이 필요합니다.' });
    }
    const idToken = authHeader.substring(7).trim();
    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (e) {
      return res.status(401).json({ success: false, message: '유효하지 않은 인증 토큰입니다.' });
    }

    const { fileName, category, mimeType, contentLength } = req.body;
    if (!fileName || !category) {
      return res.status(400).json({ success: false, message: '파일명과 카테고리는 필수 항목입니다.' });
    }

    // Allowed MIME types and size limit (15MB)
    const allowedMime = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    const cleanMime = (mimeType || 'image/jpeg').toLowerCase();
    if (!allowedMime.includes(cleanMime)) {
      return res.status(400).json({ success: false, message: '지원하지 않는 이미지 형식입니다. (JPG, PNG, WebP, GIF만 허용)' });
    }
    if (contentLength && Number(contentLength) > 15 * 1024 * 1024) {
      return res.status(400).json({ success: false, message: '파일 크기는 최대 15MB 이하만 가능합니다.' });
    }

    // Resolve storage key path
    const ext = fileName.includes('.') ? fileName.split('.').pop().toLowerCase() : 'jpg';
    const timestamp = Date.now();
    const safeKey = `${category}/${decodedToken.uid}_${timestamp}.${ext}`;

    // R2 S3 Presigned URL generation using AWS SDK
    const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
    const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

    const accountId = process.env.R2_ACCOUNT_ID || 'd85501dd64bfa1bfa98e3bcfb7d48d4e';
    const accessKeyId = process.env.R2_ACCESS_KEY_ID || '';
    const secretAccessKey = process.env.R2_SECRET_ACCESS_KEY || '';
    const bucketName = process.env.R2_BUCKET_NAME || 'oomu-spot';
    const publicBaseUrl = process.env.R2_PUBLIC_BASE_URL || 'https://pub-8d0ba75990524458bc26ba403bf6aef4.r2.dev';

    if (!accessKeyId || !secretAccessKey) {
      return res.status(503).json({
        success: false,
        message: '서버에 Cloudflare R2 스토리지 키가 설정되지 않았습니다.',
        code: 'R2_CREDENTIALS_MISSING'
      });
    }

    const s3Client = new S3Client({
      region: 'auto',
      endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
      credentials: { accessKeyId, secretAccessKey }
    });

    const command = new PutObjectCommand({
      Bucket: bucketName,
      Key: safeKey,
      ContentType: cleanMime
    });

    // Generate Presigned PUT URL expiring in 5 minutes (300 seconds)
    const uploadUrl = await getSignedUrl(s3Client, command, { expiresIn: 300 });
    const publicUrl = `${publicBaseUrl}/${safeKey}`;

    return res.json({
      success: true,
      uploadUrl,
      publicUrl,
      key: safeKey,
      expiresIn: 300
    });
  } catch (err) {
    console.error('[ServerProxy] /api/r2/sign-upload error:', err);
    return res.status(500).json({ success: false, message: 'R2 업로드 URL 생성 중 오류가 발생했습니다.' });
  }
});

// -------------------------------------------------------------
// 4. Naver OAuth Token Proxy: /api/auth/naver
// -------------------------------------------------------------
app.post('/api/auth/naver', async (req, res) => {
  try {
    const { code, state } = req.body;
    if (!code || !state) {
      return res.status(400).json({ success: false, message: '인가 코드(code)와 상태(state)는 필수입니다.' });
    }

    const clientId = process.env.NAVER_CLIENT_ID || '6W4qV0e8Y81y0gUeKxGq';
    const clientSecret = process.env.NAVER_CLIENT_SECRET || '';

    if (!clientSecret) {
      return res.status(503).json({
        success: false,
        message: '서버에 네이버 클라이언트 시크릿이 설정되지 않았습니다.',
        code: 'NAVER_SECRET_MISSING'
      });
    }

    // 1. Exchange code for access token with Naver OAuth server
    const tokenUrl = `https://nid.naver.com/oauth2.0/token?grant_type=authorization_code&client_id=${clientId}&client_secret=${clientSecret}&code=${code}&state=${state}`;
    const tokenResp = await fetch(tokenUrl);
    const tokenData = await tokenResp.json();

    if (!tokenResp.ok || !tokenData.access_token) {
      return res.status(400).json({ success: false, message: '네이버 토큰 교환에 실패했습니다.', error: tokenData });
    }

    // 2. Fetch user profile from Naver API
    const userResp = await fetch('https://openapi.naver.com/v1/nid/me', {
      headers: { 'Authorization': `Bearer ${tokenData.access_token}` }
    });
    const userData = await userResp.json();

    if (!userResp.ok || userData.resultcode !== '00') {
      return res.status(400).json({ success: false, message: '네이버 사용자 정보 조회 실패' });
    }

    const naverProfile = userData.response;
    const naverId = naverProfile.id;
    const naverEmail = (naverProfile.email || '').trim().toLowerCase();
    const naverNick = naverProfile.nickname || naverProfile.name || '네이버회원';

    // 3. Map to deterministic Firebase Auth UID: naver_<naverId>
    const uid = `naver_${naverId}`;
    const isAdmin = ADMIN_EMAILS.includes(naverEmail);

    // 4. Ensure Firebase user exists & set Custom Claims
    let userRecord;
    try {
      userRecord = await admin.auth().getUser(uid);
    } catch (e) {
      // User doesn't exist yet, create user
      userRecord = await admin.auth().createUser({
        uid,
        email: naverEmail.includes('@') ? naverEmail : `naver_${naverId}@oomu.app`,
        displayName: naverNick
      });
    }

    // Assign admin: true custom claim if included in ADMIN_EMAILS
    await admin.auth().setCustomUserClaims(uid, {
      admin: isAdmin,
      provider: 'naver'
    });

    // 5. Generate Firebase Custom Token
    const customToken = await admin.auth().createCustomToken(uid, {
      admin: isAdmin,
      provider: 'naver'
    });

    // Sync user role to Firestore
    const db = getDb();
    await db.collection('users').doc(uid).set({
      userId: uid,
      nickname: naverNick,
      role: isAdmin ? 'admin' : 'user',
      provider: 'naver',
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return res.json({
      success: true,
      customToken,
      isAdmin,
      user: {
        uid,
        email: naverEmail,
        nickname: naverNick,
        role: isAdmin ? 'admin' : 'user'
      }
    });
  } catch (err) {
    console.error('[ServerProxy] /api/auth/naver error:', err);
    return res.status(500).json({ success: false, message: '네이버 로그인 처리 중 서버 오류가 발생했습니다.' });
  }
});

// 5. Kakao OAuth -> Firebase Custom Token
app.post('/api/auth/kakao', async (req, res) => {
  try {
    const { code, redirectUri } = req.body || {};
    if (!code) {
      return res.status(400).json({ success: false, message: '인가 코드(code)는 필수입니다.' });
    }
    const restKey = process.env.KAKAO_REST_API_KEY || '';
    if (!restKey) {
      return res.status(503).json({ success: false, message: '서버에 카카오 키가 설정되지 않았습니다.', code: 'KAKAO_KEY_MISSING' });
    }
    const params = new URLSearchParams({ grant_type: 'authorization_code', client_id: restKey, code });
    if (redirectUri) params.append('redirect_uri', redirectUri);
    if (process.env.KAKAO_CLIENT_SECRET) params.append('client_secret', process.env.KAKAO_CLIENT_SECRET);
    const tokenResp = await fetch('https://kauth.kakao.com/oauth/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8' },
      body: params.toString()
    });
    const tokenData = await tokenResp.json();
    if (!tokenResp.ok || !tokenData.access_token) {
      return res.status(400).json({ success: false, message: '카카오 토큰 발급에 실패했습니다.' });
    }
    const userResp = await fetch('https://kapi.kakao.com/v2/user/me', {
      headers: { Authorization: 'Bearer ' + tokenData.access_token }
    });
    const u = await userResp.json();
    if (!userResp.ok || !u.id) {
      return res.status(400).json({ success: false, message: '카카오 사용자 정보 조회 실패' });
    }
    const uid = 'kakao_' + u.id;
    const nick = ((u.properties && u.properties.nickname) || '카카오회원').toString();
    try {
      await admin.auth().getUser(uid);
    } catch (e) {
      await admin.auth().createUser({ uid, displayName: nick });
    }
    const customToken = await admin.auth().createCustomToken(uid, { provider: 'kakao' });
    const db = getDb();
    if (db) {
      await db.collection('users').doc(uid).set({
        userId: uid, nickname: nick, provider: 'kakao',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true }).catch(() => {});
    }
    return res.json({ success: true, customToken, user: { uid, nickname: nick } });
  } catch (err) {
    console.error('[ServerProxy] /api/auth/kakao error:', err);
    return res.status(500).json({ success: false, message: '카카오 로그인 처리 중 서버 오류가 발생했습니다.' });
  }
});

module.exports = app;

