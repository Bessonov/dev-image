#!/bin/bash

set -euo pipefail

# export variables
set -a
CURRENT_DIR="$(dirname "$(readlink -f "$0")")"
. "$CURRENT_DIR/defaults.sh"
set +a

# do this or pass overrides with `-f` too
cd "$CURRENT_DIR"
docker-compose --project-name="$PROJECT_NAME" "$@"
