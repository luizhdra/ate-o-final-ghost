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
  transport: 'Mailgun',
  options: {
    auth: {
      api_key: process.env.MAILGUN_API_KEY,
      domain: 'ateofinal.com.br'
    },
    host: 'api.eu.mailgun.net'
  }
};
fs.writeFileSync('$CONFIG_FILE', JSON.stringify(c));
console.log('Mail config written - Mailgun');
"

cd /var/lib/ghost
exec node current/index.js
