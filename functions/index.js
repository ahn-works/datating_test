const { onRequest } = require('firebase-functions/v2/https');
const app = require('./app');

// Firebase Functions v2 HTTPS entrypoint (Seoul region asia-northeast3)
exports.api = onRequest({
  cors: true,
  region: 'asia-northeast3',
  maxInstances: 10,
}, app);
