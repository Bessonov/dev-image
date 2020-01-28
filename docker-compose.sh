#!/bin/bash

set -euo pipefail

# set local as default
REMOTE=${REMOTE:-false}

# export variables
set -a
CURRENT_DIR="$(dirname "$(readlink -f "$0")")"
ROOT_DIR="$CURRENT_DIR"
. "$ROOT_DIR/defaults.sh"
set +a

cd "$ROOT_DIR"

DOCKER_HOST=${DOCKER_COMPOSE_HOST} $DOCKER_COMPOSE $DOCKER_COMPOSE_OPTS --project-name="$PROJECT_NAME" "$@"
