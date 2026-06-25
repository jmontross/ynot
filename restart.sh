#!/usr/bin/env bash
#
# restart.sh — restart the YNOT Fitness app on the "djpk" server.
#
# Run from your laptop. Use this when you just need to bounce the app (e.g. after
# an nginx/puma config tweak) WITHOUT pulling new code. For a code deploy use
# ./update.sh (pull + bundle + restart); for first-time setup use ./deploy.sh.
#
#   ./restart.sh
#
set -euo pipefail

SSH_HOST="djpk"
SERVICE="ynotfitness-puma"
PORT="4568"

BOLD=$(printf '\033[1m'); GREEN=$(printf '\033[32m'); RESET=$(printf '\033[0m')

printf "\n${BOLD}==> Restarting ${SERVICE} on ${SSH_HOST}${RESET}\n"
ssh "$SSH_HOST" "sudo systemctl restart ${SERVICE}"

sleep 1
if ssh "$SSH_HOST" "curl -fsS http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
  printf "  ${GREEN}\xe2\x9c\x93${RESET} restarted — app healthy on 127.0.0.1:${PORT}\n"
else
  echo "  ! app not responding — check: ssh ${SSH_HOST} 'journalctl -u ${SERVICE} -n 50 --no-pager'"
  exit 1
fi
