#!/bin/bash
cat /var/lib/ghost/config.production.json | grep mail
exec node /var/lib/ghost/current/index.js
