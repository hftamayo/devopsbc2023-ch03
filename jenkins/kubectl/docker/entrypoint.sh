#!/bin/bash
DOCKER_SOCKET=/var/run/docker.sock
DOCKER_GROUP=docker
DOCKER_GID=$(stat -c '%g' $DOCKER_SOCKET)
groupadd -for -g $DOCKER_GID $DOCKER_GROUP
usermod -aG $DOCKER_GROUP jenkins
exec "$@"