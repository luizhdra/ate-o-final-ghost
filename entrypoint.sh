#!/bin/bash
set -e

CONFIG_FILE="/var/lib/ghost/config.production.json"

inject_mail() {
  node -e "
const fs = require('fs');
const path = '$CONFIG_FILE';

let config = {};
try {
  config = JSON.parse(fs.readFileSync(path, 'utf8'));
} catch(e) {
  config = {};
}

config.mail = {
  transport: 'SMTP',
  from: process.env.MAIL_FROM || 'noreply@ateofinal.com.br',
  options: {
    host: 'smtp.resend.com',
    port: 465,
    secure: true,
    auth: {
      user: 'resend',
      pass: process.env.RESEND_API_KEY
    }
  }
};

fs.writeFileSync(path, JSON.stringify(config, null, 2));
console.log('[entrypoint] Mail config written:', JSON.stringify(config.mail));
"
}

# Injeta antes de iniciar
inject_mail

# Inicia Ghost em background, aguarda o config ser criado, injeta de novo
docker-entrypoint.sh node current/index.js &
GHOST_PID=$!

# Aguarda 5s e injeta novamente (garante que sobrescreve qualquer config do volume)
sleep 5
inject_mail
echo "[entrypoint] Mail config re-injected after volume mount"

# Aguarda o processo Ghost
wait $GHOST_PID
