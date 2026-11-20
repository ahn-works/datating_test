const { onRequest } = require('firebase-functions/v2/https');
const functionsV1 = require('firebase-functions/v1');
const admin = require('firebase-admin');
const app = require('./app');

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Firebase Functions v2 HTTPS entrypoint (Seoul region asia-northeast3)
exports.api = onRequest({
  cors: true,
  region: 'asia-northeast3',
  maxInstances: 10,
}, app);

// Auth <-> Firestore 실시간 동기화: Auth 계정 생성 시 users/{uid} 자동 생성
exports.onAuthUserCreated = functionsV1
  .region('asia-northeast3')
  .auth.user()
  .onCreate(async (user) => {
    const db = admin.firestore();
    const uid = user.uid;
    const now = admin.firestore.FieldValue.serverTimestamp();

    await db.collection('users').doc(uid).set({
      uid,
      nickname: user.displayName || '',
      avatarUrl: user.photoURL || '',
      role: 'user',
      isBot: false,
      isGuest: false,
      isProfileComplete: false,
      createdAt: now,
      updatedAt: now,
    }, { merge: true });

    if (user.email || user.phoneNumber) {
      await db.collection('users').doc(uid).collection('private').doc('contact').set({
        ...(user.email ? { email: user.email } : {}),
        ...(user.phoneNumber ? { phone: user.phoneNumber } : {}),
        updatedAt: now,
      }, { merge: true });
    }
  });

// Auth <-> Firestore 실시간 동기화: Auth 계정 삭제 시 users/{uid} 및 하위 문서 자동 삭제
exports.onAuthUserDeleted = functionsV1
  .region('asia-northeast3')
  .auth.user()
  .onDelete(async (user) => {
    const db = admin.firestore();
    const uid = user.uid;
    const userRef = db.collection('users').doc(uid);

    if (typeof db.recursiveDelete === 'function') {
      await db.recursiveDelete(userRef);
    } else {
      await userRef.delete().catch(() => {});
    }
    await db.collection('user_states').doc(uid).delete().catch(() => {});
  });
