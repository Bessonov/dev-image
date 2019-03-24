#!/bin/bash

set -euo pipefail

# export variables
set -a
CURRENT_DIR="$(dirname "$(readlink -f "$0")")"
. "$CURRENT_DIR/defaults.sh"
set +a

"$CURRENT_DIR/docker-compose.sh" exec $SERVICE_NAME bash --login
