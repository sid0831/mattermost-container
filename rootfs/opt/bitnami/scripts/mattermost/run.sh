#!/usr/bin/env bash

# shellcheck disable=SC1091

set -euo pipefail

# Source libraries and environments
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/mattermost-env.sh

info "** Setting up Mattermost configuration **"
if [[ ! -f "${MATTERMOST_ROOT_DIR}/data/config.json" ]]; then
  cp -a "${BITNAMI_ROOT_DIR}/config.json" "${MATTERMOST_ROOT_DIR}/data/config.json"
  MM_CONFIG="${DB_CONNECTION_STRING}" "${MATTERMOST_BIN_DIR}/mattermost" db init
fi
ln -sfr "${MATTERMOST_ROOT_DIR}/data/config.json" "${MATTERMOST_ROOT_DIR}/config/config.json"

sed -i -e "s/DB_DATA_SOURCE_PLACEHOLDER/${DB_DATA_SOURCE}/" -e "s/DB_CONNECTION_STRING_PLACEHOLDER/${DB_CONNECTION_STRING}" "${MATTERMOST_ROOT_DIR}/data/config.json"
info "** Mattermost configuration finished **"

info "** Starting Mattermost **"
exec "${MATTERMOST_BIN_DIR}/mattermost"