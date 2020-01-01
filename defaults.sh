IMAGE_NAME=dev
PROJECT_NAME=dev
SERVICE_NAME=dev
WORKSPACE="$(dirname $ROOT_DIR)"

SKIP_WATCHMAN=false
SKIP_JAVA=false
SKIP_MAVEN=false
SKIP_GRADLE=false
SKIP_ANDROID=false

http_proxy=""
https_proxy=""
no_proxy=""

COMPILE_THREADS=$(nproc)

USER_NAME="$(whoami)"
USER_PASSWORD="dev"
USER_ID=$(id -u)
# just an assumption, that the user's main group id matches user id
USER_GID=$USER_ID

DOCKER_HOST_IN_CONTAINER=""
DOCKER_VERSION="5:19.03.5~3-0~ubuntu-bionic"
DOCKER_GID=$(cat /etc/group | grep "docker:" | cut -d ":" -f 3)
DOCKER_COMPOSE_VERSION=1.25.0
DOCKER_COMPOSE=${DOCKER_COMPOSE:-docker-compose}
# ensure that the variable is defined
DOCKER_COMPOSE_HOST=${DOCKER_COMPOSE_HOST:-}
DOCKER_COMPOSE_OPTS=${DOCKER_COMPOSE_OPTS:-}

JAVA_CANDIDATE="^8\\..*-zulu$"

ANDROID_SDK="build-tools;28.0.3 platform-tools platforms;android-28"
NVM_VERSION=v0.35.1
# multiple versions delimited by space
# first one becomes default
NODE_VERSIONS="lts/*"

YVM_VERSION=v3.6.4
# multiple versions delimited by space
# newest one becomes default
YARN_VERSIONS="stable"

SSH_AUTH_DIR=$(dirname $SSH_AUTH_SOCK)

docker_host_to_ssh() {
	REMOTE_DOCKER_HOST="$1"
	if [[ "$REMOTE_DOCKER_HOST" =~ ^.*ssh://([^:]+):?([^ ]*).*$ ]]; then
		SSH_HOST=${BASH_REMATCH[1]}
		SSH_PORT=${BASH_REMATCH[2]:-22}
		echo "$SSH_HOST -p $SSH_PORT"
	else
		echo "no match: $REMOTE_DOCKER_HOST"
		exit 1
	fi
}

LOCAL_CONFIG="$ROOT_DIR/local.sh"
if [ -f "$LOCAL_CONFIG" ]; then
	. "$LOCAL_CONFIG"
fi

. "$ROOT_DIR/extras/remotedev.sh"
