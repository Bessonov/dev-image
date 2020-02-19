#!/bin/bash

set -euo pipefail


# in most cases you want to forward remote ports
REMOTE=${REMOTE:-true}

# export variables
set -a
CURRENT_DIR="$(dirname "$(readlink -f "$0")")"
ROOT_DIR="$(dirname "$CURRENT_DIR")"
. "$ROOT_DIR/defaults.sh"
set +a

cd "$ROOT_DIR"

REMOTE_PORT_ASSIGNMENT=$BASE_PORT
ROWS_COUNT=$((${#PORT_MAPPING[@]}/2))
CELL=0

REMOTE_FORWARD_ARGS="${REMOTE_FORWARD_ARGS:-}"
LOCAL_FORWARD_ARGS="${LOCAL_FORWARD_ARGS:-}"

for ROW_INDEX in `seq $ROWS_COUNT`; do
	PORT_NAME=${PORT_MAPPING[$((CELL++))]}
	LOCAL_PORT=${PORT_MAPPING[$((CELL++))]}
	REMOTE_PORT=$((REMOTE_PORT_ASSIGNMENT++))
	echo "$PORT_NAME: http://localhost:$LOCAL_PORT"
	# it's easier to collect args for remote and local forwarding
	REMOTE_FORWARD_ARGS="${REMOTE_FORWARD_ARGS} -L ${LOCAL_PORT}:localhost:${REMOTE_PORT}"
	LOCAL_FORWARD_ARGS="${LOCAL_FORWARD_ARGS} docker run --rm --name forwarding-$PORT_NAME --network host alpine/socat tcp-listen:$LOCAL_PORT,fork,reuseaddr tcp-connect:127.0.0.1:$REMOTE_PORT &"
done

if ${REMOTE}; then
	echo "remote forwarding"
	ssh $REMOTE_FORWARD_ARGS $(docker_host_to_ssh "$REMOTE_HOST")
else
	echo "local forwarding"
	bash -c "($LOCAL_FORWARD_ARGS wait)"
fi
