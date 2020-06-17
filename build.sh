#!/usr/bin/env bash

set -euo pipefail

# export variables
set -a
CURRENT_DIR="$(dirname "$(readlink -f "$0")")"
ROOT_DIR="$CURRENT_DIR"
. "$ROOT_DIR/defaults.sh"
set +a

"$ROOT_DIR/docker-compose.sh" build --no-cache $SERVICE_NAME
