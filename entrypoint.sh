#!/bin/bash
set -e

CONFIG_FILE="/var/lib/ghost/config.production.json"

# Aguarda o volume ser montado e o arquivo existir
until [ -f "$CONFIG_FILE" ]; do
  echo "Waiting for config file..."
  sleep 1
done

echo "Config found, injecting mail settings..."

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
console.log('Mail config written:', JSON.stringify(c.mail));
"

cd /var/lib/ghost
exec node current/index.js
