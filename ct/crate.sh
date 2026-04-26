#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVED/main/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Hotfirenet
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Hotfirenet/crate

APP="Crate"
var_tags="${var_tags:-media;telegram}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/crate ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Stopping Services"
  systemctl stop crate-bot crate-webhook
  msg_ok "Stopped Services"

  msg_info "Updating ${APP}"
  cd /opt/crate
  $STD git pull
  $STD /opt/crate/venv/bin/pip install -q -e .
  msg_ok "Updated ${APP}"

  msg_info "Starting Services"
  systemctl start crate-bot crate-webhook
  msg_ok "Started Services"

  msg_ok "Update Successful"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Push your code then configure and start:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}rsync -av --exclude='.git' /path/to/crate/ root@${IP}:/opt/crate/${CL}"
echo -e "${TAB}${GATEWAY}${BGN}/opt/crate/venv/bin/pip install -e /opt/crate${CL}"
echo -e "${TAB}${GATEWAY}${BGN}nano /opt/crate/.env${CL}"
echo -e "${TAB}${GATEWAY}${BGN}systemctl start crate-bot crate-webhook${CL}"
