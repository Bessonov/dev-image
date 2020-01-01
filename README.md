A docker image for development
==============================

[![Project is](https://img.shields.io/badge/Project%20is-fantastic-ff69b4.svg)](https://github.com/Bessonov/dev-image)
[![License](http://img.shields.io/:license-MIT-blue.svg)](https://raw.githubusercontent.com/Bessonov/dev-image/master/LICENSE)

This image is intended for use to developing applications in ReactJS, react-native, Node.js and others.

The image contains following tools:
- watchman (can be disabled with `SKIP_WATCHMAN=true`)
- docker (to manage docker on host)
- docker-compose

Following management tools:
- sdkman to manage java, gradle, maven and others
- nvm to manage node
- yvm to manage yarn
- pip
- android sdk (can be disabled with `SKIP_ANDROID=true`)

By default following packages are installed:
- java 8 (zulu, latest, can be disabled with `SKIP_JAVA=true`)
- maven (default sdkman, can be disabled with `SKIP_MAVEN=true`)
- gradle (default sdkman, can be disabled with `SKIP_GRADLE=true`)
- android tools (android 28, can be disabled with `SKIP_ANDROID=true`)
- node/npm (lts)
- yarn (stable)
- aws cli (default pip)
- google-chrome (google stable channel)
- vim (apt default)
- visual studio code (MS default)

## How to use this image

0. Install `docker` and `docker-compose`
1. Clone repository in your workspace
2. Adjust variables and docker-compose like described below
3. Run `./dev-image/docker-compose.sh up -d`. This builds the image and create configured containers
4. Now you can run `./dev-image/bash.sh` to get into container. You can start vsc with `code`

Due to possible licensing issues I don't provide pre-built images. If you build the image, you accept the licenses.

Pro tip 1: Create a symlink with `ln -s dev-image/bash.sh` to access `bash` faster.

Pro tip 2: With `docker-compose.override.yml` you can add a database.

To tear down run `./dev-image/docker-compose.sh down`. Add `-v` to remove volumes.

## Override variables

Just create `local.sh` and override values in [`defaults.sh`](defaults.sh).

## Override docker-compose.yml

Create `docker-compose.override.yml` file. For example to bind ports and directories:

```
version: '3.3'

services:
  dev:
    ports:
      - "0.0.0.0:3000:3000"
      - "0.0.0.0:8080:8080"
      - "0.0.0.0:8081:8081"

volumes:
  workspace:
    driver: local
    driver_opts:
      type: none
      device: "${WORKSPACE}"
      o: bind
  vscode_user:
    driver: local
    driver_opts:
      type: none
      device: "${CURRENT_DIR}/vscode_user"
      o: bind
  maven-m2:
    driver: local
    driver_opts:
      type: none
      device: "${HOME}/.m2"
      o: bind
  gradle-dot:
    driver: local
    driver_opts:
      type: none
      device: "${HOME}/.gradle"
      o: bind
```

# Remote development with Visual Studio Code

Remote development is a [great feature](https://code.visualstudio.com/docs/remote/remote-overview) of vscode. On remote host you need docker 18.09+, ssh-server and an user. Make sure to use public key based authentication and add your ssh key to `ssh-agent`.

Depending on your use case you need following files:
- `docker-compose.override.yml` is used as usual to define additional services and defaults. It's used for both, local and remote development.
- `docker-compose.local.yml` is used for definitions for local instance. Usually you want to put local volume mounts here.
- `docker-compose.remote.yml` contains definitions, which are executed on remote host.
- `local.sh` contains settings and mappings for development.

## Common configuration with `docker-compose.override.yml`

As defined before you store here your project specific configuration. If you want to switch between local development and remote development, define named ports here instead of `docker-compose.remote.yml`.
```yaml
version: "3.3"

services:
  dev:
    ports:
      - "127.0.0.1:$BACKEND_PORT:3000"
      - "127.0.0.1:$FRONTEND_PORT:8080"
  # other services
```

## Local configuration with `docker-compose.local.yml`

You can provide here some additional configuration for local development only. It can be a good idea to mount your `~/.ssh` folder to pass ssh configuration and `known_hosts`:
```yaml
version: "3.3"
volumes:
  ssh:
    driver: local
    driver_opts:
      type: none
      device: "${HOME}/.ssh"
      o: bind
```

## Remote configuration with `docker-compose.remote.yml`

Usually you want override volume mounts to store your files on remote file system instead of volumes. But also add another services, which you don't ant to run on your local host.

## Configure mapping of named ports

To map container ports to local ports add following configuration to `local.sh`:

```bash
BASE_PORT=60000

PORT_MAPPING=(
	# port name		local port
	BACKEND_PORT	3000
	FRONTEND_PORT	8080
	# other ports
)
```

This configuration maps remote container port `3000` to remote host port `60000` and container port `8080` to next remote host port `60001` and so on. Variable `BASE_PORT` allows usage of the same remote docker host by multiple users. Just ensure that every user has different `BASE_PORT` and enough ports in between them.

But this configuration do another very nice thing. This allows port forwarding from containers to your local host! Just run `./extras/forwarding.sh` and `BACKEND_PORT` is forwarded to `3000` and `FRONTEND_PORT` to `8080` on local host. If you want to map your local containers, just start it with local flag: `LOCAL=true ./extras/forwarding.sh`.

Additionaly, you must set following variables in `local.sh`:
```bash
# connection to the remote host with docker
REMOTE_HOST=ssh://user@ip:port

# suffix for docker-compose project to allows multiple users
PROJECT_SUFFIX=yourname
```

Then build the image on remote host and start services:
```bash
REMOTE=true ./build.sh
REMOTE=true ./docker-compose.sh up -d
```

Go into your local container with `./bash.sh`, start the `code` and install the `ms-vscode-remote.vscode-remote-extensionpack` extension. Then attach to the running remote dev container with your project suffix and enjoy power of your server.

BTW, [sshcode](https://github.com/cdr/sshcode) is a way simpler, if you don't need or want to run everything in containers.

License
-------

The MIT License (MIT)

Copyright (c) 2019, Anton Bessonov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

