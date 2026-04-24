#!/usr/bin/env bash
set -euo pipefail
[ -f .env ] || { echo "Error: .env not found"; exit 1; }
source .env
sed \
  -e "s|%%SUPABASE_URL%%|${SUPABASE_URL}|g" \
  -e "s|%%SUPABASE_KEY%%|${SUPABASE_PUBLISHABLE_KEY}|g" \
  -e "s|%%SITE_URL%%|${SITE_URL}|g" \
  config.template.js > config.js
echo "config.js built"
