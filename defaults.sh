IMAGE_NAME=dev
PROJECT_NAME=dev
SERVICE_NAME=dev
WORKSPACE="$(dirname $CURRENT_DIR)"

http_proxy=""
https_proxy=""
no_proxy=""

COMPILE_THREADS=$(nproc)

USER_NAME="$(whoami)"
USER_PASSWORD="dev"
USER_ID=$(id -u)
USER_GID=$USER_ID

DOCKER_VERSION="5:18.09.0~3-0~ubuntu-bionic"
DOCKER_GID=$(cat /etc/group | grep "docker:" | cut -d ":" -f 3)
DOCKER_COMPOSE_VERSION=1.23.2

JAVA_CANDIDATE="^8\\..*-oracle"

ANDROID_SDK="build-tools;28.0.3 platform-tools platforms;android-28"
NVM_VERSION=v0.34.0
# multiple versions delimited by space
# first one becomes default
NODE_VERSIONS="lts/*"

YVM_VERSION=v3.0.0
# multiple versions delimited by space
# newest one becomes default
YARN_VERSIONS="stable"

LOCAL_CONFIG="$CURRENT_DIR/local.sh"
if [ -f "$LOCAL_CONFIG" ]; then
	. "$LOCAL_CONFIG"
fi
