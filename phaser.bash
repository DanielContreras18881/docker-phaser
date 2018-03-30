if [[ -z `cat .env 2>/dev/null` ]]; then
  echo "Please add a .env file\nSee: https://github.com/chrisdlangton/docker-phaser"
else
  source .env
fi

phaser-stop() {
  if [ -z ${PROJECT_NAME} ]; then
    echo "variables [PROJECT_NAME] not fond"
    exit 1
  fi
  docker stop ${PROJECT_NAME} >/dev/null 2>/dev/null
  docker rm ${PROJECT_NAME} >/dev/null 2>/dev/null
}

phaser-start() {
  if [ -z ${DOCKER_PHASER_ROOT} ] || [ -z ${DOCKERHUB_USER} ] || [ -z ${PROJECT_NAME} ]; then
    echo "variables [DOCKER_PHASER_ROOT,DOCKERHUB_USER,PROJECT_NAME] not fond"
    exit 1
  fi
  NODE_ENV=$1
  if [ -z ${NODE_ENV} ]; then
    NODE_ENV=development
  fi
  if [ -z ${SERVER_PORT} ]; then
    SERVER_PORT=3000
  fi
  if [ -z ${HOST_ADDR} ]; then
    HOST_ADDR=127.0.0.1
  fi
  if [ -z ${HOST_PORT} ]; then
    HOST_PORT=3000
  fi
  docker run \
  -v ${DOCKER_PHASER_ROOT}/.bash_history_docker:/home/phaser/.bash_history \
  -v ${DOCKER_PHASER_ROOT}/src:/phaser/src \
  -v ${DOCKER_PHASER_ROOT}/package.json:/phaser/package.json \
  -p ${HOST_ADDR}:${HOST_PORT}:${SERVER_PORT}/tcp \
  -e NODE_ENV=${NODE_ENV} \
  --name ${PROJECT_NAME} \
  -t ${DOCKERHUB_USER}/${PROJECT_NAME}
}

phaser-build() {
  if [ -z ${DOCKERHUB_USER} ] || [ -z ${PROJECT_NAME} ]; then
    echo "variables [DOCKERHUB_USER,PROJECT_NAME] not fond"
    exit 1
  fi
  VERSION=$1
  if [ -z ${VERSION} ]; then
    VERSION=latest
  fi
  if [ -z ${PHASER_PORT} ]; then
    PHASER_PORT=3000
  fi
  if [ -z ${PHASER_INDEX} ]; then
    PHASER_INDEX=src/index.html
  fi
  docker build . \
  --build-arg PHASER_PORT=${SERVER_PORT} \
  --build-arg PHASER_INDEX=${PHASER_INDEX} \
  --compress \
  --force-rm \
  --rm \
  -t ${DOCKERHUB_USER}/${PROJECT_NAME}:${VERSION}
}

phaser-exec() {
  if [ -z ${PROJECT_NAME} ]; then
    echo "variables [PROJECT_NAME] not fond"
    exit 1
  fi
  docker exec -it ${PROJECT_NAME} $@
}