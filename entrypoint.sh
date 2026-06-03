#!/bin/bash
set -e

# 1. Patch MFA PRIMEIRO (antes de tudo)
SESSION_FILE="/var/lib/ghost/versions/6.43.1/core/server/services/auth/session/session-service.js"
if [ -f "$SESSION_FILE" ]; then
  sed -i 's/await this\.sendAuthCodeToUser(.*)/\/\/ mfa disabled/g' "$SESSION_FILE"
  echo "MFA patch applied"
else
  echo "SESSION FILE NOT FOUND: $SESSION_FILE"
fi

# 2. Aguarda volume e injeta mail config
CONFIG_FILE="/var/lib/ghost/config.production.json"
until [ -f "$CONFIG_FILE" ]; do
  sleep 1
done

node -e "
const fs = require('fs');
let c = {};
try { c = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8')); } catch(e) {}
c.mail = {
  transport: 'SMTP',
  from: 'noreply@ateofinal.com.br',
  options: { host: 'smtp.resend.com', port: 465, secure: true, auth: { user: 'resend', pass: process.env.RESEND_API_KEY } }
};
fs.writeFileSync('$CONFIG_FILE', JSON.stringify(c));
console.log('Mail config written');
"

# 3. Inicia Ghost
cd /var/lib/ghost
exec node current/index.js
