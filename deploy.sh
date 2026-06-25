#!/usr/bin/env bash
#
# deploy.sh — FIRST-TIME deploy of YNOT Fitness to the "djpk" server.
#
# Run this ONCE, ON THE SERVER, as the `ubuntu` user. It is idempotent (safe to
# re-run) and uses `sudo` only for the system-level bits (dirs under /var/www,
# the systemd unit, and the nginx vhost). For routine updates afterwards, use
# ./update.sh from your laptop instead.
#
#   # on the server, as ubuntu:
#   sudo mkdir -p /var/www/ynotfitness && sudo chown ubuntu:ubuntu /var/www/ynotfitness
#   git clone git@github.com:jmontross/ynot.git /var/www/ynotfitness/app
#   cd /var/www/ynotfitness/app && ./deploy.sh
#
# (If APP_DIR below doesn't exist yet, this script will clone it for you.)
#
set -euo pipefail

# --- config -----------------------------------------------------------------
APP="ynotfitness"               # internal name: paths, service, logs
# Public domains nginx answers for (space-separated). Add/remove freely.
DOMAINS="ynot.fitness www.ynot.fitness ynotfitnesshomegyms.com www.ynotfitnesshomegyms.com"
REPO="git@github.com:jmontross/ynot.git"
BRANCH="main"
PORT="4568"                                   # loopback port nginx proxies to

APP_ROOT="/var/www/${APP}"
APP_DIR="${APP_ROOT}/app"
LOG_DIR="/var/log/${APP}"
RBENV_ROOT="/home/ubuntu/.rbenv"
BUNDLE="${RBENV_ROOT}/shims/bundle"
SERVICE="${APP}-puma"

SERVICE_FILE="/etc/systemd/system/${SERVICE}.service"
NGINX_AVAIL="/etc/nginx/sites-available/${APP}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${APP}"

# --- pretty output ----------------------------------------------------------
BOLD=$(printf '\033[1m'); GREEN=$(printf '\033[32m'); YELLOW=$(printf '\033[33m'); RESET=$(printf '\033[0m')
say()  { printf "\n${BOLD}==> %s${RESET}\n" "$1"; }
ok()   { printf "  ${GREEN}\xe2\x9c\x93${RESET} %s\n" "$1"; }
warn() { printf "  ${YELLOW}!${RESET} %s\n" "$1"; }

[ "$(whoami)" = "ubuntu" ] || { echo "Run this as the 'ubuntu' user (not root)."; exit 1; }
[ -x "$BUNDLE" ] || { echo "rbenv bundle shim not found at $BUNDLE"; exit 1; }

# --- 1. directories ---------------------------------------------------------
say "Directories"
sudo mkdir -p "$APP_ROOT"
sudo chown ubuntu:ubuntu "$APP_ROOT"
sudo mkdir -p "$LOG_DIR"
sudo chown ubuntu:ubuntu "$LOG_DIR"
ok "$APP_ROOT  +  $LOG_DIR"

# --- 2. code ----------------------------------------------------------------
say "Code"
if [ -d "${APP_DIR}/.git" ]; then
  git -C "$APP_DIR" fetch --quiet origin
  git -C "$APP_DIR" reset --hard "origin/${BRANCH}"
  ok "updated existing checkout to origin/${BRANCH}"
else
  git clone --branch "$BRANCH" "$REPO" "$APP_DIR"
  ok "cloned ${REPO} -> ${APP_DIR}"
fi
mkdir -p "${APP_DIR}/data"   # lead submissions land here (gitignored)
ok "data/ ready"

# --- 3. gems ----------------------------------------------------------------
say "Gems (bundle install)"
cd "$APP_DIR"
"$BUNDLE" config set --local path vendor/bundle
"$BUNDLE" config set --local without development
"$BUNDLE" install
ok "gems installed into vendor/bundle"

# --- 4. systemd unit --------------------------------------------------------
say "systemd unit"
sudo tee "$SERVICE_FILE" >/dev/null <<UNIT
[Unit]
Description=YNOT Fitness Puma (Sinatra)
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=${APP_DIR}
Environment=RACK_ENV=production
Environment=RBENV_ROOT=${RBENV_ROOT}
Environment=PATH=${RBENV_ROOT}/shims:${RBENV_ROOT}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=${BUNDLE} exec puma -C ${APP_DIR}/deploy/puma.rb ${APP_DIR}/config.ru
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT
ok "$SERVICE_FILE"

# --- 5. nginx vhost ---------------------------------------------------------
say "nginx vhost"
sudo tee "$NGINX_AVAIL" >/dev/null <<NGINX
server {
  listen 80;
  server_name ${DOMAINS};

  location / {
    proxy_pass http://127.0.0.1:${PORT};
    proxy_http_version 1.1;

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    # helpful for streaming/keepalive
    proxy_set_header Connection "";
  }

  access_log /var/log/nginx/${APP}.access.log;
  error_log  /var/log/nginx/${APP}.error.log;
}
NGINX
sudo ln -sfn "$NGINX_AVAIL" "$NGINX_ENABLED"
sudo nginx -t
ok "$NGINX_AVAIL (+ enabled)"

# --- 6. start it ------------------------------------------------------------
say "Start services"
sudo systemctl daemon-reload
sudo systemctl enable --now "$SERVICE"
sudo systemctl restart "$SERVICE"
sudo systemctl reload nginx
ok "${SERVICE} enabled + started; nginx reloaded"

# --- 7. health check --------------------------------------------------------
say "Health check"
sleep 1
if curl -fsS "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
  ok "app responding on 127.0.0.1:${PORT}/health"
else
  warn "no response yet on 127.0.0.1:${PORT} — check: journalctl -u ${SERVICE} -n 50 --no-pager"
fi

cat <<DONE

${BOLD}${GREEN}First-time deploy complete.${RESET}

Next steps:
  1. DNS: point an A record for each domain at this server:
        $(curl -s -m5 ifconfig.me 2>/dev/null || echo '<this server public IP>')
     Domains served: ${DOMAINS}
  2. HTTPS (do this per domain once its DNS resolves here — you can validate later):
        sudo certbot --nginx $(printf -- '-d %s ' ${DOMAINS})
  3. Routine updates from your laptop:  ./update.sh

Useful:
  sudo systemctl status ${SERVICE}
  journalctl -u ${SERVICE} -f
  tail -f ${LOG_DIR}/puma.stderr.log
DONE
