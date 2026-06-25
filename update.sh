#!/usr/bin/env bash
#
# update.sh — deploy the latest code to the "djpk" server.
#
# Run this FROM YOUR LAPTOP, from the repo root. It pushes your current branch
# to GitHub, then SSHes into the server, pulls, re-bundles, and restarts Puma.
# First-time setup is done by deploy.sh (run once on the server) — this script
# assumes that has already happened.
#
#   ./update.sh
#
set -euo pipefail

# --- config -----------------------------------------------------------------
SSH_HOST="djpk"                         # ~/.ssh/config alias for the server
APP="ynotfitness"
BRANCH="main"
PORT="4568"

APP_DIR="/var/www/${APP}/app"
SERVICE="${APP}-puma"
BUNDLE="/home/ubuntu/.rbenv/shims/bundle"

BOLD=$(printf '\033[1m'); GREEN=$(printf '\033[32m'); RESET=$(printf '\033[0m')
say() { printf "\n${BOLD}==> %s${RESET}\n" "$1"; }

# --- 1. push local commits --------------------------------------------------
say "Pushing ${BRANCH} to GitHub"
if [ -n "$(git status --porcelain)" ]; then
  echo "  ! You have uncommitted changes — commit them first so they deploy:"
  git status --short
  exit 1
fi
git push origin "$BRANCH"

# --- 2. update + restart on the server --------------------------------------
say "Deploying on ${SSH_HOST}"
ssh "$SSH_HOST" bash -se <<REMOTE
set -euo pipefail
cd "${APP_DIR}"
echo "  pulling origin/${BRANCH}…"
git fetch --quiet origin
git reset --hard "origin/${BRANCH}"
echo "  bundling…"
"${BUNDLE}" install --quiet
echo "  restarting ${SERVICE}…"
sudo systemctl restart "${SERVICE}"
REMOTE

# --- 3. health check --------------------------------------------------------
say "Health check"
sleep 1
if ssh "$SSH_HOST" "curl -fsS http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
  printf "  ${GREEN}\xe2\x9c\x93${RESET} deployed — app healthy on 127.0.0.1:${PORT}\n"
else
  echo "  ! app not responding — check: ssh ${SSH_HOST} 'journalctl -u ${SERVICE} -n 50 --no-pager'"
  exit 1
fi
