A docker image for development
==============================

[![Project is](https://img.shields.io/badge/Project%20is-fantastic-ff69b4.svg)](https://github.com/Bessonov/dev-image)
[![License](http://img.shields.io/:license-MIT-blue.svg)](https://raw.githubusercontent.com/Bessonov/dev-image/master/LICENSE)

This image is intended for use to developing applications in ReactJS, react-native, Node.js and others.

The image contains following tools:
- watchman
- docker (to manage docker on host)
- docker-compose

Following management tools:
- sdkman to manage java, gradle, maven and others
- nvm to manage node
- yvm to manage yarn
- pip
- android sdk

By default following packages are installed:
- java 8 (latest)
- maven (default sdkman)
- gradle (default sdkman)
- android tools (android 28)
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