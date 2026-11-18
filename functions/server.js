const app = require('./app');

const PORT = process.env.PORT || 5001;

app.listen(PORT, () => {
  console.log(`[OOMU Server Proxy] Listening on http://localhost:${PORT}`);
  console.log(`[OOMU Server Proxy] Endpoints:`);
  console.log(`  - GET  /health`);
  console.log(`  - POST /api/sms/send`);
  console.log(`  - POST /api/sms/verify`);
  console.log(`  - POST /api/r2/sign-upload`);
  console.log(`  - POST /api/auth/naver`);
  console.log(`  - POST /api/auth/kakao`);
});
