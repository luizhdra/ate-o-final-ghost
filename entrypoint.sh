#!/bin/bash
set -e

SESSION_FILE="/var/lib/ghost/versions/6.43.1/core/server/services/auth/session/session-service.js"

node -e "
const fs = require('fs');
let code = fs.readFileSync('$SESSION_FILE', 'utf8');

// Patch 1: desativa envio do código
code = code.replace(
  /async function sendAuthCodeToUser\(req, res\) \{[\s\S]*?\n    \}/,
  'async function sendAuthCodeToUser(req, res) { return; }'
);

// Patch 2: faz a verificação do código sempre passar
code = code.replace(
  /async function verifyAuthCode\(req, res\) \{[\s\S]*?\n    \}/,
  'async function verifyAuthCode(req, res) { return; }'
);

fs.writeFileSync('$SESSION_FILE', code);
console.log('MFA patch applied');
"

CONFIG_FILE="/var/lib/ghost/config.production.json"
until [ -f "\$CONFIG_FILE" ]; do
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

cd /var/lib/ghost
exec node current/index.js
