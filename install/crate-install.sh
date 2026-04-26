#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Hotfirenet
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Hotfirenet/crate

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  curl \
  sudo \
  mc \
  python3 \
  python3-pip \
  python3-venv \
  ffmpeg \
  libchromaprint-tools
msg_ok "Installed Dependencies"

msg_info "Preparing Crate environment"
mkdir -p /opt/crate/music /opt/crate/.cache
python3 -m venv /opt/crate/venv
cat <<EOF >/opt/crate/.env
OUTPUT_DIR=/opt/crate/music
TELEGRAM_TOKEN=
TELEGRAM_ALLOWED_USERS=
API_KEY=
API_HOST=0.0.0.0
API_PORT=8000
SPOTIFY_CLIENT_ID=
SPOTIFY_CLIENT_SECRET=
COOKIES_BROWSER=
MB_RATE_LIMIT=1.0
MB_CACHE_TTL=604800
SPONSORBLOCK_ENABLED=false
EOF
msg_ok "Prepared Crate environment"

msg_info "Creating Services"
cat <<EOF >/etc/systemd/system/crate-bot.service
[Unit]
Description=Crate Telegram Bot
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/crate
EnvironmentFile=/opt/crate/.env
ExecStart=/opt/crate/venv/bin/python channels/bot_telegram.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF >/etc/systemd/system/crate-webhook.service
[Unit]
Description=Crate Webhook API
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/crate
EnvironmentFile=/opt/crate/.env
Environment=API_HOST=0.0.0.0
ExecStart=/opt/crate/venv/bin/python channels/api_webhook.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl enable -q crate-bot crate-webhook
msg_ok "Created Services"

motd_ssh
customize
cleanup_lxc
