FROM	ubuntu:18.04

ARG	http_proxy=""
ARG	https_proxy=""
ARG	no_proxy=""

ARG	COMPILE_THREADS

ARG	DOCKER_VERSION
ARG	DOCKER_GID
ARG	USER_NAME
ARG	USER_PASSWORD
ARG	USER_ID
ARG	USER_GID

ENV	http_proxy=${http_proxy} https_proxy=${https_proxy} no_proxy=${no_proxy}
ENV	USER_NAME=${USER_NAME}
ENV	USER=${USER_NAME} PASSWORD=${USER_PASSWORD} GROUP=${USER_NAME} USER_ID=${USER_ID} USER_GID=${USER_GID}
ENV	HOME=/home/${USER}

# need docker >= 1.12
# use login shell to source profile
SHELL	["bash", "--login", "-e", "-o", "pipefail", "-c"]

# fix docker group to match host name and gui
RUN	groupadd --gid "${DOCKER_GID}" "docker"

RUN	apt-get update && \
	apt-get -yqq install \
		sudo iputils-ping vim htop nmap apache2-utils telnet curl wget git-core tree \
		bash-completion net-tools \
		# for watchman
		autoconf automake build-essential python-dev libssl-dev libtool pkg-config \
		# for android sdk
		libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 \
		# for android uiautomatorviewer
		libswt-gtk-3-java libswt-gtk-3-jni \
		# for docker
		apt-transport-https ca-certificates curl wget gnupg2 software-properties-common \
		# for sdkman
		zip unzip \
		# for cordova-icon
		imagemagick \
		# for react-devtools / electron
		libgconf-2-4 \
		# for aws cli
		groff \
		&& \
	# install watchman https://askubuntu.com/a/1040627
	( \
		cd /tmp; \
		curl -L https://github.com/facebook/watchman/archive/v4.9.0.tar.gz | tar xzf -; \
		mv watchman-* watchman; \
		cd watchman/; \
		./autogen.sh; \
		./configure; \
		make -j $COMPILE_THREADS; \
		make install; \
		cd ..; \
		rm -rf watchman/; \
	) && \
	# install visual studio code
	curl -L 'https://go.microsoft.com/fwlink/?LinkID=760868' -o vsc.deb && \
	apt-get install -f -y ./vsc.deb && \
	rm vsc.deb && \
	# for aws cli
	# install through apt instead of apt-get to set python2.7 as default for python
	apt -y install python-minimal && \
	# install docker
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(grep 'VERSION_CODENAME' /etc/os-release | cut -d = -f 2) stable" && \
	apt-get update && \
	apt-get -yqq install \
		# needed for aws-sam-cli and other libraries like bcrypt@3+
		python-dev build-essential \
		# install docker
		docker-ce=${DOCKER_VERSION} && \
	# install chrome
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
	(dpkg -i google-chrome-stable_current_amd64.deb || true) && \
	apt-get -fy install && \
	rm google-chrome-stable_current_amd64.deb && \
	# needed for mongo db, but even without it's a good idea
	apt-get install locales && locale-gen en_US.UTF-8 && \
	# clean up
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

	# docker compose
ARG	DOCKER_COMPOSE_VERSION
RUN	curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
	chmod +x /usr/local/bin/docker-compose

	# set user
RUN	groupadd --gid "${USER_GID}" "${USER}" && \
	useradd --uid ${USER_ID} --gid ${USER_GID} --groups docker \
		--create-home --shell /bin/bash ${USER} && \
	echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER	${USER}

WORKDIR	${HOME}

	# install SDKMAN
RUN	curl -s "https://get.sdkman.io" | sed 's/\.bashrc/\.profile/g' | bash

	# install java 8
ARG	JAVA_CANDIDATE
RUN	echo "export JAVA_VERSION=$(sdk list java | tr ' ' '\n' | grep "$JAVA_CANDIDATE")" >> ~/.profile
RUN	echo y | sdk install java $JAVA_VERSION && \
	sdk flush broadcast && sdk flush archives && sdk flush temp

	# install latest maven
RUN	sdk install maven && \
	sdk flush broadcast && sdk flush archives && sdk flush temp

# install android sdk
	# install latest gradle
ENV	GRADLE_USER_HOME="$HOME/.gradle"

RUN	sdk install gradle && \
	sdk flush broadcast && sdk flush archives && sdk flush temp

	# expected for ~/.android/repositories.cfg
ENV	ANDROID_HOME=$HOME/.android
RUN	mkdir -p $ANDROID_HOME

	# must be exactly this path
	#RUN touch ~/.android/repositories.cfg
WORKDIR	$ANDROID_HOME

RUN	curl https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip > sdk.zip && \
        unzip sdk.zip && \
        rm sdk.zip

ENV	PATH "${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

#RUN	echo "export PROXY_HOST_DNS=${PROXY_HOST#"http://"}" >> ${HOME}/.profile
#RUN	env

RUN	yes | sdkmanager --licenses || true
RUN	for SDK in $ANDROID_SDK; do sdkmanager $SDK; done

WORKDIR	${HOME}
# /install android sdk

	# install NVM
ARG	NVM_VERSION
RUN	curl -o- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | PROFILE=~/.profile bash

	# install node
ARG	NODE_VERSIONS
RUN	for VERSION in $NODE_VERSIONS; do nvm install $VERSION; done

	# install yvm
ARG	YVM_VERSION
RUN curl -fsSL https://raw.githubusercontent.com/tophat/yvm/$YVM_VERSION/scripts/install.sh | sed 's/\.bashrc/\.profile/g' | INSTALL_VERSION="$YVM_VERSION" bash

	# install yarn
ARG	YARN_VERSIONS
RUN	for VERSION in $YARN_VERSIONS; do yvm install $VERSION; done

	# install aws cli
ENV	PATH="${HOME}/.local/bin:${PATH}"
RUN	curl -O https://bootstrap.pypa.io/get-pip.py && \
	python get-pip.py --user && \
	rm get-pip.py && \
	pip install awscli --upgrade --user --no-cache-dir

	# prepare volumes
RUN	mkdir ${HOME}/workspace
RUN	mkdir ${HOME}/.m2
RUN	mkdir ${HOME}/.gradle
VOLUME	${HOME}/workspace
VOLUME	${HOME}/.m2
VOLUME	${HOME}/.gradle

WORKDIR	${HOME}/workspace

ENTRYPOINT bash --login
