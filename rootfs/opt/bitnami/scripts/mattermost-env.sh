#!/usr/bin/env bash
#
# Environment configuration for mattermost
# Written by Sidney Jeong, inspired by Bitnami container scripts

# The values for all environment variables will be set in the below order of precedence
# 1. Custom environment variables defined below after Bitnami defaults
# 2. Constants defined in this file (environment variables with no default), i.e. BITNAMI_ROOT_DIR
# 3. Environment variables overridden via external files using *_FILE variables (see below)
# 4. Environment variables set externally (i.e. current Bash context/Dockerfile/userdata)

# Load logging library
# shellcheck disable=SC1090,SC1091
. /opt/bitnami/scripts/liblog.sh

export BITNAMI_ROOT_DIR="/opt/bitnami"
export BITNAMI_VOLUME_DIR="/bitnami"

# Basic configuration
export MODULE="${MODULE:-mattermost}"
export BITNAMI_DEBUG="${BITNAMI_DEBUG:-false}"

export MATTERMOST_ROOT_DIR="${BITNAMI_ROOT_DIR}/mattermost"
export MATTERMOST_BIN_DIR="${MATTERMOST_ROOT_DIR}/bin"
export DB_DATA_SOURCE="${DB_DATA_SOURCE:-mysql}"
export DB_CONNECTION_STRING="${DB_CONNECTION_STRING:-'root@tcp(mysql:3306)/mattermost?charset=utf8mb4,utf8&writeTimeout=30s'}"