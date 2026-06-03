#!/bin/bash
set -e

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
  options: { host: 'smtp-relay.brevo.com', port: 587, secure: false, auth: { user: 'ad8029001@smtp-brevo.com', pass: process.env.BREVO_SMTP_KEY } }
};
fs.writeFileSync('$CONFIG_FILE', JSON.stringify(c));
console.log('Mail config written');
"

cd /var/lib/ghost
exec node current/index.js
