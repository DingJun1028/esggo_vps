#!/usr/bin/env bash
set -euo pipefail
echo "[deploy] begin"
cd /opt/esggo || { echo "/opt/esggo missing"; exit 1; }
git stash || true
git pull origin main || true
if [ -d "vps" ]; then
  cd vps
  docker compose -f docker-compose.prod.yml build --no-cache || true
  docker compose -f docker-compose.prod.yml up -d --remove-orphans || true
  docker compose -f docker-compose.prod.yml ps || true
fi
echo "[deploy] done"
