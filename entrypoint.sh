#!/bin/bash
set -e

CONFIG_FILE="/var/lib/ghost/config.production.json"

# Aguarda o config existir (Ghost cria na primeira inicialização)
# Se não existir ainda, cria um base
if [ ! -f "$CONFIG_FILE" ]; then
  echo "{}" > "$CONFIG_FILE"
fi

# Injeta configuração de email via Node.js
node -e "
const fs = require('fs');
const path = '$CONFIG_FILE';

let config = {};
try {
  config = JSON.parse(fs.readFileSync(path, 'utf8'));
} catch(e) {
  config = {};
}

// Injeta config de email do Resend via SMTP
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
console.log('[entrypoint] Mail config injected successfully');
console.log('[entrypoint] From:', config.mail.from);
console.log('[entrypoint] Host:', config.mail.options.host);
"

# Inicia o Ghost normalmente
exec docker-entrypoint.sh node current/index.js
