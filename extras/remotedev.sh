I_CAN_DO_SOMETHING_USEFUL_FOR_YOU=false
for var in USER_NAME REMOTE REMOTE_HOST BASE_PORT PORT_MAPPING; do
	if [ -n "${!var:-}" ]; then
		I_CAN_DO_SOMETHING_USEFUL_FOR_YOU=true
	fi
done

if [ ! $I_CAN_DO_SOMETHING_USEFUL_FOR_YOU ] \
		|| [ -f docker-compose.remote.yml ] \
		|| [ -f docker-compose.local.yml ]; then
	I_CAN_DO_SOMETHING_USEFUL_FOR_YOU=true
fi

if [ ! $I_CAN_DO_SOMETHING_USEFUL_FOR_YOU ]; then
	return
fi

if $REMOTE; then
	echo "remote execution"
	IMAGE_NAME=remote-dev-${PROJECT_SUFFIX}
	PROJECT_NAME=remote-dev-${PROJECT_SUFFIX}
	if [ ! -z "$REMOTE_HOST" ]; then
		echo "docker-compose host $REMOTE_HOST"
		DOCKER_COMPOSE_HOST=$REMOTE_HOST
		# set user id for remote container
		GET_IDS_FOR=(up build)
		if [[ " ${GET_IDS_FOR[@]} " =~ " ${1:-} " ]]; then
			SSH_ARGS=$(docker_host_to_ssh "$REMOTE_HOST")
			USER_ID=$(ssh $SSH_ARGS 'id -u')
			USER_NAME=$(ssh $SSH_ARGS 'whoami')
			USER_GID=$USER_ID
			if [ "${1:-}" == "build" ]; then
				DOCKER_GID=$(ssh $SSH_ARGS 'cat /etc/group | grep "docker:" | cut -d ":" -f 3')
			fi
		fi
	fi
	if [ -f docker-compose.remote.yml ]; then
		DOCKER_COMPOSE_OPTS="--file docker-compose.remote.yml $DOCKER_COMPOSE_OPTS"
	fi
else
	echo "local execution"
	if [ -n "${REMOTE_HOST:-}" ]; then
		echo "docker host in container $REMOTE_HOST"
		DOCKER_HOST_IN_CONTAINER=$REMOTE_HOST
	fi
	if [ -f docker-compose.local.yml ]; then
		DOCKER_COMPOSE_OPTS="--file docker-compose.local.yml $DOCKER_COMPOSE_OPTS"
	fi
fi

if [ -f docker-compose.override.yml ]; then
	DOCKER_COMPOSE_OPTS="--file docker-compose.override.yml $DOCKER_COMPOSE_OPTS"
fi

DOCKER_COMPOSE_OPTS="--file docker-compose.yml $DOCKER_COMPOSE_OPTS"

if [ ! -z "$BASE_PORT" ] && [ ! -z "$PORT_MAPPING" ]; then
	REMOTE_PORT_ASSIGNMENT=$BASE_PORT

	ROWS_COUNT=$((${#PORT_MAPPING[@]}/2))

	CELL=0

	for ROW_INDEX in `seq $ROWS_COUNT`; do
		PORT_NAME=${PORT_MAPPING[$((CELL++))]}
		LOCAL_PORT=${PORT_MAPPING[$((CELL++))]}
		REMOTE_PORT=$((REMOTE_PORT_ASSIGNMENT++))
		printf -v "$PORT_NAME" '%s' $REMOTE_PORT
		printf -v "${PORT_NAME}_LOCAL" '%s' $LOCAL_PORT
	done

	unset REMOTE_PORT_ASSIGNMENT
	unset ROWS_COUNT
	unset CELL
	unset ROW_INDEX
	unset PORT_NAME
	unset LOCAL_PORT
	unset REMOTE_PORT
fi
