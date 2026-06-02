#!/bin/bash
set -e

CONFIG_FILE="/var/lib/ghost/config.production.json"

# Aguarda o volume ser montado e o config existir
for i in $(seq 1 30); do
  if [ -f "$CONFIG_FILE" ]; then
    break
  fi
  sleep 1
done

# Injeta config de email
node -e "
const fs = require('fs');
const path = '$CONFIG_FILE';
let config = {};
try { config = JSON.parse(fs.readFileSync(path, 'utf8')); } catch(e) {}
config.mail = {
  transport: 'SMTP',
  from: process.env.MAIL_FROM || 'noreply@ateofinal.com.br',
  options: {
    host: 'smtp.resend.com',
    port: 465,
    secure: true,
    auth: { user: 'resend', pass: process.env.RESEND_API_KEY }
  }
};
fs.writeFileSync(path, JSON.stringify(config, null, 2));
console.log('[entrypoint] Mail config written');
"

exec docker-entrypoint.sh node current/index.js
